# NYX WALLIET

Secure, non-custodial iOS Web3 wallet.

## Project Description
NYX WALLIET is an iOS 17+ multi-chain wallet focused on local key security, non-custodial ownership, and production-ready transaction flows. It uses WalletCore for key derivation/signing, adds biometric gating and secret sharing, and provides swap/NFT read capabilities across EVM, Solana, BTC, and TRON.

## Status
NYX WALLIET is a complete iOS 17+ wallet application with end-to-end flows for:
- On-device key generation + secure vault
- Address derivation for ETH/BNB/BTC/SOL/TRON
- Send/receive with service fee display (1.5%) and hidden recipient address
- Transaction planning + risk checks
- Swap quotes (0x + Jupiter)
- NFT portfolio fetch (OpenSea + Magic Eden)

Some advanced features are intentionally left as integrations (see checklist), but the UI and services are wired for production replacement keys and paid nodes.

## Open in Xcode
1. Open `NYXWalletApp.xcodeproj` in Xcode 16.
2. Select the `NYXWalletApp_iOS` scheme.
3. Run on an iOS 17+ simulator/device.

## Features (Implemented)
- EVM (ETH/BNB), BTC, Solana, TRON
- USDT across supported chains
- Secure Enclave + Keychain
- WalletCore-based key derivation
- Biometric gating for signing
- Seed sharding (Shamir Secret Sharing)
- Transaction simulation and phishing detection
- 1.5% service fee shown on confirmation
- Swap quote aggregation (0x, Jupiter)
- NFT portfolio fetch (OpenSea, Magic Eden)

## Notes
- Service fee recipient address is not shown in UI. It remains on-chain and can be observed in explorers.
- No recovery/escrow. Loss of seed means permanent loss of access.

## RPC (Third-Party)
- Default config uses public RPC endpoints for mainnet and testnet with placeholders for API keys.
- Update `Sources/NYXCore/AppConfig.swift` with your provider endpoints and keys.

## API Keys
- 0x Swap API key is configured in `Sources/NYXCore/APIKeys.swift`
- Jupiter API key is configured in `Sources/NYXCore/APIKeys.swift`
- Magic Eden API key is configured in `Sources/NYXCore/APIKeys.swift`
- OpenSea API key is configured in `Sources/NYXCore/APIKeys.swift`
- MoonPay is not configured yet (KYB required)
- Temporary/public keys list: `PUBLIC_KEYS.md`
- Release checklist: `RELEASE_CHECKLIST.md`

## Xcode iOS App Project
A standard Xcode iOS app project is now available:
- Project: `NYXWalletApp.xcodeproj`
- App target: `NYXWalletApp`
- Info.plist: `NYXWalletApp/Info.plist`
- Entitlements: `NYXWalletApp/NYXWalletApp.entitlements`

## Release Build / IPA Export
1) Archive (unsigned if TEAM_ID not provided):
```
TEAM_ID=YOUR_TEAM_ID ./scripts/archive.sh
```

2) Export IPA (automatic signing):
```
TEAM_ID=YOUR_TEAM_ID METHOD=app-store-connect ./scripts/export_ipa.sh
```

Artifacts are written to `artifacts/`.

## Tests & Validation
- Build Swift package (compile all targets):
```
swift build
```

- Run unit tests (NYXCoreTests):
```
swift test
```

- Build iOS app for simulator (Xcode project):
```
xcodebuild -project NYXWalletApp.xcodeproj -scheme NYXWalletApp_iOS -destination "platform=iOS Simulator,name=iPhone 16" build
```

- Archive for release (requires Apple signing for distribution):
```
TEAM_ID=YOUR_TEAM_ID ./scripts/archive.sh
```

- One-step sign + export IPA:
```
TEAM_ID=YOUR_TEAM_ID ./scripts/sign_and_export.sh
```

- Capture simulator screenshots (requires Simulator to boot correctly):
```
./scripts/capture_screenshots.sh "iPhone 16"
```

## Not Yet Complete / Needs Real Credentials
- PayEVM (API endpoints + webhook signature verification + test/prod keys)
- Paid RPC providers for mainnet (currently public/placeholder endpoints)
- MoonPay on-ramp (KYB required)
- Production API keys for 0x, Jupiter, Magic Eden, OpenSea
- Final App Icons and marketing assets
- App Store signing and provisioning profiles (requires your Apple Team setup)

## Release Docs
- App Store metadata draft: `APP_STORE_METADATA.md`
- Privacy policy draft: `PRIVACY_POLICY.md`
- Terms of service draft: `TERMS_OF_SERVICE.md`
- Production key template: `PROD_KEYS_TEMPLATE.md`
- PayEVM integration placeholder: `PAYEVM_INTEGRATION.md`

## ESP Application Docs
- Summary: `esp/ESP_APPLICATION_SUMMARY.md`
- Milestones: `esp/ESP_MILESTONES.md`
- Budget: `esp/ESP_BUDGET.md`
- Open source plan: `esp/ESP_OPEN_SOURCE_PLAN.md`
