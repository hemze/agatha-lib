(in-package #:agatha-lib)

(defvar set-header "*** Settings ***")
(defvar vars-header "*** Variables ***")
(defvar keys-header "*** Keywords ***")
(defvar cases-header "*** Testcases ***")


(defun component-present-p (value)
  (and value (not (eql value :unspecific))))

(defun directory-pathname-p  (p)
  (and
   (not (component-present-p (pathname-name p)))
   (not (component-present-p (pathname-type p)))
   p))

(defun pathname-as-directory (name)
  (let ((pathname (pathname name)))
    (when (wild-pathname-p pathname)
      (error "Can't reliably convert wild pathnames."))
    (if (not (directory-pathname-p name))
        (make-pathname
         :directory (append (or (pathname-directory pathname) (list :relative))
                            (list (file-namestring pathname)))
         :name      nil
         :type      nil
         :defaults pathname)
        pathname)))

(defun prepare-file-pattern (suite-name)

  )

(defun prepare-dir-env ()
  ;;TODO: v.1.1 : read the structure from config
;;  (format nil "folders structure: ~a" (gethash "dir-structure" *config*))
  (let* ((output-path (gethash "output-path" *config*))
        (parent-dir (make-pathname
                     :defaults (pathname-as-directory output-path))))
    (ensure-directories-exist parent-dir)

    (dolist (dir-name (gethash "dir-structure" *config*))
      (cond
        ((eql (type-of dir-name) "HASH")
         (print-complex dir-name))
        (t
         (format t "Create directory: ~a~%"
                 (ensure-directories-exist
                  (merge-pathnames
                   (make-pathname
                    :defaults (pathname-as-directory dir-name))
                   parent-dir))))
        ))
    ))
