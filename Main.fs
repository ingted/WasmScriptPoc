module WasmScriptPoc.Main

open System
open System.Net.Http
open System.IO
open Microsoft.AspNetCore.Components.WebAssembly.Hosting
open Microsoft.AspNetCore.Components
open Microsoft.Extensions.DependencyInjection
open Microsoft.FSharp.Core.ExtraTopLevelOperators
open Elmish
open Bolero
open Bolero.Html
open FSharp.Compiler.CodeAnalysis
open FSharp.Compiler.Text

// --- Compiler Logic ---

type CompilerStatus = 
    | Standby
    | Running
    | Success of string
    | Failure of string

type Compiler = 
    {
        Checker: FSharpChecker
        Options: FSharpProjectOptions
        Status: CompilerStatus
    }

module Compiler = 
    let projFile = "/tmp/out.fsproj"
    let inFile = "/tmp/Main.fs"
    let outFile = "/tmp/out.exe"

    // These filenames depend on what's available in the build output.
    // We'll try to load the basics.
    let referenceFiles = 
        [ 
          "FSharp.Core.dll"
          "System.Private.CoreLib.dll" 
          "System.Runtime.Numerics.dll" 
          "System.Collections.dll" 
          "System.Net.Requests.dll" 
          "System.Net.WebClient.dll" 
          //"mscorlib.dll"
          "netstandard.dll"
          "System.dll"
          "System.Runtime.dll"
          "System.Core.dll"
          "System.Console.dll"
          "System.IO.dll"
        ]

    let ensureReferences (http: HttpClient) = async {
        if not (Directory.Exists("/tmp")) then Directory.CreateDirectory("/tmp") |> ignore
        for fileName in referenceFiles do
            let targetPath = Path.Combine("/tmp", fileName)
            if not (File.Exists(targetPath)) then
                try
                    // Try to fetch from refs/
                    let! bytes = http.GetByteArrayAsync("refs/" + fileName) |> Async.AwaitTask
                    File.WriteAllBytes(targetPath, bytes)
                    printfn "Loaded %s" fileName
                with e ->
                    printfn "Warning: Failed to download %s: %s" fileName e.Message
    }

    let create (http: HttpClient) = async {
        do! ensureReferences http
        let checker = FSharpChecker.Create(keepAssemblyContents = true)
        
        let args = 
            [|
                "--simpleresolution"
                "--optimize-"
                "--noframework"
                "--targetprofile:netstandard"
                "--target:exe"
                inFile
                //"-r:/tmp/FSharp.Core.dll"
                //"-r:/tmp/mscorlib.dll"
                //"-r:/tmp/System.Private.CoreLib.dll"
                //"-r:/tmp/netstandard.dll"
                //"-r:/tmp/System.dll"
                //"-r:/tmp/System.Core.dll"
                //"-r:/tmp/System.IO.dll"
                "-o:" + outFile
            |]
        
        // Add references
        let refs = 
            referenceFiles 
            |> List.filter (fun r -> File.Exists(Path.Combine("/tmp", r)))
            |> List.map (fun r -> "-r:/tmp/" + r) 
            |> Array.ofList
            
        let finalArgs = Array.append args refs
        
        let options = checker.GetProjectOptionsFromCommandLineArgs(projFile, finalArgs)
        
        return { Checker = checker; Options = options; Status = Standby }
    }

    let run (compiler: Compiler) (source: string) = async {
        printfn "DEBUG: Starting compilation process..."
        printfn "DEBUG: Source code length: %d" source.Length
        try
            async {
                printfn "DEBUG: Async started"
            } |> Async.Start

            File.WriteAllText(inFile, source)
            printfn "DEBUG: Source written to %s" inFile

            // Create dummy manifest
            File.WriteAllText("/default.win32manifest", "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><assembly xmlns=\"urn:schemas-microsoft-com:asm.v1\" manifestVersion=\"1.0\"></assembly>")
            printfn "DEBUG: Created /default.win32manifest"
            
            printfn "DEBUG: Yielding to UI thread (100ms)..."
            do! Async.Sleep 100
            
            let finalArgs = Array.append compiler.Options.OtherOptions compiler.Options.SourceFiles
            printfn "DEBUG: Calling compiler.Checker.Compile with %d arguments" finalArgs.Length
            // printfn "DEBUG: Arguments: %A" finalArgs

            let! (errors, exitCode) = compiler.Checker.Compile(finalArgs)
            printfn "DEBUG: compiler.Checker.Compile returned! Processing results..."
            printfn "DEBUG: Compile finished. ExitCode: %A, Errors count: %d" exitCode errors.Length
            
            let errorMsg = 
                errors 
                |> Array.map (fun e -> sprintf "%s: %s" (e.Severity.ToString()) e.Message)
                |> String.concat "\n"
            
            if Option.isNone exitCode && errorMsg.Contains("Error") |> not then
                 printfn "DEBUG: Compilation Successful! Preparing to execute..."
                 try
                     let bytes = File.ReadAllBytes(outFile)
                     let asm = System.Reflection.Assembly.Load(bytes)
                     match asm.EntryPoint with
                     | null -> 
                         printfn "DEBUG: No EntryPoint found in the generated assembly."
                         return Success ("Compilation Successful! (No EntryPoint found)\n" + errorMsg)
                     | entryPoint ->
                         printfn "DEBUG: EntryPoint found: %s" entryPoint.Name
                         let parameters = entryPoint.GetParameters()
                         printfn "DEBUG: EntryPoint parameters count: %d" parameters.Length
                         
                         // We capture stdout to show it in the UI
                         let oldOut = Console.Out
                         use sw = new StringWriter()
                         Console.SetOut(sw)
                         
                         try
                             let invokeArgs = 
                                 if parameters.Length = 0 then
                                     null
                                 elif parameters.Length = 1 && parameters.[0].ParameterType = typeof<string[]> then
                                     [| box Array.empty<string> |]
                                 else
                                     // Fallback for weird signatures, though unlikely for Main
                                     Array.zeroCreate parameters.Length

                             let _ = entryPoint.Invoke(null, invokeArgs)
                             let output = sw.ToString()
                             Console.SetOut(oldOut) // Restore immediately
                             
                             printfn "DEBUG: Execution finished."
                             printfn "DEBUG: User Output: %s" output
                             return Success ($"Compilation & Execution Successful!\n\n--- Output ---\n{output}\n\n--- Compiler Logs ---\n{errorMsg}")
                         with ex ->
                             Console.SetOut(oldOut) // Restore in case of error
                             printfn "EXECUTION ERROR: %s" ex.Message
                             return Failure ($"Compilation Successful, but Runtime Error:\n{ex.Message}\n{ex.StackTrace}")
                 with ex ->
                     printfn "LOAD ERROR: %s" ex.Message
                     return Failure ($"Compilation Successful, but Assembly Load Failed:\n{ex.Message}")
            else
                 printfn "DEBUG: Compilation Failed or had errors."
                 return Failure errorMsg
        with e ->
            printfn "FATAL DEBUG EXCEPTION: %s\nStack: %s" e.Message e.StackTrace
            return Failure (sprintf "EXCEPTION: %s" e.Message)
    }

