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

## references

- deployment docs: https://docs.stacks.co/clarinet/contract-deployment

## related documents

*deployment*
`default.testnet-plan.yaml`

*settings*
`Clarinet.toml`