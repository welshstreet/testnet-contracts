;; Welsh Street Token

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token street)

;; errors
(define-constant ERR_ZERO_AMOUNT (err u900))
(define-constant ERR_NOT_CONTRACT_OWNER (err u901))
(define-constant ERR_NOT_TOKEN_OWNER (err u902))
(define-constant ERR_EMISSION_INTERVAL (err u903))
(define-constant ERR_EXCEEDS_TOTAL_SUPPLY (err u904))
(define-constant ERR_EXCEEDS_STREET_MINT_CAP (err u905))
(define-constant ERR_NO_LIQUIDITY (err u906))
(define-constant ERR_INVALID_AMOUNT (err u907))
(define-constant ERR_NOT_CAPITAL_ADDRESS (err u908))
(define-constant ERR_LOCKED_CAPITAL_ADDRESS (err u909))
(define-constant ERR_KILL_SWITCH_FLIPPED (err u911))

;; metadata
(define-constant BASIS u10000)
(define-constant STREET_MINT_CAP u5000000000000000)
(define-constant TOKEN_DECIMALS u6)
(define-constant TOKEN_NAME "Welsh Street Token")
(define-constant TOKEN_SYMBOL "STREET")
(define-constant TOKEN_SUPPLY u10000000000000000)

;; emissions
(define-constant EMISSION_AMOUNT u10000000000)
(define-constant MAX_CAPITAL_RATE u5000)
(define-constant MIN_CAPITAL_RATE u0)

;; variables
(define-data-var capital-rate uint u1000)
(define-data-var contract-owner principal tx-sender)
(define-data-var emission-controller principal tx-sender)
(define-data-var emission-epoch uint u0)
(define-data-var kill-switch bool false)
(define-data-var last-mint-block uint u0)
(define-data-var street-minted uint u0)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://gateway.lighthouse.storage/ipfs/bafkreibc3v7iih35rfcx66gr4zam74ucet4zy65shrap4jmpr3hsddkvb4"))

;; capital account
(define-data-var capital-address principal (var-get contract-owner))

(define-public (emission-mint)
  (let (
      (capital-addr (var-get capital-address))
      (last-mint (var-get last-mint-block))
      (total-supply-lp (unwrap-panic (contract-call? .credit-token get-total-supply)))
      (rate (var-get capital-rate))
      (capital (/ (* EMISSION_AMOUNT rate) BASIS))
      (rewards (- EMISSION_AMOUNT capital))
    )
    (begin
      (asserts! (> total-supply-lp u0) ERR_NO_LIQUIDITY)
      (asserts! (not (is-eq burn-block-height last-mint)) ERR_EMISSION_INTERVAL)
      (asserts! (is-eq tx-sender (var-get emission-controller)) ERR_NOT_CONTRACT_OWNER)
      (asserts! (or 
        (not (var-get kill-switch)) 
        (<= (+ (ft-get-supply street) EMISSION_AMOUNT) TOKEN_SUPPLY)) ERR_KILL_SWITCH_FLIPPED)
        (try! (ft-mint? street rewards .street-rewards))
        (if (> capital u0)
          (try! (ft-mint? street capital capital-addr))
          true
        )
      (var-set emission-epoch (+ (var-get emission-epoch) u1))
      (var-set last-mint-block burn-block-height)
      (ok {
        capital: capital,  
        rewards: rewards,
        block: burn-block-height,
        epoch: (var-get emission-epoch),
        })
    )
  )
)

(define-public (set-capital-address (new-address principal))
  (begin
    (asserts! (is-eq (var-get capital-address) tx-sender) ERR_NOT_CAPITAL_ADDRESS)
      (var-set capital-address new-address)
      (ok true)
    )
  )

(define-public (set-capital-rate (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (asserts! (>= amount MIN_CAPITAL_RATE) ERR_INVALID_AMOUNT)
    (asserts! (<= amount MAX_CAPITAL_RATE) ERR_INVALID_AMOUNT)
    (var-set capital-rate amount)
    (ok amount)
  )
)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (var-set contract-owner new-owner)
    (ok true)
  )
)

(define-public (set-emission-controller (new-controller principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (var-set emission-controller new-controller)
    (ok true)
  )
)

(define-public (set-kill-switch)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (asserts! (is-eq (var-get kill-switch) false) ERR_KILL_SWITCH_FLIPPED)
    (var-set kill-switch true)
    (ok true)
  )
)

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (var-set token-uri (some value))
    (ok true)
  )
)

(define-public (street-mint (amount uint))
  (begin
    (asserts! (> amount u0) ERR_ZERO_AMOUNT)
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (asserts! (<= (+ (var-get street-minted) amount) STREET_MINT_CAP) ERR_EXCEEDS_STREET_MINT_CAP)
    (asserts! (<= (+ (ft-get-supply street) amount) TOKEN_SUPPLY) ERR_EXCEEDS_TOTAL_SUPPLY)
    (try! (ft-mint? street amount tx-sender))
    (var-set street-minted (+ (var-get street-minted) amount))
    (ok {
      amount: amount,
    })
  )
)

(define-public (transfer
    (amount uint)
    (sender principal)
    (recipient principal)
    (memo (optional (buff 34)))
  )
  (begin
    (asserts! (> amount u0) ERR_ZERO_AMOUNT)
    (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
    (try! (ft-transfer? street amount sender recipient))
    (match memo content (print content) 0x)
    (ok true)
  )
)

;; custom read-only
(define-read-only (get-capital-address)
  (ok (var-get capital-address)))

(define-read-only (get-capital-rate)
  (ok (var-get capital-rate)))

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner)))

(define-read-only (get-current-epoch)
  (ok (var-get emission-epoch)))

(define-read-only (get-emission-controller)
  (ok (var-get emission-controller)))

(define-read-only (get-kill-switch)
  (ok (var-get kill-switch)))

(define-read-only (get-last-mint-block)
  (ok (var-get last-mint-block)))

(define-read-only (get-street-minted)
  (ok (var-get street-minted)))

;; standard read-only
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance street who)))

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS))

(define-read-only (get-name)
  (ok TOKEN_NAME))

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL))

(define-read-only (get-token-uri)
  (ok (var-get token-uri)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply street)))