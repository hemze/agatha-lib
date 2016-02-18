(defpackage #:agatha-lib
  (:use #:cl #:yacc)
  (:export #:run #:read-id #:lexer #:get-terminal #:read-special-sym #:read-configs))

(in-package #:agatha-lib)
(defvar *common-path* "./parsers/")
