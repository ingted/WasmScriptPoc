$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Facilities\DiagnosticsLogger.fs"
$content = Get-Content -Path $path -Raw

$oldSeq = @"    let Sequential computations =
        async {
            let results = ResizeArray()

            for computation in computations do
                let! result = computation
                results.Add result

            return results.ToArray()
        }
"

$newSeq = @"    let Sequential computations =
        async {
            System.Console.WriteLine(""FCS DEBUG: Inside Sequential with "" + string (Seq.length computations) + "" computations"")
            let results = ResizeArray()
            let mutable i = 0
            for computation in computations do
                System.Console.WriteLine(""FCS DEBUG: Sequential loop iteration "" + string i)
                let! result = computation
                System.Console.WriteLine(""FCS DEBUG: Sequential loop iteration "" + string i + "" done"")
                results.Add result
                i <- i + 1

            System.Console.WriteLine(""FCS DEBUG: Sequential finished"")
            return results.ToArray()
        }
"

$content = $content.Replace($oldSeq, $newSeq)
Set-Content -Path $path -Value $content -NoNewline
Write-Host "Modified DiagnosticsLogger.fs"
