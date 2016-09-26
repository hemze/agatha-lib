(in-package #:agatha-lib)
(require 'cl-ppcre)

(defun make-cond-body (name defs)
  "Assemble the lexer function body with
COND form checking for matching the
regexp and the match starting at the begining
of the input string. If so return the token
it refers to and the value matched"
  `(let ((val))
     (cond
       ,@(loop for def in defs
               collect
               `((multiple-value-bind (start end)
                     (cl-ppcre:scan (pattern ,def) *temp-str*)
                   (if (and start end (= start 0))
                       (progn
                         (setf val (subseq *temp-str* start end))
                         (setf *temp-str* (string-trim
                                           '(#\Space)
                                           (subseq *temp-str* end)))
                         t)
                       nil))
                 (format nil "~%------- A value returning: ~a~%" val)
                 (return-from ,name (values (token ,def) val))))
       (t (return-from ,name (values nil nil))))))

(defun prepare-lexer-code (name defs)
  (let ((func-name (intern name)))
    `(defun ,func-name ()
       ,(make-cond-body func-name defs))))
