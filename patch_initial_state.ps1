$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\ParseAndCheckInputs.fs"
$content = Get-Content -Path $path -Raw

# 1. GetInitialTcState entry
$anchor1 = "let GetInitialTcState (m, ccuName, tcConfig: TcConfig, tcGlobals, tcImports: TcImports, tcEnv0, openDecls0) ="
$log1 = "let GetInitialTcState (m, ccuName, tcConfig: TcConfig, tcGlobals, tcImports: TcImports, tcEnv0, openDecls0) =`n    System.Console.WriteLine(""FCS DEBUG: Inside GetInitialTcState"")"
$content = $content.Replace($anchor1, $log1)

# 2. Before CcuThunk.Create
$anchor2 = "let ccu = CcuThunk.Create(ccuName, ccuData)"
$log2 = "System.Console.WriteLine(""FCS DEBUG: Creating CcuThunk"")`n    let ccu = CcuThunk.Create(ccuName, ccuData)"
$content = $content.Replace($anchor2, $log2)

# 3. Before return
$anchor3 = "if tcConfig.compilingFSharpCore then`n        tcGlobals.fslibCcu.Fixup ccu"
$log3 = "if tcConfig.compilingFSharpCore then`n        tcGlobals.fslibCcu.Fixup ccu`n    System.Console.WriteLine(""FCS DEBUG: Returning from GetInitialTcState"")"
$content = $content.Replace($anchor3, $log3)

Set-Content -Path $path -Value $content -NoNewline
Write-Host "Modified ParseAndCheckInputs.fs with GetInitialTcState logging"
