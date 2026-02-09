# Release Checklist

## WalletCore
- DONE: WalletCore binary artifacts download during build
- DONE: Coin types wired (Ethereum, BNB Smart Chain, Bitcoin, Solana, TRON)

## Transactions
- PARTIAL: EVM legacy transfer + ERC20 (fee estimation + fee transfer still TODO)
- PARTIAL: BTC SegWit P2WPKH + broadcast (UTXO selection + fee output TODO)
- PARTIAL: Solana SOL + SPL transfers (fee estimation + fee instruction TODO)
- PARTIAL: TRON TRX + TRC20 transfers (fee estimation + fee transfer TODO)
- DONE: USDT contracts per chain (ERC20/BEP20/TRC20/SPL)
- TODO: EIP-1559 typed transactions
 - TODO: Transaction simulation + preflight confirmation on-chain

## Swap
- DONE: 0x swap quote
- DONE: Jupiter swap quote
- TODO: Swap execution + transaction signing
 - TODO: Slippage controls + route fallback

## NFT
- DONE: OpenSea asset fetch
- DONE: Magic Eden asset fetch
- TODO: NFT buy/sell/transfer flows

## Fiat
- TODO: MoonPay KYB + production keys (UI placeholder)
 - TODO: PayEVM integration (API + webhook verify)

## App Store
- TODO: Privacy policy + terms of service
- TODO: App Store metadata + screenshots
 - TODO: App icons and marketing assets
 - TODO: App review notes + demo account (if required)

## Security & QA
 - TODO: External security review + penetration testing
 - TODO: Testnet end-to-end validation per chain
 - TODO: Edge cases (low balance, nonce gaps, invalid fees, RPC outages)
 - TODO: Recovery flows + loss scenarios (no recovery support)

## Signing & Distribution
 - TODO: Apple Developer Team ID + certificates
 - TODO: Provisioning profiles and app signing
 - TODO: App Store Connect build upload
