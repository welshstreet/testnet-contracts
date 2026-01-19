# testnet deployment troubleshooting

## objective

- welshcorgicoin has been deployed by the deployer address: `ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J`
- the other contracts have been deployed by the deployer address: `ST1VY4116Q3QK4BJMW64HHTZBTCT0GABWS9P6EFNS`

- the idea is to have the `.welshcorgicoin` contract deployed by a different address to mock the existence of the welsh token on mainnet.

- the questions are how to properly setup the project requirements so that the welshcorgicoin contract is accessible by the welshstreet contracts on testnet.

## problems

### ❌ CIRCULAR PROBLEM - UNRESOLVED

**Problem 1: If requirement is KEPT in Clarinet.toml**
```toml
[[project.requirements]]
contract_id = 'ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J.welshcorgicoin'
```
- ✅ `clarinet check` passes
- ✅ `clarinet deployments generate --testnet` creates a plan that INCLUDES welshcorgicoin deployment
- ❌ `clarinet deployments apply --testnet` fails with:
  ```
  error: transaction rejected
  reason: ContractAlreadyExists
  contract_identifier: ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J.welshcorgicoin
  ```

**Problem 2: If requirement is DELETED from Clarinet.toml**
- ❌ `clarinet check` fails with:
  ```
  error: use of unresolved contract 'ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J.welshcorgicoin'
  ```
- Cannot proceed to deployment

**Current Status:** Stuck in a loop - need the requirement for validation but it causes deployment failures.

### Configuration Settings
```toml
[repl.remote_data]
enabled = true
api_url = 'https://api.testnet.hiro.so'
```
- Remote data is enabled to fetch external contract information from testnet
- This should allow resolving external contracts without redeploying them
- **However:** This doesn't prevent the deployment plan from including them

## potential solutions to explore

1. **Manual deployment plan editing** - After generating the plan, manually remove the `requirement-publish` entries for welshcorgicoin before running `clarinet deployments apply`

2. **Check if deployment plan smart-detection works** - Sometimes `clarinet deployments generate` checks the network and excludes already-deployed contracts. Test if regenerating the plan detects the existing contracts.

3. **Use a wrapper script** - Create a script that:
   - Generates deployment plan
   - Automatically filters out existing contract deployments
   - Applies the filtered plan

4. **Check Clarinet version** - This might be a known issue. Check if updating to the latest Clarinet version resolves it.

5. **Explore alternative requirement syntax** - Check if there's a way to mark a requirement as "external-only" or "do-not-deploy"

## workaround (if needed)

If no automatic solution exists:
1. Keep the requirement in `Clarinet.toml` for validation
2. Run `clarinet deployments generate --testnet --medium-cost` (answer 'n' to overwrite prompt to preserve manual edits)
3. Manually edit `deployments/default.testnet-plan.yaml` to remove the welshcorgicoin `requirement-publish` section
4. Run `clarinet deployments apply --testnet`

## ✅ DEPLOYMENT SUCCESSFUL - NEW CRITICAL ISSUE DISCOVERED

**Contracts deployed to:** `ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW`

### ❌ RUNTIME ERROR: ContractCallExpectName

**Error Details:**
```json
{
  "tx_status": "abort_by_response",
  "vm_error": "ContractCallExpectName"
}
```

**Root Cause IDENTIFIED:** TRAIT MISMATCH

The Welsh contract at `ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J.welshcorgicoin` implements:
```clarity
(impl-trait 'ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J.sip-010-trait-ft-standard.sip-010-trait)
```

But your contracts use:
```clarity
(use-trait sip-010 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
```

**The Fix:** Update the trait import in your contracts to match the testnet-deployed Welsh contract's trait:

1. **Option A: Update your contracts** (RECOMMENDED):
   Change in `exchange.clar`, `rewards.clar`, `genesis.clar`:
   ```clarity
   (use-trait sip-010 'ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J.sip-010-trait-ft-standard.sip-010-trait)
   ```

2. **Option B: Redeploy Welsh with correct trait**:
   Deploy Welsh again with the `SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE` trait (but this requires controlling that deployment)

