# kotlin/01-android-quickstart

The 60-second SaQura integration on Android — AES, RSA (encrypt + sign),
password hashing, and large-file streaming, running on a real device on the
**Free tier** (no license, no server call).

SaQura for Android ships as an **AAR on Maven Central**, so the only dependency
you add is one line:

```kotlin
// app/build.gradle.kts
dependencies {
    implementation("jp.co.kyototech:saqura:1.2.0")
}
```

## Run

Connect a device (or start an emulator), then:

```bash
./gradlew :app:installDebug
adb shell am start -n jp.co.kyototech.saqura.sample/.MainActivity
```

The app runs every demo on launch and prints the results to the screen and to
logcat:

```bash
adb logcat -s SaQuraSample:I
```

### Requirements

| Tool | Version |
|---|---|
| JDK | 17 |
| Android SDK | compileSdk 34, build-tools 34.0.0 |
| Min device | Android 7.0 (API 24) or newer |
| Gradle | provided by the wrapper (`./gradlew`) — no system Gradle needed |

The Gradle wrapper pins the exact Gradle version; you do not need Gradle
installed. Point the build at your SDK either via the `ANDROID_HOME` environment
variable or a `local.properties` file with `sdk.dir=/path/to/Android/sdk`
(git-ignored).

## What you'll see (Free tier)

```
SaQura — Android quickstart
SDK: jp.co.kyototech:saqura:1.2.0

--- License ---
Licensed : false
Tier     : FREE

--- AES-256-GCM ---
Encrypted : [UNLICENSED-AES]…
Decrypted : [UNLICENSED-AES] Hello from SaQura on Android! [/UNLICENSED-AES]

--- RSA-4096 (encrypt + sign) ---
Decrypted : [UNLICENSED-OUTPUT] Secret [/UNLICENSED-OUTPUT]
Signature verifies : true

--- Password hashing (PBKDF2-SHA512) ---
Verify ok : true
Verify bad: false

--- Large-file streaming (SQS1, constant memory) ---
(skipped: Streaming encryption requires a Standard license or higher.)

Done. ✓
```

On the Free tier, encryption output is watermarked with `[UNLICENSED-…]` tags
and streaming is gated to Standard+ — the sample surfaces the gate instead of
crashing. **Signature verification and password verification work fully on every
tier.**

## Unlock the full library

If you purchased a license you received two `.lic` files (a `standard` one for
development and a `distribution` one for Play Store builds). Bundle the
distribution license in `app/src/main/assets/` and activate it once at startup:

```kotlin
// in SampleApplication.onCreate()
val json = assets.open("SaQura_Sample_distribution.lic")
    .bufferedReader().use { it.readText() }
ApiLicense.activateLicenseFromJson(json)
```

With a Standard+ license the watermarks disappear, AES/streaming are unlocked,
and decrypted output is byte-identical to the input. With a Pro+ license the
post-quantum surfaces (Gen8 hybrid ML-KEM, ML-DSA / SLH-DSA signatures, and the
streaming PQ envelope) become available too.

## App binding (optional)

A distribution license can be **bound to your app**, so an extracted `.lic` cannot be
activated inside a different app. It is verified offline at activation and binds to
your **package name** (`applicationId`) and **app-signing certificate** (SHA-256).

Because this sample already calls `ApiLicense.initialize(context)` at startup, **no
extra code is needed** — the library reads the package name and certificate from
Android itself. (If a license is bound but `initialize(context)` was never called,
activation is rejected fail-closed.)

> ⚠️ With **Google Play App Signing**, the certificate that matters is Google's
> app-signing key (Play Console → App integrity), not your upload key — send us that
> SHA-256 fingerprint for the bound license. On a mismatch, activation fails with a
> clear message and the app stays on the Free tier; it never crashes.

## What to look at

- `app/src/main/java/jp/co/kyototech/saqura/sample/SampleApplication.kt` —
  wiring `ApiLicense.initialize(context)` + `loadStoredLicense()` at startup.
- `app/src/main/java/jp/co/kyototech/saqura/sample/MainActivity.kt` — every call
  you need, each surfaced as its own section.
- `app/build.gradle.kts` — the single `jp.co.kyototech:saqura:1.2.0` dependency.

## Cross-platform

Data encrypted here decrypts byte-identically in the SaQura **.NET** (NuGet) and
**Swift** (SPM) packages, and vice versa — AES, RSA, passwords, quantum-safe,
and SQS1 streaming all share one wire format. See the
[USER_GUIDE](https://kyototech.co.jp/docs/saqura) for the full API.
