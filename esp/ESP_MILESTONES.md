# ESP Milestones & Deliverables (Industry Standard)

## M1 — Ethereum Transaction Safety (Month 1–2)
**Objectives**
- Implement EIP‑1559 transaction construction for ETH and ERC‑20.
- Gas estimation + fee transparency in confirmation UI.
- Pre‑signing simulation and risk prompts.

**Deliverables**
- EIP‑1559 builder module (documented).
- Risk prompt UX flow + sample scenarios.
- Public documentation for simulation interface.

**Acceptance Criteria**
- ETH + ERC‑20 transfer successfully simulated and signed in testnet.
- Fee breakdown visible before signing.

---

## M2 — Security Hardening (Month 3–4)
**Objectives**
- Seed sharding recovery flow (Shamir) completed.
- Secure Enclave/Keychain hardening checklist finalized.
- Edge‑case handling (low balance, invalid nonce, RPC errors).

**Deliverables**
- Open‑sourced security module (seed sharding + vault).
- Security test plan & results summary.
- Recovery UX flow documentation.

**Acceptance Criteria**
- Recovery flow validated with test vectors.
- No regression in signing path under fault injection.

---

## M3 — Release Readiness (Month 5–6)
**Objectives**
- App Store‑ready build pipeline and metadata.
- External security assessment or review summary.
- Public open‑source release with usage docs.

**Deliverables**
- Release checklist completed.
- Audit summary (or third‑party review notes).
- OSS documentation + examples.

**Acceptance Criteria**
- Reproducible App Store build output.
- Public repo includes integration docs and license.
