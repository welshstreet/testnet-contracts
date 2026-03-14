;; Welsh Street Emission Controller

;; errors
(define-constant ERR_EMISSION_INTERVAL (err u931))
(define-constant ERR_NOT_ELIGIBLE (err u932))
(define-constant ERR_NO_LIQUIDITY (err u933))
(define-constant ERR_BALANCE (err u934))
(define-constant ERR_SUPPLY (err u935))

;; constants
(define-constant AMOUNT u10000000000)
(define-constant THRESHOLD u1000)

;; variables
(define-data-var current-epoch uint u0)
(define-data-var last-burn-block uint u0)

(define-public (mint)
  (let (
      (last-mint (var-get last-burn-block))
      (blocks-elapsed (- burn-block-height last-mint))
      (total-lp (unwrap! (contract-call? .credit-token get-total-supply) ERR_SUPPLY))
      (caller-credit (unwrap! (contract-call? .credit-token get-balance contract-caller) ERR_BALANCE))
      (min-credit (/ total-lp THRESHOLD))
    )
    (begin
      (asserts! (> total-lp u0) ERR_NO_LIQUIDITY)
      (asserts! (>= blocks-elapsed u1) ERR_EMISSION_INTERVAL)
      (asserts! (>= caller-credit min-credit) ERR_NOT_ELIGIBLE)
      (try! (contract-call? .street-token mint AMOUNT .street-rewards))
      (try! (contract-call? .street-rewards update-rewards-b AMOUNT))
      (var-set current-epoch (+ (var-get current-epoch) u1))
      (var-set last-burn-block burn-block-height)
      (ok {
        amount: AMOUNT,
        block: burn-block-height,
        epoch: (var-get current-epoch),
      })
    )
  )
)

(define-read-only (get-current-epoch)
  (ok (var-get current-epoch)))

(define-read-only (get-last-burn-block)
  (ok (var-get last-burn-block)))