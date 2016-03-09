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

(defun read-config (filename)
  (let ((doc (cl-yy::yaml-load-file filename))
        (productions-def)
        (productions)
        (terminals)
        (start-symbol)
        (name)
        (precedence)
        (model (make-pd-model))
        (grammar)
        (parser))
    (dolist (hash doc)
      (loop for key being the hash-keys of hash
              using (hash-value value)
            do
               (cond
                 ((string= key "productions")
                  (setf productions-def (gather-productions value))
                  (if (> (list-length productions-def) 0)
                      (setf (have-productions model) t)))
                 ;;
                 ((string= key "name")
                  (setf name (intern-it value))
                  (if (> (length value) 0)
                      (setf (have-name model) t)))
                 ;;
                 ((string= key "terminals")
                  (setf terminals (gather-terminals value))
                  (if (> (list-length terminals) 0)
                      (setf (have-terminals model) t)))
                 ;;
                 ((string= key "start-symbol")
                  (setf start-symbol (intern-it value))
                  (if (> (length value) 0)
                      (setf (have-start-symbol model) t)))
                 ;;
                 ((string= key "precedence")
                  (setf precedence value))
                 (t
                  (format t "Key: ~a~%" key)))))
    ;;
    ;; Check the completeness
    (unless (equalp model *pattern-model*)
      (format t "Somethin's wrong with the parser definition: ~%")
      (format t "Assembled: ~a~%" model)
      (format t "Pattern:   ~a~%+++~%" *pattern-model*))
    ;;
    (dolist (prod productions-def)
      (setf productions (append productions (nreverse (parse-prod prod)))))
    ;; (setf productions (nreverse productions))
    (print-complex productions)

    (setf grammar (make-grammar :name name
                                :start-symbol start-symbol
                                :terminals terminals
                                :precedence precedence
                                :productions productions))
    (setf parser (make-parser grammar))
    (print-complex parser)
    ;; (make-parser-macro
    ;;  :name name
    ;;  :terms terminals
    ;;  :prods productions
    ;;  :prec precedence
    ;;  :start-sym start-symbol)
    ;; (format t "Macro: ~a~%"
    ;;         (macroexpand-1 '(make-parser-macro
    ;;                          :name name
    ;;                          :terms terminals
    ;;                          :prods productions
    ;;                          :prec precedence
    ;;                          :start-sym start-symbol)))
    )
  )
(defun read-configs (&optional (path *common-path*))
  (normalize-path path)
  (loop for file in (directory
                     (concatenate 'string path *config-file-mask*))
        do (read-config file)))
