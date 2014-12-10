#lang racket

(define ssid-db '())

(define (score-con ssid key quality prevsuccess)
  (cond ((eq? #t prevsuccess) (+ 2 quality))
        ((eq? #t key) quality)
        (else (+ 1 quality))))

(define (list-ssid ssid key quality prevsuccess)
  (list ssid (score-con ssid key quality prevsuccess) key quality prevsuccess))

(define (add-to-list ssid key quality prevsuccess)
  (set! ssid-db (append ssid-db (list (list-ssid ssid key quality prevsuccess))))
  (set! ssid-db (sort ssid-db #:key cadr >)))

(define (get-best-ssid)
;retrieves connection with highest score; deletes connection if connection attempt fails
  (cond ((null? ssid-db) (display "No Connections Available"))
    ((equal? "Connection Failed" (test-connect (car ssid-db)))
       (set! ssid-db (cdr ssid-db))
       (get-best-ssid))
    (else (car ssid-db))))

(define (test-connect ssid)
  1)