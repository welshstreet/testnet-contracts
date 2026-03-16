## Contract Inventory

> **Note:** `welshcorgicoin.clar` is a pre-existing contract and is NOT part of the new development. It is excluded from this inventory.

### credit-controller.clar

- Errors
	- `ERR_ZERO_AMOUNT` (err u911)
	- `ERR_NOT_CONTRACT_OWNER` (err u912)
	- `ERR_NOT_TOKEN_OWNER` (err u913)
	- `ERR_BALANCE` (err u914)
- Functions
	- `transfer`
	- `set-contract-owner`
	- `get-contract-owner`

### credit-token.clar

- Errors
	- `ERR_ZERO_AMOUNT` (err u921)
	- `ERR_NOT_CONTRACT_OWNER` (err u922)
	- `ERR_NOT_AUTHORIZED` (err u923)
- Functions
	- `burn`
	- `mint`
	- `set-contract-owner`
	- `set-token-uri`
	- `transfer`
	- `get-balance`
	- `get-contract-owner`
	- `get-decimals`
	- `get-name`
	- `get-symbol`
	- `get-token-uri`
	- `get-total-supply`

### emission-controller.clar

- Errors
	- `ERR_EMISSION_INTERVAL` (err u931)
	- `ERR_NOT_CONTRACT_OWNER` (err u932)
	- `ERR_NOT_ELIGIBLE` (err u933)
	- `ERR_NO_LIQUIDITY` (err u934)
- Functions
	- `mint`
	- `set-contract-owner`
	- `get-contract-owner`
	- `get-current-epoch`
	- `get-last-burn-block`

### street-controller.clar

- Errors
	- `ERR_ALREADY_MINTED` (err u941)
	- `ERR_NOT_CONTRACT_OWNER` (err u942)
	- `ERR_MINT_CAP` (err u943)
	- `ERR_NO_LIQUIDITY` (err u944)
	- `ERR_YOU_POOR` (err u2)
- Functions
	- `mint`
	- `set-contract-owner`
	- `get-contract-owner`
	- `get-mint-count`

### street-market.clar

- Errors
	- `ERR_ZERO_AMOUNT` (err u951)
	- `ERR_NOT_CONTRACT_OWNER` (err u952)
	- `ERR_NOT_INITIALIZED` (err u953)
	- `ERR_INITIALIZED` (err u954)
	- `ERR_INVALID_AMOUNT` (err u955)
- Functions
	- `burn-liquidity`
	- `lock-liquidity`
	- `initial-liquidity`
	- `provide-liquidity`
	- `remove-liquidity`
	- `swap-a-b`
	- `swap-b-a`
	- `set-contract-owner`
	- `transformer`
	- `get-blocks`
	- `get-contract-owner`
	- `get-market-info`

### street-nft.clar

- Errors
	- `ERR_NOT_CONTRACT_OWNER` (err u961)
	- `ERR_NOT_AUTHORIZED` (err u962)
	- `ERR_NOT_FOUND` (err u963)
	- `ERR_NOT_OWNER` (err u964)
- Functions
	- `mint`
	- `transfer`
	- `set-contract-owner`
	- `set-base-uri`
	- `get-contract-owner`
	- `get-owner`
	- `get-token-uri`
	- `get-base-uri`
	- `get-user-minted-tokens`

### street-rewards.clar

- Errors
	- `ERR_ZERO_AMOUNT` (err u971)
	- `ERR_NOT_CONTRACT_OWNER` (err u972)
	- `ERR_NOT_AUTHORIZED` (err u973)
	- `ERR_CLEANUP_INTERVAL` (err u975)
- Functions
	- `claim-rewards`
	- `cleanup-rewards`
	- `decrease-rewards`
	- `donate-rewards`
	- `increase-rewards`
	- `set-contract-owner`
	- `update-rewards-a`
	- `update-rewards-b`
	- `calculate-cleanup-rewards`
	- `transformer`
	- `get-cleanup-rewards`
	- `get-contract-owner`
	- `get-reward-pool-info`
	- `get-reward-user-info`

### street-token.clar

- Errors
	- `ERR_ZERO_AMOUNT` (err u981)
	- `ERR_NOT_CONTRACT_OWNER` (err u982)
	- `ERR_NOT_TOKEN_OWNER` (err u983)
	- `ERR_NOT_AUTHORIZED` (err u984)
- Functions
	- `mint`
	- `set-contract-owner`
	- `set-token-uri`
	- `transfer`
	- `get-contract-owner`
	- `get-balance`
	- `get-decimals`
	- `get-name`
	- `get-symbol`
	- `get-token-uri`
	- `get-total-supply`

### welsh-faucet.clar

- Errors
	- `ERR_NOT_CONTRACT_OWNER` (err u991)
	- `ERR_COOLDOWN` (err u992)
- Functions
	- `request`
	- `set-contract-owner`
	- `set-cooldown`
	- `transformer`
	- `get-balance`
	- `get-cooldown`
	- `get-contract-owner`
	- `get-last-request`
	- `get-next-request`
	- `get-faucet-info`
