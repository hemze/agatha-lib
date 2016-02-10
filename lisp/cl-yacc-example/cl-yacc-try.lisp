;;;; cl-yacc-try.lisp
(require 'yacc)
(defpackage #:cl-yacc-try
  (:use #:cl #:yacc))

(in-package #:cl-yacc-try)

(defun list-lexer (list)
  #'(lambda ()
      (let ((value (pop list)))
        (if (null value)
            (values nil nil)
            (let ((terminal
                    (cond ((member value '(+ - * / |(| |)|)) value)
                          ((integerp value) 'int)
                          ((symbolp value) 'id)
                          (t (error "Unexpected value ~S" value)))))
              (values terminal value))))))
;;; "cl-yacc-try" goes here. Hacks and glory await!
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun i2p (a b c)
    "Infix to prefix"
    (list b a c))

  (defun k-2-3 (a b c)
    "Second out of three"
    (declare (ignore a c))
    b)
  )

(define-parser *grammar-parser*
  (:start-symbol expression)
  (:terminals (global
               grammar-name
               grammar-context-name
               case-name
               context case-severity
               case-steps case-success
               case-fail |{| |}| |(| |)|))

  (expr_list (expr expr_list) ())

  (expr
   acase
   step
   action)

  (acase
   (|{| case_body |}|))
  (case_body
   )

(parse-with-lexer (cl-yacc-try::list-lexer '(x * - - 2 + 3 * y)) cl-yacc-try::*expression-parser*)
(+ (* X (- (- 2))) (* 3 Y))
