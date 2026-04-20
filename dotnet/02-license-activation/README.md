# dotnet/02-license-activation

Shows the two ways to activate a SaQura license: from a `.lic` file on disk, or from embedded JSON content.

## Run

```bash
# From a .lic file
export SAQURA_LICENSE_PATH=/path/to/SaQura_Pro_standard.lic
dotnet run -- file

# From embedded JSON content
export SAQURA_LICENSE_JSON="$(cat SaQura_Pro_standard.lic)"
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

## Where to put the license

Typical locations:

- **Server / desktop app**: a file next to the binary, path passed via config or env var.
- **ASP.NET Core**: embed via `ApiLicense.ActivateLicenseFromJsonAsync` in `Program.cs` (or in a startup `IHostedService`) before any encryption call.
- **Mobile / MAUI**: embed the JSON in a compiled resource; never ship the `.lic` as a loose file.

## Getting a license

Purchase at [kyototech.co.jp/pricing](https://kyototech.co.jp/pricing). You'll receive the two `.lic` files by email.
