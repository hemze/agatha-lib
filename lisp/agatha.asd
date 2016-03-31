;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(asdf:defsystem #:agatha
  :description "Aided Generating of Auto Tests is HAndy"
  :author "Seymour Makarov <seymour.makarov@gmail.com>"
  :license "BSD-style"
  :serial t
  :version "1"
  :depends-on (#:yacc #:cl-yaclyaml)
  :components ((:file "init")
               (:file "service")
               (:file "validator")
               (:file "prepare-data")
               (:file "lexer-gen")
               (:file "file-ctrl")))
