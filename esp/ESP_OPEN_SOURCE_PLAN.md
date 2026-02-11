# Open‑Source Plan (Industry Standard)

## Scope
Open‑source the Ethereum‑focused modules:
- EIP‑1559 transaction builder + ERC‑20 transfer helpers
- Transaction simulation interface + risk prompts
- Seed sharding (Shamir) + recovery flow
- Phishing/risk detection framework

## Repository Structure
- `Sources/NYXChains` — EVM transaction building
- `Sources/NYXRisk` — risk engine and prompts
- `Sources/NYXSecurity` — key management + sharding

## License
Apache‑2.0 (preferred) or MIT (final choice before release)

## Documentation Deliverables
- Usage guide with code examples
- Integration notes for other wallets
- Threat model summary for security module

## Security Policy
- Public SECURITY.md and disclosure email
- Coordinated disclosure process and timeline

## Release Plan
- Tag stable releases aligned with milestones
- Provide changelog and upgrade notes
