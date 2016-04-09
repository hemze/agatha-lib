(in-package #:agatha-lib)

(defun parse (filename)
  (read-configs)
  (parse-input filename))
