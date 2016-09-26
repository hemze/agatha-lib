(in-package #:agatha-lib)
(require 'cl-yaclyaml)

(defun read-config (filename)
  (let ((hash (cl-yy::yaml-load-file filename))
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
                (format t "Key: ~a~%" key))))

    ;; Check the completeness
    ;; TODO: make it more ...
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

    ;; Save a new parser in parsers collection
    (setf (gethash name *translators-hash*)
          (make-translator :parser (make-parser grammar)
                           :lexer (eval (prepare-lexer-code lexer-name lexer-defs))))
    ))
(defun read-configs (path)
  (normalize-path path)
  (loop for file in (directory
                     (concatenate 'string path "/" *input-file-mask*))
        do (read-config file)))
