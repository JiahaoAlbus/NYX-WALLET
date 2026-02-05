# Security Model

## Non-custodial only
- Private keys and seed remain on-device.
- No backend has access to keys or recovery material.
- Loss of seed means irreversible loss of access.

## Key storage
- Secure Enclave key pair
- Seed is encrypted with the Secure Enclave public key and stored in Keychain
- Private key operations gated by biometrics

## Seed sharding
- Target: Shamir Secret Sharing (t-of-n)
- Shards never leave the device unless user exports them manually

## Transaction security
- Pre-sign simulation
- Phishing detection (denylist + heuristics)
- Risk scoring and user warnings

## Fee transparency
- Service fee rate displayed as 1.5%
- Fee recipient address not displayed in UI
- All fee transfers are on-chain and can be independently verified
