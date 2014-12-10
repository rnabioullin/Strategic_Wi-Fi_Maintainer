#lang racket

(require racket/include)
(include "Score.rkt")
(include "networking.rkt")

;Enables Wi-Fi
(enable-Wi-Fi)

(define (connectivity-loop db)
  (cond ((null? db) (display "No Connections Currently Available"))
        ((equal? (check-for-network (car (car db))) 0) 
         (configure-Wi-Fi (car (car db)))
         (cond ((equal? (Internet-connectivity-is-available) #f)
                (add-to-list (car (car db)) #f))
               (else (add-to-list (car (car db)) #t)))
        ((equal? (check-for-network (car (car db))) #t)
         (configure-Wi-Fi (car (car db))))
        ((equal? (check-for-network (car (car db))) #f)
         (connectivity-loop (cdr db))))))
        
(define (ping-loop)
  (cond ((equal? (Internet-connectivity-is-available) #t)
       (sleep 10)
       (ping-loop))
      (else null)))

(for ((i (in-naturals)))
  (connectivity-loop ((sort (scan-insecure-Wi-Fi) #:key cadr >)))
  (ping-loop))