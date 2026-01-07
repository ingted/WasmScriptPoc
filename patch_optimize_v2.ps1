$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\OptimizeInputs.fs"
$content = Get-Content -Path $path -Raw

$oldBlock = "| Optimizer.OptimizationProcessingMode.Parallel when false -> // Force Sequential for Wasm`n            let results, optEnvFirstPhase =`n                ParallelOptimization.optimizeFilesInParallel optEnv phases implFiles`n`n            results |> Array.toList, optEnvFirstPhase"

$newBlock = "| Optimizer.OptimizationProcessingMode.Parallel ->`n            // FORCE SEQUENTIAL`n            optimizeFilesSequentially optEnv phases implFiles"

if ($content.Contains($oldBlock)) {
    $content = $content.Replace($oldBlock, $newBlock)
    Set-Content -Path $path -Value $content -NoNewline
    Write-Host "Replaced Parallel body with Sequential call"
} else {
    Write-Host "Could not find the modified Parallel block. Printing snippet..."
    $idx = $content.IndexOf("match tcConfig.optSettings.processingMode")
    if ($idx -ge 0) {
        Write-Host $content.Substring($idx, 600)
    }
}
