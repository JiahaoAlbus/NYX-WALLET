# Ethereum Foundation ESP Application (Industry-Standard Draft)

## Project Title
NYX WALLIET

## Category
Wallets / UX & Safety / Developer Tooling

## One‑Sentence Summary
NYX WALLIET is an iOS 17+ non‑custodial wallet focused on Ethereum safety, delivering secure local key management, transaction simulation/risk warnings, and transparent fees, with key modules released as open source.

## Problem Statement
Most mobile wallets still lack consistent, user‑facing transaction risk warnings, reliable simulation before signing, and reproducible open‑source security components. These gaps reduce user safety and trust in Ethereum on mobile.

## Proposed Solution
Build a production‑ready iOS wallet for Ethereum with:
- Secure on‑device key handling (Secure Enclave + Keychain).
- Transaction simulation and risk prompts before signing.
- Transparent fee disclosure (including service fee display in the confirmation flow).
- Open‑sourced modules for transaction building, risk detection, and seed sharding.

## Ethereum Ecosystem Impact
- Improves UX safety for Ethereum users on iOS.
- Provides reusable open‑source components for other wallets or integrators.
- Creates standardized patterns for fee disclosure and risk prompts.

## Current Status
- iOS prototype complete with multi‑chain support and Ethereum flows.
- Risk engine + phishing detection framework implemented.
- Release pipeline and documentation prepared.

## Deliverables (High‑Level)
- EIP‑1559 transaction builder + ERC‑20 support.
- Transaction simulation and risk warning framework.
- Seed sharding implementation + recovery flow.
- Public open‑source repository + documentation.
- Security review summary or third‑party assessment.

## Timeline
See `esp/ESP_MILESTONES.md`

## Budget
See `esp/ESP_BUDGET.md`

## Open Source
See `esp/ESP_OPEN_SOURCE_PLAN.md`

## Team
Small engineering team (2–3) with iOS, blockchain integration, and security focus.

## Links
- GitHub: https://github.com/JiahaoAlbus/NYX-WALLET

## Contact
- Email: support@nyxwallet.app
