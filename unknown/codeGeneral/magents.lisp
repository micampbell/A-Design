;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; M-AGENTS OR MANAGER-AGENTS
;;; Agents are called from RUN-PROCESS in design.lisp.
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; The following *M-???-M* variables represent the head-managers internal
;;; state.
;;; These are all lists with appended elements from each iteration.
(setf *M-max-on-t-list-M* 15)
(setf *M-memory-M* 5)
(setf *M-pareto-change-M* (make-list *M-memory-M*))
(setf *M-top-design-M* (make-list *M-memory-M*))
(setf *M-weights-M* '((1.0 1.0 10000.0 100000.0)))
(setf *M-user-satisfaction-M* '(10))
(setf *M-W-agent-record-M* 0.5)
(setf *M-W-agent-pareto-M* (/ *pareto-cap* *design-pop*))
(setf *M-W-agent-good-M* (/ *good-cap* *design-pop*))
(setf *M-W-agent-poor-M* (/ (- 0 *pareto-cap* *good-cap*) *design-pop*))
(setf *M-W-agent-todo-taboo-M* 2.0)

(defun get-manager-response (non-pareto pareto pc iteration iteration-start
					agent-data)
  (setf *M-pareto-change-M* (cons pc (butlast *M-pareto-change-M*)))
  (head-manager non-pareto pareto pc iteration iteration-start agent-data 
		(best-design-from-weights pareto)))
  
;;; Head-manager communicates with user about design alternatives, 
;;; in the simpler case acts by the *weights* preference 
;;; 
(defun head-manager (non-pareto pareto pc iteration iteration-start
				agent-data best-design)
  (setf *M-top-design-M* 
	(cons (apply '+ (mapcar #'* (car *M-weights-M*)
				(cond (best-design
				       (sc-evaluations best-design)))))
	      (butlast *M-top-design-M*)))
  (let ((num-pc-zeros (count 0 *M-pareto-change-M*))
	(num-top-design-change (count-if #'(lambda (x) 
					     (equal (car *M-top-design-M*)
						    x))
					 *M-top-design-M*)))
    (cond 
     ((invoke-m-agent-dialog best-design num-pc-zeros num-top-design-change)
      (do* ((alternatives (randomize-list pareto) 
			  (nthcdr *num-of-objectives* alternatives))
	    (new-prefs (determine-user-pref alternatives best-design) 
		       (determine-user-pref alternatives best-design)))
	  ((and 
	    (or new-prefs (format t "Sorry, error in design set, redo!~%"))
	    (not
	     (format 
	      t "Is this design as good as the best shown above [y/n]?~%"))
	    (not (present-design 
		  (best-design-from-weights pareto new-prefs)))
	    (equal (read) 'y))
	   (format t "Interpolate or Extrapolate new preference [i/e]~%")
	   (format t "Is your preference between these two designs or~%")
	   (format t "more along the lines of the second? ")
	   (cond ((equal (read) 'i) 
		  (setf *M-weights-M* 
			(cons (calibrate-new-prefs 
			       (mapcar #'(lambda (x y) (/ (+ x y) 2))
				       new-prefs (car *M-weights-M*))
			       best-design)
			      *M-weights-M*)))
		 (t 
		  (setf *M-weights-M* 
			(cons (calibrate-new-prefs 
			       (mapcar #'(lambda (x y) (+ x (/ (- x y) 2)))
				       new-prefs (car *M-weights-M*))
			       best-design)
			      *M-weights-M*))))
	   (format t "new weights = ~{~F ~}~%" (car *M-weights-M*))
	   (format t "How do you feel with the design process given~%")
	   (format t "that it is ~F complete? " 
		   (/ (+ iteration (cond (iteration-start) (t 0))) 
		      *tot-iter*))
	   (setf *M-user-satisfaction-M* 
		 (cons (read) *M-user-satisfaction-M*))))))
       (let* ((good-data (find-good non-pareto
				    (cond (pareto (sc-evaluations
						   (best-design-from-weights 
						    pareto)))
					  (t (make-list *num-of-objectives* 
							:initial-element 0)))))
	      (agent-data (update-agent-stats pareto (car good-data)
					      (third good-data)
					      agent-data))
	      (convergence (cond ((>= iteration *tot-iter*) 1)
				 (t 0)))
	      (taboo-num (truncate 
			  (cond ((> (/ (* 10 (max num-pc-zeros num-top-design-change)
					  *M-max-on-t-list-M*)
				       (car *M-user-satisfaction-M*) *M-memory-M*)
				    *M-max-on-t-list-M*) *M-max-on-t-list-M*)
				(t (/ (* 10 (max num-pc-zeros num-top-design-change)
					 *M-max-on-t-list-M*)
				      (car *M-user-satisfaction-M*) *M-memory-M*)))))
	      (todo-num (truncate (/ (* (car *M-user-satisfaction-M*) iteration 
					*M-max-on-t-list-M*)
				     10 *tot-iter*)))
	      (t-data (mapcar #'(lambda (x) (funcall x (append non-pareto pareto)))
			      (fourth agent-data)))
	      (todo (prune-t-list todo-num (apply #'append (mapcar #'first t-data))))
	      (taboo (prune-t-list taboo-num (apply #'append 
						    (mapcar #'third t-data)))))
	 (list (first good-data) (second good-data) (third good-data)
	       agent-data convergence todo taboo))))
       

(defun invoke-m-agent-dialog (best-design num-pc-zeros num-top-design-change)

  ;(dump num-pc-zeros num-top-design-change)
  (format t "Pareto last changed ~D iteration~:P ago.~%" num-pc-zeros)
  (format t "Top Design last changed ~D iteration~:P ago.~%" num-top-design-change)
  (format t "Currently the best design for your preference is:~%")
  (present-design best-design)
  (cond ;((>= (max num-pc-zeros num-top-design-change) *M-memory-M*) t)
	((null best-design) nil)
	(t
	 (format t "Talk to M-agent (hit return) ? ")
	 (do ((i 0 (1+ i)))
	     ((or (listen)
		  (= i (* (1+ (max num-pc-zeros num-top-design-change)) 100000)))
	      (cond ((listen) (format t "~%~%") (clear-input) t)
		    (t (format t "~%~%") nil)))))))


(defun determine-user-pref (alternatives best-design)
  (let* ((A (mapcar #'sc-evaluations 
		    (cons best-design
			  (butlast alternatives (- (length alternatives) -1
						   *num-of-objectives*)))))
	 (det-A (determinant A)))
    (cond (det-A
	   (do ((designs alternatives (cdr designs))
		(i 1 (1+ i)))
	       ((= i *num-of-objectives*))
	     (format t "~D: " i) (present-design (car designs)))
	   (format t "Given that the best design presented is 5,~%")
	   (format t "how would you rate each of these designs (1-10) ?~%")
	   (do ((prefs (list 5) (backcons (/ (read)) prefs))
		(i 1 (1+ i)))
	       ((= i *num-of-objectives*)
		(calibrate-new-prefs (solve-linear-system A prefs det-A)
				     best-design))
	     (format t "~D: " i))))))

(defun calibrate-new-prefs (new-prefs best-design)
  (let* ((correct (cond ((<= (apply #'min new-prefs) 0)
			 (- 1 (apply #'min new-prefs)))
			(t 0)))
	 (new-weights (mapcar #'(lambda (x) (+ correct x)) new-prefs))
	 (new-eval (apply '+ (mapcar #'* new-weights
				     (sc-evaluations best-design)))))
    (mapcar #'(lambda (x) (/ (* (car *M-top-design-M*) x) new-eval))
	    new-weights)))

(defun find-good (other-designs best-point)
  (do* ((radius nil (list-min distances)) 
	(good nil (cons (nth (position radius distances) poor) good))
	(distances (mapcar 
		    #'(lambda (x) (dx-point-to-point 
				   (sc-evaluations x) best-point)) other-designs)
		   (remove radius distances :count 1))
	(poor other-designs (remove (car good) poor))
	(i *good-cap* (1- i)))
      ((or (<= i 0) (null distances))
       (list good radius poor))))


;;; The following functions perform feedback-to-agents
(defun update-agent-stats (pareto good poor agent-data)
  (let* ((pareto-c-stats (apply 'append (mapcar 'sc-c-agents pareto)))
	 (good-c-stats (apply 'append (mapcar 'sc-c-agents good)))
	 (poor-c-stats (apply 'append (mapcar 'sc-c-agents poor)))
	 (pareto-i-stats (apply 'append (mapcar 'sc-i-agents pareto)))
	 (good-i-stats (apply 'append (mapcar 'sc-i-agents good)))
	 (poor-i-stats (apply 'append (mapcar 'sc-i-agents poor)))
	 (pareto-f-stats (apply 'append (mapcar 'sc-f-agents pareto)))
	 (good-f-stats (apply 'append (mapcar 'sc-f-agents good)))
	 (poor-f-stats (apply 'append (mapcar 'sc-f-agents poor))))
    (list
     (mapcar #'(lambda (x)
		 (list (car x) 
		       (cons (list (count (car x) pareto-c-stats)
				   (count (car x) good-c-stats)
				   (count (car x) poor-c-stats))
			     (cond ((cdr x) (butlast (cadr x)))
				   (t (make-list (1- *M-memory-M*)))))))
	     (first agent-data))
     (mapcar #'(lambda (x)
		 (list (car x) 
		       (cons (list (count (car x) pareto-i-stats)
				   (count (car x) good-i-stats)
				   (count (car x) poor-i-stats))
			     (cond ((cdr x) (butlast (cadr x)))
				   (t (make-list (1- *M-memory-M*)))))))
	     (second agent-data))
     (mapcar #'(lambda (x)
		 (list (car x) 
		       (cons (list (count (car x) pareto-f-stats)
				   (count (car x) good-f-stats)
				   (count (car x) poor-f-stats))
			     (cond ((cdr x) (butlast (cadr x)))
				   (t (make-list (1- *M-memory-M*)))))))
	     (third agent-data))
     (fourth agent-data))))


(defun prune-t-list (num items)
  (let ((sorted-items (sort (randomize-list items) #'< :key #'cdr)))
    (cond ((>= num (length items)) (mapcar #'car sorted-items))
	  (t
	   (mapcar #'car (nthcdr (- (length items) num) sorted-items))))))



(defun present-design (design)
  (cond (design
	 (format t "~{     ~A = ~F ~%~}"
		 (apply #'append (mapcar #'list *evaluators*
					 (sc-evaluations design))))
	 (format t "-------------------------------------------------~%"))))


(defun M-find-next-agent-M (agents 
			    &optional current-team todo-teams taboo-teams)
  ;; Inputs: agent-populations with first element removed after each
  ;;         recursive call, and random number from zero to total-pop.
  ;; Outputs: the randomly chosen grammar-rule
  (do* ((u (mapcar #'(lambda (x) (cond ((<= (calc-next-agent-U 
					     x current-team todo-teams
					     taboo-teams) 0)
					*min-agent-U*)
				       (t (calc-next-agent-U 
					   x current-team todo-teams 
					   taboo-teams))))
		   agents)
	   (cdr u))
	(choose (- (random (apply #'+ u)) (car u)) (- choose (car u)))
	(which-agent agents (cdr which-agent)))
      ((< choose 0)  (caar which-agent))))


(defun calc-next-agent-U (agent current-team todo-teams taboo-teams)
  (+ (* *M-W-agent-record-M* 
	(+ (* *M-W-agent-pareto-M* 
	      (apply #'+ (remove nil (mapcar #'first (cadr agent)))))
	   (* *M-W-agent-good-M* 
	      (apply #'+ (remove nil (mapcar #'second (cadr agent)))))
	   (* *M-W-agent-poor-M* 
	      (apply #'+ (remove nil (mapcar #'third (cadr agent)))))))
     (* *M-W-agent-todo-taboo-M* 
	(- (apply #'+ (mapcar #'(lambda (y) 
				  (length (intersection 
					   (cons (car agent) current-team) y)))
			      todo-teams))
	   (apply #'+ (mapcar #'(lambda (y)
				  (length (intersection 
				    (cons (car agent) current-team) y))) 
			      taboo-teams))))))
