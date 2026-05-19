// dotnet/04-bytearray-migration
//
// Migrates `byte[]` AES ciphertext produced by SaQura 1.0.0.2..1.0.7
// to the v1.0.8+ wire format. Self-contained: the embedded legacy
// ciphertext below is a real fixture from the public test corpus
// (net_1.0.4.4/symmetric/aes_gcm_short.json), produced by the
// actually-published SaQura 1.0.4.4 binary on nuget.org.
//
// Run on Free tier (no license needed — the 32-byte plaintext fits
// under the Free-tier 100-byte AES cap):
//
//   dotnet run
//
// Run with the public sample license (no watermarks):
//
//   export SAQURA_LICENSE_PATH=/path/to/SaQura_Sample_standard.lic
//   dotnet run

using System.Text;
using SaQura;

const string Sep = "═══════════════════════════════════════════════════════════════";

// ────────────────────────────────────────────────────────────────────
// Optional: activate a license to suppress watermarks. Free-tier runs
// fine for the 32-byte plaintext in this sample.
// ────────────────────────────────────────────────────────────────────
var licPath = Environment.GetEnvironmentVariable("SAQURA_LICENSE_PATH");
if (!string.IsNullOrEmpty(licPath) && File.Exists(licPath))
{
    var lic = await File.ReadAllTextAsync(licPath);
    var act = await ApiLicense.ActivateLicenseFromJsonAsync(lic);
    Console.WriteLine($"License activation: {(act.Success ? "ok" : "FAILED — " + act.ErrorMessage)}");
}
else
{
    Console.WriteLine("No SAQURA_LICENSE_PATH set — running on Free tier (watermarks visible on Release build).");
}
Console.WriteLine();

// ────────────────────────────────────────────────────────────────────
// "Customer's stored data" — a real v1.0.4.4 byte[] AES ciphertext.
//
// The fixture below was produced by SaQura 1.0.4.4 (published on
// nuget.org) via `byte[].EncryptWithAESAsync(string)`. Every customer
// who used that API and stored the output has data in this exact
// wire format.
// ────────────────────────────────────────────────────────────────────
const string keyHex = "fc7c8c231285144e21b774449b661a80dacb706f939275ddc3e44610355513ff";
const string legacyCiphertextHex = "8236c883d506a724a1f4951b3f7260180ed33bdab5c366a3203d5c99fa294363ecba5e298fe6a59790acff759970590074db91dd5b798ee90656ca704fa395ebd0f3db2a0e1d6835";
const string expectedPlaintext = "SaQura test corpus 2026 fixture.";

var key = Convert.ToBase64String(Convert.FromHexString(keyHex));
var legacyCiphertext = Convert.FromHexString(legacyCiphertextHex);

Console.WriteLine(Sep);
Console.WriteLine("byte[] AES Migration — SaQura 1.0.4.4 stored data → 1.0.8");
Console.WriteLine(Sep);
Console.WriteLine($"Encryption key:      {key}  (Base64, 32 bytes)");
Console.WriteLine($"Legacy ciphertext:   {legacyCiphertext.Length} bytes (v1.0.7 wire format with inner base64 wrap)");
Console.WriteLine($"Expected plaintext:  \"{expectedPlaintext}\" ({Encoding.UTF8.GetByteCount(expectedPlaintext)} bytes)");
Console.WriteLine();

// ────────────────────────────────────────────────────────────────────
// Step 1 — Show that the regular v1.0.8 DecryptWithAESAsync does NOT
// recover the original plaintext for legacy data.
// ────────────────────────────────────────────────────────────────────
Console.WriteLine($"STEP 1 — Regular DecryptWithAESAsync on legacy ciphertext");

byte[] regular;
try
{
    regular = await legacyCiphertext.DecryptWithAESAsync(key);
    var asString = Encoding.UTF8.GetString(regular);
    Console.WriteLine($"  Returned: \"{(asString.Length > 60 ? asString[..60] + "…" : asString)}\"");
    var matches = Encoding.UTF8.GetString(regular).Equals(expectedPlaintext);
    Console.WriteLine($"  Matches expected: {matches}  ← regular decrypt returns the UTF-8 bytes of the base64 string, NOT the original plaintext");
}
catch (Exception ex)
{
    Console.WriteLine($"  Threw {ex.GetType().Name}: {ex.Message}");
}
Console.WriteLine();

