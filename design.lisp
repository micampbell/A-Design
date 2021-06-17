;;; Design.lisp - the main part of the program
;;; Includes the general functions of A-design.
;;; General enough to accept a variety of design types,
;;; agents, and evaluations.


(defun A-design (&optional start-from)
  (cond (start-from (setf *input-agents-file* 
			  (make-pathname 
			   :directory *output-dir*
			   :name (format nil "agents_~D.out" start-from))) 
		    (setf *input-designs-file*
			  (make-pathname 
			   :directory *output-dir*
			   :name (format nil "designs_~D.out" start-from))))) 
  (run-process (read-agents) (read-designs) (read-optimal-designs) start-from))


(defun run-process (init-agent-data init-designs optimal-designs 
				    &optional iteration-start)
  (do* ((iteration (cond (iteration-start) (t 0)) (1+ iteration))
	;; After evaluating (except for in the initial population) the
	;; population is pruned by the obj. constraints, and divided into
	;; pareto, good, and poor designs.
	;;
	;; Pareto data includes the pareto designs, the rest of the designs
	;; and the pareto change
	(pareto-data nil (find-pareto-designs 
			  (prune-designs (- *design-pop* *pareto-cap*) designs)
			  pareto
			  (length pareto)))
	(pareto nil (prune-designs *pareto-cap* (car pareto-data)))
	(non-pareto nil (second pareto-data))
	(pareto-change 0 (third pareto-data))
	(m-agent-data nil (get-manager-response non-pareto pareto pareto-change
						iteration 
						iteration-start agent-data))
	(good nil (first m-agent-data))
	(radius nil (second m-agent-data))
	(poor nil (third m-agent-data))
	(agent-data init-agent-data (fourth m-agent-data))
	(convergence 0 (fifth m-agent-data))
	(todo nil (sixth m-agent-data))
	(taboo nil (seventh m-agent-data))
	;; The new iteration actually starts here with the creation of the
	;; new design population from the modified-set (append good pareto).
	(designs 
	 (cond (init-designs init-designs)
	       (t (create-instantiations 
		   (second agent-data) *design-pop*
		   (create-configs (first agent-data) 
				   (/ *design-pop* *designs-per-config*)))))
	 (create-and-modify-designs 
	  (- *design-pop* (+ (length pareto) (length pareto) (length good)))
	  (append good (mapcar 'copy-sc pareto)) (first agent-data) 
	  (second agent-data) (third agent-data) todo taboo)))
      ;; Although the stopping criteria doesn't logically follow the 
      ;; creation of designs - it's placed here for the convenience of 
      ;; the do* function and tests on the previous population.
      ((>= convergence *converged*)
       (format t "~%~%~%********end of process********~%~%~%")
       (write-iter-info 
	iteration pareto good poor radius agent-data pareto-change todo taboo)
       (write-design-data iteration pareto pareto-change
			  good poor radius agent-data todo taboo)
       (write-results (append pareto good) agent-data))
    ;; A little global garbage collecting
    (format t "~%Collecting Garbage..") (gc t) (format t "..done~%")
    ;; Here we print out the data from the previous iteration.
    (cond ((or (null iteration-start) (not (= iteration iteration-start)))
	   (write-iter-info iteration pareto good poor radius agent-data
			    pareto-change todo taboo)
	   (write-design-data iteration pareto pareto-change
			      good poor radius agent-data todo taboo)))
    ;; The new designs are passed to evaluate where they are evaluated.
    (format t "Entering evaluate..") 
    (evaluate designs iteration pareto-change)
    (format t "..done~%")))


;;; The following two functions determines the pareto-data in run-process
;;; This data is a list => (pareto-designs non-pareto-designs pareto-change)
;;; FIND-PARETO-DESIGNS cycles through each new candidate design while 
;;; UPDATE-PARETO cycles that design through each design already on the 
;;; pareto.
(defun find-pareto-designs (designs old-pareto old-length &optional 
				    (new-pareto nil) (non-pareto nil))
  (cond 
   ((endp designs) (list (append old-pareto new-pareto) non-pareto
			 (+ (length new-pareto) 
			    (- old-length (length old-pareto)))))
   (t
    (let ((pareto-data (update-pareto (car designs) old-pareto new-pareto
				      non-pareto)))
      (find-pareto-designs 
       (cdr designs) (first pareto-data)
       old-length (second pareto-data) (third pareto-data))))))

(defun update-pareto (design old-pareto new-pareto non-pareto &optional 
			     (old-pareto-pos 0) (new-pareto-pos 0)) 
  (cond ((= old-pareto-pos (length old-pareto)) 
	 (cond ((= new-pareto-pos (length new-pareto)) 
		(list old-pareto (cons design new-pareto) non-pareto))
	       ((better-than (nth new-pareto-pos new-pareto) design)
		(list old-pareto new-pareto (cons design non-pareto)))
	       ((better-than design (nth new-pareto-pos new-pareto))
		(update-pareto design old-pareto 
			       (remove-pos new-pareto-pos new-pareto) 
			       (cons (nth new-pareto-pos new-pareto) 
				     non-pareto) 
			       old-pareto-pos new-pareto-pos))
	       (t (update-pareto design old-pareto new-pareto non-pareto
				 old-pareto-pos (1+ new-pareto-pos)))))
	((better-than (nth old-pareto-pos old-pareto) design)
	 (list old-pareto new-pareto (cons design non-pareto)))
	((better-than design (nth old-pareto-pos old-pareto))
	 (update-pareto design (remove-pos old-pareto-pos old-pareto) 
			new-pareto
			(cons (nth old-pareto-pos old-pareto) non-pareto)
			old-pareto-pos new-pareto-pos))
	(t (update-pareto design old-pareto new-pareto non-pareto
			  (1+ old-pareto-pos) new-pareto-pos))))


(defun better-than (design1 design2)
  (cond ((null design1) nil)
	((null design2) t)
	(t (and-list (mapcar #'< (sc-evaluations (eval design1)) 
			     (sc-evaluations (eval design2)))))))


(defun better-than-from-weights (design1 design2 &optional 
					 (criteria (car *M-weights-M*)))
  (< (apply '+ (mapcar #'* criteria (sc-evaluations design1)))
     (apply '+ (mapcar #'* criteria (sc-evaluations design2)))))


