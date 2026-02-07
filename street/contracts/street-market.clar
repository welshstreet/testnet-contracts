;; Welsh Street Market

(use-trait sip-010 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; errors
(define-constant ERR_ZERO_AMOUNT (err u900))
(define-constant ERR_NOT_CONTRACT_OWNER (err u901))
(define-constant ERR_NOT_INITIALIZED (err u902))
(define-constant ERR_ALREADY_INITIALIZED (err u903))
(define-constant ERR_NOT_TREASURY (err u904))
(define-constant ERR_LOCKED_TREASURY (err u905))
(define-constant ERR_NOT_AVAILABLE (err u906))
(define-constant ERR_INVALID_AMOUNT (err u907))

;; constants
(define-constant BASIS u10000)
(define-constant MAX_FEE u100)
(define-constant MAX_REV u100)
(define-constant MAX_TAX u100)
(define-constant MIN_FEE u1)
(define-constant MIN_REV u1)
(define-constant MIN_TAX u1)

;; variables
(define-data-var contract-owner principal tx-sender)
(define-data-var fee uint u50)
(define-data-var locked-a uint u0)
(define-data-var locked-b uint u0)
(define-data-var reserve-a uint u0)
(define-data-var reserve-b uint u0)
(define-data-var rev uint u50)
(define-data-var tax uint u100)

;; treasury account
(define-data-var treasury-address principal (var-get contract-owner))

;; exchange functions 
(define-public (burn-liquidity (amount uint))
  (begin
    (asserts! (> amount u0) ERR_ZERO_AMOUNT)
    (try! (contract-call? .credit-token transfer amount tx-sender .street-market none))
    (try! (contract-call? .street-rewards decrease-rewards tx-sender amount))
    (try! (as-contract (contract-call? .credit-token burn amount)))
    (ok {
      amount-lp: amount,
    })
  )
)

(define-public (lock-liquidity (amount-a uint))
  (let (
    (lock-a (var-get locked-a))
    (lock-b (var-get locked-b))
    (res-a  (var-get reserve-a))
    (res-b  (var-get reserve-b))
  )
    (begin
      (asserts! (> amount-a u0) ERR_ZERO_AMOUNT)
      (asserts! (and (> res-a u0) (> res-b u0)) ERR_NOT_INITIALIZED)
      (let ((amount-b (/ (* amount-a res-b) res-a)))
        (begin
          (asserts! (> amount-b u0) ERR_ZERO_AMOUNT)
          (try! (contract-call? .welshcorgicoin transfer amount-a tx-sender .street-market none))
          (try! (contract-call? .street-token transfer amount-b tx-sender .street-market none))
          (var-set locked-a (+ lock-a amount-a))
          (var-set locked-b (+ lock-b amount-b))
          (var-set reserve-a (+ res-a amount-a))
          (var-set reserve-b (+ res-b amount-b))
          (ok { 
            amount-a: amount-a, 
            amount-b: amount-b 
          })
        )
      )
    )
  )
)

(define-public (provide-initial-liquidity (amount-a uint) (amount-b uint))
  (let (
    (lock-a (var-get locked-a))
    (lock-b (var-get locked-b))
    (res-a (var-get reserve-a))
    (res-b (var-get reserve-b))
    (total-supply-lp (unwrap-panic (contract-call? .credit-token get-total-supply)))
    (amount-lp (sqrti (* amount-a amount-b)))
  )
  (begin
    (asserts! (> amount-a u0) ERR_ZERO_AMOUNT)
    (asserts! (> amount-b u0) ERR_ZERO_AMOUNT)
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (asserts! (or
      (and (is-eq res-a u0) (is-eq res-b u0))
      (is-eq total-supply-lp u0))
      ERR_ALREADY_INITIALIZED)
    (try! (contract-call? .welshcorgicoin transfer amount-a tx-sender .street-market none))
    (try! (contract-call? .street-token transfer amount-b tx-sender .street-market none))
    (try! (contract-call? .credit-token mint amount-lp))
    (try! (contract-call? .street-rewards increase-rewards tx-sender amount-lp))
    (var-set reserve-a (+ lock-a amount-a))
    (var-set reserve-b (+ lock-b amount-b))
    (ok {
      amount-a: amount-a,
      amount-b: amount-b,
      amount-lp: amount-lp
      })
    )
  )
)

(define-public (provide-liquidity (amount-a uint))
  (let (
    (lock-a (var-get locked-a))
    (lock-b (var-get locked-b))
    (res-a  (var-get reserve-a))
    (res-b  (var-get reserve-b))
    (avail-a (if (>= res-a lock-a) (- res-a lock-a) u0))
    (avail-b (if (>= res-b lock-b) (- res-b lock-b) u0))
    (total-supply-lp (unwrap-panic (contract-call? .credit-token get-total-supply)))
  )
    (begin
      (asserts! (> amount-a u0) ERR_ZERO_AMOUNT)
      (asserts! (> total-supply-lp u0) ERR_NOT_INITIALIZED)
      (asserts! (and (> avail-a u0) (> avail-b u0)) ERR_NOT_INITIALIZED)
      (let (
        (amount-b (/ (* amount-a avail-b) avail-a))
        (lp-from-a (/ (* amount-a total-supply-lp) avail-a))
        (lp-from-b (/ (* amount-b total-supply-lp) avail-b))
        (amount-lp (if (< lp-from-a lp-from-b) lp-from-a lp-from-b))
      )
        (begin
          (try! (contract-call? .welshcorgicoin transfer amount-a tx-sender .street-market none))
          (try! (contract-call? .street-token transfer amount-b tx-sender .street-market none))
          (try! (contract-call? .credit-token mint amount-lp))
          (try! (contract-call? .street-rewards increase-rewards tx-sender amount-lp))
          (var-set reserve-a (+ res-a amount-a))
          (var-set reserve-b (+ res-b amount-b))
          (ok { 
            amount-a: amount-a, 
            amount-b: amount-b, 
            amount-lp: amount-lp 
            })
        )
      )
    )
  )
)

(define-public (remove-liquidity (amount-lp uint))
  (let (
    (res-a (var-get reserve-a))
    (res-b (var-get reserve-b))
    (lock-a (var-get locked-a))
    (lock-b (var-get locked-b))
    (avail-a (if (>= res-a lock-a) (- res-a lock-a) u0))
    (avail-b (if (>= res-b lock-b) (- res-b lock-b) u0))
    (total-supply-lp (unwrap-panic (contract-call? .credit-token get-total-supply)))
  )
    (begin
      (asserts! (> amount-lp u0) ERR_ZERO_AMOUNT)
      (asserts! (> total-supply-lp u0) ERR_NOT_INITIALIZED)
      (let (
        (remove-a (/ (* amount-lp avail-a) total-supply-lp))
        (remove-b (/ (* amount-lp avail-b) total-supply-lp))
        (tax-a (/ (* remove-a (var-get tax)) BASIS))
        (tax-b (/ (* remove-b (var-get tax)) BASIS))
        (amount-a (- remove-a tax-a))
        (amount-b (- remove-b tax-b))
      )
        (begin
          (try! (contract-call? .credit-token transfer amount-lp tx-sender .street-market none))
          (try! (transformer .welshcorgicoin amount-a tx-sender))
          (try! (transformer .street-token amount-b tx-sender))
          (try! (contract-call? .street-rewards decrease-rewards tx-sender amount-lp))
          (try! (as-contract (contract-call? .credit-token burn amount-lp)))
          (var-set reserve-a (if (>= res-a amount-a) (- res-a amount-a) u0))
          (var-set reserve-b (if (>= res-b amount-b) (- res-b amount-b) u0))
          (var-set locked-a (+ lock-a tax-a))
          (var-set locked-b (+ lock-b tax-b))
          (ok {
            amount-a: amount-a,
            amount-b: amount-b,
            amount-lp: amount-lp,
            tax-a: tax-a,
            tax-b: tax-b
          })
        )
      )
    )
  )
)


(define-public (swap-a-b (amount-a uint))
  (let (
    (res-a (var-get reserve-a))
    (res-b (var-get reserve-b))
    (lock-a (var-get locked-a))
    (lock-b (var-get locked-b))
    (fee-total (/ (* amount-a (+ (var-get fee) (var-get rev))) BASIS))
    (rev-a (/ (* amount-a (var-get rev)) BASIS))
    (fee-a (/ (* amount-a (var-get fee)) BASIS))
    (amount-a-net (- amount-a fee-total))
    (num (* amount-a-net res-b))
    (den (+ res-a amount-a-net))
    (amount-b (/ num den))
    (res-a-new (+ res-a amount-a-net))
    (res-b-new (- res-b amount-b))
    (lock-a-new (if (> res-a u0) (/ (* lock-a res-a-new) res-a) lock-a))
    (lock-b-new (if (> res-b u0) (/ (* lock-b res-b-new) res-b) lock-b))
    (treasury (var-get treasury-address))
  )
    (begin
      (asserts! (> amount-a u0) ERR_ZERO_AMOUNT)
      (asserts! (> amount-b u0) ERR_INVALID_AMOUNT)
      (asserts! (and (> res-a u0) (> res-b u0)) ERR_NOT_INITIALIZED)
      (try! (contract-call? .welshcorgicoin transfer amount-a tx-sender .street-market none))
      (try! (transformer .welshcorgicoin rev-a treasury))
      (try! (transformer .welshcorgicoin fee-a .street-rewards))
      (try! (transformer .street-token amount-b tx-sender))
      (try! (contract-call? .street-rewards update-rewards-a fee-a))
      (var-set reserve-a res-a-new)
      (var-set reserve-b res-b-new)
      (var-set locked-a lock-a-new)
      (var-set locked-b lock-b-new)
      (ok {
        amount-a: amount-a,
        amount-b: amount-b,
        fee-a: fee-a,
        res-a: res-a,
        res-a-new: res-a-new,
        res-b: res-b,
        res-b-new: res-b-new,
        rev-a: rev-a
      })
    )
  )
)

(define-public (swap-b-a (amount-b uint))
  (let (
    (res-a (var-get reserve-a))
    (res-b (var-get reserve-b))
    (lock-a (var-get locked-a))
    (lock-b (var-get locked-b))
    (fee-total (/ (* amount-b (+ (var-get fee) (var-get rev))) BASIS))
    (rev-b (/ (* amount-b (var-get rev)) BASIS))
    (fee-b (/ (* amount-b (var-get fee)) BASIS))
    (amount-b-net (- amount-b fee-total))
    (num (* amount-b-net res-a))
    (den (+ res-b amount-b-net))
    (amount-a (/ num den))
    (res-a-new (- res-a amount-a))
    (res-b-new (+ res-b amount-b-net))
    (lock-a-new (if (> res-a u0) (/ (* lock-a res-a-new) res-a) lock-a))
    (lock-b-new (if (> res-b u0) (/ (* lock-b res-b-new) res-b) lock-b))
    (treasury (var-get treasury-address))
  )
    (begin
      (asserts! (> amount-b u0) ERR_ZERO_AMOUNT)
      (asserts! (> amount-a u0) ERR_INVALID_AMOUNT)
      (asserts! (and (> res-a u0) (> res-b u0)) ERR_NOT_INITIALIZED)
      (try! (contract-call? .street-token transfer amount-b tx-sender .street-market none))
      (try! (transformer .street-token rev-b treasury))
      (try! (transformer .street-token fee-b .street-rewards))
      (try! (transformer .welshcorgicoin amount-a tx-sender))
      (try! (contract-call? .street-rewards update-rewards-b fee-b))
      (var-set reserve-a res-a-new)
      (var-set reserve-b res-b-new)
      (var-set locked-a lock-a-new)
      (var-set locked-b lock-b-new)
      (ok {
        amount-a: amount-a,
        amount-b: amount-b,
        fee-b: fee-b,
        res-a: res-a,
        res-a-new: res-a-new,
        res-b: res-b,
        res-b-new: res-b-new,
        rev-b: rev-b
      })
    )
  )
)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (var-set contract-owner new-owner)
    (ok true)
  )
)

