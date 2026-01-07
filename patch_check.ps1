$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\ParseAndCheckInputs.fs"
$content = Get-Content -Path $path -Raw

# 1. CheckClosedInputSet entry
$anchor1 = "let CheckClosedInputSet (ctok, checkForErrors, tcConfig: TcConfig, tcImports, tcGlobals, prefixPathOpt, tcState, eagerFormat, inputs) ="
$log1 = "let CheckClosedInputSet (ctok, checkForErrors, tcConfig: TcConfig, tcImports, tcGlobals, prefixPathOpt, tcState, eagerFormat, inputs) =`n    System.Console.WriteLine(""FCS DEBUG: Inside CheckClosedInputSet"")"
$content = $content.Replace($anchor1, $log1)

# 2. CheckMultipleInputsSequential entry
$anchor2 = "let CheckMultipleInputsSequential (ctok, checkForErrors, tcConfig, tcImports, tcGlobals, prefixPathOpt, tcState, inputs) ="
$log2 = "let CheckMultipleInputsSequential (ctok, checkForErrors, tcConfig, tcImports, tcGlobals, prefixPathOpt, tcState, inputs) =`n    System.Console.WriteLine(""FCS DEBUG: Inside CheckMultipleInputsSequential with "" + string inputs.Length + "" inputs"")"
$content = $content.Replace($anchor2, $log2)

# 3. CheckOneInputEntry entry
$anchor3 = "let CheckOneInputEntry (ctok, checkForErrors, tcConfig: TcConfig, tcImports, tcGlobals, prefixPathOpt) tcState input ="
$log3 = "let CheckOneInputEntry (ctok, checkForErrors, tcConfig: TcConfig, tcImports, tcGlobals, prefixPathOpt) tcState input =`n    System.Console.WriteLine(""FCS DEBUG: Checking input: "" + input.FileName)"
$content = $content.Replace($anchor3, $log3)

# 4. CheckOneInput entry
$anchor4 = "let CheckOneInput`n    (`n        checkForErrors,"
$log4 = "let CheckOneInput`n    (`n        checkForErrors,"
# This one is tricky due to formatting. Let's try matching the body start.
$anchor4_body = "cancellable {`n        try`n            use _ ="
$log4_body = "cancellable {`n        try`n            System.Console.WriteLine(""FCS DEBUG: Inside CheckOneInput logic"")`n            use _ ="
$content = $content.Replace($anchor4_body, $log4_body)

Set-Content -Path $path -Value $content -NoNewline
Write-Host "Modified ParseAndCheckInputs.fs with check logging"
