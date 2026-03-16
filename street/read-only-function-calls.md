## Read-only `get-balance` pattern (Clarity 4)

**IMPORTANT: Clarity 4 requires `unwrap-panic` for read-only functions that return `(response T never)`**

Given that `welshcorgicoin` / `credit-token` / `street-token` read-only functions always return `(ok ...)` with no error branch, they have type `(response T never)`. **Clarity 4 rejects `try!` on these types** because `try!` requires a determinate error type to propagate.

### Correct Clarity 4 pattern:

Use `unwrap-panic` to unwrap the response directly:

```clarity
(user-welsh (unwrap-panic (contract-call? .welshcorgicoin get-balance contract-caller)))
(total-lp (unwrap-panic (contract-call? .credit-token get-total-supply)))
```

### Why not `try!`?

Clarity 4 error: "attempted to obtain 'err' value from response, but 'err' type is indeterminate"

`try!` needs to know what error type to propagate, but `(response T never)` has no error type. `unwrap-panic` doesn't propagate errors - it just panics if one occurs (which never will for these read-only functions).

### Applied globally:

All contracts now use `unwrap-panic` for:
- `get-balance` calls to welshcorgicoin, credit-token, street-token
- `get-total-supply` calls to credit-token

This is the correct and only way to handle `(response T never)` types in Clarity 4.

### Historical context:

**Previous approach (pre-Clarity 4):** Used `try!` which worked in earlier Clarity versions.

**Clarity 4 change:** Type checker now enforces that `try!` requires determinate error types, making `unwrap-panic` the only valid choice for `(response T never)` functions.

### Contract-specific applications:

**credit-controller:**
- `(sender-balance (unwrap-panic (contract-call? .credit-token get-balance sender)))`

**emission-controller:**  
- `(total-lp (unwrap-panic (contract-call? .credit-token get-total-supply)))`
- `(caller-credit (unwrap-panic (contract-call? .credit-token get-balance contract-caller)))`

**street-controller:**
- `(user-welsh (unwrap-panic (contract-call? .welshcorgicoin get-balance contract-caller)))`
- `(total-lp (unwrap-panic (contract-call? .credit-token get-total-supply)))`

**street-market:**
- `(total-lp (unwrap-panic (contract-call? .credit-token get-total-supply)))`

**street-rewards:**
- All balance and supply queries use `unwrap-panic`

**welsh-faucet:**
- `(unwrap-panic (contract-call? .welshcorgicoin get-balance tx-sender))`






