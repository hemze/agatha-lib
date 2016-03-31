(in-package #:agatha-lib)

(defun parse-prod (form)
  (let ((symbol (car form))
        (productions '()))
    (dolist (stuff (cdr form))
      (cond
        ((and (symbolp stuff) (not (null stuff)))
         (push (make-production symbol (list stuff)
                                :action #'identity :action-form '#'identity)
               productions))
        ((listp stuff)
         (let ((l (car (last stuff))))
           (let ((rhs (if (symbolp l) stuff (butlast stuff)))
                 (action (if (symbolp l) '#'list l)))
             (push (make-production symbol rhs
                                    :action (eval action)
                                    :action-form action)
                   productions))))
        (t (error "Unexpected production ~S" stuff))))
    productions))

(defun gather-productions (obj)
  (let ((result))
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
                                            (intern-joint h))))
                     (setf result (append result (list (cons (intern-it key) values))))))
                  (t
                   (setf result (append result (list (list (intern-it key) (intern-it value))))))))))
    result))

(defun gather-terminals (terms)
  (if (eql (type-of terms) 'CONS)
      (loop for term in terms
            collect (intern-it term))
      (intern-it terms))
  )

(defun gather-lexer-defs (obj)
  (loop for key being the hash-keys of obj
          using (hash-value value)
        collect (make-lexer-def :pattern value :token (intern (string-upcase key)))))
