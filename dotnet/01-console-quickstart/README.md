# dotnet/01-console-quickstart

Runs AES, RSA, and password hashing back-to-back. The 30-second tour of the .NET package.

## Run

```bash
dotnet run
```

No environment variables needed. Output runs on the Free tier with watermarks.

## What to look at

- `Program.cs` — every call needed for a basic integration, heavily commented.
- `ConsoleQuickstart.csproj` — shows the only `<PackageReference>` you need.

## Unlock the paid tier

Set `SAQURA_LICENSE_PATH` to a `.lic` file you've purchased:

```bash
export SAQURA_LICENSE_PATH=/path/to/SaQura_Sample_standard.lic
dotnet run
```

Watermarks disappear, size limits are lifted, Quantum-Safe becomes available.

## Expected output (Free tier, Release build)

```
SaQura — Console quickstart
===========================

Running on the Free tier (no license). Output will be watermarked.
Set SAQURA_LICENSE_PATH=/path/to/SaQura_Sample_standard.lic to unlock full features.

--- AES-256-GCM ---
Plaintext : Hello from SaQura!
Encrypted : [UNLICENSED-AES]W6b…[/UNLICENSED-AES]
Decrypted : [UNLICENSED-AES] Hello from SaQura! [/UNLICENSED-AES]
Match     : False

--- RSA-4096 ---
...
```

In **Debug builds** (`dotnet run` without `--configuration Release`) the watermarks are suppressed for development convenience — that's why the sample's "Match: True" lines pass locally.
