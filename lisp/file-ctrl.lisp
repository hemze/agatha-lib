(in-package #:agatha-lib)
(require 'cl-yaclyaml)

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
  (let ((doc (cl-yy::yaml-load-file filename)))
    (dolist (hash doc)
      (loop for key being the hash-keys of hash
            do (print (gethash key hash))))))

  ;; (with-open-file (stream filename)

    ;; (loop for line = (read-line stream nil)
    ;;       while line
    ;;       do
    ;;          (with-input-from-string (line-stream line)
                ;; (parse-with-lexer
                ;;  #'(lambda() (lexer line-stream))
                ;;  *grammar-parser*))
          ;; ))


;;
;; productions:
;; write-file: write sentence to d-quotes file-name d-quotes #f = open("$6")\nf.write($2);
;; sentence:
;; empty
;; word sentence;
;; empty: ;


(defun read-configs (&optional (path *common-path*))
  (normalize-path path)
  (loop for file in (directory
                     (concatenate 'string path *config-file-mask*))
        do (read-config file)))
