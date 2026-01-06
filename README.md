# WasmScriptPoc

This is a Proof of Concept (POC) for running F# scripts in the browser using WebAssembly (WASM) via Bolero and FSharp.Compiler.Service.

## Prerequisites

- .NET 9.0 SDK
- Local build of `Bolero` and `Bolero.FCS.Build` (configured in `nuget.config` and `WasmScriptPoc.fsproj`)

## How to Run

1.  Navigate to the project directory:
    ```powershell
    cd WasmScriptPoc
    ```

2.  Run the application:
    ```powershell
    dotnet run
    ```

3.  Open your browser to the URL shown (usually `http://localhost:5xxx`).

## How it Works

1.  The application loads.
2.  It downloads necessary reference assemblies (DLLs) from the `/refs` endpoint (served from `wwwroot/refs`).
3.  It initializes the `FSharpChecker`.
4.  When you click "Compile & Run", it sends the code to the in-browser compiler.
5.  The compiler parses and checks the code against the downloaded references.
6.  If successful, it reports success (and would technically produce an assembly in memory/virtual FS).

## Project Structure

- `Main.fs`: Contains the UI (Elmish), Compiler logic, and EntryPoint.
- `WasmScriptPoc.fsproj`: Project configuration, references local Bolero source and Bolero.FCS.Build package.
- `wwwroot/refs`: Directory populated with DLLs during build, used by the compiler for references.
