;;; Evaluations.lisp 
;;; Contains functions called in evaluate in design.lisp
;;; These functions are specified in parameters

(setf *evaluators* (append '(cost mass)))
;;; we should be able to get rid of dial-accuracy and input-dx in 
;;; favor of a more general approach where any state variable
;;; is checked with its ideal values. Here we will use the global
;;; variables *target-state-vars* that was used in determined the 
;;; behavioral equations in 'equer.lisp'.

;;; The following functions perform evaluate
(defun evaluate (designs iteration pareto-change)  
  (cond ((endp designs) nil)
	(t (setf (sc-evaluations (car designs)) (evaluate-each-design 
						 (eval (car designs)) 
						 *evaluators*))
	   (evaluate (cdr designs) iteration pareto-change))))


(defun evaluate-each-design (design evaluators)
  (cond ((endp evaluators) 
	 (do* ((answer nil (cond ((consp (caar equations)) (discretize-interval (caar equations)))
				 ((caar equations) (discretize-interval (list (caar equations) (caar equations))))))
	       (result nil (cond ((cadar equations) (solve-equation (cadar equations)))))
	       (objectives nil (cons (cond ((and result answer (and-list (mapcar 'numberp result)) 
						 (and-list (mapcar 'numberp answer)))
					    (/ (apply '+ (mapcar 
							  #'(lambda (x y) 
							      (* (- x y (- (car answer) (car result)))
								 (- x y (- (car answer) (car result)))))
							  (cdr answer) (cdr result)))
					       (1- (length answer))))
					   (t (car max-values)))
				     objectives))
	       (equations (sc-behavior-eq design) (cdr equations))
	       (max-values (nthcdr (length *evaluators*) *obj-constraints*) (cdr max-values)))
	     ((endp equations) objectives)))
	(t (cons (funcall (car evaluators) design)
		 (evaluate-each-design design (cdr evaluators))))))


(defun cost (design)
  (apply '+ (mapcar #'(lambda (x) (first (third x))) (sc-components design))))

(defun mass (design)
  (apply '+ (mapcar #'(lambda (x) (second (third x))) (sc-components design))))

(defun calc-ineff (design)
  (- 1 (apply '* (mapcar #'(lambda (x) (third (third x)))
			 (sc-components design)))))



;;; Discretize-Interval
;;; This function discretizes an interval by operator (third interval) which is
;;; a unary function.  The number of discretized points comes from the 
;;; constant that it set *num-of-discrete-points*. Basically, for interval 
;;; (x0 xf), the results are return as
;;;             (xn-x0)
;;; yn = x0 + f(-------)*(xf - x0)
;;;             (xf-x0)
(defun discretize-interval (interval)
  (do ((x0 (first interval))
       (xf (second interval))
       (operator (third interval))
       (spacing (/ (- (second interval) (first interval))
		   *num-of-discretize-points*))
       (xn (first interval) (+ xn spacing))
       (y nil (backcons 
	       (cond ((= xf x0) x0) 
		     (operator
		      (+ x0 (* (- xf x0) 
			       (funcall operator (/ (- xn x0) (- xf x0))))))
		     (t xn))
		    y))
       (i 0 (1+ i)))
      ((> i *num-of-discretize-points*) y)))


(defun solve-equation (eq)
  (do* ((interval (find-if #'(lambda (x) (and (listp x) (numberp (car x))))
			   (apply #'append 
				  (mapcar #'return-state-vars *io-fps*))))
	(equation nil (subst (car points) interval eq :test 'equal))
	(values nil (backcons (ignore-errors (eval equation)) values))
	(points (discretize-interval interval) (cdr points)))
      ((endp points) values)))
