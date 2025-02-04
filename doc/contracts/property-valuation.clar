(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INVALID-VALUATION (err u101))

;; Property valuation request structure
(define-map property-valuations
  {property-id: uint}
  {
    requester: principal,
    current-valuation: uint,
    valuation-count: uint,
    total-valuation: uint
  }
)

;; Submit a property valuation
(define-public (submit-valuation 
  (property-id uint)
  (valuation-amount uint)
)
  (begin
    (asserts! (> valuation-amount u0) ERR-INVALID-VALUATION)
    
    (match (map-get? property-valuations {property-id: property-id})
      existing-valuation
      (let ((new-total (+ (get total-valuation existing-valuation) valuation-amount))
            (new-count (+ (get valuation-count existing-valuation) u1)))
        (map-set property-valuations 
          {property-id: property-id}
          {
            requester: (get requester existing-valuation),
            current-valuation: (/ new-total new-count),
            valuation-count: new-count,
            total-valuation: new-total
          }
        )
        (ok true))
      
      ;; First valuation for this property
      (begin
        (map-set property-valuations 
          {property-id: property-id}
          {
            requester: tx-sender,
            current-valuation: valuation-amount,
            valuation-count: u1,
            total-valuation: valuation-amount
          }
        )
        (ok true))
    )
  )
)

;; Get current property valuation
(define-read-only (get-property-valuation (property-id uint))
  (map-get? property-valuations {property-id: property-id})
)
