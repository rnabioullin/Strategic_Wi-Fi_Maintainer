;; filename: networking.rkt
;; description: interface to Wi-Fi networking functionality
;; author(s): Ruslan Nabioullin (rnabioul@cs.uml.edu)

#lang racket

(require racket/system)
(require (planet neil/sudo:1:1))

;; returns #t if Internet connectivity is available, and #f otherwise
(define (Internet-connectivity-is-available)
  (system "ping -c 1 www.google.com | grep \" 0% packet loss\""))

;; enables the Wi-Fi interface
;; returns nothing
(define (enable-Wi-Fi)
  (system*/sudo "/sbin/ifconfig"
		"wlan0"
		"up"))

;; scans for insecure Wi-Fi networks
;; returns a list of attributes of insecure Wi-Fi network(s) that are in range,
;; if any
(define (scan-insecure-Wi-Fi)
  '())

;; configures the Wi-Fi interface
;; argument "network_name"---a string specifiying the network name of the
;; network to connect to
;; returns nothing
(define (configure-Wi-Fi network_name)
  (system*/sudo "/sbin/iwconfig"
		"wlan0"
		"essid"
		network_name))

;; requests the IP address
;; returns nothing
(define (request-IP-address)
  (system*/sudo "/sbin/dhclient"
		"wlan0"))

;; Wi-Fi network name selector
;; argument "network"---the network attributes
;; returns the network name of "network"
(define (network-name network_attributes)
  (car network_attributes))

;; Wi-Fi network connection quality selector
;; argument "network"---the network attributes
;; returns the connection quality of "network"
(define (network-connection-quality network_attributes)
  (car (cdr network_attributes)))
