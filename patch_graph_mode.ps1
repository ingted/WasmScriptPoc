$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\ParseAndCheckInputs.fs"
$content = Get-Content -Path $path -Raw

# CheckMultipleInputsUsingGraphMode entry
$anchor = "let CheckMultipleInputsUsingGraphMode"
$log = "let CheckMultipleInputsUsingGraphMode"
$content = $content.Replace($anchor, $log)

# We need to find the body start.
$anchor_body = "    : FinalFileResult list * TcState =`n    use cts = new CancellationTokenSource()"
$log_body = "    : FinalFileResult list * TcState =`n    System.Console.WriteLine(""FCS DEBUG: Inside CheckMultipleInputsUsingGraphMode"")`n    use cts = new CancellationTokenSource()"
$content = $content.Replace($anchor_body, $log_body)

Set-Content -Path $path -Value $content -NoNewline
Write-Host "Modified ParseAndCheckInputs.fs with GraphMode logging"
