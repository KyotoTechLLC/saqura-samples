# js/01-node-quickstart

Runs Gen8 post-quantum encryption, an ML-DSA signature, and an SQS1 stream
back-to-back. The 30-second tour of the JavaScript/TypeScript package
([`saqura`](https://www.npmjs.com/package/saqura)).

## Run

```bash
npm install
npm start
```

No environment variables needed — it runs on the Free tier.

> Requires **Node.js 18+**. The liboqs 0.15 WebAssembly engine is bundled in the
> package; nothing to compile.

## What to look at

- `index.mjs` — every call needed for a basic integration, heavily commented.
- `package.json` — the only dependency you need: `"saqura": "^0.1.0"`.

## What v0.1 covers

The v0.1 surface is intentionally minimal and post-quantum first:

- **Gen8** — hybrid X25519 + ML-KEM encryption (`gen8Encrypt` / `gen8Decrypt`).
- **Signatures** — ML-DSA / SLH-DSA (`signatureSign` / `signatureVerify`).
- **SQS1 streaming** — AES-256-GCM (`streamEncrypt` / `streamDecrypt`), byte-identical to the .NET, Kotlin and Swift SDKs.
- **License / tier** — `ApiLicense.activate()` plus capability queries.

Direct AES, RSA and password-hashing APIs arrive in v1.0.

## Unlock the paid tier

Point `SAQURA_LICENSE_PATH` at a `.lic` file you've purchased:

```bash
export SAQURA_LICENSE_PATH=/path/to/SaQura_Sample_pro.lic
npm start
```

`ApiLicense.activate()` verifies the license's RSA signature against the embedded
server public key and sets the tier from it. Note: client-side gating is
**advisory** — the crypto round-trips above already work on the Free tier; real
entitlement enforcement lives server-side (Crypto API + signed license).

## Expected output (Free tier)

```
SaQura — Node.js quickstart
===========================

Running on the Free tier (no license).
Set SAQURA_LICENSE_PATH=/path/to/SaQura_Sample_pro.lic to unlock full features.

--- Gen8 hybrid encryption (X25519 + ML-KEM) ---
Public key  : CAJzX+2Nzy…
Plaintext   : Hello from SaQura (post-quantum)!
Ciphertext  : +JECvxc8mJ…
Decrypted   : Hello from SaQura (post-quantum)!
Match       : true

--- ML-DSA signature ---
Signature        : AlZZ/HfZbf…
Verify (genuine) : true
Verify (tampered): false

--- SQS1 streaming (AES-256-GCM) ---
Plaintext bytes  : 44
Stream bytes     : 109
Decrypted (text) : A larger payload encrypted as a SQS1 stream.
Round-trip OK    : true

--- Tier & features ---
Licensed          : false
Current tier      : 0
AES available     : false
Quantum available : false
```

The crypto round-trips succeed on the Free tier; the `available` flags show what
activating a license would unlock.
