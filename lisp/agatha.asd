;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(asdf:defsystem #:agatha
  :description "Aided Generating of Auto Tests is HAndy"
  :author "Seymour Makarov <seymour.makarov@gmail.com>"
  :license "BSD-style"
  :serial t
  :version "1"
  :depends-on (#:yacc #:cl-yaclyaml #:closure-template)
  :components ((:file "init")
               (:file "service")
               (:file "prepare-data")
               (:file "lexer-gen")
               (:file "parser-config-parser")
               ;; (:file "prepare-output-env")
               (:file "input-parser")
               (:file "front")))
