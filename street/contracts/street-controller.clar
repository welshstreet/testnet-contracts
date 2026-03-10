;; Welsh Street Controller

;; errors
(define-constant ERR_NOT_CONTRACT_OWNER (err u981))
(define-constant ERR_ALREADY_MINTED     (err u982))
(define-constant ERR_MINT_CAP           (err u983))
(define-constant ERR_NO_LIQUIDITY       (err u984))
(define-constant ERR_YOU_POOR           (err u2))

;; constants
(define-constant MINT_BONUS u1000000000000)
(define-constant MINT_STREET    u100000000000)
(define-constant DONATE_WELSH   u1000000000)
(define-constant MINT_CAP            u21000)

;; variables
(define-data-var mint-count uint u0)
(define-data-var contract-owner principal tx-sender)

(define-map users principal uint)

(define-public (mint)
  (let (
      (user-welsh (unwrap-panic (contract-call? .welshcorgicoin get-balance tx-sender)))
      (total-lp (unwrap-panic (contract-call? .credit-token get-total-supply)))
      (count (+ (var-get mint-count) u1))
      (is-milestone (is-eq (mod count u21) u0))
      (mint-amount (if is-milestone MINT_BONUS MINT_STREET))
    )
    (begin
      (asserts! (> total-lp u0) ERR_NO_LIQUIDITY)
      (asserts! (>= user-welsh DONATE_WELSH) ERR_YOU_POOR)
      (asserts! (< (default-to u0 (map-get? users tx-sender)) u2) ERR_ALREADY_MINTED)
      (asserts! (<= count MINT_CAP) ERR_MINT_CAP)
      (try! (contract-call? .street-token mint mint-amount tx-sender))
      (try! (contract-call? .street-nft mint count tx-sender))
      (try! (contract-call? .welshcorgicoin transfer DONATE_WELSH tx-sender .street-rewards none))
      (try! (contract-call? .street-rewards update-rewards-a DONATE_WELSH))
      (map-set users tx-sender (+ (default-to u0 (map-get? users tx-sender)) u1))
      (var-set mint-count count)
      (ok {
        amount-a: DONATE_WELSH,
        amount-b: mint-amount, 
        block: burn-block-height,
        count: count,
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

;; custom read-only
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner)))

(define-read-only (get-mint-count)
  (ok (var-get mint-count)))