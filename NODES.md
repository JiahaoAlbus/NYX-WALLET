# Node / RPC Requirements

NYX WALLIET can use either self-hosted nodes or third-party RPC endpoints.

## Third-party RPC (recommended for now)
- PublicNode (BNB)
- PublicNode (Ethereum mainnet + Sepolia)
- Solana public RPC (mainnet + devnet)
- TronGrid (TRON mainnet + Shasta, requires API key)
- Blockstream public API (Bitcoin mainnet + testnet)

## Public RPC limits
- Solana public RPC endpoints are rate-limited and not recommended for production. Use them for development only.

## App configuration
Update the RPC URLs in `Sources/NYXCore/AppConfig.swift` or load them from secure config at runtime.

## Security
- Never expose RPC endpoints to the public internet without authentication.
- Use TLS and IP allowlists.
- Run nodes on isolated hosts.
