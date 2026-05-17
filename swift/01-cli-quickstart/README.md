# swift/01-cli-quickstart

The Swift version of [`dotnet/01-console-quickstart`](../../dotnet/01-console-quickstart) — same flow, same free-tier behavior.

## Run

```bash
swift run
```

The SaQuraSwift package is resolved from GitHub — no other setup.

## What to look at

- `Sources/main.swift` — every call needed for a basic integration, heavily commented.
- `Package.swift` — the SaQuraSwift dependency declaration.

## Unlock the paid tier

Set `SAQURA_LICENSE_PATH` to a `.lic` file you've purchased:

```bash
export SAQURA_LICENSE_PATH=/path/to/SaQura_Sample_standard.lic
swift run
```

## Cross-platform round-trip

Data encrypted by the [.NET console quickstart](../../dotnet/01-console-quickstart) decrypts here, and vice versa — the byte format is shared. See the [main README](../../README.md#cross-platform-compatibility) for an example.
