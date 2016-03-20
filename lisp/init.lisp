(defpackage #:agatha-lib
  (:use #:cl #:buffalo #:cl-yaclyaml)
  (:export #:prepare-lexer #:read-configs))

(in-package #:agatha-lib)
(defvar *common-path* "./parsers/")

(defstruct (parser-def-model-t
            (:constructor make-pd-model)
            (:conc-name have-))
  terminals productions start-symbol name)

(defstruct (lexer-definition
            (:constructor make-lexer-def)
            (:conc-name))
  pattern
  token)

(defstruct (translator (:constructor make-translator)
                       (:conc-name))
  parser
  lexer)

(defvar *pattern-model* (make-pd-model :terminals t :productions t :start-symbol t :name t :name t))

(defparameter *translators-hash* (make-hash-table))
