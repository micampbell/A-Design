(setf rack0 (make-eb 
	     :DATA '(pitch)
	     :MG-CHANGE
	     '(((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
	       ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
	       ((2) (lambda (v) v)) ((3) (lambda (x) x)))
	     :PO-CHANGE '(PO-CHANGE PO-CHANGE PO-CHANGE PO-CHANGE)
	     :CONSTRAINTS '(0 0)))
(setf gear1 (make-eb 
	     :DATA '(teeth radius)
	     :MG-CHANGE
	     ' (((4) (lambda (m) (cond (m (list '/ m 'radius)))))
		((5) (lambda (a) (cond (a (list '* a 'radius))))) 
		((6) (lambda (w) (cond (w (list '* w 'radius)))))
		((7) (lambda (h) (cond (h (list '* h 'radius)))))
		((0) (lambda (f) (cond (f (list '* f 'radius)))))
		((1) (lambda (a) (cond (a (list '/ a 'radius)))))
		((2) (lambda (v) (cond (v (list '/ v 'radius))))) 
		((3) (lambda (x) (cond (x (list '/ x 'radius))))))
	       :PO-CHANGE  '(90.0 0.0 0.0 radius)
	       :CONSTRAINTS '(0 0)))
(setf damper-trans2 (make-eb 
	     :DATA '(d-inner d-outer b)
	     :MG-CHANGE
	     '(((2 4 6) (lambda (v1 f v2) 		;inner shaft forcee
			  (cond (f) ((and v1 v2) (list '* 'b (list '- v1 v2))))))
	       nil
	       ((0 6) (lambda (f v2)                ;inner shaft speed
			(cond ((and f v2) (list '+ v2 (list '/ f 'b))))))
	       nil
	       ((2 0 6) (lambda (v1 f v2) 		;outer shaft force
			  (cond (f) ((and v1 v2) (list '* 'b (list '- v2 v1)))))) 
	       nil
	       ((2 4) (lambda (v1 f)                ;outer shaft speed
			(cond ((and v1 f) (list '+ v1 (list '/ f 'b))))))
	       nil)
	     :PO-CHANGE '(90.0 0.0 0.0 0.0)
	     :CONSTRAINTS '(0 0)))
(setf shaft3 (make-eb
	     :DATA '(diameter)
	     :MG-CHANGE
	     '(((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
	       ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
	       ((2) (lambda (v) v)) ((3) (lambda (x) x)))
	     :PO-CHANGE '(PO-CHANGE PO-CHANGE PO-CHANGE PO-CHANGE)
	     :CONSTRAINTS '(0 0)))
(setf spring4 (make-eb 
	     :DATA '(k angle length)
	     :MG-CHANGE
	     '(((3 4 7) (lambda (x1 f x2)                       ;force1
			  (cond (f) ((and x1 x2) (list '* 'k (list '- x1 x2))))))
	       nil nil
	       ((0 7) (lambda (f x2)                            ;displacement1
			(cond ((and f x2) (list '+ x2 (list '/ f 'k))))))
	       ((3 0 7) (lambda (x1 f x2)                       ;force2
	     (cond (f) ((and x1 x2) (list '* 'k (list '- x2 x1))))))
	       nil nil
	       ((3 4) (lambda (x1 f)                            ;displacement2
			(cond ((and x1 f) (list '+ x1 (list '/ f 'k)))))))
	     :PO-CHANGE '(angle length 0.0 0.0)
	     :CONSTRAINTS '(0 0))) 
(setf spring5 (make-eb 
	     :DATA '(k angle length)
	     :MG-CHANGE
	     '(((3 4 7) (lambda (x1 f x2)                       ;force1
			  (cond (f) ((and x1 x2) (list '* 'k (list '- x1 x2))))))
	       nil nil
	       ((0 7) (lambda (f x2)                            ;displacement1
			(cond ((and f x2) (list '+ x2 (list '/ f 'k))))))
	       ((3 0 7) (lambda (x1 f x2)                       ;force2
			  (cond (f) ((and x1 x2) (list '* 'k (list '- x2 x1))))))
	       nil nil
	       ((3 4) (lambda (x1 f)                            ;displacement2
			(cond ((and x1 f) (list '+ x1 (list '/ f 'k)))))))
	     :PO-CHANGE '(angle length 0.0 0.0)
	     :CONSTRAINTS '(0 0))) 
(setf spring6 (make-eb 
	     :DATA '(k angle length)
	     :MG-CHANGE
	     '(((3 4 7) (lambda (x1 f x2)                       ;force1
			  (cond (f) ((and x1 x2) (list '* 'k (list '- x1 x2))))))
	       nil nil
	       ((0 7) (lambda (f x2)                            ;displacement1
			(cond ((and f x2) (list '+ x2 (list '/ f 'k))))))
	       ((3 0 7) (lambda (x1 f x2)                       ;force2
			  (cond (f) ((and x1 x2) (list '* 'k (list '- x2 x1))))))
	       nil nil
	       ((3 4) (lambda (x1 f)                            ;displacement2
			(cond ((and x1 f) (list '+ x1 (list '/ f 'k)))))))
	     :PO-CHANGE '(angle length 0.0 0.0)
	     :CONSTRAINTS '(0 0))) 


(setf 
 specs 
 (build-fps 
  '((NIL 0 0 0 POWER ROTAT NIL NIL SHAFT SINK ((4 0) (2 0) 
					       GROUND))
    ((0 200.0) bound  bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
     ((0 0) GOAL))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
	   ((0 1) (1 0) (4 1) (2 1)))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((1 1) (3 0))) 
    (bound bound bound (goal-met (0 100)) POWER TRANS (0 -1 0) (0 0 0) 
	   CABLE SOURCE
	   ((3 1) goal)))))
;;
;; Answer :
;;
;; (((0 100) 
;;   (* (/ RADIUS1) 
;;      (+ (* (/ K4) (+ (0 200.0) (* (- B2) 0))) 0)))) 
;; collapses to:
;; (((0 100) 
;;   (* (/ RADIUS1) 
;;      (* (/ K4) (0 200.0))))) 

(setf 
 specs2 
 (build-fps 
  '((NIL 0 0 0 POWER ROTAT NIL NIL SHAFT SINK ((4 0) (2 0) 
					       GROUND))
    ((0 200.0) bound  bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
     ((0 0) GOAL))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
	   ((0 1) (1 0)))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((1 1) (3 0))) 
    (bound bound bound (goal-met (0 100)) POWER TRANS (0 -1 0) (0 0 0) 
	   CABLE SOURCE
	   ((3 1) (4 1) (2 1) goal)))))
;;
;; Answer :
;;
;;(((0 100) 
;;  (+ (* (/ K4) 
;;        (+ (* RADIUS1 (0 200.0)) (* (- B2) 0)))
;;     0))) 
;;
;; collapses to:
;;(((0 100) 
;;  (* (/ K4) 
;;     (* RADIUS1 (0 200.0))))) 


(setf 
 specs3
 (build-fps 
  '((NIL 0 0 0 POWER ROTAT NIL NIL SHAFT SINK 
	 ((5 0) (4 0) (2 0) GROUND))
    ((0 200.0) bound  bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
     ((0 0) (5 1) goal))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
	   ((0 1) (1 0)))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((1 1) (3 0))) 
    (bound bound bound (goal-met (0 100)) POWER TRANS (0 -1 0) (0 0 0) 
	   CABLE SOURCE
	   ((3 1) (4 1) (2 1) goal)))))
;;
;; Answer :
;;
;;(((0 100)
;;  (/ (+ (/ (* (/ RADIUS1) (+ (* (/ K5) (0 200.0)) 0)))
;;        (/ (+ (* (/ K4) (+ (* RADIUS1 (0 200.0)) (* (- B2) 0))) 0)))))) 
;;
;; collapses to:
;;(((0 100)
;;  (/ (+ (/ (* (/ RADIUS1) (* (/ K5) (0 200.0))))
;;        (/ (* (/ K4) (* RADIUS1 (0 200.0)))))))) 


(setf 
 specs4 
 (build-fps 
  '((NIL 0 0 0 POWER ROTAT NIL NIL SHAFT SINK ((5 0) (2 0) 
					       GROUND))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((4 0) (5 1))) 
    ((0 200.0) bound  bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
     ((0 0) GOAL))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
	   ((0 1) (1 0)))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((1 1) (3 0))) 
    (bound bound bound (goal-met (0 100)) POWER TRANS (0 -1 0) (0 0 0) 
	   CABLE SOURCE
	   ((3 1) (4 1) (2 1) goal)))))
;;
;; Answer :
;;
;; recurses endlessly!!
;;  -- not anymore!
;;(((0 100)
;;  (+ (* (/ K4) (* RADIUS1 (0 200.0)))
;;     (+ (* (/ K5) 
;;	   (* RADIUS1 (0 200.0)))
;;     	0)))) 

(setf 
 specs5
 (build-fps 
  '((NIL 0 0 0 POWER ROTAT NIL NIL SHAFT SINK ((5 0) (6 1) 
					       (2 0) GROUND))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((4 0) (5 1))) 
    ((0 200.0) bound  bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
     ((0 0) GOAL))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
	   ((6 0) (0 1) (1 0)))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((1 1) (3 0))) 
    (bound bound bound (goal-met (0 100)) POWER TRANS (0 -1 0) (0 0 0) 
	   CABLE SOURCE
	   ((3 1) (4 1) (2 1) goal)))))
;;
;; Answer :
;;
;;(((0 100)
;;  (/ (+ (/ (* (/ RADIUS1) (+ 0 (* (/ K6) (0 200.0)))))
;;        (/ (+ (* (/ K4) (* RADIUS1 (0 200.0)))
;;              (+ (* (/ K5) (* RADIUS1 (0 200.0))) 0))))))) 

(setf 
 specs6
 (build-fps 
  '((NIL 0 0 0 POWER ROTAT NIL NIL SHAFT SINK ((5 0) (6 1) 
					       GROUND))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((4 0) (5 1))) 
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((6 0) (2 0))) 
    ((0 200.0) bound  bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
     ((0 0) GOAL))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
	   ((0 1) (1 0)))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((1 1) (3 0))) 
    (bound bound bound (goal-met (0 100)) POWER TRANS (0 -1 0) (0 0 0) 
	   CABLE SOURCE
	   ((3 1) (4 1) (2 1) goal)))))



(setf 
 specs7
 (build-fps 
  '((NIL 0 0 0 POWER ROTAT NIL NIL SHAFT SINK ((5 0) (6 1) 
					       GROUND (2 0)))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((4 0) (5 1))) 
    ((0 200.0) bound  bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
     ((0 0) GOAL))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
	   ((0 1) (1 0)))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((1 1) (3 0))) 
    (bound bound (goal-met (0 100)) bound POWER TRANS (0 -1 0) (0 0 0) 
	   CABLE SOURCE
	   ((3 1) (4 1) (2 1) goal)))))


(setf 
 specs8
 (build-fps 
  '((bound 0 0 0 POWER ROTAT NIL NIL SHAFT SINK ((5 0) GROUND))
    (bound nil nil bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((6 0) (2 0))) 
    ((0 200.0) bound  bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
     ((0 0) (4 0) GOAL))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
	   ((0 1) (1 0) (6 1) (4 1)))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((1 1) (3 0))) 
    (bound bound bound (goal-met (0 100)) POWER TRANS (0 -1 0) (0 0 0) 
	   CABLE SOURCE
	   ((3 1) (5 1) (2 1) goal)))))

(setf 
 specs9
 (build-fps 
  '((NIL 0 0 0 POWER ROTAT NIL NIL SHAFT SINK ((5 0) GROUND))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((6 0) (2 0))) 
    ((0 200.0) bound  bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
     ((0 0) GOAL))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
	   ((0 1) (6 1) (3 0)))
    (bound bound bound (goal-met (0 100)) POWER TRANS (0 -1 0) (0 0 0) 
	   CABLE SOURCE
	   ((5 1) (3 1) (2 1) goal)))))
(setf 
 specs10
 (build-fps 
  '((NIL 0 0 0 POWER ROTAT NIL NIL SHAFT SINK ((5 0) GROUND))
    (bound bound bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE 
	   ((6 0) (2 0))) 
    ((0 200.0) bound  bound bound POWER TRANS (0 -1 0) (0 0 0) CABLE SOURCE
     ((6 1) (3 0) GOAL))
    (bound bound bound (goal-met (0 100)) POWER TRANS (0 -1 0) (0 0 0) 
	   CABLE SOURCE
	   ((5 1) (3 1) (2 1) goal)))))



(defun debugeq (s)
  (print (make-behavioral-equations 
	  s
	  '(rack0 gear1 damper-trans2 shaft3 spring4 spring5 spring6))))

