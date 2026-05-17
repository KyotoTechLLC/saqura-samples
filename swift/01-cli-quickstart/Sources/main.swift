import Foundation
import SaQura

// -----------------------------------------------------------------------------
// SaQura — Swift CLI quickstart
//
// Three things every integration does:
//   1. (Optional) Activate a license — skip this to try the Free tier.
//   2. Encrypt / decrypt / hash.
//   3. Check feature availability before calling paid-tier APIs.
//
// Run:  swift run
// -----------------------------------------------------------------------------

print("SaQura — Swift CLI quickstart")
print("=============================\n")

// 1. (Optional) Activate a license. Set SAQURA_LICENSE_PATH to a .lic file
//    you purchased, or leave unset to run on the Free tier.
if let path = ProcessInfo.processInfo.environment["SAQURA_LICENSE_PATH"],
   FileManager.default.fileExists(atPath: path) {
    let result = await ApiLicense.activateLicenseFile(path)
    if result.success {
        print("License activated → tier: \(ApiLicense.currentTier)\n")
    } else {
        print("License activation failed: \(result.message ?? "unknown error")\n")
    }
} else {
    print("Running on the Free tier (no license). Output will be watermarked.")
    print("Set SAQURA_LICENSE_PATH=/path/to/SaQura_Sample_distribution.lic to unlock full features.\n")
}

// 2. AES — symmetric encryption (Free tier: max 100 chars per call).
do {
    print("--- AES-256-GCM ---")
    let key       = AESKey.newKey()
    let plaintext = "Hello from SaQura!"
    let encrypted = try await plaintext.encryptWithAES(key: key)
    let decrypted = try await encrypted.decryptWithAES(key: key)

    print("Plaintext : \(plaintext)")
    print("Encrypted : \(truncate(encrypted, 80))")
    print("Decrypted : \(decrypted)")
    print("Match     : \(matchLabel(decrypted == plaintext))\n")
} catch {
    print("AES error: \(error)\n")
}

// 3. RSA — asymmetric encryption (Free tier: max 50 chars per call).
do {
    print("--- RSA-4096 ---")
    let (privateKey, publicKey) = try await RSAKey.newKeyPair()
    let plaintext = "Secret"
    let encrypted = try await plaintext.encryptWithRSA(publicKey: publicKey)
    let decrypted = try await encrypted.decryptWithRSA(privateKey: privateKey)

    print("Public key  : \(truncate(publicKey, 80))")
    print("Plaintext   : \(plaintext)")
    print("Encrypted   : \(truncate(encrypted, 80))")
    print("Decrypted   : \(decrypted)")
    print("Match       : \(matchLabel(decrypted == plaintext))\n")
} catch {
    print("RSA error: \(error)\n")
}

// 4. Password hashing — always available.
do {
    print("--- Password hashing (PBKDF2) ---")
    let password = "correct-horse-battery-staple"
    let hash     = try await password.hashPassword()
    let okRight  = try await password.verifyPassword(hash: hash)
    let okWrong  = try await "wrong-password".verifyPassword(hash: hash)

    print("Password          : \(password)")
    print("Hash              : \(truncate(hash, 80))")
    print("Verify (correct)  : \(okRight)")
    print("Verify (wrong)    : \(okWrong)\n")
} catch {
    print("Password hashing error: \(error)\n")
}

// 5. Feature gates.
print("--- Available features ---")
print("Licensed             : \(ApiLicense.isLicensed)")
print("AES available        : \(ApiLicense.isAESAvailable)")
print("RSA available        : \(ApiLicense.isRSAAvailable)")
print("Quantum available    : \(ApiLicense.isQuantumAvailable)")
print("Password hashing     : \(ApiLicense.isPasswordHashingAvailable)")

func truncate(_ s: String, _ max: Int) -> String {
    s.count <= max ? s : String(s.prefix(max)) + "…"
}

// On the Free tier, SaQura wraps the decrypted output in [UNLICENSED-…] tags,
// so the literal equality check fails even though the round-trip itself worked.
// Activating a license strips the wrapper and the match becomes true.
func matchLabel(_ matched: Bool) -> String {
    matched ? "true" : "false  (expected on Free tier — activate a license to strip the watermark)"
}
