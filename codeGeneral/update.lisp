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

;;(defun update-through-across-direct (fps eb-num ebs &optional from-port)
;;  ;;make sure that the through and across vars are correct& direction of flow of energy
;;  (do* ((port-num (length (eb-domain (eval (nth eb-num ebs)))) (1- port-num))
;;	(other-connects nil (mapcar
;;			     #'(lambda (x y)
;;				 (port-connects-to (list eb-num x) new-fps))
;;			     '(0 1 2 3 4 5 6 7 8 9 10)
;;			     (eb-domain (eval (nth eb-num ebs)))))
;;	;; the change from above is done to 'order' the other-connects based
;;	;; on which ports they connect to on the new EB. the 'port-connect-to'
;;	;; function is used repeatedly as opposed to eb-connects-to which 
;;	;; does not return the answer in any particular order
;;	(candidate-through nil (mapcar #'fp-through other-connects))
;;	(candidate-across nil (mapcar #'fp-across other-connects))
;;	(candidate-directs nil (mapcar #'fp-direct other-connects))
;;	(new-fps fps (update-fps-in-branch other-connects eb-num port-num 
;;					   candidate-through candidate-across 
;;					   candidate-directs new-fps ebs)))
;;      ((zerop port-num) new-fps)))


;;(defun update-fps-in-branch (from eb-num port-num cand-through cand-across
;;				  cand-drs fps ebs)
;;  (do* ((start (port-connects-to (list eb-num port-num) fps))
;;	(through (update-through cand-through port-num eb-num ebs))
;;	(across (update-across cand-across port-num eb-num ebs))
;;	(direct (update-direct start (nth eb-num ebs) port-num cand-drs))
;;	(new-fps (cond ((and (equal through (fp-through start))
;;			     (equal across (fp-across start))
;;			     (equal direct (fp-direct start))) nil)
;;		       (t (modify-fp-in-list start fps :through through 
;;					     :across across :direct direct)))
;;		 (update-fps-in-branch 
;;		  (cons start from) (caar where-to) (cadar where-to) 
;;		  (mod-list cand-through port-num 
;;			    (mod-list (cadar where-to)through)
;;			    (mod-list cand-across port-num across) 
;;			    (list direct) new-fps ebs)))
;;	;;
;;	;;here's the bug cand-across not include where you are at!!!
;;	;;
;;	(where-to (cond (new-fps (fp-connects-to start nil ;;from
;;						 new-fps)) (t nil))
;;		  (cdr where-to)))
;;      ((endp where-to) (cond (new-fps) (t fps)))))


(defun update-through-across-direct (fps eb-num ebs &optional (from-port -1))
  (do* ((port-num (length (eb-domain (eval (nth eb-num ebs)))) 
		  (1- port-num))
	(other-connects nil (mapcar
			     #'(lambda (x y)
				 (port-connects-to (list eb-num x) new-fps))
			     '(0 1 2 3 4 5 6 7 8 9 10)
			     (eb-domain (eval (nth eb-num ebs)))))
	;; the change from above is done to 'order' the other-connects based
	;; on which ports they connect to on the new EB. the 'port-connect-to'
	;; function is used repeatedly as opposed to eb-connects-to which 
	;; does not return the answer in any particular order
	(candidate-through nil (mapcar #'fp-through other-connects))
	(candidate-across nil (mapcar #'fp-across other-connects))
	(candidate-directs nil (mapcar #'fp-direct other-connects))
	(new-fps fps (update-fps-in-branch 
			       eb-num port-num candidate-through
			       candidate-across candidate-directs new-fps ebs)))
      ((zerop port-num) (gc) new-fps)))

(defun update-fps-in-branch (eb-num port-num cand-through cand-across
                                    cand-drs fps ebs)
  (do* ((start (port-connects-to (list eb-num port-num) fps))
	(through (update-through cand-through port-num eb-num ebs))
	(across (update-across cand-across port-num eb-num ebs))
	(direct (update-direct start (nth eb-num ebs) port-num cand-drs))
	(new-fps (cond ((and (equal through (fp-through start))
                      (equal across (fp-across start))
                 ;(equal direct (fp-direct start))
                 ) 
                 nil) 
                (t 
   ;              (print (list through across direct))
                        (modify-fp-in-list start fps :through through 
					     :across across :direct direct)))
		 (update-through-across-direct 
		  new-fps (caar where-to) ebs (cadar where-to)))
	(where-to (cond (new-fps (remove-if 
				  #'(lambda (x) 
				      (or (equal x (list eb-num port-num))
					  (not (consp x))
					  (equal (car x) 'goal)))
				  (fp-index start)))
			(t nil)) 
		  (cdr where-to)))
      ((endp where-to) (cond (new-fps) (t fps)))))




(defun update-direct (start eb port-num cand-drs);;;cand-drs ?
  (cond ((or (r-member 'goal (fp-index start))
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
				       (mapcar #'(lambda (x) 
						   (nth (caddr x) 
							(nth (cadr x) cand-through)))
					       opers)
				     (mapcar #'(lambda (x) (cdddr x)) opers)))
				     (t (nth domain-num old-through)))
			       new-through)))
      ((zerop domain-num) new-through)))
							  
(defun update-through-term (old-val cand-vals cand-oper-types)
  ;; old-val is the old value for that particular term
  ;; cand-vals denotes possible ways the old-val can be updated.
  ;; Note: it is possible that the old value supersedes the new cand's
  ;; for through variables, the operator is unimportant, all that matters 
  ;; is that the ports are not anti-coupled (independent).
  (cond ((endp cand-vals) old-val)
	((null (car cand-vals))
	 (update-through-term old-val (cdr cand-vals) (cdr cand-oper-types)))
	;; if old-val is a number, this beats all
	((numberp old-val) old-val) 
	;; if cand is number return candidate
	((and (numberp (car cand-vals))
	      (not (member 't (car cand-oper-types) :test 'equal)))
	 (car cand-vals))
	;; if the old val is a range
	((and (consp old-val) (numberp (car old-val))) 	
	 (update-through-term old-val (cdr cand-vals) (cdr cand-oper-types)))
	;; if the cand is a range
	((and (consp (car cand-vals)) (numberp (car (car cand-vals)))
	      (not (member 't (car cand-oper-types) :test 'equal)))
	 (update-through-term (car cand-vals) (cdr cand-vals) (cdr cand-oper-types)))
	;; if the old val is 'bound'
	((equal old-val 'bound) 
	 (update-through-term old-val (cdr cand-vals) (cdr cand-oper-types)))
	;; if the cand is 'bound'
	((or (equal (car cand-vals) 'bound) 
	     (and (member 't (car cand-oper-types) :test 'equal)
		  (or (numberp (car cand-vals))
		      (and (consp (car cand-vals)) (numberp (car (car cand-vals)))))))
	 (update-through-term 'bound (cdr cand-vals) (cdr cand-oper-types)))
	;; if the old val is a 'goal' statement
	((and (consp old-val) (equal (car old-val) 'goal)) 	
	 (update-through-term old-val (cdr cand-vals) (cdr cand-oper-types)))
	;; if the cand is a 'goal' statement
	((and (consp (car cand-vals)) (equal (car (car cand-vals)) 'goal))
	 (update-through-term (car cand-vals) (cdr cand-vals) (cdr cand-oper-types)))
	;; else - it's probably nil - just return old-val
	(t (update-through-term old-val (cdr cand-vals) (cdr cand-oper-types)))))


(defun update-across (cand-across port-num eb-num ebs)
  (do* ((old-across (nth port-num cand-across))
	(domain-num 8 (1- domain-num))
	(opers nil (remove-if-not #'(lambda (x) (equal (car x) (list port-num domain-num))) ; remove everything that does not start with the port number and domain number for the particular eb that you are trying to solve
				  (eb-opers (eval (nth eb-num ebs))))) ; from Embodiments.lisp - ((a b) c d x) line in an embodiment definition.
		; what is the eval doing in (eb-opers (eval (nth eb-num ebs))) ?
		; remove-if-not (found, the first element in 'x' equal to something in the list of port-num domain-num thingies). 
		; where 'x' is given by the return variable of the call to eb-opers (which takes the (eval ebs[eb-num]))
		; but what does (eval) do there? eb-opers in the embodiments data is not something to be evaluated. it's just a list of ((1 1) 0 0 c).
		;
	(new-across nil (cons (cond (opers 
				     (update-across-term 
				      (nth domain-num old-across)
				      (mapcar #'(lambda (x) 
						  (nth (caddr x) 
						       (nth (cadr x) cand-across)))
					      opers)
				      (mapcar #'(lambda (x) (cdddr x)) opers)))
				    (t (nth domain-num old-across)))
			      new-across)))
      ((zerop domain-num) new-across)))
							  

(defun update-across-term (old-val cand-vals cand-oper-types)
  ;; old-val is the old value for that particular term
  ;; cand-vals denotes possible ways the old-val can be updated.
  ;; Note: it is possible that the old value supersedes the new cand's
  ;; here we consider the oper-types as well
  ;; trick here is in managing the cand-oper-types!!!
  (cond ((endp cand-vals) old-val)
	((null (car cand-vals))
	 (update-across-term  old-val (cdr cand-vals) (cdr cand-oper-types)))
	(t
	 (do ((new-val 
	       nil
	       (cons 
		(cond
		 ;; if old-val is a number, this beats all
		 ((numberp (nth i old-val)) (nth i old-val)) 
		 ;; then if cand is number 
		 ((and (numberp (nth i cand))
		       (or (member 'c cand-oper-type :test 'equal)
			   (and (zerop (nth i cand)) 
				(member 't cand-oper-type :test 'equal))))
		  (nth i cand))
		 ((and (numberp (nth i cand))
		       (or (member 't cand-oper-type :test 'equal)
			   (member (car oper-match) cand-oper-type :test 'equal)))
		  'bound)
		 ;; if the old val is a range
		 ((and (consp (nth i old-val)) (numberp (car (nth i old-val))))
		  (nth i old-val))
		 ;; if the cand is a range
		 ((and (consp (nth i cand)) (numberp (car (nth i cand)))
		       (member 'c cand-oper-type :test 'equal))
		  (nth i cand))
		 ((and (consp (nth i cand)) (numberp (car (nth i cand)))
		       (or (member 't cand-oper-type :test 'equal)
			   (member (car oper-match) cand-oper-type :test 'equal)))
		  'bound)
		 ;; if the old val is 'bound'
		 ((equal (nth i old-val) 'bound) (nth i old-val)) 
		 ;; if the cand is 'bound'
		 ((and (equal (nth i cand) 'bound)
		       (or (member 'c cand-oper-type :test 'equal)
			   (member 't cand-oper-type :test 'equal)
			   (member (car oper-match) cand-oper-type :test 'equal)))
		  'bound)
		 ;; if the old val is a 'goal' statement
		 ((and (consp (nth i old-val)) (equal (car (nth i old-val)) 'goal))
		  (nth i old-val))
		 ;; if the cand is a 'goal' statement
		 ((and (consp (nth i cand)) (equal (car (nth i cand)) 'goal)
		       (member 'c cand-oper-type :test 'equal))
		  (nth i cand))
		 ((and (consp (nth i cand)) (equal (car (nth i cand)) 'goal)
		       (or (member 't cand-oper-type :test 'equal)
			   (member (car oper-match) cand-oper-type :test 'equal)))
		  '(goal bound))
		 ;; else - it's probably nil - just return (nth i old-val)
		 (t (nth i old-val)))
		new-val))
	      (cand (car cand-vals)) ;; for simplicity in the above code and for speed,
					;define cand as the first cand in this step of 
					;the recursion.
	      (cand-oper-type (car cand-oper-types)) ;likewise for oper-type
	      (oper-match '(i r d) (cdr oper-match))
	      (i 2 (1- i)))
	     ((< i 0) (update-across-term new-val (cdr cand-vals)
					  (cdr cand-oper-types)))))))



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

