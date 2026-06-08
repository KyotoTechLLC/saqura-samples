# Getting started with SaQura

A 5-minute walkthrough to run your first SaQura encryption call.

## 1. Prerequisites

Pick one platform — the samples support all four.

### .NET

- .NET 8.0 SDK or newer — [download](https://dotnet.microsoft.com/download/dotnet/8.0)

### Kotlin / Android

- JDK 17
- Android SDK (compileSdk 34, build-tools 34.0.0) and a device or emulator on API 24+
- No Gradle install needed — the sample ships a Gradle wrapper (`./gradlew`)

### Swift

- macOS 12.0 or newer (Monterey)
- Xcode 15.0 or newer, **or** Swift 5.9 command-line toolchain

### JavaScript / TypeScript

- Node.js 18 or newer — [download](https://nodejs.org/)
- The liboqs WebAssembly engine is bundled in the package; nothing to compile

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

### Kotlin / Android

```bash
cd kotlin/01-android-quickstart
./gradlew :app:installDebug
adb shell am start -n jp.co.kyototech.saqura.sample/.MainActivity
adb logcat -s SaQuraSample:I
```

The app runs the same AES / RSA / password demos (plus a streaming demo) on your device and prints them to the screen and to logcat — same Free-tier watermarks.

### Swift

```bash
cd swift/01-cli-quickstart
swift run
```

Same output shape, same Free-tier watermarks.

### JavaScript / Node.js

```bash
cd js/01-node-quickstart
npm install && npm start
```

Runs a Gen8 post-quantum encryption, an ML-DSA signature and an SQS1 stream end-to-end on the Free tier. (The JS v0.1 package is post-quantum first — no direct AES/RSA string APIs yet, so no `[UNLICENSED-…]` watermark on this output.)

## 4. (Optional) Activate a license

If you've purchased SaQura, you received a `.lic` file. Activate it once at startup and the watermarks go away.

### .NET

```csharp
await ApiLicense.ActivateLicenseFileAsync("SaQura_Sample_standard.lic");
```

### Kotlin / Android

```kotlin
// Bundle the distribution .lic in app/src/main/assets/ and activate at startup:
val json = assets.open("SaQura_Sample_distribution.lic")
    .bufferedReader().use { it.readText() }
ApiLicense.activateLicenseFromJson(json)
```

### Swift

```swift
await ApiLicense.activateLicenseFile("SaQura_Sample_distribution.lic")
```

### JavaScript / TypeScript

```javascript
import { readFile } from "node:fs/promises";
import { ApiLicense } from "saqura";

const json = await readFile("SaQura_Sample_pro.lic", "utf8");
await ApiLicense.activate(json);
```

For mobile apps distributed via the App Store, embed the license JSON in your bundle instead of shipping the `.lic` file — see [`dotnet/02-license-activation`](../dotnet/02-license-activation) for both approaches.

## 5. Use SaQura in your own project

### .NET

```bash
dotnet add package SaQura
```

### Kotlin / Android

In your module's `build.gradle.kts`:

```kotlin
repositories { mavenCentral() }

dependencies {
    implementation("jp.co.kyototech:saqura:1.1.3")
}
```

### Swift

SaQura for Swift is distributed as a **binary xcframework** via `saqura.de` (no source). Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://saqura.de/swift/saqura-swift.git", from: "1.0.9")
]
```

…and reference the product as `.product(name: "SaQura", package: "saqura-swift")`.

Or in Xcode: **File → Add Package Dependencies…** and paste `https://saqura.de/swift/saqura-swift.git`.

### JavaScript / TypeScript

```bash
npm install saqura
```

Works in Node.js (ESM `import` or CommonJS `require`); the bundled WebAssembly engine is loaded automatically.

## 6. What's next?

- Browse the [sample index](../README.md#samples) for more focused walkthroughs.
- Read the [cross-platform compatibility notes](../README.md#cross-platform-compatibility) if your app has both a .NET backend and Swift clients.
- When you're ready for production, check the [pricing page](https://kyototech.co.jp/pricing) for paid tier options.

## Troubleshooting

**"Size limit exceeded" error** — You're hitting the Free tier cap (100 chars AES, 50 chars RSA, 80 chars quantum). Either shorten the input or activate a license.

**`[UNLICENSED-…]` tags in output** — Expected on the Free tier. The watermark is applied to the ciphertext, not the plaintext, so decrypting still works. Activate a license to remove it.

**Compiled output doesn't decrypt on the other platform** — The .NET, Kotlin, and Swift packages share a common wire format, but both sides must be licensed the same way. An unlicensed client can't decrypt licensed ciphertext and vice versa.

**Still stuck?** Email support@kyototech.co.jp.
