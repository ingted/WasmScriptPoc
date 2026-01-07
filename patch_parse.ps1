$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\ParseAndCheckInputs.fs"
$content = Get-Content -Path $path -Raw

# 1. 在 GetInitialTcEnv 加入 Log
$anchor1 = "let GetInitialTcEnv (assemblyName, range, tcConfig: TcConfig, tcImports: TcImports, tcGlobals: TcGlobals) ="
$log1 = "let GetInitialTcEnv (assemblyName, range, tcConfig: TcConfig, tcImports: TcImports, tcGlobals: TcGlobals) =`n    System.Console.WriteLine(""FCS DEBUG: Entering GetInitialTcEnv for "" + assemblyName)"
$content = $content.Replace($anchor1, $log1)

# 2. 在 GetInitialTcEnv 準備返回前加入 Log
$anchor2 = "    tcEnv, openDecls"
$log2 = "    System.Console.WriteLine(""FCS DEBUG: GetInitialTcEnv is about to return"")`n    tcEnv, openDecls"
$content = $content.Replace($anchor2, $log2)

Set-Content -Path $path -Value $content -NoNewline
Write-Host "Modified ParseAndCheckInputs.fs"
