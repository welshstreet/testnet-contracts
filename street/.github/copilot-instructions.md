# copilot instructions

## initial state from `setup-liquidity-users-helper-function.ts`

```ts
// STEP 1: Setup environment with multi-user liquidity state
let { marketData, rewardData, supplyData, userData } = setupLiquidityUsers(disp);
```

```console
=== SETUP LIQUIDITY USER SUMMARY ===
Market Data:
  Avail A: 10000200000000
  Avail B: 1000020000000000
  Fee: 100
  Locked A: 0
  Locked B: 0
  Reserve A: 10000200000000
  Reserve B: 1000020000000000
  Tax: 100
Reward Data:
  Global Index A: 1499964999
  Global Index B: 0
  Rewards A: 3000000000
  Rewards B: 0
Supply Data:
  STREET: 2000300000000000
  CREDIT: 3000000000
=== DEPLOYER ===
Address: ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
Balances:
  WELSH: 9985999000000000
  STREET: 1000100000000000
  CREDIT: 1000000000
Reward User Info:
  Balance: 1000000000
  Block: 12
  Debt A: 0
  Debt B: 0
  Index A: 1499935000
  Index B: 0
  Unclaimed A: 29999
  Unclaimed B: 0
=== WALLET1 ===
Address: ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5
Balances:
  WELSH: 1998900000000
  STREET: 90000000000
  CREDIT: 1000000000
Reward User Info:
  Balance: 1000000000
  Block: 8
  Debt A: 0
  Debt B: 0
  Index A: 20000
  Index B: 0
  Unclaimed A: 1499944999
  Unclaimed B: 0
=== WALLET2 ===
Address: ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
Balances:
  WELSH: 1998900000000
  STREET: 90000000000
  CREDIT: 1000000000
Reward User Info:
  Balance: 1000000000
  Block: 11
  Debt A: 0
  Debt B: 0
  Index A: 29999
  Index B: 0
  Unclaimed A: 1499935000
  Unclaimed B: 0
```

## State Management Guide for Smart Contract Tests

**Core Principle:** Treat test variables as a living mirror of on-chain state. Use `let` for any value derived from or tracking contract state.

### Rules: `const` vs `let`

**Use `const` for fixed configuration only:**
```typescript
const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const DONATE_AMOUNT = 1_000_000_000;
```

**Use `let` for everything derived from contract state:**
```typescript
let wallet1RewardInfo = userData.wallet1.rewardUserInfo;  // State reference
let globalIndexA = Number(poolInfo["global-index-a"].value);        // Chain read
let wallet1LpBalance = wallet1RewardInfo.balance;                   // Derived value
let expectedLpMinted = Math.floor((amount * supply) / reserves);    // Calculation
```

### The Pattern: Canonical State Variables

Maintain **one canonical variable per state concept** and reassign it after mutations:

```typescript
// STEP 1: Initialize mutable state
let { marketData, rewardData, supplyData, userData } = setupLiquidityUsers(disp);

// STEP 2: Track user reward state across operations
let wallet1RewardInfo = userData.wallet1.rewardUserInfo;

claimRewards(wallet1RewardInfo.unclaimedA, wallet1RewardInfo.unclaimedB, wallet1);
updateUserRewards(userData, deployer, wallet1, wallet2, disp);  // Sync from chain

// STEP 3: Track LP balance
let wallet1LpBalance = wallet1RewardInfo.balance;
burnLiquidity(wallet1LpBalance, wallet1, disp);
supplyData.credit -= wallet1LpBalance;  // Update in place
updateUserRewards(userData, deployer, wallet1, wallet2, disp);

// STEP 4: Track pool state across multiple reads
let rewardPoolInfo = simnet.callReadOnlyFn("street-rewards", "get-reward-pool-info", [], deployer);
let poolValue = (rewardPoolInfo.result as any).value.value;
let globalIndexA = Number(poolValue["global-index-a"].value);
let globalIndexB = Number(poolValue["global-index-b"].value);

// STEP 5: Reassign same variables after state change
provideLiquidity(amount, expectedB, expectedLp, wallet1, disp);
supplyData.credit += expectedLp;  // Update in place
updateUserRewards(userData, deployer, wallet1, wallet2, disp);

// STEP 6: Reread pool state using same variables
rewardPoolInfo = simnet.callReadOnlyFn("street-rewards", "get-reward-pool-info", [], deployer);
poolValue = (rewardPoolInfo.result as any).value.value;
globalIndexA = Number(poolValue["global-index-a"].value);  // Reused name!
globalIndexB = Number(poolValue["global-index-b"].value);  // Always current

// STEP 7: Refresh user state reference
wallet1RewardInfo = userData.wallet1.rewardUserInfo;  // Same variable, fresh data
```

