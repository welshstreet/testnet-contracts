;; Welsh Street Faucet

(use-trait sip-010 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; errors
(define-constant ERR_ZERO_AMOUNT (err u900))
(define-constant ERR_NOT_CONTRACT_OWNER (err u901))
(define-constant ERR_INSUFFICIENT_BALANCE (err u902))
(define-constant ERR_TRANSFER_FAILED (err u903))
(define-constant ERR_COOLDOWN (err u904))

;; constants
(define-constant AMOUNT u10000000000000) ;; 10,000,000 welsh tokens (6 decimals)

;; variables
(define-data-var contract-owner principal tx-sender)
(define-data-var cooldown uint u420)

(define-map last-request
  { user: principal }
  { block: uint }
)

(define-public (request)
  (let (
    (recipient tx-sender)
  )
    (match (map-get? last-request { user: recipient })
      last-entry
        (begin
          (asserts! (>= (- stacks-block-height (get block last-entry)) (var-get cooldown)) ERR_COOLDOWN)
          (map-set last-request { user: recipient } { block: stacks-block-height })
          (try! (transformer .welshcorgicoin AMOUNT recipient))
          (ok true)
        )
      (begin
        (map-set last-request { user: recipient } { block: stacks-block-height })
        (try! (transformer .welshcorgicoin AMOUNT recipient))
        (ok true)
      )
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

(define-public (set-cooldown (blocks uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (var-set cooldown blocks)
    (ok { cooldown: blocks })
  )
)

(define-public (transformer
    (token <sip-010>)
    (amount uint)
    (recipient principal)
  )
  (as-contract (contract-call? token transfer amount tx-sender recipient none))
)

(define-public (withdraw (amount uint) (recipient principal))
  (begin
    (asserts! (> amount u0) ERR_ZERO_AMOUNT)
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (try! (transformer .welshcorgicoin amount recipient))
    (ok { amount: amount })
  )
)

;; custom read-only
(define-read-only (get-amount)
  (ok AMOUNT)
)

(define-read-only (get-balance)
  (contract-call? .welshcorgicoin get-balance (as-contract tx-sender))
)

(define-read-only (get-cooldown)
  (ok (var-get cooldown))
)

(define-read-only (get-last-request (user principal))
  (ok (map-get? last-request { user: user }))
)

(define-read-only (get-next-request (user principal))
  (match (map-get? last-request { user: user })
    last-entry
      (let ((blocks-since-request (- stacks-block-height (get block last-entry))))
        (if (>= blocks-since-request (var-get cooldown))
          (ok u0)
          (ok (- (var-get cooldown) blocks-since-request))
        )
      )
    (ok u0)
  )
)

(define-read-only (get-faucet-info (user principal))
  (let (
    (cooldown-period (var-get cooldown))
    (last-req (map-get? last-request { user: user }))
  )
    (match last-req
      last-entry
        (let ((blocks-since-request (- stacks-block-height (get block last-entry))))
          (ok {
            blocks-remaining: (if (>= blocks-since-request cooldown-period)
              u0
              (- cooldown-period blocks-since-request)
            ),
            cooldown: cooldown-period,
            last-request: (some (get block last-entry)),
          })
        )
      (ok {
        blocks-remaining: u0,
        cooldown: cooldown-period,
        last-request: none,
      })
    )
  )
)