# Test Inventory

> **Note:** This inventory documents all test files and their test cases, organized by contract or purpose.

## Contract-Specific Tests

### credit-controller.clar

**File:** `tests/credit-controller-pass.test.ts`
- `=== CREDIT CONTROLLER PASS - TRANSFER ===`

**File:** `tests/credit-controller-error.test.ts`
- `=== CREDIT CONTROLLER FAIL - ZERO AMOUNT ===`
- `=== CREDIT CONTROLLER FAIL - NOT TOKEN OWNER ===`
- `=== CREDIT CONTROLLER FAIL - INSUFFICIENT BALANCE ===`
- `=== CREDIT CONTROLLER FAIL - NOT CONTRACT OWNER ===`

**File:** `tests/credit-controller-read-only.test.ts`
- `=== GET CONTRACT OWNER ===`

**File:** `tests/credit-controller-loss-wallet1.test.ts`
- `=== CREDIT CONTROLLER LOSS TEST WALLET1 ===`

**File:** `tests/credit-controller-loss-wallet1-and-wallet2.test.ts`
- `=== CREDIT CONTROLLER LOSS TEST WALLET1 AND WALLET2 ===`

**File:** `tests/credit-controller-debug-1.test.ts`
- `=== CREDIT CONTROLLER DEBUG 1 ===`

**File:** `tests/credit-controller-debug-2.test.ts`
- `=== CREDIT CONTROLLER DEBUG 2 ===`

**File:** `tests/credit-controller-set-contract-owner.test.ts`
- `=== CREDIT CONTROLLER SET CONTRACT OWNER PASS ===`
- `=== ERR_NOT_CONTRACT_OWNER - CREDIT CONTROLLER ===`

### credit-token.clar

**File:** `tests/credit-burn.test.ts`
- `=== CREDIT BURN PASS ===`
- `=== ERR_ZERO_AMOUNT ===`
- `=== ERR_NOT_AUTHORIZED ===`

**File:** `tests/credit-mint.test.ts`
- `=== CREDIT MINT PASS ===`
- `=== ERR_ZERO_AMOUNT ===`
- `=== ERR_NOT_AUTHORIZED ===`

**File:** `tests/credit-token-set-token-uri.test.ts`
- `=== CREDIT SET TOKEN URI PASS ===`
- `=== ERR_NOT_CONTRACT_OWNER - CREDIT ===`

**File:** `tests/credit-token-set-contract-owner.test.ts`
- `=== CREDIT TOKEN SET CONTRACT OWNER PASS ===`
- `=== ERR_NOT_CONTRACT_OWNER - CREDIT TOKEN ===`

**File:** `tests/credit-token-read-only.test.ts`
- `=== GET BALANCE ===`
- `=== GET TOTAL SUPPLY ===`
- `=== GET CONTRACT OWNER ===`
- `=== GET DECIMALS ===`
- `=== GET NAME ===`
- `=== GET SYMBOL ===`
- `=== GET TOKEN URI ===`

### emission-controller.clar

**File:** `tests/emission-controller-pass.test.ts`
- `=== EMISSION CONTROLLER PASS ===`

**File:** `tests/emission-controller-error.test.ts`
- `=== EMISSION CONTROLLER FAIL - EMISSION INTERVAL ===`
- `=== EMISSION CONTROLLER FAIL - NOT ELIGIBLE ===`
- `=== EMISSION CONTROLLER FAIL - NO LIQUIDITY ===`

**File:** `tests/emission-controller-read-only.test.ts`
- `=== GET CURRENT EPOCH ===`
- `=== GET LAST MINT BLOCK ===`

**File:** `tests/emission-controller-set-contract-owner.test.ts`
- `=== EMISSION CONTROLLER SET CONTRACT OWNER PASS ===`
- `=== ERR_NOT_CONTRACT_OWNER - EMISSION CONTROLLER ===`

### street-controller.clar

**File:** `tests/street-controller-pass.test.ts`
- `=== STREET CONTROLLER TEST - PASS ===`

**File:** `tests/street-controller-error.test.ts`
- `=== STREET CONTROLLER TEST - FAIL - ALREADY MINTED===`
- `=== STREET CONTROLLER TEST - FAIL - YOU POOR ===`
- `=== STREET CONTROLLER TEST - FAIL - NO LIQUIDITY ===`

