(defpackage #:agatha-lib
  (:use #:cl #:buffalo #:cl-yaclyaml)
  (:export #:prepare-lexer #:read-configs))

(in-package #:agatha-lib)
(defvar *common-path* "./parsers/")

(defstruct (parser-def-model-t
            (:constructor make-pd-model)
            (:conc-name have-))
  terminals productions start-symbol name)

(defstruct (lexer-def-t
            (:constructor make-lexer-def))
  pattern
  token)

(defvar *pattern-model* (make-pd-model :terminals t :productions t :start-symbol t :name t :name t))
