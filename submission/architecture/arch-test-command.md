# Architecture Test

The test enforces that `InvoiceApp.Domain` does not reference `InvoiceApp.Api` or `Microsoft.AspNetCore` assemblies, using reflection in `ArchitectureTests.cs`.

From the repository root in Windows PowerShell, run:

```powershell
& "$env:LOCALAPPDATA\dotnet\dotnet.exe" test backend/InvoiceApp.sln --filter "Category=Architecture"
```

The explicit executable path uses the user-local .NET 8 SDK installed for this workspace. If `dotnet` is on `PATH`, the equivalent command is:

```powershell
dotnet test backend/InvoiceApp.sln --filter "Category=Architecture"
```
