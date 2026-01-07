$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\fsc.fs"
$content = Get-Content -Path $path -Raw

# 修正 main1Async 中間的追蹤點，對齊縮排
$oldSection = "    // Build the initial type checking environment`n    ReportTime tcConfig ""Typecheck""`n`n    use unwindParsePhase = UseBuildPhase BuildPhase.TypeCheck`n`n    let tcEnv0, openDecls0 ="

$newSection = "    // Build the initial type checking environment`n    System.Console.WriteLine(""FCS DEBUG: About to call GetInitialTcEnv..."")`n    ReportTime tcConfig ""Typecheck""`n`n    use unwindParsePhase = UseBuildPhase BuildPhase.TypeCheck`n`n    let tcEnv0, openDecls0 ="

$content = $content.Replace($oldSection, $newSection)

# 在 TypeCheck 呼叫前加入 Log
$oldTypeCheck = "    let tcState, topAttrs, typedAssembly, _tcEnvAtEnd ="
$newTypeCheck = "    System.Console.WriteLine(""FCS DEBUG: Calling TypeCheck main logic..."")`n    let tcState, topAttrs, typedAssembly, _tcEnvAtEnd ="
$content = $content.Replace($oldTypeCheck, $newTypeCheck)

Set-Content -Path $path -Value $content -NoNewline
Write-Host "Refined fsc.fs logging"
