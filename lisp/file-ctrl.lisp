(in-package #:agatha-lib)
(require 'cl-yaclyaml)
(require 'cl-ppcre)

(defparameter *config-file-mask* "*.yml")
(defparameter *lexer-defs* '())

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

(defun gather-lexer-defs (obj)
  (loop for key being the hash-keys of obj
          using (hash-value value)
        collect (make-lexer-def :pattern value :token key)))

(defun make-cond-body (name defs)
  `(cond
     ,@(loop for def in defs
             collect
             `((multiple-value-bind (start end)
                   (cl-ppcre:scan (pattern ,def) str)
                 (if (and start end (= start 0))
                     (if (< (1+ end) (length str))
                         (setf str (subseq str (1+ end)))
                         ;; надо в str класть остатки, а возвращать с токеном не его, а то, что "сматчили" регекспом
                         t)
                     nil))
               (return-from ,name (values (token ,def) str))))
     (t (return-from ,name (values nil nil)))))

(defun prepare-lexer-code (name defs)
  (let ((func-name (intern name)))
    `(defun ,func-name (str)
       (let ((str-copy (copy-seq str)))
         (loop while str-copy
               do
               ,(make-cond-body func-name defs))
         (return-from ,func-name (values nil nil))))))

(defun read-config (filename)
  (let ((doc (cl-yy::yaml-load-file filename))
        (productions-def)
        (productions)
        (terminals)
        (lexer-defs (list 1))
        (start-symbol)
        (name)
        (parser-name)
        (lexer-name)
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
                  (setf parser-name (intern-it (concatenate 'string value "-parser")))
                  (setf lexer-name (string-upcase (concatenate 'string value "-lexer")))
                  (when (> (length value) 0)
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
                 ((string= key "lexer")
                  (setf lexer-defs (gather-lexer-defs value)))
                 (t
                  (format t "Key: ~a~%" key)))))
    ;;
    ;; Check the completeness
    (unless (equalp model *pattern-model*)
      (format t "Somethin's wrong with the parser definition: ~%")
      (format t "Assembled: ~a~%" model)
      (format t "Pattern:   ~a~%+++~%" *pattern-model*))

    ;; Prepare the list of PRODUCTION objects
    (dolist (prod productions-def)
      (setf productions (append productions (nreverse (parse-prod prod)))))
    (setf productions (nreverse productions))
    ;; Prepare grammar
    (setf grammar (make-grammar :name name
                                :start-symbol start-symbol
                                :terminals terminals
                                :precedence precedence
                                :productions productions))
    ;; Prepare parser
    (setf parser (make-parser grammar))

    (setf (gethash name *translators-hash*)
          (make-translator :parser (make-parser grammar)
                           :lexer (eval (prepare-lexer-code lexer-name lexer-defs))))

    ;;(format t "~a~%" (symbol-function  (lexer (gethash name *translators-hash*))))

    ;; (dolist (word (split-string "copy \"file.name\"" #\Space))
    ;;   (parse-with-lexer (funcall (lexer (gethash name *translators-hash*)) word)
    ;;                     (parser (gethash name *translators-hash*))))
      ;;(loop
    ;;(dotimes (i 0 2)
    (let ((copy-str (copy-seq "copy \"file.name\"")))
      (multiple-value-bind (token str) (funcall (lexer (gethash name *translators-hash*)) copy-str)
        (format t "And the result for ~a is:~%Token: ~a. Value: ~a~%" copy-str token str)))
        ;;)

        ;;when (not (and token str)) do (return)))

  ))
(defun read-configs (&optional (path *common-path*))
  (normalize-path path)
  (loop for file in (directory
                     (concatenate 'string path *config-file-mask*))
        do (read-config file))
  )

;; (defun -lexer (str)
;;   (cond
;;     ((scan pattern1 str) (return-from -lexer (values token1 str)))
;;     ((scan pattern2 str) (return-from -lexer (values token2 str)))))
