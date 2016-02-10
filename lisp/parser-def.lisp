(require 'yacc)
(defpackage #:agatha-lib
  (:use #:cl #:yacc)
  (:export #:run))

(in-package #:agatha-lib)

(defun get-terminal (token)
  (let ((terms '(terminals precedence start-symbol word productions)))
    (dolist (term terms)
      (cond
        ((eql token term)
         (return-from get-terminal '(term token)))
        (t (return-from get-terminal '(nil nil)))))))

(defun read-special-sym (sym)
  (let ((syms '((#\: 'is) (#\{ 'leftbr) (#\} 'rightbr) (#\= 'eq))))
    (dolist (smb syms)
      (cond
        ((eql sym (car smb)) (return-from read-special-sym
                               '((cadr smb) sym)))))))

(defun lexer-error (char)
  (error (make-condition 'lexer-error :character char)))

(defun maybe-unread (char stream)
  (when char
    (unread-char char stream)))

(defun read-id (stream)
  (let ((v '()))
    (loop
      (let ((c (read-char stream nil nil)))
        (when (or (null c)
                  (not (or (digit-char-p c) (alpha-char-p c) (eql c #\_))))
          (maybe-unread c stream)
          (when (null v)
            (lexer-error c))
          (return-from read-id (intern (coerce (nreverse v) 'string)))
        (push c v))))))

(defun lexer (&optional (stream *standard-input*))
  (loop
    (let ((c (read-char stream nil nil)))
      (cond
        ((member c '(#\Space #\Tab)))
        ((member c '(nil #\Newline)) (return-from lexer (values nil nil)))
        ((member c '(#\: #\{ #\} #\=))
         (return-from lexer (read-special-sym c)))
        ((alpha-char-p c)
         (unread-char c stream)
         (let ((token (read-id stream)))
           (return-from lexer (values-list (get-terminal token)))))
        (t
         (lexer-error c))))))

(defun print- (a)
  (format t "~a" a))

(define-parser *grammar-parser*
  (:start-symbol expression)
  (:terminals (terminals productions precedence start-symbol word is leftbr rightbr eq))
  (expression
   (terms-def #'print-)
   ;(prods-def #'print-) (start-def #'print-)
   )
  (terms-def (terminals is term-list))
  (term-list
   (word term-list))
  ;; (prods-def
  ;;  (productions is leftbr prods-list rightbr))
  ;; (prod-list
  ;;  (prod prod-list))
  ;; (prod (word eq word))
  )

(defun run ()
  (format t "Type in.~%")
  (loop
    ;(with-simple-restart (abort "Return to the toplevel.")
      (format t "? ")
      (let ((e (parse-with-lexer #'lexer *grammar-parser*)))
        (when (null e)
          (return-from run))
        (format t " => ~A~%"  e))))