**File:** `tests/street-controller-error-mint-cap.test.ts`
- `=== STREET CONTROLLER TEST - FAIL - MINT CAP ===`

**File:** `tests/street-controller.read-only.test.ts`
- `=== GET CONTRACT OWNER ===`
- `=== GET STREET MINTED ===`

**File:** `tests/street-controller-set-contract-owner.test.ts`
- `=== STREET CONTROLLER SET CONTRACT OWNER PASS ===`
- `=== ERR_NOT_CONTRACT_OWNER - STREET CONTROLLER ===`

### street-market.clar

**File:** `tests/burn-liquidity-deployer-pass.test.ts`
- `=== BURN LIQUIDITY DEPLOYER PASS ===`

**File:** `tests/burn-liquidity-wallet1-pass.test.ts`
- `=== BURN LIQUIDITY WALLET1 PASS ===`

**File:** `tests/burn-liquidity-err-zero-amount.test.ts`
- `=== ERR_ZERO_AMOUNT ===`

**File:** `tests/burn-liquidity-donate-rewards.test.ts`
- `=== BURN LIQUIDITY DONATE REWARDS ===`

**File:** `tests/burn-liquidity-claim-rewards-debug-1.test.ts`
- `=== BURN LIQUIDITY CLAIM REWARDS DEBUG ===`

**File:** `tests/initial-liquidity-pass.test.ts`
- `=== INITIAL LIQUIDITY PASS ===`

**File:** `tests/initial-liquidity-errors.test.ts`
- `=== ERR_ZERO_AMOUNT - AMOUNT A ===`
- `=== ERR_ZERO_AMOUNT - AMOUNT B ===`
- `=== ERR_NOT_CONTRACT_OWNER ===`
- `=== ERR_ALREADY_INITIALIZED ===`

**File:** `tests/initial-liquidity-reinitialize.test.ts`
- `=== INITIAL LIQUIDITY REINITIALIZATION TEST ===`

**File:** `tests/lock-liquidity-pass.test.ts`
- `=== LOCK LIQUIDITY PASS ===`

**File:** `tests/lock-liquidity-errors.test.ts`
- `=== ERR_ZERO_AMOUNT ===`
- `=== ERR_NOT_INITIALIZED ===`

**File:** `tests/provide-liquidity-pass.test.ts`
- `=== PROVIDE LIQUIDITY PASS ===`

**File:** `tests/provide-liquidity-errors.test.ts`
- `=== ERR_ZERO_AMOUNT - AMOUNT A ===`
- `=== ERR_INSUFFICIENT_AVAILABLE_LIQUIDITY ===`
- `=== ERR_NOT_INITIALIZED ===`

**File:** `tests/provide-liquidity-preserve-rewards.test.ts`
- `=== PROVIDE LIQUIDITY PRESERVE REWARDS TEST ===`

**File:** `tests/remove-liquidity-pass.test.ts`
- `=== REMOVE LIQUIDITY PASS ===`

**File:** `tests/remove-liquidity-error.test.ts`
- `=== ERR_ZERO_AMOUNT ===`

**File:** `tests/remove-liquidity-rewards-debug-1.test.ts`
- `=== REMOVE LIQUIDITY REWARDS DEBUG TEST ===`

**File:** `tests/remove-liquidity-rewards-debug-2.test.ts`
- `=== REMOVE LIQUIDITY REWARDS DEBUG 2 TEST ===`

**File:** `tests/swap-a-b-pass.test.ts`
- `=== SWAP-A-B PASS ===`

**File:** `tests/swap-b-a-pass.test.ts`
- `=== SWAP-B-A PASS ===`

**File:** `tests/swap-errors.test.ts`
- `=== ERR_ZERO_AMOUNT - SWAP-A-B ===`
- `=== ERR_INVALID_AMOUNT - SWAP-A-B ===`
- `=== ERR_ZERO_AMOUNT - SWAP-B-A ===`
- `=== ERR_INVALID_AMOUNT - SWAP-B-A ===`

**File:** `tests/swap-lock-adjustment.test.ts`
- `=== PROPORTIONAL LOCKED ADJUSTMENT DURING LARGE SWAP ===`

**File:** `tests/liquidity-scenarios.test.ts`
- `=== INITIAL LIQUIDITY, REMOVAL ALL LIQUIDITY, PROVIDE LIQUIDITY, INITIAL LIQUIDITY ===`

