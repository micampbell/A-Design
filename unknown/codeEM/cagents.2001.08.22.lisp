;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; C-AGENTS OR CONFIGURATION-AGENTS
;;; Agents are called from create-from in create.lisp.
;;; functions - agents are passed the fps of the incomplete design.
;;; It returns ((new fps) (embodiments))
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c-agent-strategy (fps ebs &key prefs domain dir sp connect todo taboo)
  (let* ((set-fps (remove-if #'(lambda (x) 
				 (or (member 'ground (fp-index x) :test 'equal)
				     (null (fp-inter x)))) fps))
	 (eb-lib *eb-library*)
	 (goal-oper-list (mapcar 
			 #'(lambda (z)
			     (position-if 
			      #'(lambda (zz) (and (consp zz) 
						  (equal (car zz) 'goal)))
			      (return-state-vars z)))
			 set-fps))
	 (c-fps (cons nil (append (mapcar 'copy-fp *new-connects*) set-fps)))
	 (set-fp-max (1- (length set-fps)))
	 (eb-max (1- (length eb-lib)))
	 (port-maxes (mapcar #'(lambda (x) (1- (length (eb-opers (eval x))))) 
			     eb-lib))
	 (c-fp-max (1- (length c-fps)))
	 (best (search-for-best-U fps ebs set-fps eb-lib c-fps prefs domain
				  dir sp connect goal-oper-list todo taboo
				  c-fp-max port-maxes eb-max set-fp-max)))
    ;; best = (U  connect-fp-i  connect-port-i  set-port-i  eb-i  set-fp-i)
    (cond ((zerop (car best)) nil)
	  (t
	   (let ((index (nth (random (length (cdr best))) (cdr best))))
	     (update-config 
	      (nth (fourth index) eb-lib)
	      (mod-list (mod-list (make-list port-maxes) (third index) 
				  (nth (fifth index) set-fps))
				  (second index)
				  (nth (first index) c-fps))
	      ebs
	      fps))))))


(defun search-for-best-U (fps ebs set-fps eb-lib connect-fps prefs domain dir
			      sp connect opers todo taboo c-fp-max
			      port-maxes eb-max set-fp-max)
  (do* ((U-of-index nil (calc-c-agent-utility
			 fps ebs (nth (fifth index) set-fps)
			 (nth (fourth index) eb-lib)
			 (nth (first index) connect-fps)
			 (third index) (second index) 
			 prefs domain dir sp connect 
			 (nth (fifth index) opers) todo taboo))
	(best (list 0) (cond ((> U-of-index (car best)) 
			      (list U-of-index index))
			     ((= U-of-index (car best))
			      (cons U-of-index (cons index (cdr best))))
			     (t best)))
	(index (cond ((= -1 set-fp-max) nil)
		     (t (list c-fp-max (1- (car (last port-maxes)))
			      (car (last port-maxes)) eb-max set-fp-max)))
	       (get-next-index index c-fp-max port-maxes eb-max)))
      ((null index) best)))

  
(defun get-next-index (index c-fp-max port-maxes eb-max)
  (cond ((not (zerop (car index))) (cons (1- (car index)) (cdr index)))
	((not (zerop (second index))) 
	 (cons c-fp-max (cons (1- (second index)) (nthcdr 2 index))))
	((not (zerop (third index))) 
	 (append (list c-fp-max (nth (fourth index) port-maxes)
		       (1- (third index))) (nthcdr 3 index)))
	((not (zerop (fourth index)))
	 (list c-fp-max (1- (nth (1- (fourth index)) port-maxes))
	       (nth (1- (fourth index)) port-maxes)
	       (1- (fourth index)) (fifth index)))
	((not (zerop (fifth index)))
	 (list c-fp-max (1- (car (last port-maxes)))
	       (car (last port-maxes)) eb-max (1- (fifth index))))
	(t nil)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Utility functions:
;;; The following 3 utility functions are used by
;;; the C-agents in making decisions about where,how, and which ebs are added.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun calc-c-agent-utility (fps ebs set-fp eb c-fp set-port-i connect-port-i
				 prefs domain dir sp connect oper todo taboo)
  (cond ((or (= set-port-i connect-port-i) 
	     (equal set-fp c-fp)
	     (not (match-eb-port-fp set-port-i (eval eb) set-fp))
	     (and c-fp (not (match-eb-port-fp connect-port-i (eval eb) c-fp))))
	 0)
	(t 
	 (+ 
	  (* (first prefs) (U-of-set-fp set-fp dir sp domain oper))
	  (* (second prefs) 
	     (U-of-eb-port set-fp (eval eb) set-port-i oper domain))
	  (* (third prefs)
	     (U-of-connect-fp c-fp set-fp set-port-i connect-port-i
			      (eval eb) sp connect oper))
	  (* (fourth prefs) 
	     (member-of-todo-taboo-list fps (backcons eb ebs) set-fp
					set-port-i c-fp connect-port-i todo))
	  (* (fifth prefs)
	     (member-of-todo-taboo-list fps (backcons eb ebs) set-fp
			      set-port-i c-fp connect-port-i taboo))))))


(defun U-of-set-fp (fp dir sp domain oper)
  ;; + 1 for containing a goal state variable (oper is non-nil)
  ;; + 1 for being to the proper domain
  ;; + 1 for being of the proper direction
  ;; + 1 for being proper serial or parallel
  (/ (+ (cond (oper 1) (t 0))
	(cond ((member domain (fp-domain fp) :test 'equal) 1) (t 0))
	(cond ((equal dir (fp-direct fp)) 1) (t 0))
	(cond ((or (and (equal sp 'series) (= (length (fp-index fp)) 1))
		   (and (equal sp 'parallel) (> (length (fp-index fp)) 1)))
	       1)
	      (t 0)))
     (apply '+(mapcar #'(lambda (x) (cond (x 1) (t 0)))
		       (list t dir sp domain)))))

(defun U-of-eb-port (set-fp eb set-port-num oper domain)
  ;; + 1 for being to the proper domain
  ;; + 1 for being of the proper state-var operator goal fulfillment
  (/ (+ (cond ((member domain (eb-domain eb) :test 'equal) 
	       1)
	      (t 0))
	(cond ((and oper
		    (= (mod oper 4)
		       (position (nth (truncate oper 4)
				      (nth set-port-num (eb-oper eb)))
				 '(through deriv none integ nil))))
		1)
	       (t 0)))
     (apply '+ (mapcar #'(lambda (x) (cond (x 1) (t 0)))
		       (list domain oper)))))


(defun U-of-connect-fp (connect-fp set-fp set-port-num connect-port-num eb 
				   sp connect oper)
  ;; + 1 for proper connection type (ground, connect, dangle)
  ;; + 1 for proper serial-vs-parallel (automatically score for ground or nil
  ;;       connections)
  ;; + 1 for not 'grounding' configuration (making goal go to a ground)
  ;;                                      (automatically score for nil)
  ;; + 1 for proper fulfillment of goal oper (automatically score for nil)
  (/
   (+ 
    (cond ((null connect-fp) (cond ((equal connect 'dangle) 1) (t 0)))
	  ((member 'ground (fp-index connect-fp) :test 'equal)
	   (cond ((equal connect 'ground) 1) (t 0)))
	  ((equal connect 'connect) 1)
	  (t 0))
    (cond ((or (and (equal sp 'series)
		    (or (null connect-fp)
			(= (length (fp-index connect-fp))) 1))
	       (and (equal sp 'parallel) connect-fp
		    (> (length (fp-index connect-fp)) 1))) 1)
	  (t 0))
    (cond ((null oper) 0)
	  ((null connect-fp) 1)
	  ((null (nth (truncate oper 4)
		      (nth set-port-num (eb-oper eb))))
	   (let ((c-oper (nth oper (return-state-vars connect-fp))))
	     (cond ((numberp c-oper) 0)
		   ((and (listp c-oper)
			 (not (equal (car c-oper) 'goal))) 2)
		   (t 1))))
	  (t
	   (let ((j (position 
		     (nth (truncate oper 4)
			  (nth set-port-num (eb-oper eb)))
		     '(through deriv none integ nil)))
		 (c-oper (nth oper (return-state-vars connect-fp))))
	     (cond ((and (= j (mod oper 4))
			 (or (numberp c-oper)
			     (and (listp c-oper)
				  (not (equal (car c-oper) 'goal))))) 2)
		   (t 1))))))
   (apply '+ (mapcar #'(lambda (x) (cond (x 1) (t 0))) 
		     (list connect sp oper oper)))))



(defun member-of-todo-taboo-list (fps ebs set-fp set-eb set-port-num c-fp t-list)
  (cond (t-list
	 (/ (apply #'+ (mapcar #'(lambda (y) (length (intersection ebs y))) t-list))
	    (length (apply #'append t-list))))
	(t 0)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; C-AGENT HELPER FUNCTIONS
;;; THESE FUNCTIONS ARE EXECUTED BY THE C-AGENTS IN CHOOSING SET-FPS, 
;;; CONNECT-FPS, AND EMBODIMENTS.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; MATCH-EB-PORT-FP
;;; Predicate which judges if a port of an EB can connect to an fp
(defun match-eb-port-fp (port-num eb fp)
  ;; first make sure you have both the eb and the fp
  (and eb fp
       ;; if either class is nil then ok, otherwise make sure classes are
       ;; equal
       (or (not (nth port-num (eb-class eb)))
	   (not (fp-class fp))
	   (equal (nth port-num (eb-class eb)) (fp-class f)))
       ;; if either direct is nil then ok, otherwise make sure directions
       ;; are OPPOSITE
       (or (not (nth port-num (eb-direct eb)))
	   (not (fp-direct fp))
	   (not (equal (nth port-num (eb-direct eb)) (fp-direct f))))
       ;; match interface with following function - checks with 
       ;; *interface-list* from init file
       (match-interface (nth port-num (eb-inter eb) (fp-inter f)))))


(defun match-interface (inter1 inter2)
  (and inter1 
       inter2 
       (or (member (list inter1 inter2) *interface-list* 
		   :test #'equal :key #'car)
	   (member (list inter2 inter1) *interface-list*
		   :test #'equal :key #'car))))
(defun update-interface (inter1 inter2)
  (cdr (find-if #'(lambda (x) (or (equal (list inter1 inter2) x)
				    (equal (list inter2 inter1) x)))
		  *interface-list* :key #'car)))