(define-public (set-market-fee (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (asserts! (<= amount MAX_FEE) ERR_INVALID_AMOUNT )
    (asserts! (>= amount MIN_FEE) ERR_INVALID_AMOUNT )
    (var-set fee amount)
    (ok {fee: amount})
  )
)

(define-public (set-market-rev (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (asserts! (<= amount MAX_REV) ERR_INVALID_AMOUNT )
    (asserts! (>= amount MIN_REV) ERR_INVALID_AMOUNT )
    (var-set rev amount)
    (ok {rev: amount})
  )
)

(define-public (set-market-tax (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (asserts! (<= amount MAX_TAX) ERR_INVALID_AMOUNT )
    (asserts! (>= amount MIN_TAX) ERR_INVALID_AMOUNT )
    (var-set tax amount)
    (ok {tax: amount})
  )
)

(define-public (set-treasury-address (new-treasury principal))
  (begin
    (asserts! (is-eq (var-get treasury-address) tx-sender) ERR_NOT_TREASURY)
      (var-set treasury-address new-treasury)
      (ok true)
  )
)

(define-private (transformer
    (token <sip-010>)
    (amount uint)
    (recipient principal)
  )
  (as-contract (contract-call? token transfer amount tx-sender recipient none))
)

;; custom read-only
(define-read-only (get-blocks)
  (ok {
    bitcoin-block: burn-block-height,
    stacks-block: stacks-block-height
  }))

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner)))

(define-read-only (get-market-info)
  (let (
    (lock-a (var-get locked-a))
    (lock-b (var-get locked-b))
    (res-a (var-get reserve-a))
    (res-b (var-get reserve-b))
  )
    (ok {
      avail-a: (if (>= res-a lock-a) (- res-a lock-a) u0),
      avail-b: (if (>= res-b lock-b) (- res-b lock-b) u0),
      fee: (var-get fee),
      locked-a: lock-a,
      locked-b: lock-b,
      reserve-a: res-a,
      reserve-b: res-b,
      revenue: (var-get rev),
      tax: (var-get tax)
    })
  )
)

(define-read-only (get-treasury-address)
  (ok (var-get treasury-address)))