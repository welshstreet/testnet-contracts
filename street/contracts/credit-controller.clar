;; Welsh Street Credit Controller

(use-trait sip-010 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; errors
(define-constant ERR_ZERO_AMOUNT (err u900))
(define-constant ERR_NOT_CONTRACT_OWNER (err u901))
(define-constant ERR_NOT_TOKEN_OWNER (err u902))
(define-constant ERR_INSUFFICIENT_BALANCE (err u903))

;; variables
(define-data-var contract-owner principal tx-sender)

(define-public (transfer
    (amount uint) 
    (sender principal) 
    (recipient principal)
    (memo (optional (buff 34)))
    )
  (let (
    (sender-balance (unwrap! (contract-call? .credit-token get-balance sender) ERR_INSUFFICIENT_BALANCE))
  )
    (begin
      (asserts! (> amount u0) ERR_ZERO_AMOUNT)
      (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
      (asserts! (>= sender-balance amount) ERR_INSUFFICIENT_BALANCE)
      (try! (as-contract (contract-call? .credit-token transfer amount sender recipient memo)))
      (try! (as-contract (contract-call? .street-rewards decrease-rewards sender amount)))
      (try! (as-contract (contract-call? .street-rewards increase-rewards recipient amount)))
      (match memo content (print content) 0x)
      (ok {
        amount-lp: amount
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

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner)))