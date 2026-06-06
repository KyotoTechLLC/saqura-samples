# SaQura — Official Samples

**Cryptography that works the same on .NET, Kotlin/Android, and Swift.**

[SaQura](https://kyototech.co.jp/products/saqura) is a commercial cryptography library by KyotoTech LLC. It covers AES-256-GCM, RSA-4096, password hashing, digital signatures, post-quantum encryption (FrodoKEM + Classic McEliece, plus the NIST FIPS standards — hybrid X25519/ML-KEM (FIPS 203), ML-DSA (FIPS 204), SLH-DSA (FIPS 205)), and constant-memory large-file streaming (SQS1) — and data encrypted on any one of .NET, Kotlin, or Swift decrypts identically on the others.

This repository contains runnable sample projects that show you how to add SaQura to your app in **under 5 minutes**.

---

## Samples

| # | Sample | Platform | What it shows |
|---|---|---|---|
| 01 | [`dotnet/01-console-quickstart`](dotnet/01-console-quickstart) | .NET 8+ console | The 30-second integration — AES, RSA, passwords |
| 02 | [`dotnet/02-license-activation`](dotnet/02-license-activation) | .NET 8+ console | Activating a `.lic` file to unlock paid features |
| 03 | [`dotnet/03-file-encryption`](dotnet/03-file-encryption) | .NET 8+ console | Encrypt and decrypt files with AES |
| 04 | [`dotnet/04-bytearray-migration`](dotnet/04-bytearray-migration) | .NET 8+ console | **Upgrading from 1.0.4.4?** Migrate stored `byte[]` AES ciphertext to the v1.0.8 wire format |
| 05 | [`kotlin/01-android-quickstart`](kotlin/01-android-quickstart) | Android (API 24+) | The 60-second Android integration — AES, RSA, passwords, streaming on a real device |
| 06 | [`swift/01-cli-quickstart`](swift/01-cli-quickstart) | Swift CLI (macOS) | The 30-second Swift integration |
| 07 | [`swift/02-ios-app`](swift/02-ios-app) | SwiftUI iOS / macOS | Interactive playground for every feature |

Each sample is self-contained and has its own README.

---

## Run without a license (Free tier)

**Every sample here runs on the Free tier with no credit card, no license key, no server call.**

The Free tier is size-limited and adds a visible watermark to the output — perfect for evaluation. See the [Free tier limits](#free-tier-limits) below.

```bash
# .NET
cd dotnet/01-console-quickstart
dotnet run

# Swift CLI
cd swift/01-cli-quickstart
swift run

# Android (device or emulator connected)
cd kotlin/01-android-quickstart
./gradlew :app:installDebug
adb shell am start -n jp.co.kyototech.saqura.sample/.MainActivity
```

That's it. No setup.

---

## Unlock the full library (paid tier)

If you've purchased a SaQura license, you receive a `.lic` file (or two — one `standard` for development machines and one `distribution` for App Store / production builds). Activate it once at startup:

### .NET

```csharp
using SaQura;

// From a file on disk
await ApiLicense.ActivateLicenseFileAsync("/path/to/SaQura_Sample_standard.lic");

// Or embed the JSON content directly (recommended for mobile / packaged apps)
await ApiLicense.ActivateLicenseFromJsonAsync(licenseJson);

if (ApiLicense.IsLicensed)
{
    Console.WriteLine($"Licensed: {ApiLicense.CurrentTier}");
}
```

### Swift

```swift
import SaQura

// From a file path
let result = await ApiLicense.activateLicenseFile("/path/to/SaQura_Sample_distribution.lic")

// Or embed JSON content directly (recommended for App Store)
let result = await ApiLicense.activateLicenseFromJson(licenseJson)

if ApiLicense.isLicensed {
    print("Licensed: \(ApiLicense.currentTier)")
}
```

See [`dotnet/02-license-activation`](dotnet/02-license-activation) for a full walkthrough.

---

## 30-second example (.NET)

```csharp
using SaQura;

// AES — symmetric
var key       = AES.GenerateAESKey();
var encrypted = await AES.EncryptAsync("Hello, SaQura!", key);
var decrypted = await AES.DecryptAsync(encrypted, key);
// decrypted == "Hello, SaQura!"

// RSA — asymmetric
var (privateKey, publicKey) = await RSAKey.NewKeyPairAsStringAsync();
var cipher    = await "Secret".EncryptWithRSAAsync(publicKey);
var plaintext = await cipher.DecryptWithRSAAsync(privateKey);

// Password hashing
var hash = await PasswordHasher.HashPasswordAsync("MyPassword123");
var ok   = await PasswordHasher.VerifyPasswordAsync("MyPassword123", hash);
```

## 30-second example (Swift)

```swift
import SaQura

// AES — symmetric
let key       = AESKey.newKey()
let encrypted = try await "Hello, SaQura!".encryptWithAES(key: key)
let decrypted = try await encrypted.decryptWithAES(key: key)

// RSA — asymmetric
let (privateKey, publicKey) = try await RSAKey.newKeyPair()
let cipher    = try await "Secret".encryptWithRSA(publicKey: publicKey)
let plaintext = try await cipher.decryptWithRSA(privateKey: privateKey)

// Password hashing
let hash = try await "MyPassword123".hashPassword()
let ok   = try await "MyPassword123".verifyPassword(hash: hash)
```

## 30-second example (Kotlin / Android)

```kotlin
import co.kyototech.saqura.aes.*
import co.kyototech.saqura.rsa.*
import co.kyototech.saqura.passwords.*

// AES — symmetric
val key       = AESKey.newKey()
val encrypted = "Hello, SaQura!".encryptWithAES(key)
val decrypted = encrypted.decryptWithAES(key)
// decrypted == "Hello, SaQura!"

// RSA — asymmetric
val pair      = RSAKey.newKeyPair()
val cipher    = "Secret".encryptWithRSA(pair.publicKey)
val plaintext = cipher.decryptWithRSA(pair.privateKey)

// Password hashing
val hash = PasswordHasher.hash("MyPassword123")
val ok   = PasswordHasher.verify("MyPassword123", hash)
```

(All SaQura calls are `suspend` — invoke them from a coroutine.)

---

## Free tier limits

The Free tier lets you evaluate every feature without a license. In exchange, output is size-limited and watermarked:

| Feature | Free tier limit | Watermark |
|---|---|---|
| AES encryption | 100 chars / encrypt call | `[UNLICENSED-AES]…[/UNLICENSED-AES]` |
| RSA encryption | 50 chars / encrypt call | `[UNLICENSED-OUTPUT]…[/UNLICENSED-OUTPUT]` |
| Password hashing | full size | `[UNLICENSED-HASH]…[/UNLICENSED-HASH]` |
| Quantum-safe | 80 chars / encrypt call | `[UNLICENSED-QUANTUM]…[/UNLICENSED-QUANTUM]` |
| Digital signatures | requires paid tier | — |

All paid tiers (Basic, Standard, Pro, Enterprise) remove these limits. Compare tiers at [kyototech.co.jp/pricing](https://kyototech.co.jp/pricing).

---

## Cross-platform compatibility

Encrypt on .NET, decrypt on Swift (and back):

```csharp
// .NET — server side
var encrypted = await AES.EncryptAsync("Hello from server", sharedKey);
// Send `encrypted` to the iOS app …
```

```swift
// Swift — iOS client
let decrypted = try await encrypted.decryptWithAES(key: sharedKey)
// "Hello from server"
```

The .NET, Kotlin, and Swift packages use the same byte-level format for AES, RSA, passwords, quantum-safe output, and SQS1 streaming. No conversion layer needed — a stream encrypted by an Android client decrypts on a .NET server and vice versa.

---

## Which sample should I start with?

- **Never used SaQura before** → [`dotnet/01-console-quickstart`](dotnet/01-console-quickstart) or [`swift/01-cli-quickstart`](swift/01-cli-quickstart)
- **I have a license file** → [`dotnet/02-license-activation`](dotnet/02-license-activation)
- **I want to encrypt files, not strings** → [`dotnet/03-file-encryption`](dotnet/03-file-encryption)
- **I'm building an Android app** → [`kotlin/01-android-quickstart`](kotlin/01-android-quickstart)
- **I'm building an iOS app** → [`swift/02-ios-app`](swift/02-ios-app)

See [docs/getting-started.md](docs/getting-started.md) for a longer walkthrough.

---

## Resources

- **NuGet (.NET)**: [nuget.org/packages/SaQura](https://www.nuget.org/packages/SaQura)
- **Maven Central (Kotlin/Android)**: [`jp.co.kyototech:saqura`](https://central.sonatype.com/artifact/jp.co.kyototech/saqura)
- **Swift Package**: distributed as a binary xcframework — see [kyototech.co.jp/products/saqura](https://kyototech.co.jp/products/saqura)
- **Product page**: [kyototech.co.jp/products/saqura](https://kyototech.co.jp/products/saqura)
- **Pricing**: [kyototech.co.jp/pricing](https://kyototech.co.jp/pricing)
- **Support**: support@kyototech.jp

## License

Sample code in this repository is MIT-licensed — see [LICENSE](LICENSE). The SaQura library itself is proprietary; see the SaQura [terms](https://kyototech.co.jp/products/saqura/terms).
