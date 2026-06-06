# dotnet/04-bytearray-migration

Migrates `byte[]` AES ciphertext produced by SaQura **1.0.0.2 – 1.0.4.4** to the **v1.0.8+** cross-platform wire format.

## Who needs this?

Read [§3 of MIGRATION_GUIDE_1.0.4.4_TO_1.0.8.md](https://kyototech.co.jp/docs/saqura/#aes-bytearray-migration) for the decision tree. Short version: you need this sample only if all three apply:

1. Your code called `byte[].EncryptWithAESAsync(string)` at some point.
2. You stored the output (on disk, in a database, message queue, anywhere).
3. You're now upgrading to SaQura 1.0.8 or newer.

If you only ever used `string.EncryptWithAESAsync` — this is not for you, the string API is unchanged.

## Run

```bash
dotnet run
```

No environment variables needed. The sample uses a 32-byte plaintext which fits under the Free-tier AES cap, so no license is required.

## What it does

1. Loads a real v1.0.4.4 ciphertext + key (embedded in `Program.cs`, taken from the public test corpus).
2. Shows that the regular `DecryptWithAESAsync` returns the inner base64-string bytes, not the original plaintext.
3. Calls `MigrateLegacyAESByteCiphertextAsync(key)` → recovers the original raw bytes.
4. Re-encrypts the raw bytes with `EncryptWithAESAsync(key)` to produce the v1.0.8 wire format.
5. Verifies the v1.0.8 ciphertext round-trips cleanly via `DecryptWithAESAsync(key)`.
6. Confirms the migration helper rejects v1.0.8+ ciphertext (defensive, prevents accidental double-migration).

## Production migration pattern

```csharp
byte[] legacy = LoadStoredCiphertext();              // your storage layer
string key   = LoadEncryptionKey();                  // your key-management layer

byte[] raw   = await legacy.MigrateLegacyAESByteCiphertextAsync(key);
byte[] newCt = await raw.EncryptWithAESAsync(key);

SaveCiphertext(newCt);
DeleteOldCiphertext();
```

For migrating a database column with many records, see the batch-migration pattern in the [migration guide](https://kyototech.co.jp/docs/saqura/#aes-bytearray-migration).

## Expected output (Free tier, Release build)

> **Note on byte count in Step 3:** On Free tier, the AES output includes the standard SaQura free-tier wrapper, so the byte count reads ~123 instead of the canonical 60. The `DecryptWithAESAsync` companion handles the wrapper transparently — Step 4 still recovers the original plaintext. With `SAQURA_LICENSE_PATH` set, no wrapper is added and Step 3 prints `60 bytes` instead.

```
No SAQURA_LICENSE_PATH set — running on Free tier (watermarks visible on Release build).

═══════════════════════════════════════════════════════════════
byte[] AES Migration — SaQura 1.0.4.4 stored data → 1.0.8
═══════════════════════════════════════════════════════════════
Encryption key:      /HyMIxKFFE4ht3REm2YagNrLcG+TknXdw+RGEDVVE/8=  (Base64, 32 bytes)
Legacy ciphertext:   72 bytes (legacy wire format with inner base64 wrap)
Expected plaintext:  "SaQura test corpus 2026 fixture." (32 bytes)

STEP 1 — Regular DecryptWithAESAsync on legacy ciphertext
  Returned: "U2FRdXJhIHRlc3QgY29ycHVzIDIwMjYgZml4dHVyZS4="
  Matches expected: False  ← regular decrypt returns the UTF-8 bytes of the base64 string, NOT the original plaintext

STEP 2 — MigrateLegacyAESByteCiphertextAsync
  Recovered:        "SaQura test corpus 2026 fixture."  (32 bytes)
  Matches expected: True  ← migration recovers the original bytes ✓

STEP 3 — Re-encrypt with v1.0.8 wire format
  v1.0.8 ciphertext: 123 bytes
  Layout: [Nonce:12][CT:N][Tag:16] — byte-identical with Swift + Kotlin

STEP 4 — Verify v1.0.8 roundtrip
  Recovered:        "SaQura test corpus 2026 fixture."
  Matches expected: True  ← v1.0.8 byte[] AES roundtrips byte-identical ✓

STEP 5 — Migration helper rejects v1.0.8 ciphertext (defensive)
  CryptographicException thrown as expected  ← helper correctly refuses v1.0.8 input ✓
```

## What to look at

- `Program.cs` — every call you need for a production migration, with all the verification steps surfaced as separate sections.
- `ByteArrayMigration.csproj` — only `<PackageReference Include="SaQura" Version="1.0.10" />`.

## Need help?

If your migration fails or you have data that doesn't recover with the helper, email <support@kyototech.co.jp>.

**Never include encryption keys in support tickets.** A redacted small sample (≤ 1 KB) of the ciphertext + the original API call you used is enough for us to triage.
