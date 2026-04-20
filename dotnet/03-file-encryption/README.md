# dotnet/03-file-encryption

Round-trip a file through AES-256-GCM. The key goes to its own file, so you can rotate or share it independently of the ciphertext.

## Run

```bash
# Encrypt
echo "top secret" > plain.txt
dotnet run -- encrypt plain.txt cipher.saq
# → writes cipher.saq and cipher.saq.key

# Decrypt
dotnet run -- decrypt cipher.saq recovered.txt cipher.saq.key
diff plain.txt recovered.txt   # empty — round-trip succeeded
```

## Keep the key safe

The `.key` file is the only thing that can decrypt your ciphertext. If you lose it, the data is gone — KyotoTech cannot recover it. Typical strategies:

- Store keys in a secrets manager (Azure Key Vault, AWS Secrets Manager, HashiCorp Vault).
- For per-user data, encrypt the AES key with the user's public RSA key and store the wrapped key alongside the ciphertext.
- For at-rest backups, write keys to a separate, access-restricted medium.

## Free tier limit

Without a license, AES input is capped at **100 characters per call**. That's fine for configuration values and short secrets but not for files of arbitrary size. Activate a license (see [`dotnet/02-license-activation`](../02-license-activation)) to lift the cap.

For large files on a paid tier, consider encrypting chunks rather than the entire file in one pass — AES-GCM has a per-nonce safety budget that caps a single encryption around 64 GB.
