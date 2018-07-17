;; Copyright 2018 Sergey S. Betke <sergey.s.betke@yandex.ru>
;; See LICENSE at https://github.com/Metrolog/marks

(define-module (stamps)
  #:version (2 3 0)
  #:export (range)
)

(define (range from to)
  (map (lambda (x) (+ from x)) (iota (+ 1 (- to from))))
)
