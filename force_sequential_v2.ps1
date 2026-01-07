$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\ParseAndCheckInputs.fs"
$content = Get-Content -Path $path -Raw

# Disable Graph Mode by adding 'false &&' condition
$oldPattern = "| TypeCheckingMode.Graph when"
$newPattern = "| TypeCheckingMode.Graph when false &&"

if ($content.Contains($oldPattern)) {
    $content = $content.Replace($oldPattern, $newPattern)
    Set-Content -Path $path -Value $content -NoNewline
    Write-Host "Disabled Graph Mode in ParseAndCheckInputs.fs"
} else {
    Write-Host "Could not find Graph Mode pattern"
}
