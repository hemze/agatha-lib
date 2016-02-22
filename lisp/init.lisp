(defpackage #:agatha-lib
  (:use #:cl #:buffalo #:cl-yaclyaml)
  (:export #:make-parser-macro #:read-configs))

(in-package #:agatha-lib)
(defvar *common-path* "./parsers/")
