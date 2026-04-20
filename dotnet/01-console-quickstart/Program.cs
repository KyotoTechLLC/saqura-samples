using SaQura;

// -----------------------------------------------------------------------------
// SaQura — Console quickstart
//
// Three things every integration does:
//   1. (Optional) Activate a license — skip this to try the Free tier.
//   2. Encrypt / decrypt / hash.
//   3. Check feature availability before calling paid-tier APIs.
//
// Run:   dotnet run
// -----------------------------------------------------------------------------

Console.WriteLine("SaQura — Console quickstart");
Console.WriteLine("===========================\n");

// 1. (Optional) Activate a license. Set SAQURA_LICENSE_PATH to a .lic file
//    you purchased, or leave unset to run on the Free tier.
var licensePath = Environment.GetEnvironmentVariable("SAQURA_LICENSE_PATH");
if (!string.IsNullOrWhiteSpace(licensePath) && File.Exists(licensePath))
{
    var result = await ApiLicense.ActivateLicenseFileAsync(licensePath);
    Console.WriteLine(result.Success
        ? $"License activated → tier: {ApiLicense.CurrentTier}\n"
        : $"License activation failed: {result.ErrorMessage}\n");
}
else
{
    Console.WriteLine("Running on the Free tier (no license). Output will be watermarked.");
    Console.WriteLine("Set SAQURA_LICENSE_PATH=/path/to/SaQura_Pro_standard.lic to unlock full features.\n");
}

// 2. AES — symmetric encryption (Free tier: max 100 chars per call).
{
    Console.WriteLine("--- AES-256-GCM ---");
    var key       = AES.GenerateAESKey();
    var plaintext = "Hello from SaQura!";
    var encrypted = await AES.EncryptAsync(plaintext, key);
    var decrypted = await AES.DecryptAsync(encrypted, key);

    Console.WriteLine($"Plaintext : {plaintext}");
    Console.WriteLine($"Encrypted : {Truncate(encrypted, 80)}");
    Console.WriteLine($"Decrypted : {decrypted}");
    Console.WriteLine($"Match     : {decrypted == plaintext}\n");
}

// 3. RSA — asymmetric encryption (Free tier: max 50 chars per call).
{
    Console.WriteLine("--- RSA-4096 ---");
    var (privateKey, publicKey) = await RSAKey.NewKeyPairAsStringAsync();
    var plaintext = "Secret";
    var encrypted = await plaintext.EncryptWithRSAAsync(publicKey);
    var decrypted = await encrypted.DecryptWithRSAAsync(privateKey);

    Console.WriteLine($"Public key  : {Truncate(publicKey, 80)}");
    Console.WriteLine($"Plaintext   : {plaintext}");
    Console.WriteLine($"Encrypted   : {Truncate(encrypted, 80)}");
    Console.WriteLine($"Decrypted   : {decrypted}");
    Console.WriteLine($"Match       : {decrypted == plaintext}\n");
}

// 4. Password hashing — always available.
{
    Console.WriteLine("--- Password hashing (PBKDF2) ---");
    var password = "correct-horse-battery-staple";
    var hash     = await PasswordHasher.HashPasswordAsync(password);
    var okRight  = await PasswordHasher.VerifyPasswordAsync(password,           hash);
    var okWrong  = await PasswordHasher.VerifyPasswordAsync("wrong-password",   hash);

    Console.WriteLine($"Password          : {password}");
    Console.WriteLine($"Hash              : {Truncate(hash, 80)}");
    Console.WriteLine($"Verify (correct)  : {okRight}");
    Console.WriteLine($"Verify (wrong)    : {okWrong}\n");
}

// 5. Feature gates — check before using paid-tier-only features.
Console.WriteLine("--- Available features ---");
Console.WriteLine($"Licensed             : {ApiLicense.IsLicensed}");
Console.WriteLine($"AES available        : {ApiLicense.IsAESAvailable}");
Console.WriteLine($"RSA available        : {ApiLicense.IsRSAAvailable}");
Console.WriteLine($"Quantum available    : {ApiLicense.IsQuantumAvailable}");
Console.WriteLine($"Password hashing     : {ApiLicense.IsPasswordHashingAvailable}");

return 0;

static string Truncate(string s, int max) =>
    s.Length <= max ? s : s[..max] + "…";
