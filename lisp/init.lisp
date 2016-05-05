(defpackage #:agatha-lib
  (:use #:cl #:yacc #:cl-yaclyaml)
  (:export #:start-parsing))

(in-package #:agatha-lib)

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

;; Predefined dynamic variables
(defparameter *config* (make-hash-table))
(defvar *pattern-model* (make-pd-model :terminals t :productions t :start-symbol t :name t :name t))

(defparameter *translators-hash* (make-hash-table))
(defparameter *default-app-config-path* "./config.yml")

(defparameter *input-file-mask* "*.yml")
(defparameter *app-config* nil)
(defparameter *temp-str* "")

(defparameter *default-parsers-path* "./parsers/")

(defparameter *default-dir-structure* '(test library variable resources data output))
