;; filename: networking.rkt
;; description: interface to Wi-Fi networking functionality
;; author(s): Ruslan Nabioullin (rnabioul@cs.uml.edu)

(require racket/system)

;; returns #t if Internet connectivity is available, and #f otherwise
(define (Internet-connectivity-is-available)
;  (system "ping -c 1 www.google.com | grep \" 0% packet loss\""))
  (system "ping -c 1 192.168.1.1 | grep \" 0% packet loss\""))

;; enables the Wi-Fi interface
;; returns an undefined value
(define (enable-Wi-Fi)
  (system "ifconfig wlan0 up"))

;; scans for insecure Wi-Fi networks
;; returns a list of attributes of insecure Wi-Fi network(s) that are in range,
;; if any
(define (scan-insecure-Wi-Fi)
  (define (trim-iwlist-SSID SSID-list)
    (if (empty? SSID-list)
        '()
        (cons (string-trim (string-trim (car SSID-list)
                                        "                    ESSID:\"" #:right? #f)
                           "\"" #:left? #f)
              (trim-iwlist-SSID (cdr SSID-list)))))

  (define (trim-iwlist-security-status list)
    (if (empty? list)
        '()
        (cons (string-trim (car list) "                    Encryption key:" #:right? #f)
              (trim-iwlist-security-status (cdr list)))))

  (define (trim-iwlist-quality-status list)
    (if (empty? list)
        '()
        (cons (string-trim (string-trim (car list) "Quality=" #:right? #f)
                           "/70" #:left? #f)
              (trim-iwlist-quality-status (cdr list)))))

  (define scan-results-filename-raw (with-output-to-string
				      (lambda () (system "mktemp"))))
  ; strip the ending newline
  (define scan-results-filename
    (substring scan-results-filename-raw 0 (- (string-length
					       scan-results-filename-raw) 1)))
  (system (string-append "iwlist wlan0 scan > " scan-results-filename))
  (define SSIDs (with-output-to-string
		  (lambda () (system (string-append "grep ESSID "
						    scan-results-filename)))))
  (define security-status-list (with-output-to-string
                                (lambda () (system (string-append "grep \"Encryption key:\" "
                                                                  scan-results-filename)))))
  (define quality-list (with-output-to-string
                        (lambda () (system (string-append "grep Quality= "
                                                          scan-results-filename)))))
  (define SSID_list_processed (trim-iwlist-SSID (string-split SSIDs "\n")))
  (define security-status-list-processed (trim-iwlist-security-status
                                          (string-split security-status-list "\n")))
  (define quality-list-processed (trim-iwlist-quality-status (string-split quality-list)))

  (define (construct-networks list-name list-security-status list-quality)
    (cond ((empty? list-name) '())
          ((equal? (car list-security-status) "on")
           (construct-networks (cdr list-name) (cdr list-security-status)
                               (cdr (cdr (cdr (cdr list-quality))))))
          (else (cons (list (car list-name) (string->number (car list-quality)))
                (construct-networks (cdr list-name) (cdr list-security-status)
                               (cdr (cdr (cdr (cdr list-quality)))))))))

  (construct-networks SSID_list_processed security-status-list-processed quality-list-processed))

;; configures the Wi-Fi interface
;; argument "network_name"---a string specifiying the network name of the
;; network to connect to
;; returns an undefined value
(define (configure-Wi-Fi network_name)
  (write (string-append "connecting to " network_name))
  (newline)
  (system (string-append "iwconfig wlan0 essid " network_name)))

;; requests the IP address
;; returns an undefined value
(define (request-IP-address)
  (write "requesting IP address")
  (newline)
  (system "dhclient wlan0"))

;; Wi-Fi network name selector
;; argument "network_attributes"---the network attributes
;; returns the network name of "network_attributes"
(define (network-name network_attributes)
  (car network_attributes))

;; Wi-Fi network connection quality selector
;; argument "network_attributes"---the network attributes
;; returns the connection quality of "network_attributes", [0, 70] units
(define (network-connection-quality network_attributes)
  (car (cdr network_attributes)))
