(in-package #:agatha-lib)

(defparameter *config-file-mask* "*.conf")

(defun normalize-path (path)
  (let ((last-ind (1- (length path))))
    (loop
      do
         (cond
           ((or
             (char= (elt path last-ind) #\/)
             (char= (elt path last-ind) #\\))
            (setf path (subseq path 0 last-ind)
                  last-ind (1- last-ind)))
           (t
            (return path))))))

(defun read-config (filename)
  (with-open-file (stream filename)
;    (loop for line = (read-line stream nil)
;          while line do
;            (with-input-from-string (stream line)
    (parse-with-lexer (lexer stream) *grammar-parser*)))
;))

(defun read-configs (&optional (path *common-path*))
  (normalize-path path)
  (loop for file in (directory
                     (concatenate 'string path *config-file-mask*))
        do (read-config file)))