**File:** `tests/street-market-read-only.test.ts`
- `=== GET BLOCKS PASS ===`
- `=== GET MARKET INFO ===`

**File:** `tests/get-market-info.test.ts`
- `=== GEt MARKET INFO PASS ===`

**File:** `tests/street-market-set-contract-owner.test.ts`
- `=== STREET MARKET SET CONTRACT OWNER PASS ===`
- `=== ERR_NOT_CONTRACT_OWNER - STREET MARKET ===`

### street-nft.clar

**File:** `tests/street-nft-mint-pass.test.ts`
- `=== STREET NFT MINT - MULTIPLE USERS PASS ===`

**File:** `tests/street-nft-mint-auth.test.ts`
- `=== STREET NFT MINT - UNAUTHORIZED DIRECT CALL FAIL ===`

**File:** `tests/street-nft-transfer.test.ts`
- `=== NFT TRANSFER PASS ===`
- `=== ERR_NOT_AUTHORIZED - NFT TRANSFER ===`
- `=== ERR_NOT_OWNER - NFT TRANSFER ===`
- `=== ERR_NOT_FOUND - NFT TRANSFER ===`

**File:** `tests/street-nft-set-functions.test.ts`
- `=== STREET NFT SET CONTRACT OWNER PASS ===`
- `=== ERR_NOT_CONTRACT_OWNER - NFT ===`
- `=== STREET NFT SET BASE URI PASS ===`
- `=== ERR_NOT_CONTRACT_OWNER - NFT BASE URI ===`

**File:** `tests/street-nft-read-only.test.ts`
- `=== GET NFT CONTRACT OWNER ===`
- `=== GET NFT TOKEN OWNER ===`
- `=== GET NFT TOKEN URI ===`
- `=== GET NFT BASE URI ===`
- `=== GET USER MINTED TOKENS ===`

### street-rewards.clar

**File:** `tests/claim-rewards-wallet1-pass.test.ts`
- `=== CLAIM REWARDS PASS ===`

**File:** `tests/cleanup-rewards-pass.test.ts`
- `=== CLEANUP REWARDS PASS ===`

**File:** `tests/cleanup-rewards-error.test.ts`
- `=== ERR_CLEANUP_INTERVAL (u955) ===`

**File:** `tests/cleanup-rewards-debug-1.test.ts`
- `=== CLEANUP REWARDS DEBUG 1 DEMONSTRATION ===`

**File:** `tests/cleanup-rewards-debug-2.test.ts`
- `=== CLEANUP REWARDS DEBUG 2 DEMONSTRATION ===`

**File:** `tests/get-cleanup-rewards-pass.test.ts`
- `=== GET CLEANUP REWARDS PASS ===`

**File:** `tests/donate-rewards.test.ts`
- `=== DONATE REWARDS BUG TEST ===`

**File:** `tests/decrease-rewards-debug.test.ts`
- `=== DECREASE REWARDS TEST ===`

**File:** `tests/increase-rewards-debug.test.ts`
- `=== INCREASE REWARDS TEST ===`

**File:** `tests/increase-decrease-rewards-debug-1.test.ts`
- `=== PROVIDE REMOVE LIQUIDITY REWARDS TEST ===`

**File:** `tests/increase-decrease-rewards-debug-2.test.ts`
- `=== PROVIDE TRANSFER LIQUIDITY REWARDS TEST ===`

**File:** `tests/update-rewards-a.test.ts`
- `=== UPDATE REWARDS A PASS ===`
- `=== ERR_NOT_AUTHORIZED ===`
- `=== ERR_ZERO_AMOUNT ===`

**File:** `tests/update-rewards-b.test.ts`
- `=== UPDATE REWARDS B PASS ===`
- `=== ERR_NOT_AUTHORIZED ===`
- `=== ERR_ZERO_AMOUNT ===`

**File:** `tests/rewards-read-only.test.ts`
- `=== GET REWARD POOL INFO ===`
- `=== GET REWARD USER INFO ===`

**File:** `tests/street-rewards-set-contract-owner.test.ts`
- `=== STREET REWARDS SET CONTRACT OWNER PASS ===`
- `=== ERR_NOT_CONTRACT_OWNER - STREET REWARDS ===`

### street-token.clar

**File:** `tests/street-token-initial-mint.test.ts`
- `=== STREET TOKEN INITIAL MINT PASS ===`
- `=== VERIFY TOTAL SUPPLY ===`

