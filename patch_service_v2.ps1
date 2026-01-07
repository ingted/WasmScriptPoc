$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Service\service.fs"
$content = Get-Content -Path $path -Raw

# 1. Add logging inside Compile async block
# Anchored by: let ctok = AssumeCompilationThreadWithoutEvidence()
$anchor1 = "let ctok = AssumeCompilationThreadWithoutEvidence()"
$log1 = "            System.Console.WriteLine(""FCS DEBUG: Inside FSharpChecker.Compile async block"")`n            let ctok = AssumeCompilationThreadWithoutEvidence()"
$content = $content.Replace($anchor1, $log1)

# 2. Add logging for browser check
# Anchored by: || System.Environment.GetEnvironmentVariable("FCS_BROWSER") = "1"
$anchor2 = '|| System.Environment.GetEnvironmentVariable("FCS_BROWSER") = "1"'
$log2 = '|| System.Environment.GetEnvironmentVariable("FCS_BROWSER") = "1"`n            System.Console.WriteLine(sprintf "FCS DEBUG: isBrowser=%b" isBrowser)'
$content = $content.Replace($anchor2, $log2)

# 3. Add logging before compileFromArgsAsync call
# Anchored by: return! CompileHelpers.compileFromArgsAsync (ctok, argv, legacyReferenceResolver, None, None)
$anchor3 = "return! CompileHelpers.compileFromArgsAsync (ctok, argv, legacyReferenceResolver, None, None)"
$log3 = "System.Console.WriteLine(""FCS DEBUG: Calling CompileHelpers.compileFromArgsAsync"")`n                return! CompileHelpers.compileFromArgsAsync (ctok, argv, legacyReferenceResolver, None, None)"
$content = $content.Replace($anchor3, $log3)

Set-Content -Path $path -Value $content -NoNewline
Write-Host "Modified service.fs with granular patches"
