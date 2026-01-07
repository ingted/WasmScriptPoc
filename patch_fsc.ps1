$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\fsc.fs"
$content = Get-Content -Path $path -Raw

# Replace CompileFromCommandLineArgumentsAsync to add logging
$oldAsync = @"
let CompileFromCommandLineArgumentsAsync
    (
        ctok,
        argv,
        legacyReferenceResolver,
        bannerAlreadyPrinted,
        reduceMemoryUsage,
        defaultCopyFSharpCore,
        exiter: Exiter,
        loggerProvider,
        tcImportsCapture,
        dynamicAssemblyCreator
    ) =
    async {
        use disposables = new DisposablesTracker()

        let! args = main1Async (
            ctok,
            argv,
            legacyReferenceResolver,
            bannerAlreadyPrinted,
            reduceMemoryUsage,
            defaultCopyFSharpCore,
            exiter,
            loggerProvider,
            disposables
        )
        return
            args
            |> main2
            |> main3
            |> main4 (tcImportsCapture, dynamicAssemblyCreator)
            |> main5
            |> main6 dynamicAssemblyCreator
    }
"@

$newAsync = @"
let CompileFromCommandLineArgumentsAsync
    (
        ctok,
        argv,
        legacyReferenceResolver,
        bannerAlreadyPrinted,
        reduceMemoryUsage,
        defaultCopyFSharpCore,
        exiter: Exiter,
        loggerProvider,
        tcImportsCapture,
        dynamicAssemblyCreator
    ) =
    async {
        System.Console.WriteLine("FCS DEBUG: Inside CompileFromCommandLineArgumentsAsync")
        use disposables = new DisposablesTracker()

        System.Console.WriteLine("FCS DEBUG: Calling main1Async")
        let! args = main1Async (
            ctok,
            argv,
            legacyReferenceResolver,
            bannerAlreadyPrinted,
            reduceMemoryUsage,
            defaultCopyFSharpCore,
            exiter,
            loggerProvider,
            disposables
        )
        System.Console.WriteLine("FCS DEBUG: main1Async returned")
        
        System.Console.WriteLine("FCS DEBUG: Starting pipeline main2..main6")
        return
            args
            |> main2
            |> main3
            |> main4 (tcImportsCapture, dynamicAssemblyCreator)
            |> main5
            |> main6 dynamicAssemblyCreator
    }
"@

$content = $content.Replace($oldAsync, $newAsync)

# Replace main1Async to add logging at start
$oldMain1 = @"
let main1Async
    (
        ctok,
        argv,
        legacyReferenceResolver,
        bannerAlreadyPrinted,
        reduceMemoryUsage: ReduceMemoryFlag,
        defaultCopyFSharpCore: CopyFSharpCoreFlag,
        exiter: Exiter,
        diagnosticsLoggerProvider: IDiagnosticsLoggerProvider,
        disposables: DisposablesTracker
    ) =
    async {
    // See Bug 735819
    let lcidFromCodePage =
"@

$newMain1 = @"
let main1Async
    (
        ctok,
        argv,
        legacyReferenceResolver,
        bannerAlreadyPrinted,
        reduceMemoryUsage: ReduceMemoryFlag,
        defaultCopyFSharpCore: CopyFSharpCoreFlag,
        exiter: Exiter,
        diagnosticsLoggerProvider: IDiagnosticsLoggerProvider,
        disposables: DisposablesTracker
    ) =
    async {
    System.Console.WriteLine("FCS DEBUG: Inside main1Async")
    // See Bug 735819
    let lcidFromCodePage =
"@

$content = $content.Replace($oldMain1, $newMain1)

# Add logging after ProcessCommandLineFlags
$oldProcess = @"
    // Process command line, flags and collect filenames
    let sourceFiles =
        // The ParseCompilerOptions function calls imperative function to process "real" args
        // Rather than start processing, just collect names, then process them.
        try
            let files = ProcessCommandLineFlags(tcConfigB, lcidFromCodePage, argv)
            let files = CheckAndReportSourceFileDuplicates(ResizeArray.ofList files)
            AdjustForScriptCompile(tcConfigB, files, lexResourceManager, dependencyProvider)
        with e ->
"@

$newProcess = @"
    // Process command line, flags and collect filenames
    let sourceFiles =
        // The ParseCompilerOptions function calls imperative function to process "real" args
        // Rather than start processing, just collect names, then process them.
        try
            System.Console.WriteLine("FCS DEBUG: Processing command line flags...")
            let files = ProcessCommandLineFlags(tcConfigB, lcidFromCodePage, argv)
            System.Console.WriteLine("FCS DEBUG: Command line flags processed. Files count: " + string files.Length)
            let files = CheckAndReportSourceFileDuplicates(ResizeArray.ofList files)
            AdjustForScriptCompile(tcConfigB, files, lexResourceManager, dependencyProvider)
        with e ->
"@

$content = $content.Replace($oldProcess, $newProcess)

# Add logging before and after BuildFrameworkTcImports
$oldBuildFramework = @"
    // Import basic assemblies
    let! tcGlobals, frameworkTcImports =
        TcImports.BuildFrameworkTcImports(foundationalTcConfigP, sysRes, otherRes)
"@

$newBuildFramework = @"
    // Import basic assemblies
    System.Console.WriteLine("FCS DEBUG: Calling TcImports.BuildFrameworkTcImports")
    let! tcGlobals, frameworkTcImports =
        TcImports.BuildFrameworkTcImports(foundationalTcConfigP, sysRes, otherRes)
    System.Console.WriteLine("FCS DEBUG: BuildFrameworkTcImports returned")
"@

$content = $content.Replace($oldBuildFramework, $newBuildFramework)

Set-Content -Path $path -Value $content -NoNewline
Write-Host "Modified fsc.fs"
