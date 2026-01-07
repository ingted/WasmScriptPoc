$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\OptimizeInputs.fs"
$content = Get-Content -Path $path -Raw

# Disable Parallel Optimization
$oldMatch = "| Optimizer.OptimizationProcessingMode.Parallel ->"
$newMatch = "| Optimizer.OptimizationProcessingMode.Parallel when false -> // Force Sequential for Wasm"

if ($content.Contains($oldMatch)) {
    $content = $content.Replace($oldMatch, $newMatch)
    Set-Content -Path $path -Value $content -NoNewline
    Write-Host "Forced Sequential Optimization in OptimizeInputs.fs"
} else {
    Write-Host "Could not find Parallel Optimization pattern"
}
