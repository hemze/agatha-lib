(in-package #:agatha-lib)
;;----------------------------------------------------------
;; -- service

(defmacro print-complex (value)
  `(format t
           ,(concatenate 'string (string-upcase (symbol-name value))
                         ": ~a (type: ~a)~%")
           ,value (type-of ,value)))

(defun split-string (value &optional (sep #\Space))
  (declare (type character sep))
  (loop for i = 0 then (1+ j)
        as j = (position sep value :start i)
        collect (subseq value i j)
        while j))

(defun intern-action (value)
  (if (position #\Space value)
      ;; Assemble a list with definition the lambda,
      ;; complement with "#'" chars and evaluate
      ;; the result to recieve the function object
      (let* ((*stream* (make-string-input-stream value))
             (func
               (append '(function)
                       (list (loop as obj = (read-preserving-whitespace *stream* nil nil)
                                   while obj
                                   collect obj)))))
        (eval func))
      ;; Simply evaluate the code to make
      ;; a function object
      (let* ((*stream* (make-string-input-stream "test"))
             (func (append '(function) (list (read-preserving-whitespace *stream* nil nil)))))
        (eval func))))

(defun intern-it (value)
  (if (position #\Space value)
      (intern-list-elems (split-string value))
      (intern (string-upcase value))))

(defun intern-list-elems (lst)
  (loop for item in lst
        collecting (intern-it item)))

(defun intern-joint (h)
  (loop for val being the hash-values of h
        collect
        (let* ((res)
               (v (intern-it (gethash "value" val)))
               (act-str (gethash "action" val))
               (a (when act-str
                    (intern-action act-str))))
          (cond
            ((eql (type-of v) 'CONS)
             (loop for i in v do (push i res)))
            (t
             (push v res)))
          (if a
              (append (nreverse res) (list a))
              (nreverse res)))))

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

;; -- service
;;----------------------------------------------------------
