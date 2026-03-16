# Helper Function Inventory

> **Note:** This inventory documents all helper functions used for testing contracts. Functions are grouped by their associated contract, purpose, or category.

## Contract-Specific Helper Functions

### credit-controller.clar
**File:** `tests/functions/credit-controller-helper-functions.ts`
- `transferCredit(amount, sender, recipient, caller, memo?, disp?)` - Transfer credit tokens via credit-controller

### credit-token.clar
**File:** `tests/functions/credit-token-helper-functions.ts`

-functions.ts`
- `creditBurn(amountExpected, sender, disp?)` - Burn credit tokens
- `creditMint(amountExpected, sender, disp?)` - Mint credit tokens

### emission-controller.clar
**File:** `tests/functions/emission-controller-helper-functions.ts`
- `emissionMint(amountExpected, blockExpected, epochExpected, caller, disp?)` - Mint STREET via emission controller
- `getCurrentEpoch(expectedEpoch, disp?)` - Get current emission epoch
- `getLastBurnBlock(expectedLastBurnBlock, disp?)` - Get last burn block height
- `getLastWinner(disp?)` - Get last emission winner

### street-controller.clar
**File:** `tests/functions/street-controller-helper-functions.ts`
- `streetMint(amountAExpected, amountBExpected, blockExpected, countExpected, caller, disp?)` - Mint STREET tokens by donating WELSH
- `getMintCount(disp?)` - Get total number of STREET mints

### street-market.clar
**File:** `tests/functions/street-market-helper-functions.ts`
- `burnLiquidity(amountLp, sender, disp?)` - Burn LP tokens (redistributes to reward pool)
- `lockLiquidity(amountA, lockedBExpected, sender, disp?)` - Lock liquidity for initial setup
- `initialLiquidity(amountA, amountB, mintedLpExpected, sender, disp?)` - Provide initial liquidity
- `provideLiquidity(amountA, amountBExpected, mintedLpExpected, sender, disp?)` - Add liquidity to pool
- `removeLiquidity(amountLp, taxAExpected, taxBExpected, userAExpected, userBExpected, sender, disp?)` - Remove liquidity from pool
- `swapAB(amountA, amountBExpected, feeAExpected, resAExpected, resANewExpected, resBExpected, resBNewExpected, sender, disp?)` - Swap WELSH for STREET
- `swapBA(amountB, amountAExpected, feeBExpected, resAExpected, resANewExpected, resBExpected, resBNewExpected, sender, disp?)` - Swap STREET for WELSH
- `getBlocks(sender, disp?)` - Get block information
- `getMarketInfo(availAExpected, availBExpected, feeExpected, lockedAExpected, lockedBExpected, reserveAExpected, reserveBExpected, taxExpected, sender, disp?)` - Get market state

### street-nft.clar
**File:** `tests/functions/street-nft-helper-functions.ts`
- `nftMint(tokenId, recipient, caller, disp?)` - Mint NFT token
- `nftTransfer(tokenId, sender, recipient, caller, disp?)` - Transfer NFT token
- `setNftContractOwner(newOwner, caller, disp?)` - Set NFT contract owner
- `setNftBaseUri(newUri, caller, disp?)` - Set NFT base URI
- `getNftContractOwner(disp?)` - Get NFT contract owner
- `getNftOwner(tokenId, disp?)` - Get NFT token owner
- `getNftTokenUri(tokenId, expectedUri, disp?)` - Get NFT token URI
- `getNftBaseUri(expectedUri, disp?)` - Get NFT base URI
- `getUserMintedTokens(user, disp?)` - Get list of tokens minted by user

### street-rewards.clar
**File:** `tests/functions/street-rewards-helper-functions.ts`
- `claimRewards(amountAExpected, amountBExpected, sender, disp?)` - Claim accumulated rewards
- `cleanupRewards(amountAExpected, amountBExpected, sender, disp?)` - Cleanup and redistribute stale rewards
- `donateRewards(amountA, amountB, sender, disp?)` - Donate tokens to reward pool
- `emissionRewards(rewards, totalLp, sender, disp?)` - Update rewards from emission (called by emission-controller)
- `updateRewardsA(amount, sender, disp?)` - Update WELSH rewards pool
- `updateRewardsB(amount, sender, disp?)` - Update STREET rewards pool
- `getCleanupRewards(actualAExpected, actualBExpected, claimedAExpected, claimedBExpected, cleanupAExpected, cleanupBExpected, distributedAExpected, distributedBExpected, outstandingAExpected, outstandingBExpected, sender, disp?)` - Get cleanup reward data
- `getRewardPoolInfo(globalIndexAExpected, globalIndexBExpected, rewardsAExpected, rewardsBExpected, sender, disp?)` - Get global reward pool state
- `getRewardUserInfo(user, balanceExpected, blockExpected, debtAExpected, debtBExpected, indexAExpected, indexBExpected, unclaimedAExpected, unclaimedBExpected, sender, disp?)` - Get user reward state
- `updateBurnRewards(user, oldBalance, sender, disp?)` - Update rewards after burning LP tokens
- `updateCreditSender(sender, transferAmount, caller, disp?)` - Update sender rewards on credit transfer
- `updateCreditRecipient(recipient, transferAmount, caller, disp?)` - Update recipient rewards on credit transfer

### street-token.clar
**File:** `tests/functions/street-token-helper-functions.ts`
- `emissionMint(amount, recipient, caller, disp?)` - Mint STREET via emission controller
- `streetMint(amount, recipient, caller, disp?)` - Mint STREET tokens
- `setTokenUri(uri, caller, disp?)` - Set token URI
- `transfer(amount, sender, recipient, caller, memo?, disp?)` - Transfer STREET tokens

### welsh-faucet.clar
**File:** `tests/functions/welsh-faucet-helper-functions.ts`
- `requestFaucet(sender, disp?)` - Request WELSH from faucet
- `setFaucetContractOwner(newOwner, sender, disp?)` - Set faucet contract owner
- `setFaucetCooldown(blocks, sender, disp?)` - Set faucet cooldown period
- `getFaucetBalance(balanceExpected, sender, disp?)` - Get faucet WELSH balance
- `getFaucetCooldown(cooldownExpected, sender, disp?)` - Get faucet cooldown setting
- `getLastRequest(blockExpected, user, sender, disp?)` - Get user's last faucet request block
- `getNextRequest(blocksRemainingExpected, user, sender, disp?)` - Get blocks until user can request again
- `getFaucetInfo(blocksRemainingExpected, cooldownExpected, lastRequestExpected, user, sender, disp?)` - Get complete faucet info for user

### welshcorgicoin.clar
**File:** `tests/functions/welshcorgicoin-helper-functions.ts`
- `transfer(amount, sender, recipient, caller, memo?, disp?)` - Transfer WELSH tokens

## Shared Helper Functions

### Shared Set Functions
**File:** `tests/functions/shared-set-helper-functions.ts`
- `setContractOwner(contract, newOwner, caller, disp?)` - Set contract owner (works with any contract)

### Shared Read-Only Functions
**File:** `tests/functions/shared-read-only-helper-functions.ts`
- `getBalance(balanceExpected, token, who, sender, disp?)` - Get token balance (works with any SIP-010 token)
- `getContractOwner(contractOwnerExpected, token, sender, disp?)` - Get contract owner (generic)
- `getDecimals(decimalsExpected, token, sender, disp?)` - Get token decimals
- `getName(nameExpected, token, sender, disp?)` - Get token name
- `getSymbol(symbolExpected, token, sender, disp?)` - Get token symbol
- `getTokenUri(tokenUriExpected, token, sender, disp?)` - Get token URI
- `getTotalSupply(totalSupplyExpected, token, sender, disp?)` - Get token total supply

### Generic Transfer Function
**File:** `tests/functions/transfer-helper-function.ts`
- `transfer(amount, contract, sender, recipient, disp?)` - Generic transfer for multiple token contracts

### Token URI Setter
**File:** `tests/functions/set-token-uri-helper-functions.ts`
- `setTokenUri(contract, tokenUri, sender, disp?)` - Set token URI for credit-token or street-token

## Setup Helper Functions

### Initial Liquidity Setup
**File:** `tests/functions/setup-initial-liquidity-helper-function.ts`
- `setupInitialLiquidity(disp?)` - Setup initial liquidity pool state with deployer

### Multi-User Liquidity Setup
**File:** `tests/functions/setup-liquidity-users-helper-function.ts`
- `setupLiquidityUsers(disp?)` - Setup complete test environment with deployer, wallet1, and wallet2

### User-Specific Setup
**File:** `tests/functions/setup-user-deployer-helper-function.ts`
- `setupUserDeployer(rewardData, userData, disp?, burnBlockHeight?)` - Setup deployer with STREET mint and rewards

**File:** `tests/functions/setup-user-wallet-helper-function.ts`
- `setupUserWallet(account, rewardData, userData, disp?, burnBlockHeight?, epochOverride?)` - Setup wallet user with WELSH transfer, STREET mint, and liquidity

## Other Helper Functions

### Blockchain Utilities
**File:** `tests/functions/mine-burn-block-helper-function.ts`
- `mineBurnBlock(blockExpected, disp?)` - Mine an empty burn block

### Contract Interaction
**File:** `tests/functions/transformer-helper-function.ts`
- `transformer(tokenContract, amount, recipient, sender, disp?)` - Call street-market transformer (internal token transfer helper)

### Test Utilities
**File:** `tests/functions/utility-helper-functions.ts`
- `getSupplyData(streetExpected, creditExpected, disp?)` - Get token supply data for both STREET and credit
- `getTokenBalances(welshExpected, streetExpected, creditExpected, account, disp?)` - Get three-token balance for an account
- `updateUserRewardInfo(userKey, rewardData, userData)` - Calculate user unclaimed rewards locally (for regular tests)
- `updateUserRewards(userData, deployer, wallet1, wallet2, disp?)` - Sync user reward state from blockchain (DEBUG ONLY - ⚠️ DO NOT use in regular tests)

## Function Parameter Conventions

### Common Parameters
- `disp` (boolean, optional): Display debug output to console
- `sender`/`caller`: Account executing the transaction
- `*Expected`: Expected return values for assertions
- `amount`/`amountExpected`: Token amounts in base units

### Error Handling
All helper functions automatically validate responses and throw assertion errors on unexpected results. Error codes are checked against contract inventory codes.

## Usage Notes

1. **Debug Display**: Set `disp: true` to see detailed console output during test execution
2. **Expected Values**: Most functions require expected values for validation - tests fail if actual values don't match
3. **Reward Functions**: Be careful with `updateUserRewards()` - only use in debug tests, not regular tests (causes circular verification)
4. **Setup Functions**: Use setup helpers to quickly bootstrap test environments with consistent initial state
