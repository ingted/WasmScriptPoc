$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\fsc.fs"
$content = Get-Content -Path $path -Raw

# 尋找 GetInitialTcEnv 呼叫點
$oldCall = "    let tcEnv0, openDecls0 ="
$newCall = "    System.Console.WriteLine(""FCS DEBUG: STARTING GetInitialTcEnv"")`n    let tcEnv0, openDecls0 ="
$content = $content.Replace($oldCall, $newCall)

# 尋找 TypeCheck 呼叫點
$oldTC = "    let tcState, topAttrs, typedAssembly, _tcEnvAtEnd ="
$newTC = "    System.Console.WriteLine(""FCS DEBUG: FINISHED GetInitialTcEnv, STARTING TypeCheck"")`n    let tcState, topAttrs, typedAssembly, _tcEnvAtEnd ="
$content = $content.Replace($oldTC, $newTC)

Set-Content -Path $path -Value $content -NoNewline
Write-Host "Injected final tracking logs into fsc.fs"
