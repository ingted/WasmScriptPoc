$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\ParseAndCheckInputs.fs"
$content = Get-Content -Path $path -Raw

# Replace the match block to force Sequential
$oldMatch = "        match tcConfig.typeCheckingConfig.Mode with`n        | TypeCheckingMode.Graph when (not tcConfig.isInteractive && not tcConfig.compilingFSharpCore) -> `n            CheckMultipleInputsUsingGraphMode(`n                ctok,`n                checkForErrors,`n                tcConfig,`n                tcImports,`n                tcGlobals,`n                prefixPathOpt,`n                tcState,`n                eagerFormat,`n                inputs`n            )`n        | _ -> CheckMultipleInputsSequential(ctok, checkForErrors, tcConfig, tcImports, tcGlobals, prefixPathOpt, tcState, inputs)"

# We replace it with a direct call or a match that always goes to default
$newMatch = "        match tcConfig.typeCheckingConfig.Mode with`n        // FORCE SEQUENTIAL FOR WASM STABILITY`n        // | TypeCheckingMode.Graph when (not tcConfig.isInteractive && not tcConfig.compilingFSharpCore) -> ...`n        | _ -> CheckMultipleInputsSequential(ctok, checkForErrors, tcConfig, tcImports, tcGlobals, prefixPathOpt, tcState, inputs)"

if ($content.Contains($oldMatch)) {
    $content = $content.Replace($oldMatch, $newMatch)
    Set-Content -Path $path -Value $content -NoNewline
    Write-Host "Forced Sequential Mode in ParseAndCheckInputs.fs"
} else {
    Write-Host "Could not find the match expression to replace. Printing snippet..."
    # Print the area around CheckClosedInputSet to help debug
    $idx = $content.IndexOf("let CheckClosedInputSet")
    if ($idx -ge 0) {
        Write-Host $content.Substring($idx, 1000)
    } else {
        Write-Host "CheckClosedInputSet not found"
    }
}
