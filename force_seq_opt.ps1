$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\OptimizeInputs.fs"
$content = Get-Content -Path $path -Raw

# Try to find the exact line
$pattern = "\| Optimizer.OptimizationProcessingMode.Parallel ->"
$replacement = "| Optimizer.OptimizationProcessingMode.Parallel when false ->"

if ($content -match $pattern) {
    $content = $content -replace $pattern, $replacement
    Set-Content -Path $path -Value $content -NoNewline
    Write-Host "Forced Sequential Optimization in OptimizeInputs.fs (Regex)"
} else {
    Write-Host "Could not find Parallel Optimization pattern. Printing snippet..."
    $idx = $content.IndexOf("match tcConfig.optSettings.processingMode")
    if ($idx -ge 0) {
        Write-Host $content.Substring($idx, 500)
    }
}