// ────────────────────────────────────────────────────────────────────
// Step 2 — The migration. One call recovers the original raw bytes.
// ────────────────────────────────────────────────────────────────────
Console.WriteLine($"STEP 2 — MigrateLegacyAESByteCiphertextAsync");

byte[] rawPlaintext = await legacyCiphertext.MigrateLegacyAESByteCiphertextAsync(key);
var migratedString = Encoding.UTF8.GetString(rawPlaintext);
Console.WriteLine($"  Recovered:        \"{migratedString}\"  ({rawPlaintext.Length} bytes)");
Console.WriteLine($"  Matches expected: {migratedString == expectedPlaintext}  ← migration recovers the original bytes ✓");
Console.WriteLine();

// ────────────────────────────────────────────────────────────────────
// Step 3 — Re-encrypt with v1.0.8 wire format. This is the ciphertext
// you should persist going forward (delete the legacy version).
// ────────────────────────────────────────────────────────────────────
Console.WriteLine($"STEP 3 — Re-encrypt with v1.0.8 wire format");

byte[] newCiphertext = await rawPlaintext.EncryptWithAESAsync(key);
Console.WriteLine($"  v1.0.8 ciphertext: {newCiphertext.Length} bytes");
Console.WriteLine($"  Layout: [Nonce:12][CT:N][Tag:16] — byte-identical with Swift + Kotlin");
Console.WriteLine();

// ────────────────────────────────────────────────────────────────────
// Step 4 — Verify the new ciphertext roundtrips cleanly under v1.0.8.
// ────────────────────────────────────────────────────────────────────
Console.WriteLine($"STEP 4 — Verify v1.0.8 roundtrip");

byte[] roundtrip = await newCiphertext.DecryptWithAESAsync(key);
var roundtripString = Encoding.UTF8.GetString(roundtrip);
Console.WriteLine($"  Recovered:        \"{roundtripString}\"");
Console.WriteLine($"  Matches expected: {roundtripString == expectedPlaintext}  ← v1.0.8 byte[] AES roundtrips byte-identical ✓");
Console.WriteLine();

// ────────────────────────────────────────────────────────────────────
// Step 5 — Defensive: the migration helper REJECTS v1.0.8+ ciphertext.
// This prevents accidental double-migration.
// ────────────────────────────────────────────────────────────────────
Console.WriteLine($"STEP 5 — Migration helper rejects v1.0.8 ciphertext (defensive)");

try
{
    _ = await newCiphertext.MigrateLegacyAESByteCiphertextAsync(key);
    Console.WriteLine($"  UNEXPECTED: helper accepted v1.0.8 ciphertext (this should not happen)");
    return 1;
}
catch (System.Security.Cryptography.CryptographicException)
{
    Console.WriteLine($"  CryptographicException thrown as expected  ← helper correctly refuses v1.0.8 input ✓");
}
Console.WriteLine();

Console.WriteLine(Sep);
Console.WriteLine("MIGRATION SAMPLE COMPLETE");
Console.WriteLine(Sep);
Console.WriteLine("Production migration pattern (your code):");
Console.WriteLine();
Console.WriteLine("    byte[] legacy = LoadStoredCiphertext();");
Console.WriteLine("    string key   = LoadEncryptionKey();");
Console.WriteLine("    byte[] raw   = await legacy.MigrateLegacyAESByteCiphertextAsync(key);");
Console.WriteLine("    byte[] newCt = await raw.EncryptWithAESAsync(key);");
Console.WriteLine("    SaveCiphertext(newCt);");
Console.WriteLine("    DeleteOldCiphertext();");
Console.WriteLine();
Console.WriteLine("See MIGRATION_GUIDE_1.0.7_TO_1.0.8.md in your nupkg + the");
Console.WriteLine("kyototech.co.jp/docs/saqura/#aes-bytearray-migration section");
Console.WriteLine("for batch-migration patterns and edge cases.");

return 0;
