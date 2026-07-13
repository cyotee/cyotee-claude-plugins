# permit2

Progressive disclosure skills for Uniswap Permit2 - signature-based token approvals, AllowanceTransfer, SignatureTransfer, nonce management, and wagmi integration

## Skills

| Skill | Description |
|-------|-------------|
| `permit2-addresses` | Canonical Permit2 contract addresses by chain. Use when configuring multi-chain support. |
| `permit2-allowance-flow` | Complete approval flow with reset-to-zero pattern. Use when implementing full ERC20 and Permit2 approval workflow. |
| `permit2-allowance-transfer` | Uses AllowanceTransfer for persistent token approvals. Use when user grants recurring spend authority to the protocol. |
| `permit2-nonce-management` | Bitmap nonce patterns for Permit2 signature replay protection. Use when generating nonces for SignatureTransfer permits. |
| `permit2-router-witness` |  |
| `permit2-sdk` | Uniswap Permit2 SDK for gasless token transfers in IndexedEx. Use when implementing swap/deposit/withdraw with signature |
| `permit2-signature-transfer` | Uses permitWitnessTransferFrom for gasless token transfers with EIP-712 signatures. Use when implementing swap/deposit/w |
| `permit2-signature-transfer-contract` | Solidity contract implementation for permitWitnessTransferFrom. Use when writing Solidity contracts that receive Permit2 |
| `permit2-types` | TypeScript type references for Permit2 SDK. Use when writing TypeScript code with Permit2. |
| `permit2-wagmi-integration` | Integration patterns for Permit2 with wagmi hooks. Use when building UI components that interact with Permit2. |

## Installation

```bash
# Claude Code
/plugin install permit2@cyotee
```

## License

MIT
