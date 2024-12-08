;;; test-tail-call.el -- Tests for Tail Call -- -*- lexical-binding: t -*-g
(require 'ert)
(require 'cl-lib)
(require 'tail-call)

(ert-deftest tail-call-self-recursion ()
    (cl-labels ((add (x y) (tail-call-pull (add-aux x y)))
             (add-aux (x y)
                (cond ((> x 0) (tail-call #'add-aux (1- x) (1+ y)))
                      ((< x 0) (tail-call #'add-aux (1+ x) (1- y)))
                      ((zerop x) y))))
      (let ((x 10000)
            (y 0))
        (should (= x (add x y))))))

(ert-deftest tail-call-mutual-recursion ()
  (cl-labels ((even-p (n) (tail-call-pull (even-aux (abs n))))
              (odd-p  (n) (tail-call-pull (odd-aux  (abs n))))
              (even-aux (n)
                (if (zerop n) t
                  (tail-call #'odd-aux (1- n))))
              (odd-aux (n)
                (if (zerop n) nil
                 (tail-call #'even-aux  (1- n)))))
    (should (even-p 10000))
    (should (odd-p 10001))))
