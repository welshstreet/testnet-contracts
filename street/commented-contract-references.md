```clarity
(define-public (decrease-rewards (user principal) (amount uint))
  (let (
    ;; user's current CREDIT balance (AFTER amount was removed)
    (balance (unwrap-panic (contract-call? .credit-token get-balance user)))

    ;; snapshot timing stored into the user record
    (block stacks-block-height)
    
    ;; current global reward indexes (cumulative rewards per LP token)
    (global-a (var-get global-index-a))
    (global-b (var-get global-index-b))
    
    ;; user's stored state (must exist - unwrap-panic will fail if not)
    (info (unwrap-panic (map-get? users { account: user })))
    
    ;; total CREDIT supply across all holders
    (total-lp (unwrap-panic (contract-call? .credit-token get-total-supply)))
    
    ;; user's CREDIT balance before the reduction, and all other LP
    (old-balance (+ balance amount))
    (other-lp (- total-lp old-balance))
  )
    (begin
      ;; only controller or market can shrink positions
      (asserts! (or (is-eq contract-caller .credit-controller)
                    (is-eq contract-caller .street-market)) ERR_NOT_AUTHORIZED)
      (asserts! (> amount u0) ERR_ZERO_AMOUNT)
      (let (
        ;; debt offset used to prevent double-counting existing rewards
        ;; (not the amount claimed - it's a calculated offset in the formula)
        (debt-a (get debt-a info))
        (debt-b (get debt-b info))
        
        ;; user's stored index snapshots (last time their state was updated)
        (index-a (get index-a info))
        (index-b (get index-b info))
        
        ;; compute earned: balance × (global-index - user-index) / PRECISION
        ;; represents rewards accrued since user's last index snapshot
        (earned-a (/ (* old-balance (- global-a index-a)) PRECISION))
        (earned-b (/ (* old-balance (- global-b index-b)) PRECISION))
        
        ;; unclaimed rewards = earned minus prior debt
        (unclaimed-a (if (> earned-a debt-a) (- earned-a debt-a) u0))
        (unclaimed-b (if (> earned-b debt-b) (- earned-b debt-b) u0))
        
        ;; portion of unclaimed rewards that must be forfeited
        ;; proportional to LP removed relative to old balance
        (forfeit-a (/ (* unclaimed-a amount) old-balance))
        (forfeit-b (/ (* unclaimed-b amount) old-balance))
        
        ;; convert forfeited rewards into index increments for other LPs
        ;; forfeited rewards are immediately redistributed to remaining LP holders
        ;; global index increases so remaining holders earn the forfeited portion
        (redistributed-a (if (> other-lp u0)
                      (/ (* forfeit-a PRECISION) other-lp)
                      u0))
        (redistributed-b (if (> other-lp u0)
                      (/ (* forfeit-b PRECISION) other-lp)
                      u0))
      )
        (begin
          ;; bump global indexes by redistributed amounts
          (if (> forfeit-a u0)
            (begin
              (var-set global-index-a (+ global-a redistributed-a)))
            true)
          (if (> forfeit-b u0)
            (begin
              (var-set global-index-b (+ global-b redistributed-b)))
            true)
          
          ;; clear old user entry
          (map-delete users { account: user })
          
          (let (
            ;; global indexes after applying forfeits
            (new-global-a (var-get global-index-a))
            (new-global-b (var-get global-index-b))
            
            ;; remainder of unclaimed rewards that stay with the user
            (preserve-a (- unclaimed-a forfeit-a))
            (preserve-b (- unclaimed-b forfeit-b))
            
            ;; derive new index that preserves remaining rewards on new balance
            ;; adjusts user index backward so reward formula yields correct preserved amount
            (preserve-idx-a (if (and (> balance u0) (> preserve-a u0))
                        (- new-global-a (/ (* preserve-a PRECISION) balance))
                        new-global-a))
            (preserve-idx-b (if (and (> balance u0) (> preserve-b u0))
                        (- new-global-b (/ (* preserve-b PRECISION) balance))
                        new-global-b))
          )
            ;; reinsert user if any balance remains
            (if (> balance u0)
              (map-set users
                { account: user }
                { balance: balance,
                  block: block,
                  debt-a: u0,
                  debt-b: u0, 
                  index-a: preserve-idx-a,
                  index-b: preserve-idx-b
                })
              true)
            )
          (ok true)
        )
      )
    )
  )
)
```

