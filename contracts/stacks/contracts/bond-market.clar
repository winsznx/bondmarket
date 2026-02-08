;; BondMarket - P2P bond issuance and trading
(define-constant ERR-NOT-HOLDER (err u100))
(define-constant ERR-NOT-MATURED (err u101))

(define-map bonds
    { bond-id: uint }
    { issuer: principal, principal-amount: uint, interest-rate: uint, maturity-date: uint, holder: principal, repaid: bool }
)

(define-data-var bond-counter uint u0)

(define-public (issue-bond (principal-amount uint) (interest-rate uint) (duration uint))
    (let (
        (bond-id (var-get bond-counter))
    )
        (map-set bonds { bond-id: bond-id } {
            issuer: tx-sender,
            principal-amount: principal-amount,
            interest-rate: interest-rate,
            maturity-date: (+ block-height duration),
            holder: tx-sender,
            repaid: false
        })
        (var-set bond-counter (+ bond-id u1))
        (ok bond-id)
    )
)

(define-public (transfer-bond (bond-id uint) (to principal))
    (let (
        (bond (unwrap! (map-get? bonds { bond-id: bond-id }) ERR-NOT-HOLDER))
    )
        (asserts! (is-eq (get holder bond) tx-sender) ERR-NOT-HOLDER)
        (map-set bonds { bond-id: bond-id } (merge bond { holder: to }))
        (ok true)
    )
)

(define-public (repay-bond (bond-id uint))
    (let (
        (bond (unwrap! (map-get? bonds { bond-id: bond-id }) ERR-NOT-MATURED))
    )
        (asserts! (>= block-height (get maturity-date bond)) ERR-NOT-MATURED)
        (map-set bonds { bond-id: bond-id } (merge bond { repaid: true }))
        (ok true)
    )
)

(define-read-only (get-bond (bond-id uint))
    (map-get? bonds { bond-id: bond-id })
)
