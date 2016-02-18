;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(asdf:defsystem #:agatha
  :description "Aided Generating of Auto Tests. HAndy"
  :author "Seymour Makarov <seymour.makarov@gmail.com>"
  :license "BSD-style"
  :serial t
  :version "1"
  :depends-on (#:yacc)
  :components ((:file "init")
               (:file "file-ctrl")
               (:file "parser-def")))
