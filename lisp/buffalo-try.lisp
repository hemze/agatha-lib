(require 'buffalo)
(use-package '#:buffalo)
;; (defun build-grammar-from-yacc (name file &optional name-alist)
;;   (let ((addtokens '())
;;         ;; create a automaton structure that represents the current state of the
;;         ;; finite state machine used for parsing including the symbol and
;;         ;; value stacks
;;         (automaton (make-automaton))
;;         (precs '()))
;;     (flet ((precedence (type symbls)
;;              (push (cons type symbls) precs)
;;              (values))
;;            (typ (type)
;;              (declare (ignore type))
;;              ;; The value of type, e.g. a string %left, could be used as easily
;;              ;; But the keyword symbol is known to sit on the top of the symbols
;;              ;; stack (because it a shift action on it that moved the machine here),
;;              ;; it can be used conveniently
;;              (first (automaton-symbol-stack automaton)))
;;            (second-arg (&rest rest) (second rest))
;;            (p13 (&rest rest) (list (first rest) (third rest)))
;;            (c13 (&rest rest) (cons (first rest) (third rest))))
;;       (let* ((parser
;;                (def-parser
;;                  (:start-symbol program)
;;                  (:terminals (:token :left :right :nonassoc
;;                               :start :%% :id :string_literal :|;| :|\|| :|:|))
;;                  (program
;;                   (tokendefs start productions))
;;                  (tokendefs
;;                   ()
;;                   (tokendef tokendefs #'append))
;;                  (tokendef
;;                   (:token tokens #'second-arg)
;;                   (precedence symbols #'precedence))
;;                  (tokens
;;                   ()
;;                   (:id tokens #'cons))
;;                  (precedence
;;                   (:left #'typ)
;;                   (:right #'typ)
;;                   (:nonassoc #'typ))
;;                  (start
;;                   (:start :id :%%))
;;                  (productions
;;                   (production)
;;                   (production productions #'cons))
;;                  (production
;;                   (:id :|:| alternatives :|;| #'p13))
;;                  (alternatives
;;                   (symbols)
;;                   (symbols :|\|| alternatives #'c13))
;;                  (symbols
;;                   ()
;;                   (symbol symbols #'cons))
;;                  (symbol
;;                   (:string_literal (lambda (s) (pushnew s addtokens) s))
;;                   :id)))
;;              (ast (parse-with-lexer (lisplex file name-alist) parser automaton))
;;              (tokens (first ast))
;;              (start (second ast))
;;              (rules (third ast)))
;;         `(define-parser ,name
;;            (:start-symbol ,(cadr start))
;;            (:precedence ,(nreverse precs))
;;            (:terminals ,(union addtokens tokens))
;;            ,@(loop for rule in rules
;;                    collect `(,(car rule) ,@(cadr rule))))))))
(define-parser *expression-parser*
  (:start-symbol expression)
  (:terminals (int id + - * / |(| |)|))
  (:precedence ((:left * /) (:left + -)))

  (expression
   (expression + expression #'i2p)
   (expression - expression #'i2p)
   (expression * expression #'i2p)
   (expression / expression #'i2p)
   term)

  (term
   id
   int
   (- term)
   (|(| expression |)| #'k-2-3)))
