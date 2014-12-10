#lang racket

(define ssid-db '())

(define (add-to-list ssid prevsuccess)
  (set! ssid-db (append ssid-db (list (list ssid prevsuccess (current-inexact-milliseconds))))))

(define (check-for-network ssid db)
  (cond ((null? db) "No Previous Connection Attempts")
        ((and (equal? ssid (car (car db))) (equal? (car (cdr (car db))) #f)) "Bad Connection")
        ((and (equal? ssid (car (car db))) (equal? (car (cdr (car db))) #t)) "Good Connection")
        (else (check-for-network ssid (cdr db)))))

(define (prune-db network-age)
  (define (prune-iter db newdb)
    (cond ((null? db) newdb)
      ((> (current-inexact-milliseconds) (+ (car (cdr (cdr (car db)))) network-age)) 
         (prune-iter (cdr db) (append newdb (list (car db)))))
        (else (prune-iter (cdr db) newdb))))
  (set! ssid-db (prune-iter ssid-db '())))

;(define (prune-db)
 ; (map (lambda (x) (< (current-inexact-milliseconds) (- (car (cdr (cdr x))) 25000))) ssid-db))
  
;(define (score-con ssid key quality prevsuccess)
;  (cond ((eq? #t prevsuccess) (+ 2 quality))
;        ((eq? #t key) quality)
;        (else (+ 1 quality))))

;(define (list-ssid ssid prevsuccess)
;  (list ssid prevsuccess)

;(define (add-to-list ssid key quality prevsuccess)
;  (set! ssid-db (append ssid-db (list (list-ssid ssid key quality prevsuccess))))
;  (set! ssid-db (sort ssid-db #:key cadr >)))

;(define (get-best-ssid)
;retrieves connection with highest score; deletes connection if connection attempt fails
;  (cond ((null? ssid-db) (display "No Connections Available"))
;    ((equal? "Connection Failed" (test-connect (car ssid-db)))
;       (set! ssid-db (cdr ssid-db))
;       (get-best-ssid))
;    (else (car ssid-db))))

;(define (test-connect ssid)
;  1)