**Note:** The trait address discrepancy happens because:
- Mainnet Welsh uses: `SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE` (mainnet address)
- Testnet Welsh was deployed with remapped trait: `ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J` (testnet address)

This is a common issue when deploying to testnet - the trait implementations need to match exactly.

**Files affected:**
- [exchange.clar](exchange.clar#L6) - Line 6
- [rewards.clar](rewards.clar#L6) - Line 6
- [genesis.clar](genesis.clar#L6) - Line 6

---

## ⚠️ UNDERSTANDING THE PRINCIPAL REMAPPING ISSUE

### The Confusion

**Question:** Should I hardcode testnet addresses like `ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J.sip-010-trait-ft-standard` in my contracts?

**Answer:** ❌ **NO - This is NOT standard practice and breaks portability**

### How Principal Remapping Should Work

**Standard Workflow:**
1. Write contracts with **mainnet addresses**: `SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard`
2. Clarinet **automatically remaps** `SP` → `ST` addresses during testnet deployment
3. Everything works because remapping is **consistent across all deployments**

**Your Clarinet.toml should use mainnet addresses:**
```toml
[[project.requirements]]
contract_id = 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard'
```

### Why You're Seeing This Problem

**The Issue:** Welsh contract was deployed by a **different deployer** (`ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J`)

When you look at the deployment plan:
```yaml
contract-id: SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard
remap-sender: ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW  # YOUR address
remap-principals:
  SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE: ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW
```

This means:
- **Your deployment** would remap the trait to: `ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW.sip-010-trait-ft-standard`
- **Welsh was deployed** by someone else who remapped it to: `ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J.sip-010-trait-ft-standard`
- **Result:** Trait implementations don't match = runtime error

### The Real Problem

Different deployer addresses = different trait implementations = incompatible contracts

```
Your contracts expect:    ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW.sip-010-trait-ft-standard
Welsh implements:         ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J.sip-010-trait-ft-standard
                          ↑
                          Different deployers = incompatible
```

### Solutions (Choose One)

**Option 1: Match Welsh's Trait (Quick Testnet Fix)**
- ❌ Not portable to mainnet
- ✅ Works immediately for testing
- Change imports to: `ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J.sip-010-trait-ft-standard`
- Update Clarinet.toml requirement to match

**Option 2: Deploy Your Own Trait + Welsh (Full Control)**
- ✅ Portable and proper
- ✅ Full control over all contracts
- Requires deploying both trait and Welsh yourself

**Option 3: Deploy to Mainnet (Production)**
- ✅ Everyone uses the same official trait: `SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE`
- ✅ No conflicts because mainnet Welsh uses the official trait
- Requires mainnet deployment

### Best Practice

**For Mainnet:** Keep `SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE` addresses (standard)

**For Testnet Testing:** 
- If using external contracts: Match their deployed trait address
- If full control: Deploy your own complete stack with consistent remapping

**Never:** Hardcode testnet addresses in source files meant for mainnet deployment

---

## 🚨 FUNDAMENTAL TESTNET LIMITATION DISCOVERED

### The Problem We Tried to Solve

**Goal:** Deploy Welsh from a different address than our contracts to simulate "external" mainnet Welsh
- Welsh deployed by: `ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J`
- Our contracts deployed by: `ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW`

### Why This CANNOT Work on Testnet

**Principal Remapping Mechanics:**

When Clarinet deploys to testnet, it remaps mainnet addresses:
```
Mainnet: SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE → Testnet: ST{YOUR_DEPLOYER_ADDRESS}
```

**The Fatal Flaw:**
```
Welsh deployer:      ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J
├─ Implements trait: ST3HV3C3H5CDKB06J8PCXJJKGJ83VKF16BDWXSW3J.sip-010-trait-ft-standard
└─ Result: Welsh uses ST3's trait

Your contracts:      ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW  
├─ Import SP3 trait → Remaps to: ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW.sip-010-trait-ft-standard
└─ Result: Your contracts use ST15's trait

OUTCOME: ❌ Different trait addresses = INCOMPATIBLE at runtime
```

### This IS a Testnet Limitation (Not a Bug)

**Why Mainnet Doesn't Have This Problem:**
- Everyone uses the SAME canonical trait: `SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard`
- No remapping = universal compatibility
- Welsh deployed by ANY address will use the same official trait

**Why Testnet Creates This Problem:**
- Principal remapping is NECESSARY for testnet (converts mainnet addresses)
- Each deployer gets their OWN remapped addresses
- No shared canonical traits = no cross-deployer compatibility

### ✅ THE SOLUTION: Deploy Welsh WITH Your Contracts

**What We've Already Done (Current Deployment):**
```yaml
# deployments/default.testnet-plan.yaml includes:
- ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW.sip-010-trait-ft-standard
- ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW.welshcorgicoin
- ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW.exchange
- ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW.rewards
- (... all other contracts)
```

**Why This Works:**
- ✅ All contracts deployed by same address
- ✅ All use the same remapped trait: `ST15C2QD2F2DXV7EDXDP61J6R72M7DJ2BQ4PN6HRW.sip-010-trait-ft-standard`
- ✅ Runtime compatibility guaranteed
- ✅ Still maintains mainnet portability (all use `SP3...` in source)

**Why This is CORRECT for Testnet:**
- Deploying Welsh yourself is the ONLY way to test trait compatibility
- This accurately simulates mainnet behavior (where all traits are canonical)
- Source code remains portable - Clarinet handles remapping automatically

### Recommendation

**For Testnet/Devnet Testing:**
```toml
# Clarinet.toml - Include Welsh as a requirement
[[project.requirements]]
contract_id = 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard'

# This causes Clarinet to:
# 1. Fetch Welsh source from mainnet/previous testnet deployment
# 2. Include it in YOUR deployment plan
# 3. Deploy it from YOUR address with YOUR trait
# 4. Everything works!
```

**For Mainnet Deployment:**
- Same Clarinet.toml works
- Welsh already exists at canonical address
- Your contracts interact with real Welsh
- Official `SP3...` trait ensures compatibility

### Conclusion

**This is NOT a workaround - this IS the correct approach.**

You cannot simulate external contracts with different deployers on testnet due to principal remapping. Deploying Welsh yourself ensures:
1. Trait compatibility on testnet
2. Accurate functionality testing
3. Mainnet portability

The "different deployer" scenario can only be truly tested on mainnet where canonical traits exist.

## references

- deployment docs: https://docs.stacks.co/clarinet/contract-deployment

---

## ✅ MAINNET DEPLOYMENT - NO REMAPPING ISSUES

### Mainnet Deployment Plan

When deploying to mainnet with the same contracts (using `SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE` trait), Clarinet generates a plan that:
- **Does NOT include Welsh** (already exists on mainnet)
- **Does NOT include the trait** (already exists on mainnet)
- **Does NOT perform any principal remapping**
- **Only deploys the 6 user contracts**

Example mainnet deployment plan:
```yaml
---
id: 0
name: Mainnet deployment
network: mainnet
stacks-node: "https://api.hiro.so"
bitcoin-node: "http://blockstack:blockstacksystem@bitcoin.blockstack.com:8332"
plan:
  batches:
    - id: 0
      transactions:
        - contract-publish:
            contract-name: credit
            expected-sender: SP1FRW6E2441D7C5R8YYYAKQ6HN59HKMJYWE0DE5Z
            cost: 82993328
            path: contracts/credit.clar
            anchor-block-only: true
            clarity-version: 3
        - contract-publish:
            contract-name: street
            expected-sender: SP1FRW6E2441D7C5R8YYYAKQ6HN59HKMJYWE0DE5Z
            cost: 83027258
            path: contracts/street.clar
            anchor-block-only: true
            clarity-version: 3
        - contract-publish:
            contract-name: rewards
            expected-sender: SP1FRW6E2441D7C5R8YYYAKQ6HN59HKMJYWE0DE5Z
            cost: 83319058
            path: contracts/rewards.clar
            anchor-block-only: true
            clarity-version: 3
        - contract-publish:
            contract-name: controller
            expected-sender: SP1FRW6E2441D7C5R8YYYAKQ6HN59HKMJYWE0DE5Z
            cost: 82976363
            path: contracts/controller.clar
            anchor-block-only: true
            clarity-version: 3
        - contract-publish:
            contract-name: exchange
            expected-sender: SP1FRW6E2441D7C5R8YYYAKQ6HN59HKMJYWE0DE5Z
            cost: 83159586
            path: contracts/exchange.clar
            anchor-block-only: true
            clarity-version: 3
        - contract-publish:
            contract-name: genesis
            expected-sender: SP1FRW6E2441D7C5R8YYYAKQ6HN59HKMJYWE0DE5Z
            cost: 83020472
            path: contracts/genesis.clar
            anchor-block-only: true
            clarity-version: 3
      epoch: "3.3"
```

**Key Differences from Testnet:**
- ❌ NO `requirement-publish` entries for Welsh or traits
- ❌ NO `remap-sender` directives
- ❌ NO `remap-principals` mappings
- ✅ ONLY the 6 user contracts are deployed
- ✅ Clean, simple deployment plan

### Testnet vs Mainnet Comparison

| Aspect | Testnet | Mainnet |
|--------|---------|---------|
| **Principal Remapping** | ✅ Yes - SP→ST{deployer} | ❌ No - SP stays as SP |
| **Trait Address** | Per deployer (e.g., ST3..., ST15...) | Canonical SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE |
| **Cross-Deployer Compatibility** | ❌ Broken - each deployer gets unique traits | ✅ Works - everyone uses same canonical trait |
| **Welsh Detection** | Detects but remaps to deployer address | Detects existing mainnet Welsh exactly |
| **Deployment Plan** | Includes Welsh + traits (remapped) | Excludes Welsh + traits (already exist) |
| **Solution** | Co-deploy Welsh with your contracts | Use external Welsh (already deployed) |
| **Trait Mismatch Risk** | ⚠️ High - if using different deployers | ✅ None - canonical trait is universal |

### Why Mainnet Works Correctly

**1. No Principal Remapping:**
- On mainnet, `SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE` stays as `SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE`
- Welsh contract on mainnet implements: `SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard`
- Your contracts use: `SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard`
- **Perfect match** ✅

**2. Clarinet Smart Detection:**
- `clarinet deployments generate --mainnet` checks the mainnet network
- Finds existing Welsh contract
- Finds existing trait contract
- Automatically excludes them from deployment plan
- Only includes your 6 contracts

**3. Canonical Trait Usage:**
- Everyone on mainnet uses the same `SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE` trait
- No per-deployer variations
- Universal compatibility

**4. Source Code is Mainnet-Ready:**
- Your contracts already use `SP3...` addresses (correct for mainnet)
- Only need to update Welsh contract address in constants
- No other code changes required

### Mainnet Deployment Steps

1. **Update Welsh Address** in contracts:
   - Change `WELSH_CONTRACT` from testnet address to mainnet address
   - Files: [exchange.clar](exchange.clar#L6), [rewards.clar](rewards.clar#L6), [genesis.clar](genesis.clar#L6)

2. **Update Clarinet.toml** requirements:
   ```toml
   [[project.requirements]]
   contract_id = 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard'
   
   [[project.requirements]]
   contract_id = '{MAINNET_WELSH_ADDRESS}.welshcorgicoin'
   ```

3. **Generate Mainnet Plan:**
   ```bash
   clarinet deployments generate --mainnet --medium-cost
   ```

4. **Verify Plan:**
   - Should see ONLY your 6 contracts
   - Should NOT see Welsh or trait deployments
   - Should NOT see any `remap-sender` or `remap-principals`

5. **Deploy:**
   ```bash
   clarinet deployments apply --mainnet
   ```

6. **Expected Result:**
   - All 6 contracts deployed to your mainnet address
   - Contracts can call Welsh without trait mismatch
   - Perfect compatibility ✅

---

## related documents

*deployment*
`default.testnet-plan.yaml`

*settings*
`Clarinet.toml`