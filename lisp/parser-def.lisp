(proclaim '(optimize (speed 0) (safety 3) (debug 3)))
(require 'buffalo)

(in-package #:agatha-lib)

;;(defvar *term-list* '(terminals productions precedence start-symbol))

(defmacro make-parser-macro (name terminals start-symbol productions &optional precedence)
;  (declare (symbol start-symbol))
  `(make-gramma ,name
     (:start-symbol ,start-symbol)
;     (:terminals terminals)
;     ,(if precedence
;          '(:precedence precedence))
     (productions)
  ))


(defmacro define-parse (name &body body)
  `(defparameter ,name
     (def-parser ,@body)))

(defmacro do-primes ((var start end) &body body)
  `(do ((,var (next-prime ,start) (next-prime (1+ ,var))))
       ((> ,var ,end))
     ,@body))
