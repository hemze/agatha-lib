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

(defun walk-through-hash (hash)
;;  (format t "Type: ~a;" (type-of hash))
  (let ((result '()))
    ;;(dolist (hash list-of-hashes)
      (cond
        ((eql (type-of hash) 'HASH-TABLE)
         (loop for key being the hash-keys of hash
                 using (hash-value value)
               do
                  (cond
                    ((eql (type-of value) 'CONS)
                     (format t "Type: ~a~%" (type-of value))
                     (return-from walk-through-hash (append result (cons key (walk-through-hash value))))
                     )
                    (t
                     (format t "Another-2: ~a~%" (type-of value))))))
        (t
         (format t "Another-1: ~a~%" (type-of hash))
         (return-from walk-through-hash (list hash))
         ))))


(defun read-config (filename)
  (let ((doc (cl-yy::yaml-load-file filename)))
    (dolist (hash doc)
      (loop for key being the hash-keys of hash
              using (hash-value value)
            do
               (cond
                 ((string= key "productions")
                  (walk-through-hash (gethash "productions" hash)))
                 (t
                  (format t "Key: ~a~%" key)))))))
;;
;;       (loop for key being the hash-keys of hash
;;             do
;; ;               (format t "Key: ~a. Value: ~a~%" key (gethash key hash))))))
;;                (dolist (h (gethash key hash))
;;                  (loop for k being the hash-keys of h
;;                        do
;;                           (format t "Key: ~a. Value: ~a~%" k (gethash k h)))))))
  )

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