// --- App Logic ---

type Model = 
    {
        Code: string
        Output: string
        Compiler: Compiler option
    }

type Message = 
    | SetCode of string
    | Run
    | CompilerReady of Compiler
    | CompilationFinished of CompilerStatus
    | Error of exn

let update message model =
    match message with
    | SetCode code -> { model with Code = code }, Cmd.none
    | Run ->
        match model.Compiler with
        | Some compiler ->
            { model with Output = "Compiling..." },
            Cmd.OfAsync.either (fun () -> Compiler.run compiler model.Code) () CompilationFinished Error
        | None -> model, Cmd.none
    | CompilerReady compiler ->
        { model with Compiler = Some compiler; Output = "Compiler Ready. Click Run." }, Cmd.none
    | CompilationFinished status ->
        match status with
        | Success msg -> { model with Output = msg }, Cmd.none
        | Failure msg -> { model with Output = "Error:\n" + msg }, Cmd.none
        | Running -> { model with Output = "Compiling..." }, Cmd.none
        | Standby -> model, Cmd.none
    | Error exn ->
        { model with Output = sprintf "EXCEPTION: %s\nStack: %s" exn.Message exn.StackTrace }, Cmd.none

let view model dispatch =
    div {
        //h1 { "Wasm Script POC" }
        p { "Enter F# code below:" }
        textarea {
            attr.value model.Code
            attr.style "width: 100%; height: 200px; font-family: monospace;"
            on.change (fun e -> dispatch (SetCode (unbox e.Value)))
        }
        br {}
        button {
            on.click (fun _ -> dispatch Run)
            attr.disabled (if model.Compiler.IsNone then "true" else null)
            "Compile & Run"
        }
        br {}
        h3 { "Output" }
        pre {
            attr.style "background: #f0f0f0; padding: 10px; white-space: pre-wrap;"
            model.Output
        }
    }

type MyApp() =
    inherit ProgramComponent<Model, Message>()
    
    [<Inject>]
    member val HttpClient = Unchecked.defaultof<HttpClient> with get, set

    override this.Program =
        let init _ = 
            { Code = "let x = 42\nprintfn \"Answer: %d\" x"; Output = "Loading compiler (fetching DLLs)..."; Compiler = None },
            Cmd.OfAsync.either (Compiler.create) this.HttpClient CompilerReady Error

        Program.mkProgram init update view

module Program = 
    [<EntryPoint>]
    let Main args =
        let asm = typeof<list<int>>.Assembly
        Console.WriteLine($"DEBUG: FSharp.Core loaded from: {asm.Location}")
        Console.WriteLine($"DEBUG: FSharp.Core version: {asm.GetName().Version}")
        
        System.Environment.SetEnvironmentVariable("FSharp_CacheEvictionImmediate", "1")
        System.Environment.SetEnvironmentVariable("FCS_BROWSER", "1")
        System.Environment.SetEnvironmentVariable("FCS_ParallelReferenceResolution", "false")
        let builder = WebAssemblyHostBuilder.CreateDefault(args)
        builder.Services.AddScoped<HttpClient>(fun sp -> new HttpClient(BaseAddress = Uri(builder.HostEnvironment.BaseAddress))) |> ignore
        builder.RootComponents.Add<MyApp>("#main")
        builder.Build().RunAsync() |> ignore
        0