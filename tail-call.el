;;; tail-call.el -- Simulated proper tail calls for Emacs -*- lexical-binding: t -*-

;; Copyright (C) 2025 Samuel B. Johnson

;; Author: Samuel B. Johnson <sabjohnso.dev@gmain.com>
;; Version: 0.1.0
;; URL: https://github.com/sabjohnso/tail-call

;;; Commetary

;; A trampoline for simulating proper tail calls in Emacs:

;; Example: Self Recursion

;; (defun example-fib (n)
;;   (labels ((aux (m a b)
;;             (if (>= m n) b
;;               (tail-call #'aux (1+ m) b (+ a b)))))
;;     (tail-call-pull (aux 0 0 1))))

;; The use of explicit function calls to return unevaluated function
;; applications and to pull values from unevaluated function
;; applications make tail-call flexible enough to implement functions
;; with mutual recursion:

;; Example: Mutual Recursion

;; (defun even-integer-p (n)
;;   (tail-call-pull (even-integer-p-aux (abs n))))
;;
;; (defun odd-integer-p (n)
;;   (tail-call-pull (odd-integer-p-aux (abs n))))
;;
;; (defun even-integer-p-aux (n)
;;   (if (zerop n) t
;;     (tail-call #'odd-integer-p-aux (1- n))))
;;
;; (defun odd-integer-p-aux (n)
;;   (if (zerop n) nil
;;     (tail-call #'even-integer-p-aux (1- n))))

;; Similar projects exist that provide macros for definining
;; functions with self recursion, but they do not have the
;; flexibility for mutual recursion.  For many use cases,
;; those project may be preferable:
;;
;;  - tail-call : https://github.com/ROCKTAKEY/recur
;;  - tco   : https://github.com/Wilfred/tco.el/blob/master/tco.el

;;; Code:

(require 'eieio)

(defclass tail-call-data ()
  ((func :initarg :func)
   (args :initarg :args)
   (evaluated :initform nil :accessor tail-call-evaluated)
   (result    :initform nil :accessor tail-call-result)))

(defun tail-call-get-result (tc)
  (when (not (tail-call-evaluated tc))
    (setf (tail-call-result tc)
          (with-slots (func args) tc
            (apply #'funcall func args)))
    (setf (tail-call-evaluated tc) t))
  (tail-call-result tc))

(defun tail-call-pull (arg)
  "Pull a value from unevaluated function applications"
  (while (tail-call-data-p arg)
    (setf arg (tail-call-get-result arg)))
  arg)

(defun tail-call (func &rest args)
  "Return an unevaluated function application"
  (make-instance 'tail-call-data
    :func func
    :args args))

(provide 'tail-call)
;;; tail.el ends here
