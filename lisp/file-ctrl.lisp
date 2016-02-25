(in-package #:agatha-lib)
(require 'cl-yaclyaml)

(defparameter *config-file-mask* "*.yml")

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

(defun gather-productions (obj result)
  (cond
    ((eql (type-of obj) 'HASH-TABLE)
     (loop for key being the hash-keys of obj
             using (hash-value value)
           do
              (cond
                ((eql (type-of value) 'CONS)
                 (let ((values))
                   (dolist (h value)
                     (setf values (append values
                                          (list
                                           (loop for val being the hash-values of h
                                                 collecting val)))))
                   (setf result (append result (list (cons key values))))))
                (t
                 (setf result (append result (list (list key value)))))))))
  result)

(defun print-hash (hash)
  (loop for key being the hash-keys of hash
          using (hash-value value)
        do
           (cond
             ((eql (type-of value) 'HASH-TABLE)
              (print-hash value))
             ((eql (type-of value) 'CONS)
              (dolist (obj value)
                (print-hash obj)))
             (t
              (format t "key: ~a, value: ~a~%" key value))
             )))

(defun read-config (filename)
  (let ((doc (cl-yy::yaml-load-file filename)) (result '()))
    (dolist (hash doc)
      (loop for key being the hash-keys of hash
              using (hash-value value)
            do
               (cond
                 ((string= key "productions")
                  (setf result (gather-productions value result)))
                 (t
                  (format t "Key: ~a~%" key)))))
    (format t "Result: ~a~%" result)))


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
