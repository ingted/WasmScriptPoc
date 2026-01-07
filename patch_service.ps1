$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Service\service.fs"
$content = Get-Content -Path $path -Raw

$oldString = @"
    member _.Compile(argv: string[], ?userOpName: string) =
        let _userOpName = defaultArg userOpName "Unknown"
        use _ = Activity.start "FSharpChecker.Compile" [| Activity.Tags.userOpName, _userOpName |]        

        async {
            let ctok = AssumeCompilationThreadWithoutEvidence()
            let isBrowser =
                System.Runtime.InteropServices.RuntimeInformation.IsOSPlatform(System.Runtime.InteropServices.OSPlatform.Create("BROWSER"))
                || System.Environment.GetEnvironmentVariable("FCS_BROWSER") = "1"

            if isBrowser then
                return! CompileHelpers.compileFromArgsAsync (ctok, argv, legacyReferenceResolver, None, None)
            else
                return CompileHelpers.compileFromArgs (ctok, argv, legacyReferenceResolver, None, None)   
        }
"@

$newString = @"
    member _.Compile(argv: string[], ?userOpName: string) =
        let _userOpName = defaultArg userOpName "Unknown"
        use _ = Activity.start "FSharpChecker.Compile" [| Activity.Tags.userOpName, _userOpName |]        

        async {
            System.Console.WriteLine("FCS DEBUG: Inside FSharpChecker.Compile")
            let ctok = AssumeCompilationThreadWithoutEvidence()
            let isBrowser =
                System.Runtime.InteropServices.RuntimeInformation.IsOSPlatform(System.Runtime.InteropServices.OSPlatform.Create("BROWSER"))
                || System.Environment.GetEnvironmentVariable("FCS_BROWSER") = "1"
            
            System.Console.WriteLine(sprintf "FCS DEBUG: isBrowser=%b" isBrowser)

            if isBrowser then
                System.Console.WriteLine("FCS DEBUG: Calling CompileHelpers.compileFromArgsAsync")
                return! CompileHelpers.compileFromArgsAsync (ctok, argv, legacyReferenceResolver, None, None)
            else
                System.Console.WriteLine("FCS DEBUG: Calling CompileHelpers.compileFromArgs")
                return CompileHelpers.compileFromArgs (ctok, argv, legacyReferenceResolver, None, None)   
        }
"@

$newContent = $content.Replace($oldString, $newString)
Set-Content -Path $path -Value $newContent -NoNewline
Write-Host "Modified service.fs"