(defun best-design-from-weights (designs &optional 
					 (criteria (car *M-weights-M*))
					 best)
  (cond ((endp designs) best)
	((or (null best)
	     (< (apply '+ (mapcar #'* criteria 
				  (sc-evaluations (eval (car designs))))) 
		(apply '+ (mapcar #'* criteria 
				  (sc-evaluations (eval best))))))
	 (best-design-from-weights (cdr designs) criteria (car designs)))
	(t
	 (best-design-from-weights (cdr designs) criteria best))))


(defun order-designs (designs num &optional (criteria (car *M-weights-M*)))
  (butlast (sort-designs designs criteria) (- (length designs) num)))
(defun sort-designs (designs criteria)
  (sort (mapcar #'copy-sc designs)
	#'(lambda (x y) (better-than-from-weights x y criteria))))


(defun designs-better-than-cutoff (cutoff designs)
  (cond ((endp designs) nil)
	(t
	 (cond ((better-than (car designs) cutoff)
		(cons (car designs) (designs-better-than-cutoff 
				     cutoff (cdr designs))))
	       (t (designs-better-than-cutoff cutoff (cdr designs)))))))


(defun prune-designs (total designs)
  (cond ((and *obj-constraints* *remove-similar-designs*)
	 (remove-similar-designs total
				 (designs-better-than-cutoff 
				  (make-sc :evaluations *obj-constraints*)
				  designs)))
	(*obj-constraints* (designs-better-than-cutoff 
			    (make-sc :evaluations *obj-constraints*) designs))
	(*remove-similar-designs* (remove-similar-designs total designs))
	(t designs)))


(defun remove-similar-designs (total designs &optional diff-list)
  (cond ((or (null designs) (<= total 0)) designs)
	((null diff-list)
	 (cons (best-design-from-weights designs)
	       (remove-similar-designs 
		(- (length designs) total)
		;; total is no longer the cap, but the amount of designs
		;; to be removed.
		(remove (best-design-from-weights designs) designs)
		(mapcar 
		 #'(lambda (x)
		     (mapcar 
		      #'(lambda (xx) 
			  (cond ((equal x xx) nil)
				(t
				 (norm 
				  (mapcar #'(lambda (w u v) (* w (- u v)))
					  (car *M-weights-M*)
					  (sc-evaluations (eval x))
					  (sc-evaluations (eval xx)))))))
		      (remove (best-design-from-weights designs) designs)))
		 (remove (best-design-from-weights designs) designs)))))
	(t
	 (let* ((closest-value 
		 (list-min (remove nil (apply 'append diff-list))))
		(i (position-if #'(lambda (x) (member closest-value x)) 
				diff-list)))
	   (remove-similar-designs
	    (1- total)
	    (remove-pos i designs)
	    (remove-pos i (mapcar #'(lambda (x) (remove-pos i x)) 
				  diff-list)))))))


(defun concavity (pareto)
  (format t "Entering concavity..")
  (let* ((min-designs (find-min-in-each-eval pareto))
	 (min-plane (plane-descriptor-from-pts
		     (mapcar #'(lambda (x) (sc-evaluations x)) min-designs))))
    (format t "almost done..")
    (cond (min-plane
	   (list 
	    (dx-point-to-plane            ;perpendicular dx from origin 
	     (make-list *num-of-objectives* :initial-element 0) min-plane) 
	    (let ((dxs (mapcar 
			#'(lambda (x) (dx-point-to-plane (sc-evaluations x) 
							 min-plane))
			  pareto)))
	      (+ (list-max dxs) (list-min dxs)))))
	  (t  (list nil nil)))))
  

(defun find-min-in-each-eval (designs)
  (do* ((i *num-of-objectives* (1- i))
	(mins nil (list-min (nth i (return-evals designs))))
	(ret-list nil (cons (find-if #'(lambda (x) 
					 (= mins (nth i (sc-evaluations x))))
				     designs)
			    ret-list)))
      ((zerop i) ret-list)))
