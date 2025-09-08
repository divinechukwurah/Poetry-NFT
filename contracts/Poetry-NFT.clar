;; Poetry NFT Smart Contract
;; Users submit poetry lines that get combined into collaborative poems

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-poem-not-found (err u101))
(define-constant err-line-too-long (err u102))
(define-constant err-empty-line (err u103))
(define-constant max-line-length u280)

;; Data Variables
(define-data-var next-poem-id uint u1)
(define-data-var next-line-id uint u1)

;; Data Maps
(define-map poems 
    uint 
    {
        title: (string-ascii 100),
        creator: principal,
        lines-count: uint,
        is-complete: bool,
        created-at: uint
    }
)

(define-map poem-lines
    uint
    {
        poem-id: uint,
        line-number: uint,
        content: (string-utf8 280),
        author: principal,
        submitted-at: uint
    }
)

(define-map user-poem-count principal uint)

;; NFT Definition
(define-non-fungible-token poetry-nft uint)

;; Read-only functions
(define-read-only (get-poem (poem-id uint))
    (map-get? poems poem-id)
)

(define-read-only (get-poem-line (line-id uint))
    (map-get? poem-lines line-id)
)

(define-read-only (get-user-poem-count (user principal))
    (default-to u0 (map-get? user-poem-count user))
)

(define-read-only (get-next-poem-id)
    (var-get next-poem-id)
)

(define-read-only (get-next-line-id)
    (var-get next-line-id)
)

;; Public functions
(define-public (create-poem (title (string-ascii 100)))
    (let ((poem-id (var-get next-poem-id)))
        (map-set poems poem-id {
            title: title,
            creator: tx-sender,
            lines-count: u0,
            is-complete: false,
            created-at: block-height
        })
        (var-set next-poem-id (+ poem-id u1))
        (ok poem-id)
    )
)

(define-public (submit-line (poem-id uint) (content (string-utf8 280)))
    (let (
        (line-id (var-get next-line-id))
        (poem-data (unwrap! (map-get? poems poem-id) err-poem-not-found))
        (line-length (len content))
    )
        ;; Validate line
        (asserts! (> line-length u0) err-empty-line)
        (asserts! (<= line-length max-line-length) err-line-too-long)
        (asserts! (not (get is-complete poem-data)) (err u104))

        ;; Add line
        (map-set poem-lines line-id {
            poem-id: poem-id,
            line-number: (+ (get lines-count poem-data) u1),
            content: content,
            author: tx-sender,
            submitted-at: block-height
        })

        ;; Update poem
        (map-set poems poem-id (merge poem-data {
            lines-count: (+ (get lines-count poem-data) u1)
        }))

        (var-set next-line-id (+ line-id u1))
        (ok line-id)
    )
)

(define-public (complete-poem (poem-id uint))
    (let ((poem-data (unwrap! (map-get? poems poem-id) err-poem-not-found)))
        (asserts! (is-eq tx-sender (get creator poem-data)) err-owner-only)
        (asserts! (> (get lines-count poem-data) u0) (err u105))

        ;; Mark poem as complete
        (map-set poems poem-id (merge poem-data {
            is-complete: true
        }))

        ;; Mint NFT to creator
        (try! (nft-mint? poetry-nft poem-id tx-sender))

        ;; Update user poem count
        (map-set user-poem-count tx-sender 
            (+ (get-user-poem-count tx-sender) u1))

        (ok poem-id)
    )
)

(define-public (transfer-poem (poem-id uint) (recipient principal))
    (nft-transfer? poetry-nft poem-id tx-sender recipient)
)