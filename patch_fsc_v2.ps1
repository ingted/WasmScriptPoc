$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\fsc.fs"
$content = Get-Content -Path $path -Raw

# 1. Add logging to CompileFromCommandLineArgumentsAsync
$anchor1 = "use disposables = new DisposablesTracker()"
$log1 = "        System.Console.WriteLine(""FCS DEBUG: Inside CompileFromCommandLineArgumentsAsync"")`n        use disposables = new DisposablesTracker()"
$content = $content.Replace($anchor1, $log1)

# 2. Add logging before main1Async call in CompileFromCommandLineArgumentsAsync
$anchor2 = "let! args = main1Async ("
$log2 = "System.Console.WriteLine(""FCS DEBUG: Calling main1Async"")`n        let! args = main1Async ("
$content = $content.Replace($anchor2, $log2)

# 3. Add logging inside main1Async
$anchor3 = "// See Bug 735819"
$log3 = "    System.Console.WriteLine(""FCS DEBUG: Inside main1Async"")`n    // See Bug 735819"
$content = $content.Replace($anchor3, $log3)

# 4. Add logging before TcImports.BuildFrameworkTcImports
$anchor4 = "let! tcGlobals, frameworkTcImports ="
$log4 = "System.Console.WriteLine(""FCS DEBUG: Calling TcImports.BuildFrameworkTcImports"")`n    let! tcGlobals, frameworkTcImports ="
$content = $content.Replace($anchor4, $log4)

Set-Content -Path $path -Value $content -NoNewline
Write-Host "Modified fsc.fs with granular patches"
