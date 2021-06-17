;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Trend Finding Funcitons (TREND.LISP)
;;; In order to process the designs, m-agents must utilize a variety of
;;; extra functions. This file includes the functions necessary to execute
;;; the most difficult manager routine, FIND-TREND.
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; Each trend agent is looking at the head-managers values for :
;; 1) pareto-change (progress)
;; 2) user-satisfaction
;; 3) iteration
;; 4) approx. of user preferences (*M-weights-M*)
(defun t-agent-group-c-agents (designs)
  (let ((x (cond ((> 5 (/ (length designs) 2))
		  (/ (length designs) 2)) (t 5))))
    (find-trend
     designs (car *M-weights-M*) 
     (list (list x 3) (list (- (length designs) x x) 0) (list x 3))
     'sc-c-agents)))

(defun t-agent-group-i-agents (designs)
  (let ((x (cond ((> 5 (/ (length designs) 2))
		  (/ (length designs) 2)) (t 5))))
   (find-trend 
   designs (car *M-weights-M*) 
   (list (list x 3) (list (- (length designs) x x) 0) (list x 3))
   'sc-i-agents)))


(defun t-agent-group-f-agents (designs)
  (let ((x (cond ((> 5 (/ (length designs) 2))
		  (/ (length designs) 2)) (t 5))))
   (find-trend 
   designs (car *M-weights-M*) 
   (list (list x 3) (list (- (length designs) x x) 0) (list x 3))
   'sc-f-agents)))


(defun t-agent-group-components (designs)
  (let ((x (cond ((> 5 (/ (length designs) 2))
		  (/ (length designs) 2)) (t 5))))
   (find-trend 
   designs (car *M-weights-M*) 
   (list (list x 3) (list (- (length designs) x x) 0) (list x 3))
   'sc-components)))


(defun t-agent-group-embodiments (designs)
  (let ((x (cond ((> 5 (/ (length designs) 2))
		  (/ (length designs) 2)) (t 5))))
   (find-trend 
   designs (car *M-weights-M*) 
   (list (list x 3) (list (- (length designs) x x) 0) (list x 3))
   'sc-embodiments)))


(defun t-agent-graph-embodiments (designs)
  (let ((x (cond ((> 5 (/ (length designs) 2))
		  (/ (length designs) 2)) (t 5))))
   (find-trend 
   designs (car *M-weights-M*) 
   (list (list x 3) (list (- (length designs) x x) 0) (list x 3))
   'sc-eb-graph)))


(defun find-trend (designs criteria division set-name)
  ;; FIND_TREND
  ;; INPUTS:
  ;;   designs - a list of designs
  ;;   criteria - is the same form as *weights* but can be used in any form
  ;;         for example if you only want to consider cost then pass '(1 0 0)
  ;;   division - a duple-list of sets of numbers adding up to the total number
  ;;             of designs and the number of subsets to find at that division
  ;;         if a number is 0 then just discard this many designs as 
  ;;         their comparison is inconsequential to the manager's judgement
  ;;   set-name - this can be (sc-eb-graph, sc-embodiments, sc-components,
  ;;              sc-c-agents, sc-i-agents, sc-f-agents)
  ;; OUTPUTS:
  ;;   a list equal to the length of division with either sub-lists of 
  ;;   subsysterms or a nil for cases where the trend is uninteresting
  (do* ((compare-list nil (butlast sorted-designs (- (length sorted-designs)
						      (caar division))))
	(sorted-designs (sort-designs designs criteria)
			(nthcdr (caar division) sorted-designs))
	(subsystems nil (cons 
			 (cond ((equal set-name 'sc-eb-graph)
				(find-subsystems compare-list
						 (cadar division)))
			       (t (find-sets compare-list (cadar division) 
					     set-name)))
			 subsystems))
	(division division (cdr division)))
      ((or (endp sorted-designs) (endp division)) subsystems)))


(defun find-sets (designs num-ss-to-find set-name &optional ss level)
  ;; Outputs - an association list of a subsystem and the number of designs it
  ;;           occurs within
  ;;        ss == subsystems (actually an assoc list)
  (cond ((null level) (find-sets designs num-ss-to-find set-name ss 
				 (length designs)))
	((or (>= (length ss) num-ss-to-find) (= 1 level)) ss)
	(t (find-sets
	    designs num-ss-to-find set-name
	    (do ((design-sets (choose-designs designs level) (cdr design-sets))
		 (new-ss nil (reduce #'my-intersection 
				       (mapcar #'(lambda (x) 
						   (funcall set-name x))
					       (car design-sets))))
		 (ss ss (cond ((and new-ss (not (member new-ss ss :key 'car)))
			       (cons (cons new-ss level) ss))
			      (t ss))))
		((endp design-sets) ss))
	    (1- level)))))

  	


(defun find-subsystems (designs num-ss-to-find &optional ss level)
  ;; Outputs - an association list of a subsystem and the number of designs it
  ;;           occurs within
  ;;        ss == subsystems (actually an assoc list)
  (cond ((null level) (find-subsystems designs num-ss-to-find ss 
				       (length designs)))
	((or (>= (length ss) num-ss-to-find) (= 1 level)) ss)
	(t (find-subsystems 
	    designs num-ss-to-find 
	    (do ((design-sets (choose-designs designs level) (cdr design-sets))
		 (ss ss (intersect-set-of-designs (car design-sets) ss level)))
		((endp design-sets) ss))
	    (1- level)))))


(defun choose-designs (design-list level)
  (let ((element (car design-list)))
    (cond ((> level (length design-list)) nil)
	  ((= (length design-list) level) (list design-list))
	  ((= 1 level) (mapcar #'(lambda (x) (list x))
			       design-list))
	  (t (append (mapcar #'(lambda (x) (cons element x))
			     (choose-designs (cdr design-list) (1- level)))
	     (choose-designs (cdr design-list) level))))))


(defun intersect-set-of-designs (designs ss level)
  (do* ((common-ebs (reduce #'my-intersection 
			    (mapcar #'sc-embodiments designs)))
	(cand-ss (mapcar #'(lambda (x) (put-ss-in-canonical-form x common-ebs))
			 (find-subgraphs (car designs) common-ebs))
		 (remove-if #'(lambda (x) (member x ss 
						  :key 'car :test 'subgraphp))
			    (intersect-design-with-graph 
			     (car designs) cand-ss)))
       (designs (cdr designs) (cdr designs)))
      ((or (endp designs) (null cand-ss))
       (append (mapcar #'(lambda (x) (cons x level)) cand-ss) ss))))


(defun intersect-design-with-graph (design graph)
  (do* ((g1 graph (cond ((endp g2) (cdr g1)) (t g1)))
	(g2 (find-subgraphs design (cadar g1))
	    (cond ((endp g2) (find-subgraphs design (cadar g1)))
		  (t (cdr g2))))
	(cand-intersect nil 
			(put-ss-in-canonical-form
			 (intersection (caar g1) (car g2) :test 'same-arc)
			 (cadar g1)))
	(intersections 
	 nil (cond ((and (car cand-intersect)
			 (not (member cand-intersect intersections
				      :test #'subgraphp)))
		    (cons cand-intersect
			  (remove-if #'(lambda (x) 
					 (subgraphp x cand-intersect))
				     intersections)))
		   (t intersections))))
      ((endp g1) intersections)))
       

(defun find-subgraphs (design common-ebs)
  (do* ((subgraph nil (remove-if #'(lambda (x) (<= (length x) 1)) 
				 (find-subgraph-helper (sc-graph design) 
						       (car eb-num-combos))))
	(subgraphs nil (cond ((and subgraph (subgraph-is-connected subgraph))
			      (cons subgraph subgraphs))
			     (t subgraphs)))
	(eb-num-combos (enumerate-combinations 
			(mapcar 
			 #'(lambda (x) (positions x (sc-embodiments design)))
			 common-ebs))
		       (cdr eb-num-combos)))
      ((endp eb-num-combos) subgraphs)))


(defun find-subgraph-helper (fps eb-nums)
  (mapcar #'(lambda (x) 
	      (do* ((test nil (cond ((and (consp (car index))
					  (member (caar index) new-eb-nums))
				     (caar index))
				    (t nil)))
		    (new-index nil (cond (test (cons (list 
						      (position test eb-nums)
						      (cadar index))
						     new-index))
					 (t new-index)))
		    (new-eb-nums eb-nums (remove test new-eb-nums))
		    (index (fp-index x) (cdr index)))
		  ((endp index) new-index)))
	  fps))


(defun subgraph-is-connected (arcs)
  (dolist (elm arcs t)
	   (let* ((search-list (remove elm arcs))
		 (connects (mapcar 'car (apply 'append search-list))))
	     (unless (or-list (mapcar #'(lambda (x) (member x connects)) 
			    (mapcar 'car elm)))
		 (return nil)))))


(defun enumerate-combinations (set)
  (cond ((null set) nil)
	((= (length set) 1) (mapcar 'list (car set)))
	(t 
	 (do ((new-combos nil 
			  (append (mapcar #'(lambda (x) (cons (car alter) x))
					  combos)
				  new-combos))
	      (combos (enumerate-combinations (cdr set)))
	      (alter (car set) (cdr alter)))
	     ((endp alter) new-combos)))))


(defun put-ss-in-canonical-form (graph common-ebs)
  (let* ((eb-num-list (remove-duplicates (mapcar 'car (apply 'append graph))))
	 (true-common-ebs (mapcar #'(lambda (x) (nth x common-ebs)) 
				  eb-num-list))
	 (true-sorted (sort true-common-ebs #'string-lessp))
	 (new-eb-num-list (remove-duplicates
			   (apply
			    #'append
			    (mapcar #'(lambda (x) (positions x common-ebs)) 
				    true-sorted)))))
    (list (mapcar #'(lambda (x) 
		      (mapcar #'(lambda (xx) (list (position (car xx) 
							     new-eb-num-list)
						   (cadr xx)))
			      x))
		  graph)
	  true-sorted)))


(defun same-arc (x y)
  (and (subsetp x y :test 'equal) (subsetp y x :test 'equal)))


(defun subgraphp (ss1 ss2)
  ;; Tests to see is ss1 is a subgraph of ss2
  (and (my-subsetp (cadr ss1) (cadr ss2))
       (do ((subgraph nil 
		      (mapcar 
		       #'(lambda (x) 
			   (mapcar #'(lambda (xx) 
				        (list (nth (car xx) (car eb-num-sets))
					      (cadr xx)))
				   x))
		       (car ss2)))
	    (eb-num-sets (enumerate-combinations 
			  (mapcar #'(lambda (x) (cond 
						 ((positions x (cadr ss1)))
						 (t (list nil))))
				  (cadr ss2)))
			 (cdr eb-num-sets)))
	   ((my-subsetp (car ss1) subgraph :test 'same-arc) t)
	 (cond ((endp eb-num-sets) (return nil))))))
 
