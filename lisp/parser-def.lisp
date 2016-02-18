(require 'yacc)

(in-package #:agatha-lib)

(defun get-terminal (token)
  (let* ((terms '(terminals precedence start-symbol productions))
         (token-sym (intern (string-upcase token) '#.*package*))
         )
    (dolist (term terms)
      (cond
        ((eql token-sym term)
         (return-from get-terminal (list term token)))
        (t
         ())))
    (unintern token-sym '#.*package*)
    (return-from get-terminal (list 'word token))))

(defun read-special-sym (sym)
  (let ((syms '((#\: is) (#\{ leftbr) (#\} rightbr) (#\= eq))))
    (dolist (smb syms)
      (cond
        ((eql sym (car smb))
         (format t "Special symbol: ~a~%" sym)
         (return-from read-special-sym
                               (list (cadr smb) sym)))
        (t (return-from read-special-sym (list nil nil)))))))

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

(defun lexer (&optional (stream *standard-input*))
  (loop
    (let ((c (read-char stream nil nil)))
      (cond
        ((member c '(#\Space #\Tab)))
        ((member c '(nil #\Newline)) (return-from lexer (values nil nil)))
        ((member c '(#\: #\{ #\} #\=))
         (return-from lexer (values-list (read-special-sym c))))
        ((alpha-char-p c)
         (unread-char c stream)
         (let ((token (read-id stream)))
           (format t "Token: ~a~%" token)
           (return-from lexer (values-list (get-terminal token)))))
        (t
         ;(lexer-error c)
         (print c))))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun print- (&rest a)
    (format t "~%----------~%Term: ~a ~% Value: ~a" (car a) (cdr a))))

(define-parser *grammar-parser*
  (:start-symbol expression)
  (:terminals (terminals productions precedence start-symbol word is leftbr rightbr eq))
  (expression
   ()
   start-def
   terms-def
   )
  (start-def (start-symbol is term #'print-))
  (term
   terminals
   productions
   precedence
   start-symbol
   word)
  (terms-def (terminals is term-list #'print-))
  (term-list
   ()
   (word term-list)
   )
  (prods-def
   (productions is leftbr prods-list rightbr))
  (prod-list
   (prod prod-list))
  (prod (word eq word))
  )
