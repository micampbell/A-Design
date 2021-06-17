(load "initweigh.fixed.lisp")
(load "codeGeneral/design.lisp")

;(A-design)


; what is s? see cordtests/oldtest/test.lisp

(print (make-behavioral-equations
          s
          '(rack0 gear1 damper-trans2 shaft3 spring4 spring5 spring6)))
