;;; Create.lisp
;;; Contains the functions that deal with modifying and creating new
;;; designs from design.lisp.

;;; The following function calls both create-new-designs and modify-designs
;;; for a given iteration.  It maintains the changing agent-pops over the
;;; the iteration.

(defun create-and-modify-designs (new-num mod-set c-agents i-agents f-agents
					  todo taboo)
   (do* ((agent nil (M-find-next-agent-M f-agents))  ; todo taboo)
	 (fragment-&-original nil (funcall agent mod-set))
	 (fragments nil (cond (fragment-&-original 
			       (cons (cons (car fragment-&-original) agent)
				     fragments))
			      (t fragments)))
	 (mod-set mod-set (remove (cadr fragment-&-original) mod-set)))
       ((null mod-set)
	(append (create-instantiations 
		 i-agents (length fragments)
		 (reconstruct-fragments c-agents fragments todo taboo)
		 todo taboo)
		(create-instantiations 
		 i-agents new-num 
		 (create-configs 
		  c-agents (/ new-num *designs-per-config*) todo taboo)
		 todo taboo)))))


(defun reconstruct-fragments (c-agents fragments todo taboo &optional attempt)
  (cond 
   ((endp fragments) (format t "~%"))
   (t
    (let* ((config (create-from 
			    (mapcar 'copy-fp (sc-graph (caar fragments)))
			    c-agents (sc-embodiments (caar fragments))))
	   (equations 
	    (cond ((first config) 
		   (make-behavioral-equations (first config) 
					      (second config)))))
	   (graph-with-coords
	    (cond ((first config) (update-coordinates (first config) 
						      (second config))))))
       (cond 
	(equations
	 (format t "+")
	 (cons (make-sc :graph graph-with-coords
			:behavior-eq equations
			:embodiments (second config)
			:c-agents (append (sc-c-agents (caar fragments))
					  (third config))
			:components 
			(append (sc-components (caar fragments))
				(make-list 
				 (- (length (second config))
				    (length (sc-components (caar fragments))))))
			:i-agents
			(append (sc-i-agents (caar fragments))
				(make-list 
				 (- (length (second config))
				    (length (sc-components (caar fragments))))))
			:f-agents (cons (cdar fragments)
					(sc-f-agents (caar fragments))))
	       ;;
	       ;;
	       ;;
	       ;;
	       ;;
	       ;; Am I drunk or does the cdr in the following line look better?
	       ;;
	       ;;
	       ;;
	       ;;
	       ;;
	       (reconstruct-fragments c-agents (cdr fragments) todo taboo)))
	       ;;
	       ;;
	       ;;
	       ;;
	       ;;
	       ;;
	       ;;
	       ;;
	       ;;
	       ;;
	((zerop (cycle1+ attempt *attempts-to-reconstruct*))
	 (format t "-") 
	 (reconstruct-fragments c-agents (cdr fragments) todo taboo))
	(t 
	 (format t ".")
	 (reconstruct-fragments 
	  c-agents fragments todo taboo (cycle1+ attempt))))))))
 

(defun create-configs (c-agents new-num &optional todo taboo)
  (cond 
   ((<= new-num 0) 
    (format t "~%"))
   (t
    (let* ((config (create-from (mapcar 'copy-fp *io-fps*) 
				c-agents todo taboo))
	   (equations 
	    (cond 
	     ((first config) 
	      (make-behavioral-equations (first config) (second config)))))
	   (graph-with-coords
	    (cond ((first config) (update-coordinates (first config) 
						      (second config))))))
      (cond 
       (equations
	(format t "+")
	(cons (make-sc :graph graph-with-coords
		       :behavior-eq equations
		       :embodiments (second config)
		       :c-agents (third config))
	      (create-configs c-agents (1- new-num) todo taboo)))
       (t (format t "-") (create-configs c-agents new-num todo taboo)))))))


;;; CREATE-FROM
;;; This is the main function that calls the c-agents and builds a config
;;; EB by EB.  Note, update-config is called within the c-agents because
;;; of preferences they have to connecting components.
;;; Inputs:  the current list of FPs that make up the fps of the design
;;;          the updated c-agents that haven't been called yet.
;;; Outputs: list where the first element is the FP's of the system, the 
;;;          second is the EB's chosen by the agents, and the agents involved.
(defun create-from (fps c-agents todo taboo &optional ebs)
  (cond ((design-is-complete fps) (list fps ebs nil))
	((>= (length ebs) *max-num-ebs*) 
	 (list nil nil nil))
	(t
	 (let* ((agent (M-find-next-agent-M c-agents))  ; todo taboo))
		(d-state (c-agent-strategy 
			  fps ebs 
			  :prefs (second agent) :domain (third agent)
			  :dir (fourth agent) :sp (fifth agent) 
			  :connect (sixth agent) :todo todo :taboo taboo))
		;; d-state returns ((the updated FP's) (embodiments))
		(recurse-d-states
		 (cond 
		  (d-state
		   (create-from 
		    (car d-state) c-agents todo taboo (cadr d-state))))))
	   (list (car recurse-d-states)             ;FP's
		 (cadr recurse-d-states)            ;Embodiments
		 (cond (d-state                     ;Agents
			(cons agent (caddr recurse-d-states))) 
		       (t (caddr recurse-d-states))))))))


(defun create-instantiations (i-agents new-num configs 
				       &optional todo taboo config-num)
  (cond ((or (null configs) (<= new-num 0)) (format t "~%"))
	(t 
	 (let* ((i (cond (config-num) (t 0)))
		(config (nth i configs))
		(instantiation 
		 (instantiate-config 
		  i-agents (make-sc 
			    :graph (sc-graph config)
			    :behavior-eq (sc-behavior-eq config)
			    :embodiments (sc-embodiments config)
			    :c-agents (sc-c-agents config)
			    :components (make-list 
					 (length (sc-embodiments config)))
			    :i-agents (make-list 
				       (length (sc-embodiments config)))
			    :f-agents (sc-f-agents config))
		  todo taboo)))
	   (format t "~D " i)
	   (cons instantiation 
		 (create-instantiations 
		  i-agents (1- new-num) configs todo taboo
		  (cycle1+ config-num (length configs))))))))


(defun instantiate-config (i-agents config todo taboo)
  (cond 
   ((and-list (sc-components config)) 
    (instantiate-variables config todo taboo)
    config)
   (t (let ((agent (M-find-next-agent-M i-agents (sc-i-agents config)
					todo taboo)))
	(instantiate-config i-agents (funcall agent config todo taboo))))))

(defun instantiate-variables (concept)
  (do* ((i (length (sc-embodiments concept)) (1- i))
	(vars nil (append (mapcar 
			   #'(lambda (x) (intern 
					  (make-symbol 
					   (format nil "~A_~D" (string x) i))))
			   (eb-data (eval (nth i (sc-embodiments concept)))))
			  vars))
	(vals nil (append (copy-list (second (nth i (sc-components 
							 concept)))) vals)))
      ((zerop i)
       (setf (sc-behavior-eq concept)
	     (fill-in-values (sc-behavior-eq concept) vars vals))
       (setf (sc-graph concept)
	     (apply #'append
		    (mapcar #'(lambda (x) (modify-fp-in-list 
					   x nil 
					   :coord (fill-in-values
						   (fp-coord x) vars vals)))
			    (sc-graph concept)))))))


(defun fill-in-values (item vars vals)
  (cond ((endp vars) item)
	(t (fill-in-values (subst (car vals) (car vars) item) 
			   (cdr vars) (cdr vals)))))

