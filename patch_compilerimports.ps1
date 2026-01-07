$path = "..\Bolero.FCS.Build - Copy\src\Compiler\Driver\CompilerImports.fs"
$content = Get-Content -Path $path -Raw

# 1. BuildFrameworkTcImports entry
$anchor1 = "static member BuildFrameworkTcImports(tcConfigP: TcConfigProvider, frameworkDLLs, nonFrameworkDLLs) = "
$log1 = "    static member BuildFrameworkTcImports(tcConfigP: TcConfigProvider, frameworkDLLs, nonFrameworkDLLs) = `n        System.Console.WriteLine(""FCS DEBUG: Inside BuildFrameworkTcImports"")"
$content = $content.Replace($anchor1, $log1)

# 2. BuildFrameworkTcImports - calling RegisterAndImportReferencedAssemblies for primary assembly
$anchor2 = "let! primaryAssem = frameworkTcImports.RegisterAndImportReferencedAssemblies(ctok, primaryAssemblyResolution)"
$log2 = "System.Console.WriteLine(""FCS DEBUG: Calling RegisterAndImportReferencedAssemblies for primary assembly"")`n            let! primaryAssem = frameworkTcImports.RegisterAndImportReferencedAssemblies(ctok, primaryAssemblyResolution)"
$content = $content.Replace($anchor2, $log2)

# 3. RegisterAndImportReferencedAssemblies entry
$anchor3 = "member tcImports.RegisterAndImportReferencedAssemblies(ctok, nms: AssemblyResolution list) ="
$log3 = "    member tcImports.RegisterAndImportReferencedAssemblies(ctok, nms: AssemblyResolution list) =`n        System.Console.WriteLine(""FCS DEBUG: Inside RegisterAndImportReferencedAssemblies with "" + string nms.Length + "" assemblies"")"
$content = $content.Replace($anchor3, $log3)

# 4. tryGetAssemblyData - inside the async block
$anchor4 = "let tryGetAssemblyData (r: AssemblyResolution) =`n            async {"
$log4 = "let tryGetAssemblyData (r: AssemblyResolution) =`n            async {`n                System.Console.WriteLine(""FCS DEBUG: tryGetAssemblyData for: "" + r.resolvedPath)"
$content = $content.Replace($anchor4, $log4)

# 5. Inside RegisterAndImportReferencedAssemblies async block - check parallel mode
$anchor5 = "let runMethod computations ="
$log5 = "System.Console.WriteLine(""FCS DEBUG: RegisterAndImportReferencedAssemblies - parallelReferenceResolution: "" + string tcConfig.parallelReferenceResolution)`n            let runMethod computations ="
$content = $content.Replace($anchor5, $log5)

# 6. BuildFrameworkTcImports - calling RegisterAndImportReferencedAssemblies for resolvedAssemblies
$anchor6 = "let! _assemblies = frameworkTcImports.RegisterAndImportReferencedAssemblies(ctok, resolvedAssemblies)"
$log6 = "System.Console.WriteLine(""FCS DEBUG: Calling RegisterAndImportReferencedAssemblies for resolvedAssemblies"")`n            let! _assemblies = frameworkTcImports.RegisterAndImportReferencedAssemblies(ctok, resolvedAssemblies)"
$content = $content.Replace($anchor6, $log6)

Set-Content -Path $path -Value $content -NoNewline
Write-Host "Modified CompilerImports.fs with granular patches"
