(defpackage #:agatha-lib
  (:use #:cl #:yacc #:cl-yaclyaml)
  (:export #:parse))

(in-package #:agatha-lib)

(defparameter *config-file-mask* "*.yml")
(defparameter *temp-str* "")

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

(defstruct (translatable (:constructor make-input-object)
                         (:conc-name))
  action
  context)

(defvar *pattern-model* (make-pd-model :terminals t :productions t :start-symbol t :name t :name t))

(defparameter *translators-hash* (make-hash-table))
