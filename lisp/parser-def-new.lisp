(proclaim '(optimize (speed 0) (safety 3) (debug 3)))
(require 'buffalo)

(in-package #:agatha-lib)

(defvar *term-list* '(terminals productions precedence start-symbol))

(defmacro make-parser-macro (&key name terminals start-symbol precedence productions)
  `(define-parser ,name
     (:start-symbol ,start-symbol)
     (:terminals ,terminals)
     ,(if precedence
          '(:precedence precedence))
     @(productions)
  ))