```clarity
(define-public (increase-rewards (user principal) (amount uint))
  (let (
    
    ;; user's new CREDIT balance after increase
    (balance (unwrap! (contract-call? .credit-token get-balance user) ERR_BALANCE))

    ;; snapshot timing stored into the user record
    (block stacks-block-height)
    
    ;; snapshot current global reward indexes for both tokens
    (global-a (var-get global-index-a))
    (global-b (var-get global-index-b))
    
    ;; existing user info if present
    ;; no error check because user state may not exist (receive transfer)
    (info (map-get? users { account: user }))
    
    ;; previous balance before increase
    (old-balance (- balance amount))
  )
    (begin
      ;; only credit-controller (transfers) or 
      ;; street-market (provide-liquidity) can increase positions
      (asserts! (or (is-eq contract-caller .credit-controller)
                    (is-eq contract-caller .street-market)) ERR_NOT_AUTHORIZED)
      (asserts! (> amount u0) ERR_ZERO_AMOUNT)
      
      ;; if user already has a rewards snapshot, preserve existing unclaimed
      ;; two preservation strategies available depending on caller
      (if (is-some info)
        (let (
          
          ;; unwrap stored user record
          (data (unwrap-panic info))
          
          ;; debt offset used to prevent double-counting existing rewards
          ;; (not the amount claimed - it's a calculated offset in the formula)
          (debt-a (get debt-a data))
          (debt-b (get debt-b data))
          
          ;; user's stored index snapshots (last time their state was updated)
          (index-a (get index-a data))
          (index-b (get index-b data))
          
          ;; compute earned: old-balance × (global-index - user-index) / PRECISION
          ;; represents rewards accrued on old balance since user's last index snapshot
          (earned-a (/ (* old-balance (- global-a index-a)) PRECISION))
          (earned-b (/ (* old-balance (- global-b index-b)) PRECISION))
          
          ;; Compare what user should have earned (earned-*) to what they already took (debt-*).
          ;; If earned > debt → unclaimed = difference.
          ;; If earned ≤ debt → unclaimed = 0 (no negative unclaimed).
          (unclaimed-a (if (> earned-a debt-a) (- earned-a debt-a) u0))
          (unclaimed-b (if (> earned-b debt-b) (- earned-b debt-b) u0))
        )
          ;; street-market caller: provide-liquidity
          ;; preserve unclaimed rewards by adjusting debt while keeping user index constant
          (if (is-eq contract-caller .street-market)
            (let (
              
              ;; compute earned on NEW balance using SAME user indexes
              ;; since we're keeping index-a and index-b unchanged
              (new-earned-a (/ (* balance (- global-a index-a)) PRECISION))
              (new-earned-b (/ (* balance (- global-b index-b)) PRECISION))
              
              ;; preserve existing unclaimed rewards by adjusting debt offset
              ;; debt offset compensates for larger balance using same index
              (preserve-debt-a (if (> new-earned-a unclaimed-a) (- new-earned-a unclaimed-a) u0))
              (preserve-debt-b (if (> new-earned-b unclaimed-b) (- new-earned-b unclaimed-b) u0))
            )
              ;; update user keeping same indexes, with adjusted debt for new balance
              (map-set users { account: user } {
                balance: balance,
                block: block,
                debt-a: preserve-debt-a,
                debt-b: preserve-debt-b,
                index-a: index-a,
                index-b: index-b
              })
            )
            (let (
              
              ;; credit-controller caller: transferCredit for LP token transfers
              ;; preserve unclaimed rewards by adjusting user index upward, zeroing debt
              (preserve-idx-a (if (> unclaimed-a u0)
                                (- global-a (/ (* unclaimed-a PRECISION) balance))
                                global-a))
              (preserve-idx-b (if (> unclaimed-b u0)
                                (- global-b (/ (* unclaimed-b PRECISION) balance))
                                global-b))
            )
              ;; reset debt to zero and set user index to calculated preserve-idx
              ;; adjusted index maintains same unclaimed amount on new balance
              (map-set users { account: user } {
                balance: balance,
                block: block,
                debt-a: u0,
                debt-b: u0,
                index-a: preserve-idx-a,
                index-b: preserve-idx-b
              })
            )
          )
        )

        ;; if new user, initialize snapshot at current indexes
        (map-set users { account: user } {
          balance: balance,
          block: block,
          debt-a: u0,
          debt-b: u0,
          index-a: global-a,
          index-b: global-b
        })
      )
      (ok true)
    )
  )
)
```