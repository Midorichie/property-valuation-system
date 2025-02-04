(define-fungible-token property-valuation-token)

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))
(define-constant ERR-TRANSFER-FAILED (err u102))

;; Reward configuration
(define-data-var token-per-valuation uint u10)
(define-data-var total-rewards-distributed uint u0)

;; Tracks contributor rewards
(define-map contributor-rewards
  {contributor: principal}
  {total-rewards: uint}
)

;; Distribute rewards for property valuation
(define-public (distribute-valuation-reward (contributor principal))
  (begin
    ;; Ensure only the contract can distribute rewards
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    
    (let ((reward-amount (var-get token-per-valuation)))
      (match (ft-mint? property-valuation-token reward-amount contributor)
        success 
        (begin
          ;; Update total rewards distributed
          (var-set total-rewards-distributed 
            (+ (var-get total-rewards-distributed) reward-amount))
          
          ;; Update contributor's total rewards
          (map-set contributor-rewards
            {contributor: contributor}
            {total-rewards: 
              (+ (default-to u0 
                   (get total-rewards 
                     (map-get? contributor-rewards {contributor: contributor})))
                 reward-amount)
            }
          )
          (ok u1))  ;; Changed to return a consistent uint response
        error (err u103)  ;; Added a new error code for mint failure
      )
    )
  )
)

;; Allow token transfers
(define-public (transfer 
  (amount uint) 
  (sender principal) 
  (recipient principal)
)
  (begin
    (asserts! 
      (or 
        (is-eq tx-sender sender)
        (is-eq contract-caller sender)
      ) 
      ERR-UNAUTHORIZED
    )
    (ft-transfer? property-valuation-token amount sender recipient)
  )
)

;; Read-only functions
(define-read-only (get-total-rewards-distributed)
  (var-get total-rewards-distributed)
)

(define-read-only (get-contributor-rewards (contributor principal))
  (default-to {total-rewards: u0} 
    (map-get? contributor-rewards {contributor: contributor}))
)

(define-read-only (get-token-balance (account principal))
  (ft-get-balance property-valuation-token account)
)
