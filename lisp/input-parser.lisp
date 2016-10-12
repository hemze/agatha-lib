(in-package #:agatha-lib)
(require 'cl-yaclyaml)
(require 'closure-template)

(defparameter *general-input-path* "./input/")

(defun parse-input-with-context (input)
  (declare (type translatable input))
;;  (print-complex input)
  (let* ((action (action input))
         (context (intern (string-upcase (context input))))
         (translator
           (gethash context *translators-hash*)))
    (setf *temp-str* (copy-seq action))
    (if translator
        (let ((result (parse-with-lexer (symbol-function (lexer translator))
                                 (parser translator))))
          (if result
              (format nil "~a~%" result)
              (format t "::::::::::")))
        (format t "No translator found by key: ~a" context))
    )
  )

(defun parse-input-file (filename)
  (let ((doc (cl-yy::yaml-load-file filename))
        (commands))
    (setf commands (gethash "commands" doc))
    (dolist (cmd commands)
      (let ((input)
            (action (gethash "cmd" cmd))
            (context (gethash "context" cmd)))
        (format t "~%Translate action: <~a> in context of <~a>~%" action context)
        (setf input (make-input-object :action action
                                       :context context))
        (format t "~a~%" (parse-input-with-context input))
        )
      )
    ))

(defun read-input-files (path)
  ;; prepare templator to work
  (closure-template:compile-template :common-lisp-backend #P"tmpl/rf.tmpl") ;; parameterize it
  ;; make sure that given path is existing and proper
  (normalize-path path)
  ;; and do the thing!
  (loop for file in (directory
                     (concatenate 'string path "/" *input-file-mask*))
        do (progn
             (parse-input-file file))))
