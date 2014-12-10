;#lang racket

(define ssid-db '())

;;Adds a list containing the attributes of a network to the network db
(define (add-to-list ssid prevsuccess)
  (set! ssid-db (append ssid-db (list (list ssid prevsuccess (current-inexact-milliseconds))))))

;;Checks the network db for a network based on ssid, and
;;Returns an appropriate status based on whether or not
;;The network was previously connected to successfully
(define (check-for-network ssid db)
  (cond ((null? db) "No Previous Connection Attempts")
        ((and (equal? ssid (car (car db))) (equal? (car (cdr (car db))) #f)) "Bad Connection")
        ((and (equal? ssid (car (car db))) (equal? (car (cdr (car db))) #t)) "Good Connection")
        (else (check-for-network ssid (cdr db)))))

;;Removes all network entries from the database that are older than
;;a given time (in milliseconds) "network-age"
(define (prune-db network-age)
  (define (prune-iter db newdb)
    (cond ((null? db) newdb)
      ((> (current-inexact-milliseconds) (+ (car (cdr (cdr (car db)))) network-age)) 
         (prune-iter (cdr db) (append newdb (list (car db)))))
        (else (prune-iter (cdr db) newdb))))
  (set! ssid-db (prune-iter ssid-db '())))