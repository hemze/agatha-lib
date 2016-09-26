(in-package #:agatha-lib)
(require 'cl-yaclyaml)

(defun read-app-config (path)
  (setf *config* (cl-yy::yaml-load-file path))
  (cond
    ((null (gethash "parsers-path" *config*))
     (setf (gethash "parsers-path" *config*) *default-config-path*))
    ((null (gethash "input-path" *config*))
     (setf (gethash "input-path" *config*) *default-input-path*)))
  )

(defun start-parsing (&optional (path *default-app-config-path*))
  (read-app-config path)
  ;; read all parsing settings and generate relative parsers
  (read-configs (gethash "parsers-path" *config*))
  (read-input-files (gethash "input-path" *config*)))