**File:** `tests/street-token-set-token-uri.test.ts`
- `=== STREET SET TOKEN URI PASS ===`
- `=== ERR_NOT_CONTRACT_OWNER - STREET ===`

**File:** `tests/street-token-transfer-pass.test.ts`
- `=== STREET TRANSFER PASS ===`

**File:** `tests/street-token-transfer-error.test.ts`
- `=== ERR_ZERO_AMOUNT (u961) ===`
- `=== ERR_NOT_TOKEN_OWNER (u963) ===`

**File:** `tests/street-mint-auth.test.ts`
- `=== STREET MINT AUTH 1 ===`
- `=== STREET MINT AUTH 2 ===`
- `=== STREET MINT AUTH 3 ===`

**File:** `tests/street-token-set-contract-owner.test.ts`
- `=== STREET TOKEN SET CONTRACT OWNER PASS ===`
- `=== ERR_NOT_CONTRACT_OWNER - STREET TOKEN ===`

**File:** `tests/street-token-read-only.test.ts`
- `=== GET TOTAL SUPPLY ===`
- `=== GET CONTRACT OWNER ===`
- `=== GET DECIMALS ===`
- `=== GET NAME ===`
- `=== GET SYMBOL ===`
- `=== GET NAME ===`
- `=== GET SYMBOL ===`
- `=== GET TOKEN URI ===`

### welsh-faucet.clar

**File:** `tests/welsh-faucet-request-pass.test.ts`
- `=== FAUCET REQUEST - FIRST TIME (NO COOLDOWN) ===`

**File:** `tests/welsh-faucet-request-error.test.ts`
- `=== FAUCET REQUEST FAILS DUE TO COOLDOWN ===`

**File:** `tests/welsh-faucet-cooldown-pass.test.ts`
- `=== SET COOLDOWN AND REQUEST RESPECTING COOLDOWN ===`

**File:** `tests/welsh-faucet-read-only.test.ts`
- `=== GET FAUCET BALANCE AND COOLDOWN ===`
- `=== GET LAST AND NEXT REQUEST (NO PRIOR REQUEST) ===`

**File:** `tests/welsh-faucet-set-contract-owner.test.ts`
- `=== WELSH FAUCET SET CONTRACT OWNER PASS ===`
- `=== ERR_NOT_CONTRACT_OWNER - WELSH FAUCET ===`

## Setup Tests

**File:** `tests/setup-initial-liquidity.test.ts`
- `=== SETUP INITIAL LIQUIDITY PASS ===`

**File:** `tests/setup-user-deployer.test.ts`
- `=== SETUP USER DEPLOYER PASS ===`

**File:** `tests/setup-user-wallet.test.ts`
- `=== SETUP USER WALLET PASS ===`

**File:** `tests/setup-liquidity-users.test.ts`
- `=== SETUP LIQUIDITY USER PASS ===`

## Shared/Generic Tests

**File:** `tests/shared-read-only.test.ts`
- `=== GET BALANCE PRINCIPAL ===`
- `=== GET BLOCKS PASS ===`
- `=== GET MARKET INFO ===`

## Other Tests

**File:** `tests/mine-burn-block.test.ts`
- `=== MINE BURN BLOCK PASS ===`
- `=== MINE BURN BLOCK FAIL ===`

## Test File Summary

**Total Test Files:** 85
**Total Tests:** 154

**By Contract:**
- credit-controller: 8 files, 12 tests
- credit-token: 5 files, 17 tests
- emission-controller: 4 files, 8 tests
- street-controller: 5 files, 9 tests
- street-market: 25 files, 35 tests
- street-nft: 5 files, 15 tests
- street-rewards: 15 files, 21 tests
- street-token: 7 files, 20 tests
- welsh-faucet: 5 files, 7 tests

**Other:**
- Setup: 4 files, 4 tests
- Shared: 1 file, 3 tests
- Other: 1 file, 2 tests

## Test Naming Conventions

- **PASS** - Successful execution tests
- **FAIL/ERROR** - Error condition tests
- **DEBUG** - Debugging/investigation tests (should observe behavior, not assert)
- **READ ONLY** - Read-only function tests
- Test names use `===` markers for clear console output visibility
- Error tests specifically name the error constant being tested (e.g., `ERR_ZERO_AMOUNT`)
