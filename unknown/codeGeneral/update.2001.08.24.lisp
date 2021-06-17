;;; UPDATE-CONFIG
;;; With the agent picking the embodiment it wishes to add to a design, this
;;; function returns how the fp's of the design state are affected. Obviously
;;; the set-fp is affected since the embodiment attaches to it, but also
;;; the connect-fps includes other fp's the agent might like to see the
;;; other ports of the embodiment attach to (only one port can go to any
;;; in connect-fps, that is, connect-fps are removed after they are 
;;; used.  Returns all the fp's of the design, even if some are not changed.
(defun update-config (eb connect-fps ebs fps)
  (do ((new-fps fps
		(cond ((car connect-fps)
		       (modify-fp-in-list 
			(car connect-fps) new-fps 
			:class (cond ((nth i (eb-class (eval eb))))
				     (t 'empty))
			:domain (cond ((nth i (eb-domain (eval eb))))
				      (t 'empty))
			:inter (update-interface 
				(nth i (eb-inter (eval eb))) 
				(fp-inter (car connect-fps)))
			:index (cons (list (length ebs) i) 
				     (fp-index (car connect-fps)))))
		      (t (cons (create-fp ;;create a new fp if nil
				nil nil
				(nth i (eb-class (eval eb)))
				(nth i (eb-domain (eval eb)))
				nil (nth i (eb-inter (eval eb))) nil
				(list (list (length ebs) i)))
			       new-fps))))
       (connect-fps connect-fps (cdr connect-fps))
       (i 0 (1+ i)))
      ((endp connect-fps) 
       (list 
	(update-through-across-direct-coord new-fps (length ebs) (backcons eb ebs))
	;; the new-fps But...
	(backcons eb ebs)
	;; the new-ebs basically adding the new one to the end of the list
	))))
;;; old version - new version not yet tested
;;(defun update-config (eb set-port set-fp connect-fps ebs fps)
;;  (do ((new-fps (modify-fp-in-list 
;;		 set-fp fps 
;;		 :class (cond ((cp-class (nth set-port 
;;					      (eb-const-param (eval eb)))))
;;			      (t 'empty))
;;		 :domain (cond ((cp-domain (nth set-port 
;;						(eb-const-param (eval eb)))))
;;			       (t 'empty))
;;		 :inter (update-interface 
;;			 (cp-inter (nth set-port (eb-const-param (eval eb)))) 
;;			 (fp-inter set-fp))
;;		 :index (cons (list (length ebs) set-port) (fp-index set-fp)))
;;		(cond ((= i set-port) new-fps)
;;		      ((car connect-fps)
;;		       (modify-fp-in-list 
;;			(car connect-fps) new-fps 
;;			:class (cond ((cp-class 
;;				       (nth i (eb-const-param (eval eb)))))
;;				     (t 'empty))
;;			:domain (cond ((cp-domain 
;;					(nth i (eb-const-param (eval eb)))))
;;				      (t 'empty))
;;			:inter (update-interface 
;;				(cp-inter (nth i (eb-const-param (eval eb)))) 
;;				(fp-inter (car connect-fps)))
;;			:index (cons (list (length ebs) i) 
;;				     (fp-index (car connect-fps)))))
;;		      (t (cons (create-fp 
;;				(make-list (length (cp-domain (car ports))))
;;				(make-list (length (cp-domain (car ports))))
;;				(cp-class (car ports)) (cp-domain (car ports))
;;				nil (cp-inter (car ports)) nil
;;				(list (list (length ebs) i)))
;;			       new-fps))))
;;       (ports (eb-const-param (eval eb)) (cdr ports))
;;       (connect-fps connect-fps (cdr connect-fps))
;;       (i 0 (1+ i)))
;;      ((endp ports) 
;;       (list 
;;	(update-through-across-direct new-fps (length ebs) (backcons eb ebs))
;;	(backcons eb ebs)))))



;;; MODIFY-FP-IN-LIST
;;; Makes any modification to an FP in the current set of FP's. All slots are
;;; optional. Returns the complete FP list.
(defun modify-fp-in-list (fp fps &key (through 'empty) (across 'empty)
			     (class 'empty) (domain 'empty) (coord 'empty) 
			     (inter 'empty) (direct 'empty) (index  'empty))
  (cons (create-fp
	 (cond ((equal 'empty through) (fp-through fp)) (t through))
	 (cond ((equal 'empty across) (fp-across fp)) (t across))
	 (cond ((equal 'empty class) (fp-class fp)) (t class))
	 (cond ((equal 'empty domain) (fp-domain fp)) (t domain))
	 (cond ((equal 'empty coord) (fp-coord fp)) (t coord))
	 (cond ((equal 'empty inter) (fp-inter fp)) (t inter))
	 (cond ((equal 'empty direct) (fp-direct fp)) (t direct))
	 (cond ((equal 'empty index) (fp-index fp)) (t index)))
	(remove fp fps)))


(defun update-through-across-direct (fps eb-num ebs)
  (do* ((other-connects nil (eb-connects-to (list eb-num port-num) new-fps))
	(candidate-through nil (mapcar #'fp-through other-connects))
	(candidate-across nil (mapcar #'fp-across other-connects))
	(candidate-directs nil (mapcar #'fp-direct other-connects))
	(new-fps fps (update-fps-in-branch other-connects eb-num port-num 
					   candidate(1+ i-through candidate-across 
					   candidate-directs new-fps ebs))
	(port-num 0 (1+ port-num))))
      ((= port-num (length (eb-const-param (eval (nth eb-num ebs))))) 
       new-fps)))

;;; New function.
;;; We need to change update-through-across-direct to 
;;; update-through-across-direct-COORD.
(defun update-through-across-direct-coord (fps eb-num ebs)
  (do* ((other-connects nil (eb-connects-to (list eb-num port-num) new-fps))
	(candidate-through nil (mapcar #'fp-through other-connects))
	(candidate-across nil (mapcar #'fp-across other-connects))
	(candidate-directs nil (mapcar #'fp-direct other-connects))
	;; candidate-coords?
	(new-fps fps (update-fps-in-branch other-connects eb-num port-num 
					   candidate-through candidate-across 
					   candidate-directs new-fps ebs))
	(port-num 0 (1+ port-num)))
      ((= port-num (length (eb-domain (eval (nth eb-num ebs))))) 
       new-fps)))


(defun update-fps-in-branch (from eb-num port-num cand-through cand-across
				  cand-drs fps ebs)
  (do* ((start (port-connects-to (list eb-num port-num) fps))
	(through (update-through (fp-through start) cand-through))
	(across (update-across (fp-across start) (nth eb-num ebs)
			       port-num cand-across))
	(direct (update-direct start (nth eb-num ebs) port-num cand-drs))
	(new-fps (print (cond ((and (equal through (fp-through start))
			     (equal across (fp-across start))
			     (equal direct (fp-direct start))) nil)
		       (t (modify-fp-in-list start fps :through through 
					     :across across :direct direct))))
		 (update-fps-in-branch 
		  (cons start from) (caar where-to) (cadar where-to) 
		  (list through) (list across) (list direct) new-fps ebs))
	(where-to (cond (new-fps (fp-connects-to start nil ;;from
						 new-fps)) (t nil))
		  (cdr where-to)))
      ((endp where-to) (cond (new-fps) (t fps)))))


(defun update-direct (start eb port-num cand-drs)
  (cond ((or (member 'goal (fp-index start))
	     (member 'ground (fp-index start))) 
	 (fp-direct start))
	((nth port-num (eb-direct (eval eb))))
	((or (equal (fp-direct start) 'source)
	     (member 'source cand-drs :test 'equal))
	 'source)
	((or (equal (fp-direct start) 'sink)
	     (member 'sink cand-drs :test 'equal))
	 'sink)))


(defun update-through (through cand-through)
  (do ((terms (backcons through cand-through)
	      (cons (mapcar #'(lambda (x y) (update-through-across-term x y))
			    (cond ((cadr terms))
				  (t (make-list (length (car terms)))))
			    (cond ((car terms))
				  (t (make-list (length (cadr terms))))))
		    (cddr terms))))
      ((= 1 (length terms)) (car terms))))
;			 (cond ((or (equalp x 0) (equalp y 0)) 0)
;			       ((or (equal x 'bound) (equal y 'bound)
;				    (and (consp x) 
;					 (not (equal (car x) 'goal))) 
;				    (and (consp y) 
;					 (not (equal (car y) 'goal)))) 
;				'bound)
;			       ((or (and (consp x) (cadr x))
;				    (and (consp y) (cadr y)))
;				'(goal bound))
;			       ((or (consp x) (consp y)) '(goal nil))
;			       (t nil)))


(defun update-across (across eb port-num cand-across)
  (cond ((cdr cand-across)      ; First reduce the cand-across to one set.
	 (update-across
	  across eb port-num
	  (cons (mapcar 
		 #'(lambda (x y) 
		     (do ((new-value nil (backcons (update-through-across-term 
						    (car candidate1) 
						    (car candidate2) 
						    :term-num i)
						   new-value))
			  (candidate1 x (cdr candidate1))  
			  (candidate2 y (cdr candidate2))
			  (i 0 (1+ i)))  
			 ((and (endp candidate1) (endp candidate2)) 
			  new-value)))
		 (car cand-across) (cadr cand-across))
		(cddr cand-across))))
	;; Now, compare this to the actual opers at the fp, taking into account
	;; that you have to pass through the operator of the embodiment
	(t (mapcar #'(lambda (x y z) 
		       (do ((new-value nil (backcons 
					    (update-through-across-term 
					     (car candidate1) 
					     (car candidate2) 
					     :oper-num z :term-num i)
					    new-value))
			    (candidate1 x (cdr candidate1))  
			    (candidate2 y (cdr candidate2))
			    (i 0 (1+ i)))  
			   ((and (endp candidate1) (endp candidate2)) 
			    new-value)))
		   (cond (across) (t (make-list (length (car cand-across)))))
		   (cond ((car cand-across)) (t (make-list (length across))))
		   (mapcar #'(lambda (x) (position x '(deriv none integ)))
			   (nth port-num (eb-oper (eval eb))))))))


(defun update-through-across-term (x y &key (oper-num nil) (term-num nil))
  (cond ((and (numberp oper-num) (not (= oper-num term-num))) x)
	((and (numberp y) (zerop y) (null oper-num)) y)
	((and (consp x) (equal (car x) 'goal)
	      (or (numberp y) 
		  (and (consp y) (numberp (car y)))
		  (and (consp y) (equal (car y) 'goal-met))))
	 (list 'goal-met (cadr x)))
	((and (null x)
	      (or (numberp y) 
		  (equal y 'bound)
		  (and (consp y) (numberp (car y)))
		  (and (consp y) (equal (car y) 'goal-met))))
	 'bound)
	((and (null x) y) (list 'goal 'bound))
	(t x)))


(defun make-unique-mg-change (eb-num port-num oper eb)
  (do ((coeff (nth (+ (* 4 port-num) oper) (eb-MG-change (eval eb)))
	      (subst (intern
		      (make-symbol 
		       (format nil "~A_~D" (string (car ebdata)) eb-num))) 
		     (car ebdata) coeff))
       (ebdata (eb-data (eval eb)) (cdr ebdata)))
      ((endp ebdata) coeff)))

(defun make-unique-po-change (eb-num from-port to-port eb)
  (do ((matrix (nth from-port (nth to-port (eb-PO-change (eval eb))))
	       (subst (intern 
		       (make-symbol
			(format nil "~A_~D" (string (car ebdata)) eb-num))) 
		     (car ebdata) coeff))
       (ebdata (eb-data (eval eb)) (cdr ebdata)))
      ((endp ebdata) coeff)))

;;; This functions goes through and creates symbolic positions in each of the
;;; FP's coord slot.
(defun update-coordinates (fps ebs)
  (do* ((start (car (remove-if-not 
		     #'(lambda (x) (and (fp-coord x) 
					(member 'goal (fp-index x))))
		     fps)))
	(fps fps (cond ((consp (car ports))
			(update-coord-branch-eb
			 fps ebs (caar ports) (cadar ports) (fp-coord start)))
		       (t fps)))	    
	(ports (fp-index start) (cdr ports)))
      ((endp ports) fps)))


(defun update-coord-branch-eb (fps ebs eb-num port-num coord)
  (do* ((fp nil (port-connects-to (list eb-num i) fps))
	(fps fps (cond ((or (= i port-num) (fp-coord fp)) fps)
		       (t 
			(update-coord-branch-fp 
			 (modify-fp-in-list 
			  fp fps :coord (matrix-multiply 
					 (make-unique-po-change
					  eb-num port-num i 
					  (eval (nth eb-num ebs))) 
					 coord))
			 ebs (remove-if #'(lambda (x) 
					    (or (not (consp x))
						(equal x (list eb-num i))))
					(fp-index fp))))))
	(i (1- (length (eb-const-param (eval (nth eb-num ebs)))))
	   (1- i)))
      ((< i 0) fps)))


(defun update-coord-branch-fp (fps ebs ports)
  (do ((coord (fp-coord (car fps)))
       (ports ports (cdr ports))
       (fps fps (update-coord-branch-eb 
		 fps ebs (caar ports) (cadar ports) coord)))
      ((endp ports) fps)))

