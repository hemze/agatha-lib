(in-package #:agatha-lib)
(require 'cl-yaclyaml)

(defparameter *general-input-path* "./input/")

(defun read-input-files (&optional (path *general-input-path*))
  (normalize-path path)
  (loop for file in (directory
                     (concatenate 'string path *config-file-mask*))
        do (parse-input file)))


(defun parse-input (filename)
  (let ((doc (cl-yy::yaml-load-file filename))
        (suite-name)
        (run-cmd)
        (cases)
        (prepare-cmd)
        (test-start-ready))
    (setf run-cmd (gethash "run_cmd" doc))
    (setf cases (gethash "cases" doc))
    (dolist (test-case cases)
      (let ((steps (gethash "steps" test-case)))
        (dolist (step steps)
          (let ((input)
                (action (gethash "action" step))
                (context (gethash "context" step)))
            (setf input (make-input-object :action action
                                           :context context))
            (parse-input-with-context input))
          )))
    ))
