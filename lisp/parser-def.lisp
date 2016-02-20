(proclaim '(optimize (speed 0) (safety 3) (debug 3)))
(require 'yacc)

(in-package #:agatha-lib)

(defun get-terminal (token)
  (let* ((terms '(terminals precedence start-symbol productions))
         (token-sym (intern (string-upcase token) '#.*package*))
         )
    (dolist (term terms)
      (cond
        ((eql token-sym term)
         (format t "Token: ~a~%" term)
         (return-from get-terminal (list token-sym token))))))
  ;;(unintern token-sym '#.*package*)
    (format t "Token: ~a~%" 'word)
    (return-from get-terminal (list 'word token)))

(defun read-special-sym (sym)
  (let ((syms '((#\: is) (#\{ leftbr) (#\} rightbr) (#\= eq))))
    (dolist (smb syms)
      (cond
        ((eql sym (car smb))
         (format t "Token: ~a~%" (cadr smb))
         (return-from read-special-sym
           (list (cadr smb) sym)))))))

(defun lexer-error (char)
  (error (make-condition 'yacc-runtime-error :character char)))

(defun maybe-unread (char stream)
  (when char
    (unread-char char stream)))

(defun read-id (&optional (stream *standard-input*))
  (let ((v '()))
    (loop
      (let ((c (read-char stream nil nil)))
        (when (or (null c)
                  (not (or (digit-char-p c) (alpha-char-p c) (eql c #\-))))
          (maybe-unread c stream)
          (when (null v)
            (lexer-error c))
          (return-from read-id (coerce (nreverse v) 'string)))
        (push c v)))))

(defun lexer (line)
  (format t "-------~a--------~%" line)
  (with-input-from-string (stream line)
    (loop
      (let ((c (read-char stream nil nil)))
        (cond
          ((member c '(#\Space #\Tab #\Newline)))
          ((member c '(#\Return)) (return-from lexer (values nil nil)))
          ;;((member c '(nil)) (return-from lexer (values nil nil)))
          ((member c '(#\: #\{ #\} #\= #\;))
           (return-from lexer (values-list (read-special-sym c))))
          ((alpha-char-p c)
           (unread-char c stream)
           (let ((token (read-id stream)))
             (return-from lexer (values-list (get-terminal token)))))
          (t
           (lexer-error c)))))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun print- (&rest a)
    (format t "~%----------~%Result: ~a~%" a)))

(define-parser *grammar-parser*
  (:start-symbol expr)
  (:terminals (terminals productions precedence start-symbol word is leftbr rightbr eq break))
  (expr
   start-def
   terms-def
   prods-def)
  (start-def
   (start-symbol is term))
  (term
   terminals
   productions
   precedence
   start-symbol
   word)
  (terms-def (terminals is term-list #'print-))
  (term-list
   (word term-list)
   )
  (prods-def
   ()
   (productions is leftbr prods-list rightbr))
  (prod-list
   (prod prod-list))
  (prod (word eq word))
  )
