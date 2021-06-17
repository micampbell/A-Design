;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; F-AGENTS OR FRAGMENT-AGENTS
;;; Agents are called from CREATE-AND-MODIFY-DESIGNS in create.lisp.
;;;
;;; Agent functions - agents are passed a set of designs.
;;; 
;;; It chooses a design to modify and returns the fragmented design along
;;; with the original design. 
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun agent-low1-low1-in-comps (designs)
  (let* ((design (max-or-min-of-designs 0 designs :operator 'min))
	 (i (position-of-max-or-min-comp 0 (sc-components design) 
					 :operator 'max)))
    (list (make-sc :graph (sc-graph design) 
		   :embodiments (sc-embodiments design) 
		   :c-agents (sc-c-agents design)
		   :components (mod-list (sc-components design) i nil)
		   :i-agents (mod-list (sc-i-agents design) i nil))
	  design)))


(defun agent-high1-low1-in-comps (designs)
  (let* ((design (max-or-min-of-designs 0 designs :operator 'max))
	 (i (position-of-max-or-min-comp 0 (sc-components design) 
					 :operator 'max)))
    (list (make-sc :graph (sc-graph design) 
		   :embodiments (sc-embodiments design) 
		   :c-agents (sc-c-agents design)
		   :components (mod-list (sc-components design) i nil)
		   :i-agents (mod-list (sc-i-agents design) i nil))
	  design)))

;(defun agent-low2-low2-in-comps (designs)
;  (let* ((design (max-or-min-of-designs 1 designs :operator 'min))
;	 (i (position-of-max-or-min-comp 1 (sc-components design) 
;					 :operator 'max)))
;    (list (make-sc :graph (sc-graph design) 
;		   :embodiments (sc-embodiments design) 
;		   :c-agents (sc-c-agents design)
;		   :components (mod-list (sc-components design) i nil)
;		   :i-agents (mod-list (sc-i-agents design) i nil))
;	  design)))


;(defun agent-high2-low2-in-comps (designs)
;  (let* ((design (max-or-min-of-designs 1 designs :operator 'max))
;	 (i (position-of-max-or-min-comp 1 (sc-components design) 
;					 :operator 'max)))
;    (list (make-sc :graph (sc-graph design) 
;		   :embodiments (sc-embodiments design) 
;		   :c-agents (sc-c-agents design)
;		   :components (mod-list (sc-components design) i nil)
;		   :i-agents (mod-list (sc-i-agents design) i nil))
;	  design)))


;(defun agent-low3-low3-in-comps (designs)
;  (let* ((design (max-or-min-of-designs 2 designs :operator 'min))
;	 (i (position-of-max-or-min-comp 2 (sc-components design) 
;					 :operator 'max)))
;    (list (make-sc :graph (sc-graph design) 
;		   :embodiments (sc-embodiments design) 
;		   :c-agents (sc-c-agents design)
;		   :components (mod-list (sc-components design) i nil)
;		   :i-agents (mod-list (sc-i-agents design) i nil))
;	  design)))

;(defun agent-high3-low3-in-comps (designs)
;  (let* ((design (max-or-min-of-designs 2 designs :operator 'max))
;	 (i (position-of-max-or-min-comp 2 (sc-components design) 
;					 :operator 'max)))
;    (list (make-sc :graph (sc-graph design) 
;		   :embodiments (sc-embodiments design) 
;		   :c-agents (sc-c-agents design)
;		   :components (mod-list (sc-components design) i nil)
;		   :i-agents (mod-list (sc-i-agents design) i nil))
;	  design)))


(defun agent-low1-doubles-in-comps (designs)
  (let ((design (max-or-min-of-designs 
		 0 (remove-if 
		    #'(lambda (x) (equal 
				   (sc-components x) 
				   (remove-duplicates (sc-components x))))
		    designs) :operator 'min)))
    (cond 
     (design 
      (do* ((comp-list (sc-components design) (mod-list comp-list i nil))
	    (i-agent-list (sc-i-agents design) (mod-list i-agent-list i nil))
	    (i (position (apply 'max (mapcar #'(lambda (x) (count x comp-list))
					     comp-list))
			 (mapcar #'(lambda (x) (count x comp-list)) comp-list))
	       (position double-comp comp-list))
	    (double-comp (nth i comp-list)))
	  ((not i) (list (make-sc :graph (sc-graph design) 
				  :embodiments (sc-embodiments design) 
			       :c-agents (sc-c-agents design)
			       :components comp-list
			       :i-agents i-agent-list)
			 design)))))))

(defun agent-high1-doubles-in-comps (designs)
  (let ((design (max-or-min-of-designs 
		 0 (remove-if 
		    #'(lambda (x) (equal 
				   (sc-components x) 
				   (remove-duplicates (sc-components x))))
		    designs) :operator 'max)))
    (cond 
     (design 
      (do* ((comp-list (sc-components design) (mod-list comp-list i nil))
	    (i-agent-list (sc-i-agents design) (mod-list i-agent-list i nil))
	    (i (position (apply 'max (mapcar #'(lambda (x) (count x comp-list))
					     comp-list))
			 (mapcar #'(lambda (x) (count x comp-list)) comp-list))
	       (position double-comp comp-list))
	    (double-comp (nth i comp-list)))
	  ((not i) (list (make-sc :graph (sc-graph design) 
				  :embodiments (sc-embodiments design) 
			       :c-agents (sc-c-agents design)
			       :components comp-list
			       :i-agents i-agent-list)
			 design)))))))

(defun agent-low2-doubles-in-comps (designs)
  (let ((design (max-or-min-of-designs 
		 1 (remove-if 
		    #'(lambda (x) (equal 
				   (sc-components x) 
				   (remove-duplicates (sc-components x))))
		    designs) :operator 'min)))
    (cond 
     (design 
      (do* ((comp-list (sc-components design) (mod-list comp-list i nil))
	    (i-agent-list (sc-i-agents design) (mod-list i-agent-list i nil))
	    (i (position (apply 'max (mapcar #'(lambda (x) (count x comp-list))
					     comp-list))
			 (mapcar #'(lambda (x) (count x comp-list)) comp-list))
	       (position double-comp comp-list))
	    (double-comp (nth i comp-list)))
	  ((not i) (list (make-sc :graph (sc-graph design) 
				  :embodiments (sc-embodiments design) 
			       :c-agents (sc-c-agents design)
			       :components comp-list
			       :i-agents i-agent-list)
		      design)))))))

(defun agent-high2-doubles-in-comps (designs)
  (let ((design (max-or-min-of-designs 
		 1 (remove-if 
		    #'(lambda (x) (equal 
				   (sc-components x) 
				   (remove-duplicates (sc-components x))))
		    designs) :operator 'max)))
    (cond 
     (design 
      (do* ((comp-list (sc-components design) (mod-list comp-list i nil))
	    (i-agent-list (sc-i-agents design) (mod-list i-agent-list i nil))
	    (i (position (apply 'max (mapcar #'(lambda (x) (count x comp-list))
					     comp-list))
			 (mapcar #'(lambda (x) (count x comp-list)) comp-list))
	       (position double-comp comp-list))
	    (double-comp (nth i comp-list)))
	  ((not i) (list (make-sc :graph (sc-graph design) 
				  :embodiments (sc-embodiments design) 
				  :c-agents (sc-c-agents design)
				  :components comp-list
				  :i-agents i-agent-list)
			 design)))))))


(defun agent-low3-doubles-in-comps (designs)
  (let ((design (max-or-min-of-designs 
		 2 (remove-if 
		    #'(lambda (x) (equal 
				   (sc-components x) 
				   (remove-duplicates (sc-components x))))
		    designs) :operator 'min)))
    (cond 
     (design 
      (do* ((comp-list (sc-components design) (mod-list comp-list i nil))
	    (i-agent-list (sc-i-agents design) (mod-list i-agent-list i nil))
	    (i (position (apply 'max (mapcar #'(lambda (x) (count x comp-list))
					     comp-list))
			 (mapcar #'(lambda (x) (count x comp-list)) comp-list))
	       (position double-comp comp-list))
	    (double-comp (nth i comp-list)))
	  ((not i) (list (make-sc :graph (sc-graph design) 
				  :embodiments (sc-embodiments design) 
			       :c-agents (sc-c-agents design)
			       :components comp-list
			       :i-agents i-agent-list)
		      design)))))))

(defun agent-high3-doubles-in-comps (designs)
  (let ((design (max-or-min-of-designs 
		 2 (remove-if 
		    #'(lambda (x) (equal 
				   (sc-components x) 
				   (remove-duplicates (sc-components x))))
		    designs) :operator 'max)))
    (cond 
     (design 
      (do* ((comp-list (sc-components design) (mod-list comp-list i nil))
	    (i-agent-list (sc-i-agents design) (mod-list i-agent-list i nil))
	    (i (position (apply 'max (mapcar #'(lambda (x) (count x comp-list))
					     comp-list))
			 (mapcar #'(lambda (x) (count x comp-list)) comp-list))
	       (position double-comp comp-list))
	    (double-comp (nth i comp-list)))
	  ((not i) (list (make-sc :graph (sc-graph design) 
				  :embodiments (sc-embodiments design) 
				  :c-agents (sc-c-agents design)
				  :components comp-list
				  :i-agents i-agent-list)
			 design)))))))


(defun agent-low1-dangles-in-graph (designs)
  (let* ((design 
	  (max-or-min-of-designs 
	   0 (remove-if-not
	      #'(lambda (x) (member-if #'(lambda (xx) 
					   (= (length (fp-index xx)) 1))
				       (sc-graph x))) 
	      designs) :operator 'min))
	 (ebs-to-remove
	  (cond (design
		  (mapcar #'(lambda (x) (cond ((= (length (fp-index x)) 1)
					       (caar (fp-index x)))))
			  (sc-graph design))))))
    (cond (ebs-to-remove
	   (list (fragment-graph ebs-to-remove design) design)))))


(defun agent-high1-dangles-in-graph (designs)
  (let* ((design (max-or-min-of-designs 
		 0 (remove-if-not
		    #'(lambda (x) (member-if #'(lambda (xx) 
						 (= (length (fp-index xx)) 1))
					     (sc-graph x))) 
		    designs) :operator 'max))
	 (ebs-to-remove
	  (cond (design
		 (mapcar #'(lambda (x) (cond ((= (length (fp-index x)) 1)
					      (caar (fp-index x)))))
			 (sc-graph design))))))
    (cond (ebs-to-remove
	   (list (fragment-graph ebs-to-remove design) design)))))


(defun agent-low2-dangles-in-graph (designs)
  (let* ((design (max-or-min-of-designs 
		 1 (remove-if-not
		    #'(lambda (x) (member-if #'(lambda (xx) 
						 (= (length (fp-index xx)) 1))
					     (sc-graph x))) 
		    designs) :operator 'min))
	 (ebs-to-remove
	  (cond (design
		 (mapcar #'(lambda (x) (cond ((= (length (fp-index x)) 1)
					      (caar (fp-index x)))))
			 (sc-graph design))))))
    (cond (ebs-to-remove
	   (list (fragment-graph ebs-to-remove design) design)))))


(defun agent-high2-dangles-in-graph (designs)
  (let* ((design (max-or-min-of-designs 
		 1 (remove-if-not
		    #'(lambda (x) (member-if #'(lambda (xx) 
						 (= (length (fp-index xx)) 1))
					     (sc-graph x))) 
		    designs) :operator 'max))
	 (ebs-to-remove
	  (cond (design
		 (mapcar #'(lambda (x) (cond ((= (length (fp-index x)) 1)
					      (caar (fp-index x)))))
			 (sc-graph design))))))
    (cond (ebs-to-remove
	   (list (fragment-graph ebs-to-remove design) design)))))


(defun agent-low3-dangles-in-graph (designs)
  (let* ((design (max-or-min-of-designs 
		 2 (remove-if-not
		    #'(lambda (x) (member-if #'(lambda (xx) 
						 (= (length (fp-index xx)) 1))
					     (sc-graph x))) 
		    designs) :operator 'min))
	 (ebs-to-remove
	  (cond (design
		 (mapcar #'(lambda (x) (cond ((= (length (fp-index x)) 1)
					      (caar (fp-index x)))))
			 (sc-graph design))))))
    (cond (ebs-to-remove
	   (list (fragment-graph ebs-to-remove design) design)))))



(defun agent-high3-dangles-in-graph (designs)
  (let* ((design (max-or-min-of-designs 
		 2 (remove-if-not
		    #'(lambda (x) (member-if #'(lambda (xx) 
						 (= (length (fp-index xx)) 1))
					     (sc-graph x))) 
		    designs) :operator 'max))
	 (ebs-to-remove
	  (cond (design
		 (mapcar #'(lambda (x) (cond ((= (length (fp-index x)) 1)
					      (caar (fp-index x)))))
			 (sc-graph design))))))
    (cond (ebs-to-remove
	   (list (fragment-graph ebs-to-remove design) design)))))


(defun agent-low1-low1-in-graph (designs)
  (let* ((design (max-or-min-of-designs 0 designs :operator 'min))
	 (i (position-of-max-or-min-comp 0 (sc-components design) 
					 :operator 'max)))
    (cond (i (list (fragment-graph (list i) design) design)))))


(defun agent-high1-low1-in-graph (designs)
  (let* ((design (max-or-min-of-designs 0 designs :operator 'max))
	 (i (position-of-max-or-min-comp 0 (sc-components design) 
					 :operator 'max)))
    (cond (i (list (fragment-graph (list i) design) design)))))


;(defun agent-low2-low2-in-graph (designs)
;  (let* ((design (max-or-min-of-designs 1 designs :operator 'min))
;	 (i (position-of-max-or-min-comp 1 (sc-components design) 
;					 :operator 'max)))
;    (cond (i (list (fragment-graph (list i) design) design)))))


;(defun agent-high2-low2-in-graph (designs)
;  (let* ((design (max-or-min-of-designs 1 designs :operator 'max))
;	 (i (position-of-max-or-min-comp 1 (sc-components design) 
;					 :operator 'max)))
;    (cond (i (list (fragment-graph (list i) design) design)))))


;(defun agent-low3-low3-in-graph (designs)
;  (let* ((design (max-or-min-of-designs 2 designs :operator 'min))
;	 (i (position-of-max-or-min-comp 2 (sc-components design) 
;					 :operator 'max)))
;    (cond (i (list (fragment-graph (list i) design) design)))))


;(defun agent-high3-low3-in-graph (designs)
;  (let* ((design (max-or-min-of-designs 2 designs :operator 'max))
;	 (i (position-of-max-or-min-comp 2 (sc-components design) 
;					 :operator 'max)))
;    (cond (i (list (fragment-graph (list i) design) design)))))


(defun agent-low1-doubles-in-graph (designs)
  (let ((design (max-or-min-of-designs 
		 0 (remove-if 
		    #'(lambda (x) (= (length (sc-components x))
				     (length (remove-duplicates 
					      (sc-components x)))))
		    designs) :operator 'min)))
    (cond 
     (design
      (do ((double-comp
	    (nth
	     (position 
	      (apply 'max (mapcar #'(lambda (x) (count 
						 x (sc-embodiments design)))
				  (sc-embodiments design)))
	      (mapcar #'(lambda (x) (count x comp-list)) 
		      (sc-embodiments design))) (sc-embodiments design)))
	   (i nil (cond ((equal (nth j (sc-embodiments design)) double-comp) 
			 (adjoin j i))))
	   (j 0 (1+ j)))
	  ((= j (length (sc-embodiments design)))
	   (list (fragment-graph i design) design)))))))


(defun agent-high1-doubles-in-graph (designs)
  (let ((design (max-or-min-of-designs 
		 0 (remove-if 
		    #'(lambda (x) (= (length (sc-components x))
				     (length (remove-duplicates 
					      (sc-components x)))))
		    designs) :operator 'max)))
    (cond 
     (design
      (do ((double-comp
	    (nth
	     (position 
	      (apply 'max (mapcar #'(lambda (x) (count 
						 x (sc-embodiments design)))
				  (sc-embodiments design)))
	      (mapcar #'(lambda (x) (count x comp-list)) 
		      (sc-embodiments design))) (sc-embodiments design)))
	   (i nil (cond ((equal (nth j (sc-embodiments design)) double-comp) 
			 (adjoin j i))))
	   (j 0 (1+ j)))
	  ((= j (length (sc-embodiments design)))
	   (list (fragment-graph i design) design)))))))


(defun agent-low2-doubles-in-graph (designs)
  (let ((design (max-or-min-of-designs 
		 1 (remove-if 
		    #'(lambda (x) (= (length (sc-components x))
				     (length (remove-duplicates 
					      (sc-components x)))))
		    designs) :operator 'min)))
    (cond 
     (design
      (do ((double-comp
	    (nth
     (position 
	      (apply 'max (mapcar #'(lambda (x) (count 
						 x (sc-embodiments design)))
				  (sc-embodiments design)))
	      (mapcar #'(lambda (x) (count x comp-list)) 
		      (sc-embodiments design))) (sc-embodiments design)))
	   (i nil (cond ((equal (nth j (sc-embodiments design)) double-comp) 
			 (adjoin j i))))
	   (j 0 (1+ j)))
	  ((= j (length (sc-embodiments design)))
	   (list (fragment-graph i design) design)))))))


(defun agent-high2-doubles-in-graph (designs)
  (let ((design (max-or-min-of-designs 
		 1 (remove-if 
		    #'(lambda (x) (= (length (sc-components x))
				     (length (remove-duplicates 
					      (sc-components x)))))
		    designs) :operator 'max)))
    (cond 
     (design
      (do ((double-comp
	    (nth
	     (position 
	      (apply 'max (mapcar #'(lambda (x) (count 
						 x (sc-embodiments design)))
				  (sc-embodiments design)))
	      (mapcar #'(lambda (x) (count x comp-list)) 
		      (sc-embodiments design))) (sc-embodiments design)))
	   (i nil (cond ((equal (nth j (sc-embodiments design)) double-comp) 
			 (adjoin j i))))
	   (j 0 (1+ j)))
	  ((= j (length (sc-embodiments design)))
	   (list (fragment-graph i design) design)))))))

(defun agent-low3-doubles-in-graph (designs)
  (let ((design (max-or-min-of-designs 
		 2 (remove-if 
		    #'(lambda (x) (= (length (sc-components x))
				     (length (remove-duplicates 
					      (sc-components x)))))
		    designs) :operator 'min)))
    (cond 
     (design
      (do ((double-comp
	    (nth
     (position 
	      (apply 'max (mapcar #'(lambda (x) (count 
						 x (sc-embodiments design)))
				  (sc-embodiments design)))
	      (mapcar #'(lambda (x) (count x comp-list)) 
		      (sc-embodiments design))) (sc-embodiments design)))
	   (i nil (cond ((equal (nth j (sc-embodiments design)) double-comp) 
			 (adjoin j i))))
	   (j 0 (1+ j)))
	  ((= j (length (sc-embodiments design)))
	   (list (fragment-graph i design) design)))))))


(defun agent-high3-doubles-in-graph (designs)
  (let ((design (max-or-min-of-designs 
		 2 (remove-if 
		    #'(lambda (x) (= (length (sc-components x))
				     (length (remove-duplicates 
					      (sc-components x)))))
		    designs) :operator 'max)))
    (cond 
     (design
      (do ((double-comp
	    (nth
	     (position 
	      (apply 'max (mapcar #'(lambda (x) (count 
						 x (sc-embodiments design)))
				  (sc-embodiments design)))
	      (mapcar #'(lambda (x) (count x comp-list)) 
		      (sc-embodiments design))) (sc-embodiments design)))
	   (i nil (cond ((equal (nth j (sc-embodiments design)) double-comp) 
			 (adjoin j i))))
	   (j 0 (1+ j)))
	  ((= j (length (sc-embodiments design)))
	   (list (fragment-graph i design) design)))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; F-AGENT HELPER FUNCTIONS
;;; THESE FUNCTIONS ARE EXECUTED BY THE F-AGENTS IN THE REMOVING OF
;;; COMPONENTS AND EMBODIMENTS FROM A CHOOSEN DESIGN.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun max-or-min-of-designs (i designs &key operator) 
  (cond (designs
	 (nth 
	  (position (apply operator (mapcar #'(lambda (x) 
						(nth i (sc-evaluations x)))
					    designs))
		    (mapcar #'(lambda (x) (nth i (sc-evaluations x))) designs))
	  designs))
	(t nil)))
(defun position-of-max-or-min-comp (i comps &key operator) 
  (position (apply operator (mapcar #'(lambda (x) (nth i (third x))) comps))
	    (mapcar #'(lambda (x) (nth i (third x))) comps)))
 


(defun fragment-graph (eb-positions design)
  (do* ((eb-list (sc-embodiments design) (remove-pos (car i) eb-list))
	(c-agent-list (sc-c-agents design) (remove-pos (car i) c-agent-list))
	(comp-list (sc-components design) (remove-pos (car i) comp-list))
	(i-agent-list (sc-i-agents design) (remove-pos (car i) i-agent-list))
	(graph (mapcar 'copy-fp (sc-graph design))
	       (remove-eb-from-graph i graph eb-list))
	(i (sort (remove-duplicates (remove nil eb-positions)) '>) (cdr i)))
      ((endp i) (make-sc :graph (do ((fps (reset-fps graph)
					  (update-through-across-direct
					   fps i eb-list))
				     (i 0 (1+ i)))
				    ((= i (length eb-list)) fps))
			 :embodiments eb-list :c-agents c-agent-list 
			 :components comp-list :i-agents i-agent-list))))


(defun remove-eb-from-graph (eb-num graph ebs)
  (cond ((endp graph) nil)
	((and (consp (car (fp-index (car graph))))
	      (= (caar (fp-index (car graph))) (car eb-num))
	      (or (= (length (fp-index (car graph))) 1)
		  (and (= (length (fp-index (car graph))) 2)
		       (equal (cadr (fp-index (car graph))) 'ground))))
	 (remove-eb-from-graph eb-num (cdr graph) ebs))
	(t 
	 (cons
	  (do* ((new-index
		 (remove nil (mapcar 
			      #'(lambda (x) 
				  (cond ((and (consp x) (> (car x) 
							    (car eb-num))) 
					 (cons (1- (car x)) (cdr x)))
					((and (consp x) (= (car x)
							    (car eb-num)))
					 nil)
					(t x)))
			      (fp-index (car graph)))))
		(ports 
		 (remove 
		  nil (mapcar 
		       #'(lambda (x) 
			   (cond 
			    ((consp x)
			     (cp-inter 
			      (nth 
			       (cadr x) 
			       (eb-const-param 
				(eval (nth (car x) ebs))))))
			    ((equal x 'goal)
			     (fp-inter
			      (find-if 
			       #'(lambda (xx) 
				   (and (equal (fp-domain xx)
					       (fp-domain (car graph)))
					(equal (fp-direct xx)
					       (fp-direct (car graph)))))
			       *io-fps*)))
			    (t nil)))
		       new-index))
		 (cons (cond ((cdr ports) (update-interface (car ports)
							    (cadr ports)))
			     (t (car ports))) (cddr ports))))
	      ((endp (cdr ports))
	       (car (modify-fp-in-list (car graph) nil :inter (car ports) 
				       :index new-index))))
	  (remove-eb-from-graph eb-num (cdr graph) ebs)))))


(defun reset-fps (fps)
  (cond ((endp fps) nil)
	((member 'ground (fp-index (car fps)))
	 (modify-fp-in-list (car fps) (reset-fps (cdr fps))
			    :through nil
			    :coord nil))
	 ((member 'goal (fp-index (car fps)))
	  (let ((io-fp (find-if #'(lambda (xx) 
				   (and (equal (fp-domain xx)
					       (fp-domain (car fps)))
					(equal (fp-direct xx)
					       (fp-direct (car fps)))))
			       *io-fps*)))
	    (modify-fp-in-list (car fps) (reset-fps (cdr fps))
			       :through (fp-through io-fp)
			       :across (fp-across io-fp)
			       :coord (fp-coord io-fp))))
	 (t (modify-fp-in-list (car fps) (reset-fps (cdr fps))
			       :through nil
			       :across nil
			       :coord nil
			       :direct nil))))
	
