# Roadmap

Next steps for building a **fiat-backed stablecoin**.

---
## 1. Build a Basic ERC-20 Token First
Replace the Counter contract with a proper ERC-20 implementation:

**Changes needed:**
- Install OpenZeppelin contracts: `forge install OpenZeppelin/openzeppelin-contracts`
- Create `src/FiatStablecoin.sol` with basic ERC-20 functionality (name, symbol, decimals)
- Add mint/burn functions with access control (only owner can mint initially)
- Update your deployment script to deploy the stablecoin instead of Counter

**Key concepts to implement:**
- `_mint()` and `_burn()` internal functions
- `onlyOwner` modifier using OpenZeppelin's Ownable
- Proper decimals (use 6 for USD-pegged, matching USDC)


---
## 2. Add Reserve Tracking
This is crucial for fiat-backed stablecoins - you need to track reserves:

**Add to your contract:**
- A `reserveBalance` state variable (tracks fiat deposits)
- Events: `ReserveDeposited`, `ReserveWithdrawn`
- Functions: `depositReserve()` and `withdrawReserve()` (owner only)
- Ensure: only mint tokens when reserves are deposited first


---
## 3. Create Mint/Redeem Flow
**Add two key functions:**
- `mintWithReserve(address to, uint256 amount)` - mints tokens only if reserves >= total supply
- `redeemForReserve(uint256 amount)` - burns tokens and marks reserves for withdrawal

**Add a collateralization check:**
- Function to verify reserves >= outstanding token supply (should always be true)


---
## Practical Implementation Details


1. ERC-20 implementation + tests
1. Add reserve tracking + basic mint/burn with reserve checks
1. Write comprehensive tests for mint/redeem flows
1. Add role-based access control (separate minter/redeemer roles)
1. Implement pause/unpause functionality (for emergencies)
1. Add events and create basic monitoring
