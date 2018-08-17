;; Copyright 2018 Sergey S. Betke <sergey.s.betke@yandex.ru>
;; See LICENSE at https://github.com/Metrolog/marks

(define-module (stamps)
  #:version (2 3 0)
  #:export (range month quarter)
  #:use-module (ice-9 list)
)

(define (range from to)
  (map (lambda (x) (+ from x)) (iota (+ 1 (- to from))))
)

(define (month index)
  index
)

(define (quarter index)
  (list-ref '(I II III IV) (- index 1))
)
