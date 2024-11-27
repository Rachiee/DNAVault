;; Genomic Data Marketplace
;; Implements a decentralized marketplace for genomic data

;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INVALID-DATASET (err u2))
(define-constant ERR-ALREADY-PROCESSED (err u3))
(define-constant ERR-PAYMENT-FAILED (err u4))
(define-constant ERR-INVALID-PARAMS (err u5))
(define-constant ERR-INVALID-PRICE (err u6))
(define-constant ERR-INVALID-REQUEST (err u7))
(define-constant ERR-RESEARCHER-NOT-FOUND (err u8))
(define-constant ERR-INVALID-SCORE (err u9))

;; Configuration Constants
(define-constant MAX-PRICE u1000000000000) ;; 1 million STX
(define-constant MAX-REQUEST-ID u1000000)

;; Data Variables
(define-data-var dataset-count uint u0)

;; Maps
(define-map datasets
    uint
    {
        owner: principal,
        encrypted-data-hash: (string-utf8 256),
        metadata-hash: (string-utf8 256),
        price: uint,
        is-available: bool
    }
)

(define-map dataset-access {dataset-id: uint, researcher: principal} bool)

(define-map researchers
    principal
    {
        name: (string-utf8 100),
        institution: (string-utf8 100),
        credentials: (string-utf8 256),
        is-verified: bool,
        reputation-score: uint
    }
)

(define-map access-requests
    {dataset-id: uint, request-id: uint}
    {
        researcher: principal,
        approved: bool,
        processed: bool
    }
)

(define-map researcher-contributions principal uint)

;; Governance
(define-data-var contract-owner principal tx-sender)

;; Validation Functions
(define-private (validate-price (price uint))
    (and (> price u0) (<= price MAX-PRICE)))

(define-private (validate-request-id (request-id uint))
    (<= request-id MAX-REQUEST-ID))

(define-private (validate-researcher (researcher principal))
    (is-some (map-get? researchers researcher)))

(define-private (validate-score (score uint))
    (<= score u100))

;; Authorization check
(define-private (is-contract-owner)
    (is-eq tx-sender (var-get contract-owner)))

;; Dataset Management
(define-public (register-dataset 
    (encrypted-data-hash (string-utf8 256))
    (metadata-hash (string-utf8 256))
    (price uint))
    (let
        ((dataset-id (var-get dataset-count)))
        (asserts! (validate-price price) ERR-INVALID-PRICE)
        (asserts! (and
            (> (len encrypted-data-hash) u0)
            (> (len metadata-hash) u0))
            ERR-INVALID-PARAMS)
        
        (begin
            (map-set datasets dataset-id
                {
                    owner: tx-sender,
                    encrypted-data-hash: encrypted-data-hash,
                    metadata-hash: metadata-hash,
                    price: price,
                    is-available: true
                })
            (var-set dataset-count (+ dataset-id u1))
            (ok dataset-id))))

;; Researcher Registration
(define-public (register-researcher 
    (name (string-utf8 100))
    (institution (string-utf8 100))
    (credentials (string-utf8 256)))
    (if (and
            (> (len name) u0)
            (> (len institution) u0)
            (> (len credentials) u0))
        (begin
            (map-set researchers tx-sender
                {
                    name: name,
                    institution: institution,
                    credentials: credentials,
                    is-verified: false,
                    reputation-score: u0
                })
            (ok true))
        ERR-INVALID-PARAMS))

;; Access Management
(define-public (request-access (dataset-id uint))
    (let ((dataset (unwrap! (map-get? datasets dataset-id) ERR-INVALID-DATASET)))
        (if (get is-available dataset)
            (begin
                (map-set access-requests 
                    {dataset-id: dataset-id, request-id: u0}
                    {
                        researcher: tx-sender,
                        approved: false,
                        processed: false
                    })
                (ok true))
            ERR-INVALID-DATASET)))

(define-public (approve-access (dataset-id uint) (request-id uint))
    (let
        (
            (dataset (unwrap! (map-get? datasets dataset-id) ERR-INVALID-DATASET))
            (request (unwrap! (map-get? access-requests {dataset-id: dataset-id, request-id: request-id}) ERR-INVALID-DATASET))
        )
        (asserts! (validate-request-id request-id) ERR-INVALID-REQUEST)
        (asserts! (and
            (is-eq (get owner dataset) tx-sender)
            (not (get processed request)))
            ERR-NOT-AUTHORIZED)
        
        (begin
            (map-set access-requests
                {dataset-id: dataset-id, request-id: request-id}
                {
                    researcher: (get researcher request),
                    approved: true,
                    processed: true
                })
            (map-set dataset-access
                {dataset-id: dataset-id, researcher: (get researcher request)}
                true)
            (ok true))))

;; Researcher Verification
(define-public (verify-researcher (researcher principal))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (asserts! (validate-researcher researcher) ERR-RESEARCHER-NOT-FOUND)
        
        (match (map-get? researchers researcher)
            researcher-data (begin
                (map-set researchers researcher
                    (merge researcher-data {is-verified: true}))
                (ok true))
            ERR-INVALID-PARAMS)))

;; Reputation Management
(define-public (update-reputation (researcher principal) (score uint))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (asserts! (validate-researcher researcher) ERR-RESEARCHER-NOT-FOUND)
        (asserts! (validate-score score) ERR-INVALID-SCORE)
        
        (match (map-get? researchers researcher)
            researcher-data (begin
                (map-set researchers researcher
                    (merge researcher-data {reputation-score: score}))
                (ok true))
            ERR-INVALID-PARAMS)))

;; Read-only functions
(define-read-only (get-dataset-details (dataset-id uint))
    (map-get? datasets dataset-id))

(define-read-only (get-researcher-profile (researcher principal))
    (map-get? researchers researcher))

(define-read-only (get-access-status (dataset-id uint) (researcher principal))
    (default-to false
        (map-get? dataset-access {dataset-id: dataset-id, researcher: researcher})))