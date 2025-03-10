;; Vehicle Registration Contract

;; Define data maps
(define-map vehicles
  { vehicle-id: (string-ascii 36) }
  {
    owner: principal,
    model: (string-ascii 50),
    registration-date: uint,
    status: (string-ascii 20)
  }
)

(define-data-var vehicle-count uint u0)

;; Register a new vehicle
(define-public (register-vehicle (vehicle-id (string-ascii 36)) (model (string-ascii 50)))
  (let ((caller tx-sender))
    (if (is-none (map-get? vehicles { vehicle-id: vehicle-id }))
      (begin
        (map-set vehicles
          { vehicle-id: vehicle-id }
          {
            owner: caller,
            model: model,
            registration-date: block-height,
            status: "active"
          }
        )
        (var-set vehicle-count (+ (var-get vehicle-count) u1))
        (ok true)
      )
      (err u403) ;; Vehicle ID already exists
    )
  )
)

;; Get vehicle details
(define-read-only (get-vehicle (vehicle-id (string-ascii 36)))
  (map-get? vehicles { vehicle-id: vehicle-id })
)

;; Update vehicle status
(define-public (update-vehicle-status (vehicle-id (string-ascii 36)) (new-status (string-ascii 20)))
  (let ((vehicle (map-get? vehicles { vehicle-id: vehicle-id })))
    (if (and (is-some vehicle) (is-eq tx-sender (get owner (unwrap-panic vehicle))))
      (begin
        (map-set vehicles
          { vehicle-id: vehicle-id }
          (merge (unwrap-panic vehicle) { status: new-status })
        )
        (ok true)
      )
      (err u404) ;; Vehicle not found or not authorized
    )
  )
)

;; Get total number of registered vehicles
(define-read-only (get-vehicle-count)
  (var-get vehicle-count)
)

