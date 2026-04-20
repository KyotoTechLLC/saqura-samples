using SaQura;

// -----------------------------------------------------------------------------
// SaQura — File encryption
//
// Encrypt a file to disk and decrypt it back — AES-256-GCM, same authenticated
// output format as every other AES call in SaQura.
//
// Usage:
//   dotnet run -- encrypt <input-path> <output-path> [key-out-path]
//   dotnet run -- decrypt <input-path> <output-path>  <key-path>
//
// Without a license, the Free tier caps AES input at 100 characters — big
// enough for config files and secrets, not for arbitrary media. Activate
// a license to lift the limit (see dotnet/02-license-activation).
// -----------------------------------------------------------------------------

if (args.Length < 3)
{
    PrintUsage();
    return 2;
}

var mode = args[0].ToLowerInvariant();

// Optional: activate a license if SAQURA_LICENSE_PATH is set.
var licensePath = Environment.GetEnvironmentVariable("SAQURA_LICENSE_PATH");
if (!string.IsNullOrWhiteSpace(licensePath) && File.Exists(licensePath))
{
    await ApiLicense.ActivateLicenseFileAsync(licensePath);
}

try
{
    switch (mode)
    {
        case "encrypt": await EncryptAsync(args[1], args[2], args.ElementAtOrDefault(3)); return 0;
        case "decrypt": await DecryptAsync(args[1], args[2], args[3]);                    return 0;
        default: PrintUsage(); return 2;
    }
}
catch (Exception ex)
{
    Console.Error.WriteLine($"Error: {ex.Message}");
    return 1;
}

// -----------------------------------------------------------------------------

static async Task EncryptAsync(string inputPath, string outputPath, string? keyOutPath)
{
    var plaintext = await File.ReadAllTextAsync(inputPath);
    var key       = AES.GenerateAESKey();
    var encrypted = await AES.EncryptAsync(plaintext, key);

    await File.WriteAllTextAsync(outputPath, encrypted);

    // Key goes to a separate file so you can rotate / share it independently.
    var keyFile = keyOutPath ?? outputPath + ".key";
    await File.WriteAllTextAsync(keyFile, key);

    Console.WriteLine($"Encrypted {inputPath} → {outputPath} ({new FileInfo(outputPath).Length} bytes)");
    Console.WriteLine($"Key saved → {keyFile}");
    Console.WriteLine("Keep the key file safe. Lost keys = unrecoverable data.");
}

static async Task DecryptAsync(string inputPath, string outputPath, string keyPath)
{
    var encrypted = await File.ReadAllTextAsync(inputPath);
    var key       = (await File.ReadAllTextAsync(keyPath)).Trim();
    var plaintext = await AES.DecryptAsync(encrypted, key);

    await File.WriteAllTextAsync(outputPath, plaintext);
    Console.WriteLine($"Decrypted {inputPath} → {outputPath}");

    if (!ApiLicense.IsLicensed)
    {
        Console.WriteLine();
        Console.WriteLine("Note: the Free tier wraps the decrypted output in [UNLICENSED-AES]…");
        Console.WriteLine("tags, so the recovered file will not be byte-identical to the input.");
        Console.WriteLine("Activate a license (see dotnet/02-license-activation) to get a clean round-trip.");
    }
}

static void PrintUsage()
{
    Console.Error.WriteLine("Usage:");
    Console.Error.WriteLine("  dotnet run -- encrypt <input> <output.saq>  [key-out]");
    Console.Error.WriteLine("  dotnet run -- decrypt <input.saq> <output> <key>");
}
