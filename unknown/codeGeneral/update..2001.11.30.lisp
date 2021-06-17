;;; UPDATE-CONFIG
;;; With the agent picking the embodiment it wishes to add to a design, this
;;; function returns how the fp's of the design state are affected. Obviously
;;; the set-fp is affected since the embodiment attaches to it, but also
;;; the connect-fps includes other fp's the agent might like to see the
;;; other ports of the embodiment attach to (only one port can go to any
;;; in connect-fps, that is, connect-fps are removed after they are 
;;; used.  Returns all the fp's of the design, even if some are not changed.
(defun update-config (eb connect-fps ebs fps);;fps/ebs -> all the fps/ebs in existing design
  (do ((new-fps fps ;; new fps set to old fps 
		(cond ((car connect-fps);how does this evaluate to a true/false ? connect-fp->list of fps on the component
		       (modify-fp-in-list ;;first fp nil -> create new one
			(car connect-fps) new-fps;; 
			:class (cond ((nth i (eb-class (eval eb))));;;i -> ports
				     (t 'empty))
			:domain (cond ((nth i (eb-domain (eval eb))))
				      (t 'empty))
			:inter (update-interface 
				(nth i (eb-inter (eval eb)));;;result when fps a 
				(fp-inter (car connect-fps)))
			:index (cons (list (length ebs) i) 
				     (fp-index (car connect-fps)))));;track of the eb and port of eb connection
		      (t (cons (create-fp ;;create a new fp if nil
				;;This will always be executed or the else condition ?
				;;creates a new list of fp,eb,domain,interface ?.
				nil nil
				(nth i (eb-class (eval eb)))
				(nth i (eb-domain (eval eb)))
				nil (nth i (eb-inter (eval eb))) nil
				(list (list (length ebs) i)));;cons new fp to fps
			       new-fps))))
       (connect-fps connect-fps (cdr connect-fps))
       (i 0 (1+ i)))
      ((endp connect-fps) 
       (list 
	(update-through-across-direct new-fps (length ebs) (backcons eb ebs));;updation of ebs/design. Why backcons ?
	;; the new-fps But...
	(backcons eb ebs);;adds a new eb to the ebs
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
(defun modify-fp-in-list (fp fps &key (through 'empty) (across 'empty);;&->optional arguments
			     (class 'empty) (domain 'empty) (coord 'empty) 
			     (inter 'empty) (direct 'empty) (index  'empty));;;explanation of arguments required
  (cons (create-fp;;return 
	 (cond ((equal 'empty through) (fp-through fp)) (t through))
	 (cond ((equal 'empty across) (fp-across fp)) (t across))
	 (cond ((equal 'empty class) (fp-class fp)) (t class))
	 (cond ((equal 'empty domain) (fp-domain fp)) (t domain))
	 (cond ((equal 'empty coord) (fp-coord fp)) (t coord))
	 (cond ((equal 'empty inter) (fp-inter fp)) (t inter))
	 (cond ((equal 'empty direct) (fp-direct fp)) (t direct))
	 (cond ((equal 'empty index) (fp-index fp)) (t index)))
	(remove fp fps)))


;;; old version - new version not yet tested
;(defun update-through-across-direct (fps eb-num ebs)
;  (do* ((other-connects nil (eb-connects-to (list eb-num port-num) new-fps))
;	(candidate-through nil (mapcar #'fp-through other-connects))
;	(candidate-across nil (mapcar #'fp-across other-connects))
;	(candidate-directs nil (mapcar #'fp-direct other-connects))
;	(new-fps fps (update-fps-in-branch other-connects eb-num port-num 
;					   candidate(1+ i-through candidate-across 
;					   candidate-directs new-fps ebs))
;	(port-num 0 (1+ port-num))))
;      ((= port-num (length (eb-const-param (eval (nth eb-num ebs))))) 
;       new-fps)))

(defun update-through-across-direct (fps eb-num ebs)
  ;;make sure that the through and across vars are correct& direction of flow of energy
  (do* ((port-num (length (eb-domain (eval (nth eb-num ebs)))) (1- port-num))
	(other-connects nil (cons (port-connects-to (list eb-num port-num) fps)
				  other-connects)))
      ((zerop port-num) 
       (do* ((port-num (length (eb-domain (eval (nth eb-num ebs)))) (1- port-num))
	     (candidate-through nil (mapcar #'fp-through other-connects))
	     (candidate-across nil (mapcar #'fp-across other-connects))
	     (candidate-directs nil (mapcar #'fp-direct other-connects))
	     (new-fps fps (update-fps-in-branch other-connects eb-num port-num 
						candidate-through candidate-across 
						candidate-directs new-fps ebs)))
	   ((zerop port-num) new-fps)))))


(defun update-fps-in-branch (from eb-num port-num cand-through cand-across
				  cand-drs fps ebs)
  (do* ((start (port-connects-to (list eb-num port-num) fps))
	(through (update-through cand-through port-num eb-num ebs))
	(across (update-across cand-across port-num eb-num ebs))
	(direct (update-direct start (nth eb-num ebs) port-num cand-drs))
	(new-fps (cond ((and (equal through (fp-through start))
			     (equal across (fp-across start))
			     (equal direct (fp-direct start))) nil)
		       (t (modify-fp-in-list start fps :through through 
					     :across across :direct direct)))
		 (update-fps-in-branch 
		  (cons start from) (caar where-to) (cadar where-to) 
		  (list through) (list across) (list direct) new-fps ebs))
	(where-to (cond (new-fps (fp-connects-to start from new-fps)) (t nil))
		  (cdr where-to)))
      ((endp where-to) (cond (new-fps) (t fps)))))


(defun update-direct (start eb port-num cand-drs);;;cand-drs ?
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


(defun update-through (cand-through port-num eb-num ebs)
  (do* ((old-through (nth port-num cand-through))
	(domain-num 8 (1- domain-num))
	(opers nil (remove-if-not #'(lambda (x) (equal (car x) (list port-num domain-num)))
				 (eb-opers (eval (nth eb-num ebs)))))
	(new-through nil (cons (cond (opers 
				      (update-through-term 
				       (nth domain-num old-through)
				       (mapcar #'(lambda (x) (nth (caddr x) (nth (cadr x) cand-through)))
					       opers)))
				     (t (nth domain-num old-through)))
			      new-through)))
      ((zerop domain-num) (print new-through))))
							  
(defun update-across (cand-across port-num eb-num ebs)
  (do* ((old-across (nth port-num cand-across))
	(domain-num 8 (1- domain-num))
	(opers nil (remove-if-not #'(lambda (x) (equal (car x) (list port-num domain-num)))
				 (eb-opers (eval (nth eb-num ebs)))))
	(new-across nil (cons (cond (opers 
				      (update-across-term 
				       (nth domain-num old-across)
				       (mapcar #'(lambda (x) (nth (caddr x) (nth (cadr x) cand-across)))
					       opers)
				       (mapcar #'(lambda (x) (cdddr x)) opers)))
				     (t (nth domain-num old-across)))
			      new-across)))
      ((zerop domain-num) new-across)))
							  
(defun update-through-term (old-val cand-vals)
  ;; old-val is the old value for that particular term
  ;; cand-vals and cand-oper-types are lists of the same length
  ;; that denote possible ways the old-val can be updated.
  ;; Note: it is possible that the old value supersedes the new cand's
  (cond ((endp cand-vals) old-val)
	((or (numberp old-val) (numberp (car cand-vals))) old-val)
	((null (car cand-vals))
	 (update-through-term old-val (cdr cand-vals)))
	((or (equal old-val 'bound) 
	     (equal (car cand-vals) 'bound)
	     (and (consp old-val) 
		  (not (equal (car old-val) 'goal))) 
	     (and (consp (car cand-vals)) 
		  (not (equal (car (car cand-vals)) 'goal)))) 
	 (update-through-term 'bound (cdr cand-vals)))
	((or (and (consp old-val) (cadr old-val))
	     (and (consp (car cand-vals)) (cadr (car cand-vals))))
	 (update-through-term '(goal bound) (cdr cand-vals)))
	;; what about goal-met?
	(t (update-through-term old-val (cdr cand-vals)))))


(defun update-across-term (old-val cand-vals cand-oper-types)
  ;; old-val is the old value for that particular term
  ;; cand-vals and cand-oper-types are lists of the same length
  ;; that denote possible ways the old-val can be updated.
  ;; Note: it is possible that the old value supersedes the new cand's
  (cond ((endp cand-vals) old-val)
	((or (numberp old-val) (numberp (car cand-vals))) old-val)
	((null (car cand-vals))
	 (update-across-term old-val (cdr cand-vals) cand-oper-types))
	((or (equal old-val 'bound) 
	     (equal (car cand-vals) 'bound)
	     (and (consp old-val) 
		  (not (equal (car old-val) 'goal))) 
	     (and (consp (car cand-vals)) 
		  (not (equal (car (car cand-vals)) 'goal)))) 
	 (update-across-term 'bound (cdr cand-vals) cand-oper-types))
	((or (and (consp old-val) (cadr old-val))
	     (and (consp (car cand-vals)) (cadr (car cand-vals))))
	 (update-across-term '(goal bound) (cdr cand-vals) cand-oper-types))
	;; what about goal-met?
	(t (update-across-term old-val (cdr cand-vals) cand-oper-types))))

;(defun update-through (through cand-through)
;  (do ((terms (backcons through cand-through)
;	      (cons (mapcar #'(lambda (x y) (update-through-across-term x y))
;			    (cond ((cadr terms))
;				  (t (make-list (length (car terms)))))
;			    (cond ((car terms))
;				  (t (make-list (length (cadr terms))))))
;		    (cddr terms))))
;      ((= 1 (length terms)) (car terms))))
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


;(defun update-across (across eb port-num cand-across)
;  (cond ((cdr cand-across)      ; First reduce the cand-across to one set.
;	 (update-across
;	  across eb port-num
;	  (cons (mapcar 
;		 #'(lambda (x y) 
;		     (do ((new-value nil (backcons (update-through-across-term 
;						    (car candidate1) 
;						    (car candidate2) 
;						    :term-num i)
;						   new-value))
;			  (candidate1 x (cdr candidate1))  
;			  (candidate2 y (cdr candidate2))
;			  (i 0 (1+ i)))  
;			 ((and (endp candidate1) (endp candidate2)) 
;			  new-value)))
;		 (car cand-across) (cadr cand-across))
;		(cddr cand-across))))
;	;; Now, compare this to the actual opers at the fp, taking into account
;	;; that you have to pass through the operator of the embodiment
;	(t (mapcar #'(lambda (x y z) 
;		       (do ((new-value nil (backcons 
;					    (update-through-across-term 
;					     (car candidate1) 
;					     (car candidate2) 
;					     :oper-num z :term-num i)
;					    new-value))
;			    (candidate1 x (cdr candidate1))  
;			    (candidate2 y (cdr candidate2))
;			    (i 0 (1+ i)))  
;			   ((and (endp candidate1) (endp candidate2)) 
;			    new-value)))
;		   (cond (across) (t (make-list (length (car cand-across)))))
;		   (cond ((car cand-across)) (t (make-list (length across))))
;		   (mapcar #'(lambda (x) (position x '(deriv none integ)))
;			   (nth port-num (eb-opers (eval eb))))))))


(defun update-through-across-term (x y &key (oper-num nil) (term-num nil))
  ;; x is what you're currently trying to update and
  ;; y is your candidate
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


(defun make-unique-mg-change (eb-num port-num oper eb);;does unique refer to one eb ? Shouldn't the other ebs be modified as well ?
  (do ((coeff (nth (+ (* 4 port-num) oper) (eb-MG-change (eval eb)))
	      (subst (intern
		      (make-symbol 
		       (format nil "~A_~D" (string (car ebdata)) eb-num))) 
		     (car ebdata) coeff))
       (ebdata (eb-data (eval eb)) (cdr ebdata)))
      ((endp ebdata) coeff)))

(defun make-unique-po-change (eb-num from-port to-port eb)
  (do ((matrix (nth to-port (nth from-port (eb-PO-change (eval eb))))
	       (subst (intern 
		       (make-symbol
			(format nil "~A_~D" (string (car ebdata)) eb-num))) 
		     (car ebdata) matrix))
       (ebdata (eb-data (eval eb)) (cdr ebdata)))
      ((endp ebdata) matrix)))

;;; This functions goes through and creates symbolic positions in each of the
;;; FP's coord slot.
(defun update-coordinates (fps ebs)
  (do* ((start (find-if #'(lambda (x) (fp-coord x)) fps));;find-if ? test in sequence ,start local variable from hereon
	;	(car (remove-if-not 
	;	     #'(lambda (x) (and (fp-coord x) 
	;				(member 'goal (fp-index x))))
	;	     fps)))
	(fps fps (cond ((consp (car ports));;consp ? ;; fps set to fps
			(update-coord-branch-eb
			 fps ebs (caar ports) (cadar ports) (fp-coord start)))
		       (t fps)))	    
	(ports (fp-index start) (cdr ports)));;how does this function work ?
      ((endp ports) fps)))


(defun update-coord-branch-eb (fps ebs eb-num port-num coord);;why do we need to do this ?
  (do* ((fp nil (port-connects-to (list eb-num i) fps))
	(fps fps (cond ((or (= i port-num) (fp-coord fp)) fps);;not to change the fps
		       (t 
			(update-coord-branch-fp 
			 (modify-fp-in-list 
			  fp fps :coord (matrix-multiply;;modifies only the coord of the fp in the fps 
					 coord (make-unique-po-change
					  eb-num port-num i 
					  (eval (nth eb-num ebs))) 
					 ));;coord of start for the first time
			 ebs (remove-if #'(lambda (x) 
					    (or (not (consp x))
						(equal x (list eb-num i))))
					(fp-index fp))))))
	(i (1- (length (eb-domain (eval (nth eb-num ebs)))))
	   (1- i)))
      ((< i 0) fps)))


(defun update-coord-branch-fp (fps ebs ports) 
  (do ((coord (fp-coord (car fps)))
       (ports ports (cdr ports))
       (fps fps (update-coord-branch-eb 
		 fps ebs (caar ports) (cadar ports) coord)))
      ((endp ports) fps)))

