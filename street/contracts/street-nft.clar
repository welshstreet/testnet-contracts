;; Welsh Street Genesis NFT

;; errors
(define-constant ERR_NOT_CONTRACT_OWNER  (err u991))
(define-constant ERR_NOT_AUTHORIZED      (err u992))
(define-constant ERR_NOT_FOUND           (err u993))
(define-constant ERR_NOT_OWNER           (err u994))
(define-constant ERR_MINT_CAP            (err u995))
(define-constant ERR_MAX_TOKENS_REACHED  (err u996))

;; constants
(define-constant MINT_CAP u21000)

;; token definition
(define-non-fungible-token welsh-street-genesis-nft uint)

;; variables
(define-data-var base-uri (string-ascii 256) "https://ipfs.io/ipfs/bafybeifgnlibngkzvd6nfryu57kf54logbj5dbbcvmznc45hv47pkxzjli/")
(define-data-var contract-owner principal tx-sender)

(define-map users principal (list 2 uint))

;; public functions
(define-public (mint (token-id uint) (recipient principal))
  (let ((existing-tokens (default-to (list) (map-get? users recipient))))
    (begin
      (asserts! (is-eq contract-caller .street-controller) ERR_NOT_AUTHORIZED)
      (asserts! (<= token-id MINT_CAP) ERR_MINT_CAP)
      (try! (nft-mint? welsh-street-genesis-nft token-id recipient))
      (map-set users recipient (unwrap! (as-max-len? (append existing-tokens token-id) u2) ERR_MAX_TOKENS_REACHED))
      (ok token-id)
    )
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (let ((owner (unwrap! (nft-get-owner? welsh-street-genesis-nft token-id) ERR_NOT_FOUND)))
    (begin
      (asserts! (is-eq owner sender) ERR_NOT_OWNER)
      (asserts! (is-eq tx-sender sender) ERR_NOT_AUTHORIZED)
      (try! (nft-transfer? welsh-street-genesis-nft token-id sender recipient))
      (ok true)
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

(define-public (set-base-uri (new-uri (string-ascii 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_CONTRACT_OWNER)
    (var-set base-uri new-uri)
    (ok true)
  )
)

;; read-only functions
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner)))

(define-read-only (get-token-owner (token-id uint))
  (ok (nft-get-owner? welsh-street-genesis-nft token-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get base-uri) (int-to-ascii token-id)) ".json"))))

(define-read-only (get-base-uri)
  (ok (var-get base-uri)))

(define-read-only (get-user-minted-tokens (user principal))
  (ok (map-get? users user)))