# Clarinet 4 / Clarity 4: as-contract? Upgrade Documentation

## ⚠️ CRITICAL: Test Suite is Correct - Fix Contracts, Not Tests!

**IMPORTANT**: The test suite in this project has been extensively vetted and tested with Clarity 3.0. All tests were passing before the Clarity 4 upgrade. With the new `as-contract?` changes in Clarity 4, the **contract behavior** broke, causing test failures.

**DO NOT UPDATE THE TESTS!** The tests represent the correct, expected behavior. We need to update the **contracts** to match the test expectations, not change the tests to match broken contract behavior.

### Current Status
- ✅ Tests: Correct and validated (Clarity 3.0)
- ❌ Contracts: Broken after `as-contract?` migration
- 🎯 Goal: Fix contracts to pass existing tests

---

## Critical Changes from Clarity 1-3 to Clarity 4

### Function Signature Change

**Old (Clarity 1-3):** `as-contract`
**New (Clarity 4):** `as-contract?`

### New Allowance System

The Clarity 4 `as-contract?` function requires **explicit allowances** for any asset transfers.

#### Input Parameters

1. **Allowances** (first parameter): 
   - `((with-stx|with-ft|with-nft|with-stacking)*|with-all-assets-unsafe)`
   - Maximum of 128 allowances
   - Can use empty `()` if no assets will be transferred

2. **Body Expressions** (remaining parameters):
   - One or more Clarity expressions
   - Final expression returning type `A`, where `A` is **NOT a response**

#### Output

Returns `(response A uint)` where:
- `(ok x)` - Success, where `x` is the result of the final body expression
- `(err index)` - Allowance violated
  - `index` is the 0-based index of the first violated allowance
  - `u128` if an asset with no allowance caused the violation

### Available Allowances

#### 1. `with-stx`
```clarity
(with-stx amount)
```
Grants access to `amount` uSTX from the contract principal.

**Example:**
```clarity
(as-contract? ((with-stx u1000000))
  (stx-transfer? u1000000 tx-sender recipient))
```

#### 2. `with-ft`
```clarity
(with-ft contract-id token-name amount)
```
Grants access to fungible tokens.
- `contract-id`: principal - The contract defining the FT
- `token-name`: (string-ascii 128) - Token name or `"*"` for all FTs in contract
- `amount`: uint - Amount to grant access to

**Example:**
```clarity
(as-contract? ((with-ft (contract-of token) "credit" amount))
  (contract-call? .credit-token transfer amount sender recipient none))
```

#### 3. `with-nft`
```clarity
(with-nft contract-id token-name identifiers)
```
Grants access to specific NFT identifiers.
- `contract-id`: principal - The contract defining the NFT
- `token-name`: (string-ascii 128) - Token name or `"*"` for all NFTs
- `identifiers`: (list 128 T) - List of NFT identifiers

#### 4. `with-stacking`
```clarity
(with-stacking amount)
```
Grants stacking allowance for `amount` uSTX.

#### 5. `with-all-assets-unsafe`
```clarity
(with-all-assets-unsafe)
```
⚠️ **DANGER**: Grants unrestricted access to ALL contract assets.
- Use with extreme caution
- Only for verified trusted code
- More restrictive allowances preferred

### Critical Rules

#### 1. No Nested Responses
The final body expression **CANNOT** return a response type:
```clarity
;; ❌ WRONG - nested response
(as-contract? ()
  (contract-call? .some-contract some-function)) ;; returns (response ...)

;; ✅ CORRECT - unwrap the response
(as-contract? ()
  (unwrap! (contract-call? .some-contract some-function) ERR_SOME_ERROR))
```

#### 2. Empty Allowances
If no asset transfers occur, use empty allowances:
```clarity
(as-contract? ()
  ;; Read-only or non-asset operations
  (contract-call? .some-contract read-only-function))
```

#### 3. Error Handling
Always use `unwrap!` with specific error constants instead of `unwrap-panic`:
```clarity
;; ❌ BAD - generic error
(unwrap-panic (contract-call? .token transfer amount sender recipient none))

;; ✅ GOOD - specific error code
(unwrap! (contract-call? .token transfer amount sender recipient none) ERR_TRANSFER)
```

### Common Patterns

#### Pattern 1: Token Transfer with Allowance
```clarity
(define-constant ERR_TRANSFER (err u915))

(as-contract? ((with-ft .token-contract "token-name" amount))
  (unwrap! 
    (contract-call? .token-contract transfer amount sender recipient none) 
    ERR_TRANSFER))
```

#### Pattern 2: Multiple Operations (No Assets)
```clarity
(define-constant ERR_REWARDS (err u916))

(as-contract? ()
  (unwrap! 
    (contract-call? .rewards-contract update-rewards user amount) 
    ERR_REWARDS))
```

#### Pattern 3: Read-Only Balance Check
```clarity
(define-constant ERR_BALANCE (err u972))

(define-read-only (get-contract-balance)
  (as-contract? ()
    (unwrap! 
      (contract-call? .token get-balance tx-sender) 
      ERR_BALANCE)))
```

#### Pattern 4: Using try! with as-contract?
```clarity
;; as-contract? returns (response A uint)
;; try! can unwrap it and propagate errors
(try! (as-contract? ((with-ft .token "name" amount))
  (unwrap! 
    (contract-call? .token transfer amount tx-sender recipient none) 
    ERR_TRANSFER)))
```

