$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Facilities\DiagnosticsLogger.fs"
$content = Get-Content -Path $path -Raw

$oldSeq = "    let Sequential computations =" + [Environment]::NewLine +
"        async {" + [Environment]::NewLine +
"            let results = ResizeArray()" + [Environment]::NewLine +
"" + [Environment]::NewLine +
"            for computation in computations do" + [Environment]::NewLine +
"                let! result = computation" + [Environment]::NewLine +
"                results.Add result" + [Environment]::NewLine +
"" + [Environment]::NewLine +
"            return results.ToArray()" + [Environment]::NewLine +
"        }"

$newSeq = "    let Sequential computations =" + [Environment]::NewLine +
"        async {" + [Environment]::NewLine +
"            System.Console.WriteLine(""FCS DEBUG: Inside Sequential with "" + string (Seq.length computations) + "" computations"")" + [Environment]::NewLine +
"            let results = ResizeArray()" + [Environment]::NewLine +
"            let mutable i = 0" + [Environment]::NewLine +
"            for computation in computations do" + [Environment]::NewLine +
"                System.Console.WriteLine(""FCS DEBUG: Sequential loop iteration "" + string i)" + [Environment]::NewLine +
"                let! result = computation" + [Environment]::NewLine +
"                System.Console.WriteLine(""FCS DEBUG: Sequential loop iteration "" + string i + "" done"")" + [Environment]::NewLine +
"                results.Add result" + [Environment]::NewLine +
"                i <- i + 1" + [Environment]::NewLine +
"" + [Environment]::NewLine +
"            System.Console.WriteLine(""FCS DEBUG: Sequential finished"")" + [Environment]::NewLine +
"            return results.ToArray()" + [Environment]::NewLine +
"        }"

if ($content.Contains($oldSeq)) {
    $content = $content.Replace($oldSeq, $newSeq)
    Set-Content -Path $path -Value $content -NoNewline
    Write-Host "Modified DiagnosticsLogger.fs"
} else {
    Write-Host "Could not find target string in DiagnosticsLogger.fs"
    # Print a snippet to help debug
    # Write-Host $content.Substring(0, 1000)
}
