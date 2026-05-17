using SaQura;

// -----------------------------------------------------------------------------
// SaQura — License activation patterns
//
// Three ways to activate a purchased license:
//   1. From a .lic file path     — best for desktop/server apps.
//   2. From embedded JSON        — best for packaged mobile apps or containers
//                                  where you don't want to ship a separate file.
//   3. Re-activation on startup  — fast path that uses cached activation.
//
// Each purchase gives you two .lic files:
//   SaQura_{Tier}_standard.lic      — development machines
//   SaQura_{Tier}_distribution.lic  — App Store / production builds
//
// Run:  dotnet run -- file          # or: dotnet run -- json
// -----------------------------------------------------------------------------

var mode = args.Length > 0 ? args[0].ToLowerInvariant() : "file";

switch (mode)
{
    case "file": await ActivateFromFileAsync();     break;
    case "json": await ActivateFromJsonAsync();     break;
    default:
        Console.Error.WriteLine("Usage: dotnet run -- [file|json]");
        return 2;
}

PrintFeatureMatrix();
return 0;

// -----------------------------------------------------------------------------

static async Task ActivateFromFileAsync()
{
    Console.WriteLine("Mode: activate from .lic file\n");

    var path = Environment.GetEnvironmentVariable("SAQURA_LICENSE_PATH");
    if (string.IsNullOrWhiteSpace(path))
    {
        Console.WriteLine("Set SAQURA_LICENSE_PATH to the .lic file you received.");
        Console.WriteLine("Example:");
        Console.WriteLine("  export SAQURA_LICENSE_PATH=/path/to/SaQura_Sample_standard.lic");
        Console.WriteLine("  dotnet run -- file\n");
        Console.WriteLine("Continuing on the Free tier for demonstration.\n");
        return;
    }

    if (!File.Exists(path))
    {
        Console.Error.WriteLine($"File not found: {path}");
        return;
    }

    var result = await ApiLicense.ActivateLicenseFileAsync(path);
    Console.WriteLine(result.Success
        ? $"Activated. Tier: {ApiLicense.CurrentTier}, days remaining: {ApiLicense.GetDaysRemaining()}"
        : $"Activation failed: {result.ErrorMessage}");
}

static async Task ActivateFromJsonAsync()
{
    Console.WriteLine("Mode: activate from embedded JSON\n");

    // In a real app, load this JSON from an embedded resource, a config file,
    // or a build-time code generator — whatever keeps it out of source control.
    // The sample reads SAQURA_LICENSE_JSON for simplicity.
    var json = Environment.GetEnvironmentVariable("SAQURA_LICENSE_JSON");
    if (string.IsNullOrWhiteSpace(json))
    {
        Console.WriteLine("Set SAQURA_LICENSE_JSON to the contents of your .lic file.");
        Console.WriteLine("Example:");
        Console.WriteLine("  export SAQURA_LICENSE_JSON=\"$(cat SaQura_Sample_standard.lic)\"");
        Console.WriteLine("  dotnet run -- json\n");
        Console.WriteLine("Continuing on the Free tier for demonstration.\n");
        return;
    }

    var result = await ApiLicense.ActivateLicenseFromJsonAsync(json);
    Console.WriteLine(result.Success
        ? $"Activated. Tier: {ApiLicense.CurrentTier}, days remaining: {ApiLicense.GetDaysRemaining()}"
        : $"Activation failed: {result.ErrorMessage}");
}

static void PrintFeatureMatrix()
{
    Console.WriteLine("\nFeature availability:");
    Console.WriteLine($"  Licensed          : {ApiLicense.IsLicensed}");
    Console.WriteLine($"  Current tier      : {ApiLicense.CurrentTier}");
    Console.WriteLine($"  AES               : {ApiLicense.IsAESAvailable}");
    Console.WriteLine($"  RSA               : {ApiLicense.IsRSAAvailable}");
    Console.WriteLine($"  Quantum-Safe      : {ApiLicense.IsQuantumAvailable}");
    Console.WriteLine($"  Password Hashing  : {ApiLicense.IsPasswordHashingAvailable}");
}
