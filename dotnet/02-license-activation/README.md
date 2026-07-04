# dotnet/02-license-activation

Shows the two ways to activate a SaQura license: from a `.lic` file on disk, or from embedded JSON content.

## Run

```bash
# From a .lic file
export SAQURA_LICENSE_PATH=/path/to/SaQura_Sample_standard.lic
dotnet run -- file

# From embedded JSON content
export SAQURA_LICENSE_JSON="$(cat SaQura_Sample_standard.lic)"
dotnet run -- json
```

If neither variable is set, the sample runs on the Free tier and prints the feature matrix so you can see what's available without a license.

## Which license file to use

Each purchase ships two `.lic` files:

| File | When to use |
|---|---|
| `SaQura_{Tier}_standard.lic` | Local development on your own machines |
| `SaQura_{Tier}_distribution.lic` | Apps distributed to end users (App Store, public NuGet, customer installs) |

For mobile apps submitted to app stores, prefer the embedded-JSON approach — you don't want the `.lic` file extractable from your app bundle as a standalone asset.

## App binding (optional)

A distribution license can optionally be **bound to your app**, so that an extracted `.lic` cannot be activated inside a different app. Binding is verified offline at activation — **your activation code stays exactly the same**; the library reads the app identity from the operating system itself.

| Platform | Bound to |
|---|---|
| Android | package name (`applicationId`) + signing certificate |
| iOS / Mac Catalyst | bundle identifier |
| Windows | the host executable's Authenticode signature |

Native device binding uses the .NET 10 MAUI targets (`net10.0-android` / `net10.0-ios` / `net10.0-maccatalyst`). A `net8.0` console/server app uses the base assembly: binding is available on Windows (Authenticode); other desktop OSes have no OS-attested app identity, so a bound license fails closed there — use an unbound license for cross-platform servers. On iOS only the bundle identifier is bound.

On a mismatch, activation fails with a clear message (e.g. *"License is not valid for this application package"*) and the app continues on the Free tier — it never crashes. To request a bound license, contact us with your package name / bundle identifier (and signing certificate on Android/Windows).

## Where to put the license

Typical locations:

- **Server / desktop app**: a file next to the binary, path passed via config or env var.
- **ASP.NET Core**: embed via `ApiLicense.ActivateLicenseFromJsonAsync` in `Program.cs` (or in a startup `IHostedService`) before any encryption call.
- **Mobile / MAUI**: embed the JSON in a compiled resource; never ship the `.lic` as a loose file.

## Getting a license

Purchase at [kyototech.co.jp/pricing](https://kyototech.co.jp/pricing). You'll receive the two `.lic` files by email.