### Migration Checklist

- [ ] Replace `as-contract` with `as-contract?`
- [ ] Add allowances as first parameter
  - [ ] Use `()` for read-only or non-asset operations
  - [ ] Use `(with-ft ...)` for fungible token transfers
  - [ ] Use `(with-stx ...)` for STX transfers
  - [ ] Use `(with-nft ...)` for NFT transfers
- [ ] Ensure final body expression does NOT return response
  - [ ] Unwrap any response-returning calls with `unwrap!` or `try!`
- [ ] Replace `unwrap-panic` with `unwrap!` and error constants
- [ ] Add error constants for each operation (ERR_TRANSFER, ERR_BALANCE, etc.)
- [ ] Wrap `as-contract?` calls with `try!` if needed to propagate errors
- [ ] Test all paths thoroughly with `clarinet check`

### Error Codes Strategy

Use distinct error codes in u9XX range:
```clarity
(define-constant ERR_TRANSFER     (err u915))
(define-constant ERR_REWARDS      (err u916))
(define-constant ERR_BALANCE      (err u914))
(define-constant ERR_TRANSFORMER  (err u947))
(define-constant ERR_BURN         (err u948))
```

### Common Errors

#### Error: "intermediary responses must be checked"
**Cause**: Response-returning expression not wrapped with `unwrap!`, `unwrap-panic`, or `try!`

**Fix**:
```clarity
;; ❌ WRONG
(contract-call? .token transfer ...)

;; ✅ CORRECT
(unwrap! (contract-call? .token transfer ...) ERR_TRANSFER)
```

#### Error: "(err u128)"
**Cause**: Asset transfer without corresponding allowance

**Fix**: Add appropriate allowance:
```clarity
;; ❌ WRONG - no allowance for transfer
(as-contract? ()
  (unwrap! (contract-call? .token transfer ...) ERR_TRANSFER))

;; ✅ CORRECT - with-ft allowance
(as-contract? ((with-ft .token "name" amount))
  (unwrap! (contract-call? .token transfer ...) ERR_TRANSFER))
```

#### Error: "nested responses not allowed"
**Cause**: Final body expression returns a response

**Fix**: Unwrap the final response:
```clarity
;; ❌ WRONG
(as-contract? ()
  (contract-call? .token transfer ...)) ;; returns (response ...)

;; ✅ CORRECT
(as-contract? ()
  (unwrap! (contract-call? .token transfer ...) ERR_TRANSFER))
```

### Official Documentation

Source: https://docs.stacks.co/reference/clarity/functions#as-contract

**Full Signature:**
```clarity
(as-contract? 
  ((with-stx|with-ft|with-nft|with-stacking)*|with-all-assets-unsafe) 
  expr-body1 
  expr-body2 
  ... 
  expr-body-last)
```

**Description from Stacks Docs:**
> Switches the current context's `tx-sender` and `contract-caller` values to the contract's principal and executes the body expressions within that context, then checks the asset outflows from the contract against the granted allowances, in declaration order. If any allowance is violated, the body expressions are reverted and an error is returned.

**Key Points:**
- Introduced in Clarity 4
- Allowance setup expressions evaluated before body expressions
- Final body expression cannot return response (avoids nested responses)
- Returns `(ok x)` on success, `(err index)` on allowance violation
- Max 128 allowances per call
- Empty `()` allowances valid for non-asset operations

### When NOT to Use as-contract?

#### Pattern: Functions with Authorization Checks

**Problem**: When calling a function that checks `contract-caller` for authorization, wrapping it in `as-contract?` breaks the authorization.

```clarity
;; In street-rewards.clar:
(define-public (decrease-rewards (user principal) (amount uint))
  (begin
    (asserts! (or (is-eq contract-caller .credit-controller)
                  (is-eq contract-caller .street-market)) ERR_NOT_AUTHORIZED)
    ;; ... rest of function
  )
)

;; ❌ WRONG - breaks authorization check
(try! (as-contract? ()
  (unwrap! (contract-call? .street-rewards decrease-rewards sender amount) ERR_REWARDS)))

;; ✅ CORRECT - direct call preserves contract-caller
(try! (contract-call? .street-rewards decrease-rewards sender amount))
```

**Why this happens:**
- `as-contract?` changes the calling context (`tx-sender` and `contract-caller`)
- Functions checking `contract-caller` expect the calling contract's identity
- Wrapping in `as-contract?` changes `contract-caller` to the contract's own principal
- This fails authorization checks expecting specific callers

**When to use direct contract-call instead:**
- The called function already has authorization checks
- The called function expects to identify the caller via `contract-caller`
- You don't need to transfer assets owned by your contract
- The function handles its own security/validation

### Additional Notes

1. **tx-sender Context**: Inside `as-contract?`, `tx-sender` becomes the contract principal
2. **Order Matters**: Allowances checked in declaration order
3. **Allowance Matching**: Token name in `with-ft` must match `define-fungible-token` name
4. **Wildcard Support**: Use `"*"` for token-name to match all FTs/NFTs in a contract
5. **Contract Resolution**: Ensure contract dependencies properly defined in Clarinet.toml
6. **Authorization Context**: Don't use `as-contract?` when calling functions that check `contract-caller` for authorization