### Anti-Pattern: Snapshot Proliferation

❌ **Don't create naming nightmares:**
```typescript
const poolAfterBurn = simnet.callReadOnlyFn(...);
const poolAfterDonation = simnet.callReadOnlyFn(...);  // Which is current?
```

✅ **Reassign, don't proliferate:**
```typescript
let rewardPoolInfo = simnet.callReadOnlyFn(...);
// ... operation ...
rewardPoolInfo = simnet.callReadOnlyFn(...);  // Refresh - always clear what's current
```

### Summary

- **`let`** = "Tracks mutable blockchain state"
- **`const`** = "Fixed configuration only"
- **One variable per concept** - reuse names across steps
- **Reassign, don't proliferate** - no `AfterX` suffixes

**Key Principles:**
- ✅ **Accept state objects**: Functions receive full `rewardData` and `userData` objects
- ✅ **Extract with `let`**: Pull values into mutable variables for clarity
- ✅ **Reassign, don't redeclare**: Update variables with `=`, not `const` or `let`
- ✅ **Comment pass-through**: Mark unchanged values with `// Unchanged` for clarity
- ✅ **Return full structure**: Include both modified and unmodified state
- ✅ **Destructure assignment**: Use `({ rewardData, userData } = ...)` to update multiple objects

This pattern eliminates redundancy and creates a single source of truth for global state.

## CRITICAL: `updateUserRewards()` Usage Restriction

⚠️ **`updateUserRewards()` is ONLY for debug test files** (files containing `*debug*` in the name).

### Debug Tests (files with `*debug*`):
```typescript
// ✅ ALLOWED in debug test files
let { marketData, rewardData, supplyData, userData } = setupLiquidityUsers(disp);

claimRewards(wallet1RewardInfo.unclaimedA, wallet1RewardInfo.unclaimedB, wallet1);
updateUserRewards(userData, deployer, wallet1, wallet2, disp);  // ✅ OK in debug tests

burnLiquidity(wallet1LpBalance, wallet1, disp);
updateUserRewards(userData, deployer, wallet1, wallet2, disp);  // ✅ OK in debug tests
```

### Regular Tests (files WITHOUT `*debug*`):
```typescript
// ❌ FORBIDDEN: Do NOT use updateUserRewards() in regular tests
// ✅ REQUIRED: Manually calculate state updates

let { marketData, rewardData, supplyData, userData } = setupLiquidityUsers(disp);

// STEP 2: After burning liquidity
burnLiquidity(deployerLpBalance, deployer, disp);

// ✅ Manually calculate new global index from redistribution
totalLpSupply = wallet1LpBalance + wallet2LpBalance;
let deployerRedistributionA = Math.floor((deployerUnclaimedA * PRECISION) / totalLpSupply);
globalIndexA = globalIndexA + deployerRedistributionA;

// STEP 3: After donating rewards
donateRewards(DONATE_WELSH, DONATE_STREET, deployer, disp);

// ✅ Manually calculate new global index from donation
globalIndexA = globalIndexA + Math.floor((DONATE_WELSH * PRECISION) / totalLpSupply);
globalIndexB = globalIndexB + Math.floor((DONATE_STREET * PRECISION) / totalLpSupply);

// ✅ Manually calculate user unclaimed
let wallet1UnclaimedA = Math.floor((wallet1LpBalance * (globalIndexA - wallet1UserIndexA)) / PRECISION) - wallet1DebtA;
```

**Rationale:**
- **Debug tests** observe contract behavior and verify correctness using direct chain reads
- **Regular tests** verify the test logic itself matches expected calculations
- Using `updateUserRewards()` in regular tests would make them circular - reading from chain instead of testing our understanding of the math