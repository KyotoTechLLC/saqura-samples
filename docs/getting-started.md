# Getting started with SaQura

A 5-minute walkthrough to run your first SaQura encryption call.

## 1. Prerequisites

Pick one platform — the samples support both.

### .NET

- .NET 8.0 SDK or newer — [download](https://dotnet.microsoft.com/download/dotnet/8.0)

### Swift

- macOS 12.0 or newer (Monterey)
- Xcode 15.0 or newer, **or** Swift 5.9 command-line toolchain

## 2. Clone this repository

```bash
git clone https://github.com/KyotoTechLLC/saqura-samples.git
cd saqura-samples
```

## 3. Run the quickstart

### .NET

```bash
cd dotnet/01-console-quickstart
dotnet run
```

You should see AES, RSA, and password-hash demos run end-to-end. The output is watermarked with `[UNLICENSED-…]` tags because you're on the Free tier — that's expected.

### Swift

```bash
cd swift/01-cli-quickstart
swift run
```

Same output shape, same Free-tier watermarks.

## 4. (Optional) Activate a license

If you've purchased SaQura, you received a `.lic` file. Activate it once at startup and the watermarks go away.

### .NET

```csharp
await ApiLicense.ActivateLicenseFileAsync("SaQura_Pro_standard.lic");
```

### Swift

```swift
await ApiLicense.activateLicenseFile("SaQura_Pro_distribution.lic")
```

For mobile apps distributed via the App Store, embed the license JSON in your bundle instead of shipping the `.lic` file — see [`dotnet/02-license-activation`](../dotnet/02-license-activation) for both approaches.

## 5. Use SaQura in your own project

### .NET

```bash
dotnet add package SaQura
```

### Swift

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/KyotoTechLLC/SaQuraSwift.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies…** and paste `https://github.com/KyotoTechLLC/SaQuraSwift.git`.

## 6. What's next?

- Browse the [sample index](../README.md#samples) for more focused walkthroughs.
- Read the [cross-platform compatibility notes](../README.md#cross-platform-compatibility) if your app has both a .NET backend and Swift clients.
- When you're ready for production, check the [pricing page](https://kyototech.co.jp/pricing) for paid tier options.

## Troubleshooting

**"Size limit exceeded" error** — You're hitting the Free tier cap (100 chars AES, 50 chars RSA, 80 chars quantum). Either shorten the input or activate a license.

**`[UNLICENSED-…]` tags in output** — Expected on the Free tier. The watermark is applied to the ciphertext, not the plaintext, so decrypting still works. Activate a license to remove it.

**Compiled output doesn't decrypt on the other platform** — The Swift and .NET packages share a common format, but both sides must be licensed the same way. An unlicensed Swift client can't decrypt licensed .NET ciphertext and vice versa.

**Still stuck?** Email support@kyototech.jp.
