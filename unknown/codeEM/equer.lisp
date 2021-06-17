;;; Equer.lisp
;;; This file has functions that create behavioral-equations.

(defun make-behavioral-equations (fps ebs)
  (do* ((goal-fp nil
		 (find-if #'(lambda (x) 
			      (member (list 'goal (first (car targets))) 
				      (fp-index x) :test 'equal)) 
			  fps))
	(equations
	 nil 
	 (cons
	  (cond ((equal (second (car targets)) 'through)
		 (cons (nth (third (car targets)) (fp-through goal-fp))
		       (extract-eq goal-fp ?oper? fps ebs)))
		(t
		 (cons (nth (fourth (car targets)) 
			    (nth (third (car targets)) (fp-across goal-fp)))
		       (extract-eq goal-fp ?oper? fps ebs))))
	  equations))
	(targets *target-state-vars* (cdr targets)))
      ((endp targets) equations)))

;;; not sure what to do with the oper in the below functions - 
;;; some rework of how MG-change must be done before these 2
;;; functions are brought up to date.
(defun extract-eq (start oper fps ebs &optional from avoids)
  (format nil "|")
  (let ((terminal (nth oper (return-state-vars start))))
    (cond 
     ((or (null terminal) 
	  (numberp terminal)
	  (and (consp terminal) (numberp (car terminal))))
      (list terminal (cons (cons start oper) avoids)))
     (t
      (do* ((new-term nil (extract-coeffs 
			   (car ports) oper fps ebs new-avoids))
	    (terms nil (cond ((car new-term) (cons (car new-term) terms)) 
			     (t terms)))
	    (new-avoids (cons (cons start oper) avoids) 
			(union new-avoids (cadr new-term)))
	    (ports (cond 
		    ((and start (not (member 'ground (fp-index start) 
					     :test 'equal)))
		     (set-difference (fp-index start) (list from 'goal)
				     :test 'equal)))
		   (cdr ports)))
	  ((endp ports)
	   (cond 
	    ((and from (> (length terms) 1) (zerop oper))
	     (list (cons '+ terms) new-avoids))
	    ((and (> (length terms) 1) (zerop oper))
	     (cons '+ terms))
	    ((and from (> (length terms) 1)) 
	     (list 
	      (list '/ (cons '+ (mapcar #'(lambda (x) (list '/ x)) terms)))
	      new-avoids))
	    ((> (length terms) 1)
	     (list '/ (cons '+ (mapcar #'(lambda (x) (list '/ x)) terms))))
	    ((and terms from) (list (car terms) new-avoids))
	    (terms (car terms))
	    (t nil))))))))


(defun extract-coeffs (eb oper fps ebs avoids)
;;  (cond ((make-unique-mg-change (car eb) (cadr eb) oper (nth (car eb) ebs))
;;	 (let* ((coeffs (make-unique-mg-change (car eb) (cadr eb) oper 
;;					       (nth (car eb) ebs)))
;;		(connects 
;;		 (substitute-if 
;;		  nil #'(lambda (x) (member x avoids :test 'equal)) 
;;		  (mapcar 
;;		   #'(lambda (i) (cons (port-connects-to 
;;					(list (car eb) (car i)) specs) 
;;				       (cadr i))) 
;;		   (car coeffs))))
;;		(terms 
;;		 (mapcar 
;;		  #'(lambda (x i) 
;;		      (cond (x (extract-eq (car x) (cadr i) specs ebs 
;;					   (list (car eb) (car i)) avoids))))
;;		  connects (car coeffs))))
;;	   (list (apply (cadr coeffs) (mapcar 'car terms))
;;		 (list-union (mapcar 'cadr terms)))))))
  (cond ((make-unique-mg-change (car eb) (cadr eb) oper (nth (car eb) ebs))
	 (let* ((coeffs (make-unique-mg-change (car eb) (cadr eb) oper 
					       (nth (car eb) ebs)))
		(connects
		 (substitute-if 
		  nil #'(lambda (x) (member x avoids :test 'equal)) 
		  (mapcar #'(lambda (i) (cons (port-connects-to 
					       (list (car eb) (truncate i 4)) fps)
					      (mod i 4))) (car coeffs))))
		(terms (mapcar 
			#'(lambda (x i) 
			    (cond (x (extract-eq (car x) (mod i 4) fps ebs 
						 (list (car eb) (truncate i 4)) 
						 avoids))))
			connects (car coeffs))))
	   (list (apply (cadr coeffs) (mapcar 'car terms))
	    (list-union (mapcar 'cadr terms)))))))
