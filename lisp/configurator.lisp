(in-package #:agatha-lib)
(require 'cl-yaclyaml)

(defparameter *parser-config-fields* '(name start-symbol terminals productions lexer))
(defparameter *app-config-fields* '(parsers-path input-path dir-structure))

(defclass basic-config ()
  (field-list))

;; (defclass parser-config (basic-config)
;;   ((name
;;     :initarg :name
;;     :accessor name)
;;    (start-symbol
;;     :initarg :start-symbol
;;     :accessor start-symbol)
;;    (terminals
;;     :initarg :terminals
;;     :accessor terminals)
;;    (productions
;;     :initarg :productions
;;     :accessor productions)
;;    (lexer
;;     :initarg :lexer
;;     :accessor lexer)
;;    ))

;; (defclass app-config (basic-config)
;;   ((parsers-path
;;     :initarg :parsers-path
;;     :initform *default-parsers-path*
;;     :accessor parsers-path)
;;    (input-path
;;     :initarg :input-path
;;     :initform *default-input-path*
;;     :accessor input-path)
;;    (dir-structure
;;     :initarg :dir-struct
;;     :initform *default-dir-structure*
;;     :accessor dir-structure)
;;    ))


(defmacro gen-config-class (class-name super-classes fields)
  `(defclass ,(intern (string-upcase class-name)) (,@super-classes)
     ,(append
       (loop for field in fields
            collect `(,field
                      :initarg ,(intern (string-upcase (symbol-name field)) "KEYWORD")
              :accessor ,field))
       `((field-list :initform ,fields)))))


(gen-config-class "app-config" (basic-config) (parsers-path input-path dir-structure))
(gen-config-class "parser-config" (basic-config) (name start-symbol terminals productions lexer))

(defgeneric parse-config (config path)
  (:documentation "Parse config file defined by <;; path> parameter"))

;; (defmethod parse-config ((config app-config) path)
;;   (let ((config-hash (cl-yy::yaml-load-file filename)))
;;     (with-slots
;;           (loop for field in *app-config-fields*
;;                 collect field)
;;         config
;;       (setf field (gethash field config-hash)))))
