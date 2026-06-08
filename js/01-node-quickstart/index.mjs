import { readFile } from "node:fs/promises";
import { webcrypto as crypto } from "node:crypto";
import {
  ApiLicense,
  gen8GenerateKeyPair,
  gen8Encrypt,
  gen8Decrypt,
  QuantumStrength,
  signatureGenerateKeyPair,
  signatureSign,
  signatureVerify,
  SignatureAlgorithm,
  streamEncrypt,
  streamDecrypt,
} from "saqura";

// -----------------------------------------------------------------------------
// SaQura — Node.js quickstart (JavaScript/TypeScript SDK, v0.1)
//
// The v0.1 surface is intentionally minimal and post-quantum first:
//   1. (Optional) Activate a license — skip it to run on the Free tier.
//   2. Gen8 hybrid encryption (X25519 + ML-KEM).
//   3. ML-DSA / SLH-DSA signatures.
//   4. SQS1 streaming (AES-256-GCM).
//   5. Check tier / feature availability.
//
// Direct AES, RSA and password-hashing APIs arrive in v1.0. The wire formats
// here are byte-compatible with the .NET, Kotlin and Swift SDKs.
//
// Run:   npm install && npm start
// -----------------------------------------------------------------------------

const line = (s) => console.log(s);
const trunc = (s, n = 72) => (s.length <= n ? s : s.slice(0, n) + "…");
const b64 = (u8) => Buffer.from(u8).toString("base64");

line("SaQura — Node.js quickstart");
line("===========================\n");

// 1. (Optional) Activate a license. Point SAQURA_LICENSE_PATH at a .lic file
//    you purchased, or leave it unset to run on the Free tier.
const licensePath = process.env.SAQURA_LICENSE_PATH;
if (licensePath) {
  try {
    const licenseJson = await readFile(licensePath, "utf8");
    const result = await ApiLicense.activate(licenseJson);
    line(
      result.isValid
        ? `License activated → tier: ${ApiLicense.currentTier}\n`
        : `License activation failed (running Free): ${result.error ?? "invalid"}\n`,
    );
  } catch (err) {
    line(`Could not read license file (running Free): ${err.message}\n`);
  }
} else {
  line("Running on the Free tier (no license).");
  line("Set SAQURA_LICENSE_PATH=/path/to/SaQura_Sample_pro.lic to unlock full features.\n");
}

// 2. Gen8 — hybrid post-quantum encryption (X25519 + ML-KEM-1024 at Highest).
{
  line("--- Gen8 hybrid encryption (X25519 + ML-KEM) ---");
  const { publicKey, privateKey } = await gen8GenerateKeyPair(QuantumStrength.Highest);
  const plaintext = "Hello from SaQura (post-quantum)!";

  const { encapsulatedSecret, encryptedMessage } = await gen8Encrypt(plaintext, publicKey);
  const decrypted = await gen8Decrypt(encapsulatedSecret, privateKey, encryptedMessage);

  line(`Public key  : ${trunc(b64(publicKey))}`);
  line(`Plaintext   : ${plaintext}`);
  line(`Ciphertext  : ${trunc(b64(encryptedMessage))}`);
  line(`Decrypted   : ${decrypted}`);
  line(`Match       : ${decrypted === plaintext}\n`);
}

// 3. ML-DSA signatures (sign with the private key, verify with the public key).
{
  line("--- ML-DSA signature ---");
  const { publicKey, privateKey } = await signatureGenerateKeyPair(
    QuantumStrength.Highest,
    SignatureAlgorithm.MLDsa,
  );
  const message = new TextEncoder().encode("This message is authentic.");

  const signature = await signatureSign(message, privateKey);
  const okValid = await signatureVerify(message, signature, publicKey);

  const tampered = new TextEncoder().encode("This message is forged.");
  const okForged = await signatureVerify(tampered, signature, publicKey);

  line(`Signature        : ${trunc(b64(signature))}`);
  line(`Verify (genuine) : ${okValid}`);
  line(`Verify (tampered): ${okForged}\n`);
}

// 4. SQS1 streaming — AES-256-GCM, byte-identical across all SaQura SDKs.
{
  line("--- SQS1 streaming (AES-256-GCM) ---");
  const key = crypto.getRandomValues(new Uint8Array(32));
  const plaintext = new TextEncoder().encode("A larger payload encrypted as a SQS1 stream.");

  const blob = await streamEncrypt(plaintext, key);
  const decrypted = await streamDecrypt(blob, key);

  const roundTrips =
    Buffer.compare(Buffer.from(plaintext), Buffer.from(decrypted)) === 0;

  line(`Plaintext bytes  : ${plaintext.length}`);
  line(`Stream bytes     : ${blob.length}`);
  line(`Decrypted (text) : ${new TextDecoder().decode(decrypted)}`);
  line(`Round-trip OK    : ${roundTrips}\n`);
}

// 5. Tier / feature availability — query before relying on paid-tier features.
line("--- Tier & features ---");
line(`Licensed          : ${ApiLicense.isLicensed}`);
line(`Current tier      : ${ApiLicense.currentTier}`);
line(`AES available     : ${ApiLicense.isAESAvailable}`);
line(`Quantum available : ${ApiLicense.isQuantumAvailable}`);
