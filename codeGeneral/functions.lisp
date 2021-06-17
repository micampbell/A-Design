;;; Function.lisp - contains all the math and index functions used in 
;;; all the other processes in A-design


(defun positions (element set &optional (start 0))
  (let ((num (position element set :start start :test 'equal)))
    (cond (num (cons num (positions element set (1+ num))))
	  (t nil))))


;;Need to define my own subset function
;;because the one in lisp will say that
;;(i i) is a subset of (i).
(defun my-subsetp (s1 s2 &key (test #'equal))
  (cond ((endp s1) t)
	((and (member (car s1) s2 :test test)
	      (my-subsetp 
	       (cdr s1) (remove (car s1) s2 :count 1 :test test))))))


(defun my-intersection (l1 l2 &optional common)
  (cond ((endp l1) common)
        ((member (first l1) l2) 
         (my-intersection (rest l1) (remove (first l1) l2 :count 1) 
		    (cons (first l1) common)))
        (t (my-intersection (rest l1) l2 common))))


;;; This function cons'es elements on end of list instead of front.
(defun backcons (a b)
  (append b (list a)))

(defun remove-pos (i l)
  ;; This function has been written to solve the BUG of Feb. '96 in which
  ;; I couldn't figure out why the agent bookkeeping was getting messed up.
  ;; It simply removes the ith link of l.  No lisp basic funciton seems to 
  ;; do this without prone to error therefore here it is.  "l" can be any
  ;; kind of list.  "i" is the index starting with 0.  If there is less
  ;; elements in l than i then l is returned.
  (cond ((endp l) nil)
	((zerop i) (cdr l))
	(t (cons (car l) (remove-pos (1- i) (cdr l))))))


;;  Changes the j-th element in list to 'change'
;;  Returns the complete modified list l
;;  if 'change' is nil then remove j-th element
(defun mod-list (l j change)
  (cond ((endp l) nil)
	((zerop j) (cons change (cdr l)))
	(t (cons (car l) (mod-list (cdr l) (1- j) change)))))


;;; Cycle1+ is a function similar to 1+ but will cycle back to zero at the
;;; limit.  x is always less-than limit, not less-than-or-equal-to.
(defun cycle1+ (&optional num limit)
  (cond ((= 1 limit) 0) 
	((null num) 1)
	((and (numberp limit) (= (1+ num) limit)) 0) 
	(t (1+ num))))
	

;;; Recursive-count 
;;; This function is based on count, but counts on all levels
;;; of the list.  For lists of lists of lists of ...
(defun r-count (item sequence &key (test 'equal))
  (apply '+ (mapcar #'(lambda (x) (cond ((consp x) (r-count item x :test test))
					((funcall test item x) 1)
					(t 0)))
		    sequence)))


(defun r-member (a l)
  (cond 
   ((member a l))
   ((or-list (mapcar #'(lambda (x) (cond ((consp x) (r-member a x)))) l)))))

;;; Dx-Point-to-Point
;;; These work for n-dimensional space.
;;; A point is an n-dim vector with the coords. of the point.
;;; A line is ??? 
;;; And a plane is an n+1-dim vector with the [a b c d ...] 
;;;  as in ax + by + cz + d = 0
(defun dx-point-to-point (p1 p2)
  (sqrt (norm (mapcar '- p1 p2))))

;;; Dx-Point-to-Plane
;;; Note: this value can be negative, if the point lies below the plane (in
;;; other words, in the opposite direction of the plane's normal vector, n1)
(defun dx-point-to-plane (p1 n1)
  (- (apply '+ (mapcar #'* p1 n1)) (car (last n1))))

;;; Plane-Descriptor-from-Pts
;;; What the hell is this? (and previous function) Do they really work?
;;;
;;; 3/16/98 -- Yes. The output of init-terms is in the form 
;;; ax + by + cz + d = 0, however this differs slightly from geometric form 
;;; pn=d where n is the unit vector pointing away (instead of being arbitrary
;;; as in init-terms) from origin and d is the distance to the origin. The 
;;; rest of this function puts in that form and returns a vector 
;;; [n1 n2 n3 n4 ... d].
(defun plane-descriptor-from-pts (points)
  (let* ((init-terms (determinant-terms 
		      (cons (make-list (1+ (length points)) :initial-element 1)
			    (mapcar #'(lambda (x) (backcons 1 x)) points))))
	 (magnitude (sqrt (norm (butlast init-terms)))))
    (cond ((zerop magnitude) nil)
	  ((< (car (last init-terms)) 0)
	   (backcons (- (/ (car (last init-terms)) magnitude))
		     (mapcar #'(lambda (x) (/ x magnitude))
			     (butlast init-terms))))
	  (t
	   (backcons (/ (car (last init-terms)) magnitude)
		     (mapcar #'(lambda (x) (- (/ x magnitude))) 
			     (butlast init-terms)))))))
				     
;;; Solve-linear-system
;;; returns x in the formula Ax = b
;;; uses Cramer's Rule and therefore not efficient on matrices larger than
;;; 5x5. If A is non-singular the result is nil
;;; Warning if A in not square, this will make it that way be ignoring the
;;; extra columns. It will solve under-specified systems (DOF>0 ; more
;;; columns than rows) but not over-specified systems (more rows than columns)
(defun solve-linear-system (A b &optional (det-A nil))
  (do* ((i (length A) (1- i))
	(b-in-A nil (mapcar #'(lambda (x y)
				(append (butlast x (- (length x) i))
					(cons y (nthcdr (1+ i) x)))) A b))
	(det-b-in-A nil (determinant b-in-A))
	(solution nil (cons (/ det-b-in-A det-A) solution))
	(det-A (cond (det-A) (t (determinant A)))))
      ((or (zerop i) (zerop det-A))
       (cond ((zerop det-A) nil)
	     (t solution)))))

;;; Determinant
;;; Find the determinant of the matrix A. Recursively calls determinant-terms
;;; sub-routine. Ends when sub-matrix A is 1x1 at which point it just returns
;;; A.
(defun determinant (A)
  (cond ((cdr A) (apply '+ (determinant-terms A)))
	(t (caar A))))

;;; Determinant-terms
;;; Find the determinant values for the submatrix in A. Called recursively with
;;; Determinant. Somehow it is used to find the description of a plane. Can't
;;; recall how this works.
(defun determinant-terms (A)
  (do* ((i (length A) (1- i))
	(sgn nil (cond ((evenp i) 1) (t -1)))
 	(pivot nil (nth i (car A)))
	(return-list
	 nil (cons (* (* sgn pivot) (determinant 
				     (mapcar #'(lambda (x) (remove-pos i x))
					     (cdr A))))
		   return-list)))
      ((zerop i) return-list)))
  

(defun matrix-multiply (a b)
  (direct-multiply a (transpose b)))

(defun direct-multiply (a b)
  (cond ((endp a) nil)
	(t 
	 (cons (cond ((and-list (mapcar #'consp b))
		      (mapcar 	
		       #'(lambda (bj)
			   (let ((elts (mapcar #'(lambda (aij bij) 
						   (element-multiply aij bij))
					       (car a) bj)))
			     (cond ((and-list (mapcar #'numberp elts))
				    (apply '+ elts))
				   (t (cons '+ elts)))))
		       b))
		     (t (let ((elts (mapcar #'(lambda (ai bj) 
						(element-multiply ai bj))
					    (car a) b)))
			  (cond ((and-list (mapcar #'numberp elts))
				 (apply '+ elts))
				(t (cons '+ elts))))))
	       (direct-multiply (cdr a) b)))))
(defun element-multiply (aij bij)
  (cond ((or (null aij) (null bij) (and (numberp aij) (zerop aij))
	     (and (numberp bij) (zerop bij))) 0)
	((and (numberp aij) (numberp bij)) (* aij bij))
	((and (numberp aij) (= 1 aij) bij))
	((and (numberp bij) (= 1 bij) aij))
	(t (list '* aij bij))))
(defun transpose (a)
  (cond ((and-list (mapcar #'consp a))
	 (do* ((i (length (car a)) (1- i))
	       (ta nil (cons (mapcar #'(lambda (x) (nth i x)) a) ta)))
	     ((zerop i) ta)))
	(t a)))
;;;inverse of the matrix

;;;(defun inverse (a)
;;;  matrix-multiply(a )
;;;
(defun randomize-list (set)
  (cond ((endp set) nil)
	(t 
	 (let ((i (random (length set))))
	   (cons (nth i set) (randomize-list (remove-pos i set)))))))


;; Returns lists of just evaluations from a list of designs
(defun return-evals (designs)
  (cond ((endp designs) nil)
	((endp (cdr designs))
	 (mapcar 'list (sc-evaluations (eval (car designs)))))
	(t
	 (mapcar 'cons (sc-evaluations (eval (car designs)))
		 (return-evals (cdr designs))))))


(defun average (l)
  (cond ((null l) nil)
	((consp (car l)) (mapcar #'(lambda (x) (average x)) l))
	(t (/ (apply '+ l) (length l)))))


(defun standard-deviation (l)
  (cond ((null l) nil)
	((consp (car l)) (mapcar #'(lambda (x) (standard-deviation x)) l))
	(t (let ((avg (average l)))
	     (sqrt (/ (norm (mapcar #'(lambda (x) (- x avg)) l)) 
		      (length l)))))))

(defun norm (l)
    (apply '+ (mapcar '* l l)))


;;; The following functions operate the same as they're counterparts, but on
;;; a single list instead.
(defun list-min (l)
  (cond ((null l) nil)
	((consp (car l)) (mapcar #'(lambda (x) (list-min x)) l))
	(t (apply 'min l))))
(defun list-max (l)
  (cond ((null l) nil)
	((consp (car l)) (mapcar #'(lambda (x) (list-max x)) l))
	(t (apply 'max l))))
(defun list-union (l)
  (cond ((endp (cdr l)) (car l))
	(t (list-union (cons (union (car l) (cadr l)) (cddr l))))))
(defun and-list (l)
  (cond ((endp l) t)
	((car l) (and-list (cdr l)))
	(t nil)))
(defun or-list (l)
  (cond ((endp l) nil)
	((car l) t) 
	(t (or-list (cdr l)))))


(defun return-state-vars (fp)
  (apply
   #'append 
   (mapcar #'(lambda (x y) (cons x (cond ((null y) (make-list 3)) (t y))))
	   (cond ((null (fp-through fp)) (make-list (length (fp-domain fp))))
		 (t (fp-through fp)))
	   (cond ((null (fp-across fp)) (make-list (length (fp-domain fp))))
		 (t (fp-across fp))))))


;;; The following functions define predicates.  Those that start with match-
;;; accept wildcards and return t if characters are the same or have wildcards.
;;; Predicates that start with same- are only t when characters match 
;;; completely, nil when wildcards.
(defun same-fp (fp1 fp2)
  (and fp1 fp2 
       (equal (fp-across fp1) (fp-across fp2))       
       (equal (fp-class fp1) (fp-class fp2))
       (equal (fp-domain fp1) (fp-domain fp2))
       (equal (fp-inter fp1) (fp-inter fp2))
       (equal (fp-direct fp1) (fp-direct fp2))
       (equal (fp-index fp1) (fp-index fp2))))


(defun match-fp-fp (f1 f2)
  (and f1 f2
       (or (not (fp-class f1))
	   (not (fp-class f2))
	   (equal (fp-class f1) (fp-class f2)))
       (or (not (fp-domain f1)) 
	   (not (fp-domain f2))
	   (equal (fp-domain f1) (fp-domain f2)))
       (or (not (fp-coord f1)) 
	   (not (fp-coord f2))
	   (equal (fp-coord f1) (fp-coord f2))
	   t)
       (match-interface (fp-inter f1) (fp-inter f2))
       (or (not (fp-direct f1)) 
	   (not (fp-direct f2))
	   (not (equal (fp-direct f1) (fp-direct f2))))))


(defun opposite-direction (fp1 fp2)
  (or (not (fp-direct fp1)) 
      (not (fp-direct fp2))
      (not (equal (fp-direct fp1) (fp-direct fp2)))))


;; The new fp-connects-to!
;; to be used in conjunction with port-connects-to as it only return a list
;; of ports (eb-num port-num).
(defun fp-connects-to (at from fps)
  ;; Inputs: at - is the fp one is currently "at"
  ;;         from - is a list of fps one is coming "from" or doesn't want 
  ;;                to connect to
  ;;         fps is the list of all fps
  ;; Outputs: list ports on the other FP's - therefore need to use in 
  ;;          conjunction with port-connects-to e.g. 
  ;;          (mapcar #'port-connects-to (fp-connects-to at from fps))
  (remove-if-not
   #'(lambda (x) (and (consp x) (member (car x) (remove-if 
						 #'symbolp (fp-index at)) 
					:key #'car)))
   (set-difference
    (apply #'append (mapcar #'fp-index fps))
    (apply #'append (mapcar #'fp-index (cons at from))))))
  		  
	     
(defun eb-connects-to (eb fps)
  ;; Inputs: eb, either a list where the first element is the embodiment and
  ;;         the second is a number of the port one is coming from
  ;;         (e.g. (3 0) is a possible eb) or the eb number itself w/o
  ;;         port number (e.g. (3)).  eb = ground or goal will return nil.
  ;;         fps are the FP's in the design
  ;; Outputs: list of FP's that eb connects to except where it connects to
  ;;          the port one is coming from.
  (remove-if-not 
   #'(lambda (x) 
       (and (not (member eb (fp-index x) :test 'equal))
	    (member (car eb) 
		    (mapcar #'(lambda (xx) (and (listp xx) (car xx))) 
			    (fp-index x))
		    :test 'equal)))
   fps))
 

(defun port-connects-to (port fps)
  ;; Inputs: port is a eb paired with a port no. (e.g. (3 0)).
  ;;         fps are the fps to be searched
  ;; Output: the fp that connects to port.
  (find-if #'(lambda (x) (member port (fp-index x) :test 'equal)) fps))


(defun design-is-complete (graph)
  (and (design-goals-are-met graph)
       (design-is-connected graph)))

(defun design-goals-are-met (graph)
  (cond ((endp graph) t)
	((r-member 'goal (return-state-vars (car graph)))
	 nil)
	(t (design-goals-are-met (cdr graph)))))

;;; this tests to see if a design is connected.  First it creates a list 
;;; of inputs and outputs and checks to see that the first connects to the
;;; second, the second connects to the third, etc.  If all connect then t.
(defun design-is-connected (fps)
  (do ((fp-index-list 
	(mapcar #'(lambda (x) (remove-if #'symbolp (fp-index x))) fps)
	(remove-if
	 #'(lambda (x)
	     (or-list 
	      (mapcar 
	       #'(lambda (y) (member y x :key #'car)) connect-ebs)))
	 fp-index-list))
       (connect-ebs
	(mapcar #'(lambda (xx) (and (consp xx) (numberp xx)))
		(fp-index
		 (find-if #'(lambda (x) (r-member 'goal (fp-index x))) fps)))
	(remove nil
		(apply #'append
		       (mapcar 
			#'(lambda (x) 
			    (apply #'append 
				   (mapcar 
				    #'(lambda (y) (and (member y x :key #'car)
						       (mapcar #'car x)))
				    connect-ebs)))
		fp-index-list)))))
      ((or (null connect-ebs) (null fp-index-list))
       (cond ((null fp-index-list) t) (t nil)))))


