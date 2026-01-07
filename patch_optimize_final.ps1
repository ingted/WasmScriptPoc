$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\OptimizeInputs.fs"
$content = Get-Content -Path $path -Raw

$startMarker = "match tcConfig.optSettings.processingMode with"
$endMarker = "#if DEBUG"

$startIndex = $content.IndexOf($startMarker)
if ($startIndex -ge 0) {
    $endIndex = $content.IndexOf($endMarker, $startIndex)
    
    if ($endIndex -gt $startIndex) {
        $before = $content.Substring(0, $startIndex)
        $after = $content.Substring($endIndex)
        
        $newCode = "optimizeFilesSequentially optEnv phases implFiles" + [Environment]::NewLine + [Environment]::NewLine

        $newContent = $before + $newCode + $after
        Set-Content -Path $path -Value $newContent -NoNewline
        Write-Host "Replaced Optimization logic with mandatory Sequential call"
    } else {
        Write-Host "Could not find #if DEBUG after the match block."
    }
} else {
    Write-Host "Could not find start marker."
}