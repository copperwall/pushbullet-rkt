#lang racket

(require json)
(require net/url)

;; pushbullet-rkt
;; A minimal racket library for interacting with Pushbullet.

;; URL definitions
(define DEVICES_URL "https://api.pushbullet.com/v2/devices")
(define CHATS_URL "https://api.pushbullet.com/v2/chats")
(define CHANNELS_URL "https://api.pushbullet.com/v2/channels")
(define ME_URL "https://api.pushbullet.com/v2/users/me")
(define PUSH_URL "https://api.pushbullet.com/v2/pushes")
(define UPLOAD_REQUEST_URL "https://api.pushbullet.com/v2/upload-request")
(define EPHERMERALS_URL "https://api.pushbullet.com/v2/ephemerals")

(struct pushbullet (token))

;; Make an authenticated GET request to the given url string.
(define (get pb url)
  (call/input-url (string->url url)
                  get-pure-port
                  read-json
                  (default-headers pb)))

;; Make an authenticated POST request to the given url string
;; using the data jsexpr as the request body.
(define (post pb url data . headers)
  (read-json (post-pure-port (string->url PUSH_URL)
                                (jsexpr->bytes data)
                                (default-headers pb))))

;; Create a list of default headers given a pushbullet struct.
;; This uses the token field of the pushbullet struct for
;; authentication.
(define (default-headers pb)
  (list "Content-Type: application/json"
        (string-append "Access-Token: " (pushbullet-token pb))))

;; Get a list of devices
(define (pb-get-devices pb)
  (hash-ref (get pb DEVICES_URL) 'devices))

;; Get a list of chats
(define (pb-get-chats pb)
  (hash-ref (get pb CHATS_URL) 'chats))

;; Get a hash of user information
(define (pb-get-user-info pb)
  (get pb ME_URL))

;; Get a list of channels
(define (pb-get-channels pb)
  (hash-ref (get pb CHANNELS_URL) 'channels))

;; Get a list of all pushes
(define (pb-get-pushes pb)
  (hash-ref (get pb PUSH_URL) 'pushes))

;; Send a push to all devices with the given title and body
(define (pb-push-note pb title body)
  (define note (hash 'type "note" 'title title 'body body))
  (post pb PUSH_URL note))
