;;;****************************************************************************   updated  09-09-2001 by Advait Limaye
;;;****************************************************************************
;;;For all gears ports 3 & 4 are -ve and ports 1 & 2 are +ve.

;;; New EMBODIMENTS 
;;; This file contains the embodiments used by A-Design, each of these has a
;;; a corresponding component file (eb.comps).  The format for the eb follows
;;; the structure for eb found in the init.lisp file.
;;;(defstruct eb
;;;  name
;;;  data
;;;  MG-change
;;;  PO-change
;;;  constraints
;;;  )
;;; The following are separate lists (no global parens to bound complete file
;;; where the lists have form:
;;; (NAME
;;;  (DATA1 DATA2 DATA3 ...)
;;;  ((MG-CHANGE-FUNCTION ... ...)   Four for 
;;;   (MG-CHANGE-FUNCTION ... ...)   each port
;;;   ...                            of the
;;;   (MG-CHANGE-FUNCTION ... ...))  device.
;;;  (PO-CHANGE PO-CHANGE PO-CHANGE PO-CHANGE)
;;;  ((THROUGH-RANGE ACROSS-RANGE OPER CLASS DOMAIN INTERFACE DIRECTION)
;;;    ....                 Constraints-Parameters for each of the ports.
;;;   (THROUGH-RANGE ACROSS-RANGE OPER CLASS DOMAIN INTERFACE DIRECTION)).
;;;   
;;;  Much debate over the convention of DIRECTION...from here on out SINK is
;;;  when energy can only come into the port, and SOURCE is when energy can 
;;;  only leave the port.  As opposed to the sink/source FP compatibility.
;;   oper - the operators are now of the form:			        
;;					; a list of one or more operator types
;;					; d, r, i, t, c
;;					; d = differentiator,
;;					; i = integrator, 
;;					; r = dissipator
;;					; t = transformer,
;;					; c = coupler
;;                                      ; c+ coupled in positive direction,but
;;                                      ; anti-coupled in neg.
;;                                      ; c- coupled in negative direction,but
;;                                      ; anti-coupled in pos.
;;                                      ; nil = anti-coupler


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Rotational Bearing
(bearing-rotat
 (d-inner d-outer b)
 (((2 4 6) (lambda (v1 f v2) 			;inner shaft torque
	     (cond (f) ((and v1 v2) (list '* 'b (list '- v1 v2)))))) 	
  nil

  ((0 6) (lambda (f v2)			;inner shaft speed
	   (cond ((and f v2) (list '+ v2 (list '/ f 'b))))))
  nil
  ((2 0 6) (lambda (v1 f v2) 		;outer shaft torque
	     (cond (f) ((and v1 v2) (list '* 'b (list '- v2 v1)))))) 	
  nil
  ((2 4) (lambda (v1 f)                ;outer shaft speed
	   (cond ((and v1 f) (list '+ v1 (list '/ f 'b))))))
  nil)
 ((nil 
   ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) 
   nil))
 nil
 (rotat rotat);domain
 (shaft-hole bolt)
 (nil nil)
 ((((c) (trans 1 0)) ((c) (trans 1 1)) ((c) (trans 1 2))
		     nil ((c) (rotat 1 1)) ((c) (rotat 1 2)))
  (((c) (trans 0 0)) ((c) (trans 0 1)) ((c) (trans 0 2)) 
			    nil ((c) (rotat 0 1)) ((c) (rotat 0 2)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GEAR
(gear
 (dia shaft-dia teeth pitch)
 (((4) (lambda (m) (cond (m (list '/ m (list '/ 'dia 2))))))
  ((5) (lambda (a) (cond (a (list '* a (list '/ 'dia 2)))))) 
  ((6) (lambda (w) (cond (w (list '* w (list '/ 'dia 2))))))
  ((7) (lambda (h) (cond (h (list '* h (list '/ 'dia 2))))))
  ((0) (lambda (f) (cond (f (list '* f (list '/ 'dia 2))))))
  ((1) (lambda (a) (cond (a (list '/ a (list '/ 'dia 2))))))
  ((2) (lambda (v) (cond (v (list '/ v (list '/ 'dia 2)))))) 
  ((3) (lambda (x) (cond (x (list '/ x (list '/ 'dia 2)))))))
 ((nil					;0-0
    ((0 1 0 0)(-1 0 0 0)(0 0 1 (/ dia 2))(0 0 0 1)) ;0-1
    ((0 1 0 0)(0 0 1 (/ dia 2))(1 0 0 0 )(0 0 0 1)) ;0-2
   ((0 -1 0 0)(1 0 0 0)(0 0 1 (- (/ dia 2)))(0 0 0 1)) ;0-3
   ((0 -1 0 0)(0 0 1 (- (/ dia 2))) (-1 0 0 0)(0 0 0 1))) ;0-4
  (((0 -1 0 0)(1 0 0 0)(0 0 1 (- (/ dia 2)))(0 0 0 1)) ;1-0 
    nil					;1-1
   ((0 0 -1 (- (/ dia 2)))(0 1 0 0)(1 0 0 (- (/ dia 2)))(0 0 0 1)) ;1-2
   ((-1 0 0 0)(0 -1 0 0)(0 0 1 (- dia))(0 0 0 1)) ;1-3
   ((0 0 -1 (/ dia 2))(0 -1 0 0)(-1 0 0 (- (/ dia 2)))(0 0 0 1))) ;1-4
  (((0 0 1 0)(1 0 0 0)(0 1 0 (- (/ dia 2)))(0 0 0 1)) ;2-0
   ((0 0 1 (/ dia 2))(0 1 0 0)(-1 0 0 (- (/ dia 2)))(0 0 0 1)) ;2-1
   nil					;2-2
   ((0 0 1 (- ((/ dia 2))))(0 1 0 0)(1 0 0 (- (/ dia 2)))(0 0 0 1)) ;2-3
   ((-1 0 0 0)(0 -1 0 0)(0 0 1 (- dia))(0 0 0 1))) ;2-4
  (((0 1 0 0)(-1 0 0 0)(0 0 1 (/ dia 2))(0 0 0 1)) ;3-0
   ((-1 0 0 0)(0 -1 0 0)(0 0 1 dia)(0 0 0 1)) ;3-1
   ((0 0 1 (/ dia 2))(0 -1 0 0)(1 0 0 (/ dia 2))(0 0 0 1)) ;3-2
   nil					;3-3
   ((0 1 0 (/ dia 2))(0 1 0 0)(-1 0 0 (/ dia 2))(0 0 0 1))) ;3-4
  (((0 0 -1 0)(-1  0 0 0)(0 1 0 (/ dia 2))(0 0 0 1)) ;4-0
   ((0 0 -1 (- (/ dia 2)))(0 -1 0 0)(-1 0 0 (/ dia 2))(0 0 0 1)) ;4-1
   ((-1 0 0 0)(0 -1 0 0)(0 0 1 dia)(0 0 0 1)) ;4-2
   ((0 0 -1 (/ dia 2))(0 1 0 0)(1 0 0 (/ dia 2))(0 0 0 1)) ;4-3
   nil))
 nil					;4-4  
 (rotat trans trans trans trans);domain
 (shaft-hole gear-teeth-pos gear-teeth-pos gear-teeth-neg gear-teeth-neg)
 (nil nil nil nil nil)
 ((nil ;trans x
   (((c+) (trans 2 2)) ((c-) (trans 4 2))) ;trans y
   (((c+) (trans 1 2)) ((c-) (trans 3 2))) ;trans z
   (((t) (trans 1 0) (trans 2 0) (trans 3 0) (trans 4 0)));rot x
   nil ;rot y
   nil);c = coupler					;rot z
  ((((t) (rotat 0 0)) ((c) (trans 2 0) (trans 3 0) (trans 4 0)))
	  nil 
	  (((c+) (trans 0 2)))
	  nil nil nil)
  ((((t) (rotat 0 0)) ((c) (trans 1 0) (trans 3 0) (trans 4 0)))
   nil 
   (((c+) (trans 0 1))) 
   nil nil nil)
  ((((t) (rotat 0 0)) ((c) (trans 1 0) (trans 2 0) (trans 4 0)))
   nil 
   (((c-) (trans 0 2))) 
   nil nil nil)
  ((((t) (rotat 0 0)) ((c) (trans 1 0) (trans 2 0) (trans 3 0)))
   nil 
   (((c-) (trans 0 1))) 
   nil nil nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Translational Bearing
(bearing-trans
 (d-inner d-outer b)
 (((2 4 6) (lambda (v1 f v2) 		;inner shaft force
	     (cond (f) ((and v1 v2) (list '* 'b (list '- v1 v2)))))) 	
  nil
  ((0 6) (lambda (f v2)               ;inner shaft speed
	   (cond ((and f v2) (list '+ v2 (list '/ f 'b))))))
  nil
  ((2 0 6) (lambda (v1 f v2) 		;outer shaft force
	     (cond (f) ((and v1 v2) (list '* 'b (list '- v2 v1)))))) 	
  nil
  ((2 4) (lambda (v1 f)                ;outer shaft speed
	   (cond ((and v1 f) (list '+ v1 (list '/ f 'b))))))
 nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
   (((0 1 0 0) (0 0 1 0) (0 0 0 1) nil)))
  nil
  (trans trans);domain
  (shaft-hole bolt);interface
  (nil nil)
  (((((a) (1 trans))) (nil nil nil (a 1 r0) nil nil));a = anticoupler
  (((a) (0 trans))) (nil nil nil (a 0 r0) nil nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Belt
(belt
 (length dia)
 (((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
  ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
  ((2) (lambda (v) v)) ((3) (lambda (x) x)))
  ((nil ((1 0 0 length) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
   (((1 0 0 (- length)) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
  nil
  (trans trans);domain
  (belt belt);interface
  (nil nil)
  ((nil (nil nil (a 1 t2) (a 1 r0) (a 1 r1) nil))
   ((nil (nil nil (a 0 t2) (a 0 r0) (a 0 r1) nil)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Chain
(chain
 (length pitch)
 (((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
  ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
  ((2) (lambda (v) v)) ((3) (lambda (x) x)))
  ((nil ((1 0 0 length) (0 1 0 0) (0 0 1 0) (0 0 0 1)));like a shaft
  (((1 0 0 (- length)) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
  nil
  (trans trans);domain
  (chain chain);interface
  (nil nil)
  (( nil (nil nil (a 1 t2) nil (a 1 r1) nil))
   ( nil (nil nil (a 0 t2) nil (a 0 r1) nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 1st Class Lever
(lever1stclass 
 (lengtha lengthb)
 (((4) (lambda (f) (cond (f (list '* f (list '/ 'lengthb 'lengtha))))))
  ((5) (lambda (a) (cond (a (list '* a (list '/ 'lengtha 'lengthb)))))) 
  ((6) (lambda (v) (cond (v (list '* v (list '/ 'lengtha 'lengthb))))))
  ((7) (lambda (x) (cond (x (list '* x (list '/ 'lengtha 'lengthb))))))
  ((0) (lambda (f) (cond (f (list '* f (list '/ 'lengtha 'lengthb))))))
  ((1) (lambda (a) (cond (a (list '* a (list '/ 'lengthb 'lengtha))))))
  ((2) (lambda (v) (cond (v (list '* v (list '/ 'lengthb 'lengtha)))))) 
  ((3) (lambda (x) (cond (x (list '* x (list '/ 'lengthb 'lengtha)))))))
  ((nil ((-1 0 0 0) (0 -1 0 0) (0 0 1 (+ lengtha lengthb)) (0 0 0 1)))
   (((-1 0 0 0) (0 -1 0 0) (0 0 1 (- (+ lengtha lengthb))) (0 0 0 1)) nil))
  ;; note: hidden fp at ground! this affects how the state variables couple.
  nil
  (trans trans);domain
  (bolt bolt);interface
  (nil nil)
 ((nil nil (nil) power (trans) nil bolt nil)
  (nil nil (nil) power (trans) nil bolt nil)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 2nd Class Lever (negative- y into the plane)
(lever2ndclass 
 (lengtha lengthb)
 (((4) (lambda (f) (cond (f (list '* f (list '/ (list '+ 'lengthb 'lengtha) 'lengtha))))))
  ((5) (lambda (a) (cond (a (list '* a (list '/ 'lengtha (list '+ 'lengthb 'lengtha))))))) 
  ((6) (lambda (v) (cond (v (list '* v (list '/ 'lengtha (list '+ 'lengthb 'lengtha)))))))
  ((7) (lambda (x) (cond (x (list '* x (list '/ 'lengtha (list '+ 'lengthb 'lengtha)))))))
  ((0) (lambda (f) (cond (f (list '* f (list '/ 'lengtha (list '+ 'lengthb 'lengtha)))))))
  ((1) (lambda (a) (cond (a (list '* a (list '/ (list '+ 'lengthb 'lengtha) 'lengtha))))))
  ((2) (lambda (v) (cond (v (list '* v (list '/ (list '+ 'lengthb 'lengtha) 'lengtha)))))) 
  ((3) (lambda (x) (cond (x (list '* x (list '/ (list '+ 'lengthb 'lengtha) 'lengtha)))))))
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 (- lengtha lengthb)) (0 0 0 1)));0-1
  (((1 0 0 0) (0 1 0 0) (0 0 1 (- lengthb lengtha)) (0 0 0 1)) nil));1-0
  nil
  (trans trans);domain
  (bolt bolt);interface
  (nil nil)
 ((nil nil (nil) power (trans) nil bolt nil)
  (nil nil (nil) power (trans) nil bolt nil)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 2nd Class Lever (positive- y out of the plane)
(lever2ndclass 
 (lengtha lengthb)
 (((4) (lambda (f) (cond (f (list '* f (list '/ (list '+ 'lengthb 'lengtha) 'lengtha))))))
  ((5) (lambda (a) (cond (a (list '* a (list '/ 'lengtha (list '+ 'lengthb 'lengtha))))))) 
  ((6) (lambda (v) (cond (v (list '* v (list '/ 'lengtha (list '+ 'lengthb 'lengtha)))))))
  ((7) (lambda (x) (cond (x (list '* x (list '/ 'lengtha (list '+ 'lengthb 'lengtha)))))))
  ((0) (lambda (f) (cond (f (list '* f (list '/ 'lengtha (list '+ 'lengthb 'lengtha)))))))
  ((1) (lambda (a) (cond (a (list '* a (list '/ (list '+ 'lengthb 'lengtha) 'lengtha))))))
  ((2) (lambda (v) (cond (v (list '* v (list '/ (list '+ 'lengthb 'lengtha) 'lengtha)))))) 
  ((3) (lambda (x) (cond (x (list '* x (list '/ (list '+ 'lengthb 'lengtha) 'lengtha)))))))
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 (- lengthb lengtha)) (0 0 0 1)));0-1
  (((1 0 0 0) (0 1 0 0) (0 0 1 (- lengtha lengthb)) (0 0 0 1)) nil));1-0
  nil
  (trans trans);domain
  (bolt bolt);interface
  (nil nil)
 ((nil nil (nil) power (trans) nil bolt nil)
  (nil nil (nil) power (trans) nil bolt nil)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Pipe 
(pipe
 (length dia rho)
 (((3 4 7) (lambda (iP1 i iP2)                 ;mass flow rate in
	     (cond (i) ((and iP1 iP2) 
			(list '/ (list '*  *pi/4* 'dia 'dia (list '- iP1 iP2)) 
			      'rho 'length)))))
  nil nil
  ((0 7) (lambda (i iP2)                       ;integrated pressure1
	   (cond ((and i iP2) (list '+ iP2 (list '/ 
						 (list '* 'rho 'length i)
						 *pi/4* 'dia 'dia))))))
  ((3 0 7) (lambda (iP1 i iP2)                 ;mass flow rate out
	     (cond (i) ((and iP1 iP2) 
			(list '/ (list '*  *pi/4* 'dia 'dia (list '- iP2 iP1)) 
			      'rho 'length)))))
  nil nil
  ((3 4) (lambda (iP1 i)                       ;integrated pressure2
	   (cond ((and i iP1) (list '+ iP1 (list '/ 
						 (list '* 'rho 'length i)
						 *pi/4* 'dia 'dia)))))))
  ((nil ((1 0 0 length) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 (- length)) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
  nil
  (hydra hydra);domain
  (pipe pipe);interface
  (nil nil)
 ((nil nil (nil) power (hydra) nil nil)
  (nil nil (nil) power (hydra) nil nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Cylinder
(cylinder
 (diameter)
 (((4) (lambda (f) (cond (f (list '/ f *pi/4* 'diameter 'diameter)))))
  ((5) (lambda (a) (cond (a (list '* a *pi/4* 'diameter 'diameter))))) 
  ((6) (lambda (v) (cond (v (list '* v *pi/4* 'diameter 'diameter)))))
  ((7) (lambda (x) (cond (x (list '* x *pi/4* 'diameter 'diameter)))))
  ((0) (lambda (p) (cond (p (list '* p *pi/4* 'diameter 'diameter)))))
  ((1) (lambda (a) (cond (a (list '/ a *pi/4* 'diameter 'diameter)))))
  ((2) (lambda (v) (cond (v (list '/ v *pi/4* 'diameter 'diameter))))) 
  ((3) (lambda (x) (cond (x (list '/ x *pi/4* 'diameter 'diameter))))))
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
  nil
  (hydra trans);domain
  (pipe bolt);interface
  (nil nil)
 ((nil nil (nil) power (hydra) nil nil)
  (nil nil (nil) power (trans) nil nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Pulley
(pulley 
 (dia shaft-dia groove-dia)
 (((4) (lambda (m) (cond (m (list '/ m (list '/ 'dia 2))))))
  ((5) (lambda (a) (cond (a (list '* a (list '/ 'dia 2)))))) 
  ((6) (lambda (w) (cond (w (list '* w (list '/ 'dia 2))))))
  ((7) (lambda (h) (cond (h (list '* h (list '/ 'dia 2))))))
  ((0) (lambda (f) (cond (f (list '* f (list '/ 'dia 2))))))
  ((1) (lambda (a) (cond (a (list '/ a (list '/ 'dia 2))))))
  ((2) (lambda (v) (cond (v (list '/ v (list '/ 'dia 2)))))) 
  ((3) (lambda (x) (cond (x (list '/ x (list '/ 'dia 2)))))))
 
 ((nil					;0-0
    ((0 1 0 0)(-1 0 0 0)(0 0 1 (/ dia 2))(0 0 0 1)) ;0-1
    ((0 1 0 0)(1 0 1 (/ dia 2))(1 0 0 0 )(0 0 0 1)) ;0-2
   ((0 -1 0 0)(1 0 0 0)(0 0 1 (- (/ dia 2)))(0 0 0 1)) ;0-3
   ((0 -1 0 0)(0 0 1 (- (/ dia 2)))((- 1) 0 0 (/ dia 2))(0 0 0 1))) ;0-4
  (((0 -1 0 0)(1 0 0 0)(0 0 1 (- (/ dia 2)))(0 0 0 1)) ;1-0 
   nil					;1-1
   ((0 0 (- 1) (- (/ dia 2)))(0 1 0 0)(1 0 0 (- (/ dia 2)))(0 0 0 1)) ;1-2
   ((-1 0 0 0)(0 -1 0 0)(0 0 1 (- dia))(0 0 0 1)) ;1-3
   ((0 0 -1 (/ dia 2))(0 -1 0 0)(-1 0 0 (- (/ dia 2)))(0 0 0 1))) ;1-4
  (((0 0 1 0)(1 0 0 0)(0 1 0 (- (/ dia 2)))(0 0 0 1)) ;2-0
   ((0 0 1 (/ dia 2))(0 1 0 0)(-1 0 0 (- (/ dia 2)))(0 0 0 1)) ;2-1
   nil					;2-2
   ((0 0 1 (- (/ dia 2)))(0 1 0 0)(1 0 0 (- (/ dia 2)))(0 0 0 1)) ;2-3
   ((-1 0 0 0)(0 -1 0 0)(0 0 1 (- dia) )(0 0 0 1))) ;2-4
  (((0 1 0 0)(-1 0 0 0)(0 0 1 (/ dia 2))(0 0 0 1)) ;3-0
   ((-1 0 0 0)(0 -1 0 0)(0 0 1 dia)(0 0 0 1)) ;3-1
   ((0 0 1 (/ dia 2))(0 -1 0 0)(1 0 0 (/ dia 2))(0 0 0 1)) ;3-2
   nil					;3-3
   ((0 1 0 (/ dia 2))(0 1 0 0)(-1 0 0 (/ dia 2))(0 0 0 1))) ;3-4
  (((0 0 -1 0)(-1 0 0 0)(0 1 0 (/ dia 2))(0 0 0 1)) ;4-0
   ((0 0 -1 (- (/ dia 2)))(0 -1 0 0)(-1 0 0 (/ dia 2))(0 0 0 1)) ;4-1
   ((-1 0 0 0)(0 -1 0 0)(0 0 1 dia)(0 0 0 1)) ;4-2
   ((0 0 -1 (/ dia 2))(0 1 0 0)(1 0 0 (/ dia 2))(0 0 0 1)) ;4-3
   nil))					;4-4  
  nil
  (rotat trans trans trans trans);domain
  (shaft-hole pulley pulley pulley pulley);inetrface && opers for pulley same as for gear ?
  (nil nil nil nil nil)
 ((nil nil (nil) power (trans) nil pulley nil)
  (nil nil (nil) power (rotat) nil shaft-hole nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Positive rack(z coming out of gear teeth)
(rack-pos 
 (pitch length)
 (((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
  ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
  ((2) (lambda (v) v)) ((3) (lambda (x) x)))
 ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 nil
 (trans trans);domain
 (gear-teeth-pos bolt);interface
 (nil nil)
 ((nil nil (nil) power (trans) nil bolt nil) 
  (nil nil (nil) power (trans) nil gear-teeth-pos nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Negative rack (z going into gear teeth)
(rack-neg
 (pitch length)
 (((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
  ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
  ((2) (lambda (v) v)) ((3) (lambda (x) x)))
 ((nil ((1 0 0 0) (0 -1 0 0) (0 0 -1 0) (0 0 0 1)))
  (((1 0 0 0) (0 -1 0 0) (0 0 -1 0) (0 0 0 1)) nil))
 nil
 (trans trans);domain
 (gear-teeth-neg bolt);interface
 (nil nil)
 ((nil nil (nil) power (trans) nil bolt nil) 
  (nil nil (nil) power (trans) nil gear-teeth-neg nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Shaft
(shaft
 (length diameter)
 (((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
  ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
  ((2) (lambda (v) v)) ((3) (lambda (x) x)))
  ((nil ((1 0 0 length) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 (- length)) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
  nil
  (rotat rotat);domain
  (shaft-neg shaft-pos);interface
  (nil nil)
  ((nil nil (nil) power (rotat) nil shaft nil)
  (nil nil (nil) power (rotat) nil shaft nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Spring
(spring
 (k o-dia length wire-dia)
 (((3 4 7) (lambda (x1 f x2)                       ;force1
	     (cond (f) ((and x1 x2) (list '* 'k (list '- x1 x2))))))
  nil nil
  ((0 7) (lambda (f x2)                            ;displacement1
	   (cond ((and f x2) (list '+ x2 (list '/ f 'k))))))
  ((3 0 7) (lambda (x1 f x2)                       ;force2
	     (cond (f) ((and x1 x2) (list '* 'k (list '- x2 x1))))))
  nil nil
  ((3 4) (lambda (x1 f)                            ;displacement2
	   (cond ((and x1 f) (list '+ x1 (list '/ f 'k)))))))
  ((nil ((1 0 0 length) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
   (((1 0 0 (- length)) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
  nil
  (trans trans);domain
  (bolt bolt);interface
  (nil nil)
 ((i nil nil nil nil nil nil nil (integ) power (trans) nil bolt nil)
  (i nil nil nil nil nil nil nil (integ) power (trans) nil bolt nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Sprocket
(sprocket 
 (dia shaft-dia teeth pitch)
 (((4) (lambda (m) (cond (m (list '/ m (list '/ 'dia 2))))))
  ((5) (lambda (a) (cond (a (list '* a (list '/ 'dia 2)))))) 
  ((6) (lambda (w) (cond (w (list '* w (list '/ 'dia 2))))))
  ((7) (lambda (h) (cond (h (list '* h (list '/ 'dia 2))))))
  ((0) (lambda (f) (cond (f (list '* f (list '/ 'dia 2))))))
  ((1) (lambda (a) (cond (a (list '/ a (list '/ 'dia 2))))))
  ((2) (lambda (v) (cond (v (list '/ v (list '/ 'dia 2)))))) 
  ((3) (lambda (x) (cond (x (list '/ x (list '/ 'dia 2)))))))
 
 (((nil					;0-0
    ((0 1 0 0)(-1 0 0 0)(0 0 1 (/ dia 2))(0 0 0 1)) ;0-1
    ((0 1 0 0))(1 0 1 (/ dia 2))(1 0 0 0 )(0 0 0 1)) ;0-2
   ((0 -1 0 0)(1 0 0 0)(0 0 1 (- (/ dia 2)))(0 0 0 1)) ;0-3
   ((0 -1 0 0)(0 0 1 (- (/ dia 2)))((- 1) 0 0 (/ dia 2))(0 0 0 1))) ;0-4
  (((0 -1 0 0)(1 0 0 0)(0 0 1 (- (/ dia 2)))(0 0 0 1)) ;1-0 
   nil					;1-1
   ((0 0 -1 (- (/ dia 2)))(0 1 0 0)(1 0 0 (- (/ dia 2)))(0 0 0 1)) ;1-2
   ((-1 0 0 0)(0 -1 0 0)(0 0 1 (- dia))(0 0 0 1)) ;1-3
   ((0 0 -1 (/ dia 2))(0 -1 0 0)(-1 0 0 (- (/ dia 2)))(0 0 0 1))) ;1-4
  (((0 0 1 0)(1 0 0 0)(0 1 0 (- (/ dia 2)))(0 0 0 1)) ;2-0
   ((0 0 1 (/ dia 2))(0 1 0 0)(-1 0 0 (- (/ dia 2)))(0 0 0 1)) ;2-1
   nil					;2-2
   ((0 0 1 (- (/ dia 2)))(0 1 0 0)(1 0 0 (- (/ dia 2)))(0 0 0 1)) ;2-3
   ((-1 0 0 0)(0 -1 0 0)(0 0 1 (- dia))(0 0 0 1))) ;2-4
  (((0 1 0 0)(-1 0 0 0)(0 0 1 (/ dia 2))(0 0 0 1)) ;3-0
   ((-1 0 0 0)(0 -1 0 0)(0 0 1 dia)(0 0 0 1)) ;3-1
   ((0 0 1 (/ dia 2))(0 -1 0 0)(1 0 0 (/ dia 2))(0 0 0 1)) ;3-2
   nil					;3-3
   ((0 1 0 (/ dia 2))(0 1 0 0)(-1 0 0 (/ dia 2))(0 0 0 1))) ;3-4
  (((0 0 -1 0)(-1 0 0 0)(0 1 0 (/ dia 2))(0 0 0 1)) ;4-0
   ((0 0 -1 (- (/ dia 2)))(0 -1 0 0)(-1 0 0 (/ dia 2))(0 0 0 1)) ;4-1
   ((-1 0 0 0)(0 -1 0 0)(0 0 1 dia)(0 0 0 1)) ;4-2
   ((0 0 -1 (/ dia 2))(0 1 0 0)(1 0 0 (/ dia 2))(0 0 0 1)) ;4-3
   nil))					;4-4  
  nil
  (rotat trans trans trans trans);domain
  (shaft-hole sprocket-teeth sprocket-teeth sprocket-teeth sprocket-teeth);interface
  (nil nil nil nil nil)
 ((nil nil (nil) power (trans) nil sprocket-teeth nil)
  (nil nil (nil) power (rotat) nil shaft-hole nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Tank
(tank  ;hydraulic capacitors
 (dia rho)
 (((1 4 5) (lambda (dP1 m dP2)                       ;input flow rate
	     (cond (m) ((and dP1 dP2) 
			(list '/ (list '* *pi/4* 'dia 'dia (list '- dP1 dP2))
			      'rho *gravity*)))))
  ((0 5) (lambda (m dP2)                ;input derivative pressure
	   (cond ((and m dP2) (list '+ dP2 (list '/ (list '* 'rho *gravity* m) 
						 *pi/4* 'dia 'dia))))))
  nil nil
  ((1 0 5) (lambda (dP1 m dP2)                       ;output flow rate
	     (cond (m) ((and dP1 dP2) 
			(list '/ (list '* *pi/4* 'dia 'dia (list '- dP2 dP1)) 
			      'rho *gravity*)))))
  ((1 4) (lambda (dP1 m)                ;output derivative pressure
	   (cond ((and m dP2) (list '+ dP1 (list '/ (list '* 'rho *gravity* m) 
						 *pi/4* 'dia 'dia))))))
 nil nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
   (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
  nil
  (hydra hydra);domain
  (pipe pipe);interface
  (nil nil)
 ((nil nil (integ) power (hydra) nil pipe nil)
  (nil nil (integ) power (hydra) nil pipe nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Helical Torsion Spring
(torsion-spring 
 (k length)
 (((3 4 7) (lambda (x1 f x2)                       ;torque1
	     (cond (f) ((and x1 x2) (list '* 'k (list '- x1 x2))))))
  nil nil
  ((0 7) (lambda (f x2)                            ;angle1
	   (cond ((and f x2) (list '+ x2 (list '/ f 'k))))))
  ((3 0 7) (lambda (x1 f x2)                       ;torque2
	     (cond (f) ((and x1 x2) (list '* 'k (list '- x2 x1))))))
  nil nil
  ((3 4) (lambda (x1 f)                            ;angle2
	   (cond ((and x1 f) (list '+ x1 (list '/ f 'k)))))))
 ((nil ((1 0 0 length) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 (- length)) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 nil
 (rotat rotat)				;domain
 (bolt bolt);;interface	

					;how to connect this to a shaft?
					;do we need another component, say 
					;an armature?
 (nil nil)
 ((nil nil (integ) power (rotat) nil shaft-hole nil)
 (nil nil (integ) power (rotat) nil bolt nil)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Spiral Torsion Spring
(torsion-spring 
 (k length)
 (((3 4 7) (lambda (x1 f x2)                       ;torque1
	     (cond (f) ((and x1 x2) (list '* 'k (list '- x1 x2))))))
  nil nil
  ((0 7) (lambda (f x2)                            ;angle1
	   (cond ((and f x2) (list '+ x2 (list '/ f 'k))))))
  ((3 0 7) (lambda (x1 f x2)                       ;torque2
	     (cond (f) ((and x1 x2) (list '* 'k (list '- x2 x1))))))
  nil nil
  ((3 4) (lambda (x1 f)                            ;angle2
	   (cond ((and x1 f) (list '+ x1 (list '/ f 'k)))))))
 ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil (integ) power (rotat) nil shaft-hole nil);domain && interface ?
 (nil nil (integ) power (rotat) nil bolt nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Rotationally Controlled Valve
(valve-rotat-control
 (DATA1 DATA2 DATA3)
 ((nil nil (* b) nil nil nil (* (- b)) nil) ;inner shaft force
   ()
   ((* (/ b)) nil nil nil nil nil (* 1) nil)     ;inner shaft speed
   ()
   (nil nil (* (- b)) nil nil nil (* b) nil) ;outer shaft force
   ()
   (nil nil (* 1) nil (* (/ b)) nil nil nil)     ;outer shaft speed
   ()
   ()
   ()
   ()
   ())
 (PO-CHANGE PO-CHANGE PO-CHANGE PO-CHANGE)
 ((nil nil (integ) power (rotat) nil shaft sink)
  (nil nil (none) power (hydra) nil pipe nil) 
  (nil nil (none) power (hydra) nil pipe nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Worm (the helical one )
(worm
 (pitch dia angle length)
 (((4) (lambda (m) (cond (m (list '/ m (list '/ 'dia 2) 
				  (list 'sin 'angle) (list 'cos 'angle))))))
  ((5) (lambda (a) (cond (a (list '* a (list '/ 'dia 2) (list 'tan 'angle)))))) 
  ((6) (lambda (w) (cond (w (list '* w (list '/ 'dia 2) (list 'tan 'angle))))))
  ((7) (lambda (h) (cond (h (list '* h (list '/ 'dia 2) (list 'tan 'angle))))))
  nil nil nil nil)
 ((nil ((1 0 0 (/length 2)) (0 1 0 0) (0 0 1 (- (/ dia 2))) (0 0 0 1)) ;0-1
  ((1 0 0 0) (0 -1 0 0 )(0 0 -1 (- dia)) (0 0 0 1)));0-2    
  (((1 0 0 (- (/ length 2))) (0 1 0 0) (0 0 1 (/ dia 2)) (0 0 0 1)) nil) ;1-0
  (nil ; 1-1 
   ((1 0 0 (- (/ length 2))) (0 -1 0 0 ) (0 0 -1 (- (/ dia 2))) ( 0 0 0 1))) ;1-2
   ((1 0 0 0 )(0 -1 0 0 )(0 0 -1 (- dia))(0 0 0 1)) ; 2-0
   ((1 0 0 (/ length 2)) (0 -1 0 0 ) (0 0 -1 (- (/ dia 2))) (0 0 0 1)) ; 2-1
   nil)
 ;;domain and interface ?
 ((nil nil (nil) power (trans) nil worm-teeth source)
  (nil nil (nil) power (rotat) nil shaft-hole sink)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ELECTRICAL COMPONENTS 
;;(battery
;; (step)
;; (((4) (lambda (i) i)) nil ((6) (lambda (v1) (cond (v1 (list '+ 'step v1)))))
;;		       nil ((0) (lambda (i) i)) nil 
;;  ((2) (lambda (v2) (cond (v2 (list '+ v2 'step))))) nil)
;;  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
;;  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
;; ((nil nil (nil) power (elect) nil wire source)
;;  (nil nil (nil) power (elect) nil wire sink)))
(capacitor
 (cap dia length max-v)
 (((1 4 5) (lambda (dv1 i dv2)                       ;input current
	     (cond (i) ((and dv1 dv2) (list '* 'cap (list '- dv1 dv2))))))
  ((0 5) (lambda (i dv2)                ;deriv voltage
	   (cond ((and i dv2) (list '+ dv2 (list '/ i 'cap))))))
  nil nil
  ((1 0 5) (lambda (dv1 i dv2)                       ;input current
	     (cond (i) ((and dv1 dv2) (list '* 'cap (list '- dv2 dv1))))))
  ((1 4) (lambda (dv1 i)                ;deriv voltage
	   (cond ((and dv1 i) (list '+ dv1 (list '/ i 'cap))))))
  nil nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((elect wire nil (((d) (1 elect))) nil)
  (elect wire nil (((d) (0 elect))) nil)))
(inductor
 (L Q freq-of-Q)
 (((3 4 7) (lambda (iv1 i iv2)                       ;current1
	     (cond (i) ((and iv1 iv2) (list '/ (list '- iv1 iv2) 'L)))))
  nil nil
  ((0 7) (lambda (i iv2)                             ;integrated voltage1
	   (cond ((and i iv2) (list '+ iv2 (list '* 'L i))))))
  ((3 0 7) (lambda (iv1 i iv2)                       ;current2
	     (cond (i) ((and iv1 iv2) (list '/ (list '- iv2 iv1) 'L)))))
  nil nil
  ((3 4) (lambda (iv1 i)                ;integrated voltage2
	   (cond ((and iv1 i) (list '+ iv1 (list '* 'L i)))))))
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
  ((nil nil nil nil nil nil i nil power nil wire nil) 
   (nil nil nil nil nil nil i nil power nil wire nil))) 
;(relay
; (DATA1 DATA2 DATA3)
; (()
;  ()
;  ()
;  ())
; (PO-CHANGE PO-CHANGE PO-CHANGE PO-CHANGE)
; ((nil nil nil signal (elect) wire sink) 
;  (nil nil (nil) power (elect) wire nil) 
;  (nil nil (nil) power (elect) wire nil)))
(resistor
 (R tol)
 (((2 4 6) (lambda (v1 i2 v2) 		;current1
	     (cond (i2) ((and v1 v2) (list '/ (list '- v1 v2) 'R))))) 	
  nil
  ((0 6) (lambda (i1 v2)                ;voltage1
	   (cond ((and i1 v2) (list '+ v2 (list '* 'R i1))))))
  nil
  ((2 0 6) (lambda (v1 i1 v2) 		;current2
	     (cond (i1) ((and v1 v2) (list '/ (list '- v2 v1) 'R))))) 	
  nil
  ((2 4) (lambda (v1 i2)                ;voltage2
	   (cond ((and v1 i2) (list '+ v1 (list '* 'R i2))))))
  nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil (none) power (elect) nil wire nil)
  (nil nil (none) power (elect) nil wire nil)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ELECTRICAL-TO-MECHANICAL COMPONENTS 
(generator
 (Ke R L D J)
 (((2 4 6 10) (lambda (v1 i v2 w)         ;current1
		(cond (i) ((and v1 v2 w)
			   (list '/ (list '- v1 v2 (list '* 'Ke w)) 'R)))))
  nil                                    ;derivative voltage1
  ((0 6 10) (lambda (i v2 w)              ;voltage1
	      (cond ((and i v2 w) 
		     (list '+ v2 (list '* 'R i1) (list '* 'Ke w))))))
  nil                                     ;integral voltage1
  ((2 0 6 10) (lambda (v1 i1 v2 w) 	 ;current2
		(cond (i1) ((and v1 v2 w) 
			    (list '/ (list '- v2 v1 (list '* 'Ke w)) 'R)))))
  nil                                    ;derivative voltage2
  ((2 4 10) (lambda (v1 i2 w)            ;voltage2
	      (cond ((and v1 i2) 
		     (list '- v1 (list '* 'R i2) (list '* 'Ke w))))))
  nil                                    ;integral voltage2
  ((0 4) (lambda (i1 i2)                 ;output torque
	   (cond (i1 (list '* 'Ke i1)) (i2 (list '* 'Ke i2)))))
  nil
  ((8) (lambda (m) (cond (m (list '/ m 'D)))))
  nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) 
	((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil 
	((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1))
	((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil (nil) power (elect) nil wire source)
  (nil nil (nil) power (elect) nil wire sink)	
  (nil nil (nil) power (rotat) nil shaft sink)))

(motor 
 (Ke R L D J)
 (((2 4 6 10) (lambda (v1 i v2 w)         ;current1
		(cond (i) ((and v1 v2 w)
			   (list '/ (list '- v1 v2 (list '* 'Ke w)) 'R)))))
  nil                                    ;derivative voltage1
  ((0 6 10) (lambda (i v2 w)              ;voltage1
	      (cond ((and i v2 w) 
		     (list '+ v2 (list '* 'R i1) (list '* 'Ke w))))))
  nil                                     ;integral voltage1
  ((2 0 6 10) (lambda (v1 i1 v2 w) 	 ;current2
		(cond (i1) ((and v1 v2 w) 
			    (list '/ (list '- v2 v1 (list '* 'Ke w)) 'R)))))
  nil                                    ;derivative voltage2
  ((2 4 10) (lambda (v1 i2 w)            ;voltage2
	      (cond ((and v1 i2) 
		     (list '- v1 (list '* 'R i2) (list '* 'Ke w))))))
  nil                                    ;integral voltage2
  ((0 4) (lambda (i1 i2)                 ;output torque
	   (cond (i1 (list '* 'Ke i1)) (i2 (list '* 'Ke i2)))))
  nil
  ((8) (lambda (m) (cond (m (list '/ m 'D)))))
  nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) 
	((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil 
	((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1))
	((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil nil nil nil nil (((r i)(0 6))((t)(2 3))) nil)
  (nil nil (nil) power (elect) nil wire sink)	
  (nil nil (nil) power (rotat) nil shaft source)))
(potentiometer
 (dia R-rate b)
 (((2 4 6 11) (lambda (v1 i2 v2 h) 		;current1
		(cond (i2) ((and v1 v2) (list '/ (list '- v1 v2) 
					      (list '* h 'R-rate))))))
  nil
  ((0 6 11) (lambda (i1 v2 h)                ;voltage1
	      (cond ((and i1 v2) (list '+ v2 (list '* 
						   (list '* h 'R-rate) i1))))))
  nil
  ((2 0 6 11) (lambda (v1 i1 v2 h) 		;current2
		(cond (i1) ((and v1 v2) (list '/ (list '- v2 v1) 
					      (list '* h 'R-rate)))))) 	
  nil
  ((2 4 11) (lambda (v1 i2 h)                ;voltage2
	      (cond ((and v1 i2) (list '+ v1 (list '* 
						   (list '* h 'R-rate) i2))))))
  nil
  ((10) (lambda (xdot) (cond (xdot (list '* 'b xdot)))))   ;inner shaft torque 
  nil
  ((8) (lambda (f) (cond (f (list '/ f 'b)))))      ;inner shaft speed
	 
  nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) 
	((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil 
	((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1))
	((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 (((nil nil nil) (nil nil nil) d nil power nil wire nil)
  ((nil nil nil) (nil nil nil) d nil power nil wire nil)
  ((c c c) (d nil nil) nil nil power nil shaft sink)))

(solenoid
 (Ke R L D)
 (((2 4 6 10) (lambda (v1 i v2 w)         ;current1
		(cond (i) ((and v1 v2 w)
			   (list '/ (list '- v1 v2 (list '* 'Ke w)) 'R)))))
  nil                                    ;derivative voltage1
  ((0 6 10) (lambda (i v2 w)              ;voltage1
	      (cond ((and i v2 w) 
		     (list '+ v2 (list '* 'R i1) (list '* 'Ke w))))))
  nil                                     ;integral voltage1
  ((2 0 6 10) (lambda (v1 i1 v2 w) 	 ;current2
		(cond (i1) ((and v1 v2 w) 
			    (list '/ (list '- v2 v1 (list '* 'Ke w)) 'R)))))
  nil                                    ;derivative voltage2
  ((2 4 10) (lambda (v1 i2 w)            ;voltage2
	      (cond ((and v1 i2) 
		     (list '- v1 (list '* 'R i2) (list '* 'Ke w))))))
  nil                                    ;integral voltage2
  ((0 4) (lambda (i1 i2)                 ;output torque
	   (cond (i1 (list '* 'Ke i1)) (i2 (list '* 'Ke i2)))))
  nil
  ((8) (lambda (m) (cond (m (list '/ m 'D)))))
  nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) 
	((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil 
	((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1))
	((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil (nil) power (elect) nil wire sink)
  (nil nil (nil) power (elect) nil wire source)	
  (nil nil (nil) power (trans) nil bolt nil)))

;(switch
; (throw d)
; (((2) (lambda (v) (cond (v (list '* 'b v))))) 	
;  nil
;  ((0) (lambda (f) (cond (f (list '/ f 'b)))))
;  nil
;  ((3) (lambda (x) 		;outer shaft force
;	     (cond (x) ((and v1 v2) (list '* 'b (list '- v2 v1)))))) 	
;  nil
;  ((2 4) (lambda (v1 f)                ;outer shaft speed
;	   (cond ((and v1 f) (list '+ v1 (list '/ f 'b))))))
;  nil)
; (PO-CHANGE PO-CHANGE PO-CHANGE PO-CHANGE)
; ((nil nil (integ) power (trans) nil nil sink) 
;  (nil nil (nil) power (elect) nil wire nil) 
					;  (nil nil (nil) power (elect) nil wire nil)))
					;(transistor
; (DATA1 DATA2 DATA3)
; (()
;  ()
;  ()
;  ())
; (PO-CHANGE PO-CHANGE PO-CHANGE PO-CHANGE)
; ((OPERATOR CLASS DOMAIN INTERFACE DIRECTION) 
;  (OPERATOR CLASS DOMAIN INTERFACE DIRECTION)))
;(valve-elect-control
; (DATA1 DATA2 DATA3)
; ((nil nil (* b) nil nil nil (* (- b)) nil) ;inner shaft force
;   ()
;   ((* (/ b)) nil nil nil nil nil (* 1) nil)     ;inner shaft speed
;   ()
;   (nil nil (* (- b)) nil nil nil (* b) nil) ;outer shaft force
;   ()
;   (nil nil (* 1) nil (* (/ b)) nil nil nil)     ;outer shaft speed
;   ()
;   ()
;   ()
;   ()
;   ())
; (PO-CHANGE PO-CHANGE PO-CHANGE PO-CHANGE)
; ((nil nil (integ) power (elect) wire sink)
;  (nil nil (none) power (hydra) nil pipe nil) 
					;  (nil nil (none) power (hydra) nil pipe nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MISCELLANEOUS COMPONENTS
(dial
 (default-data)
 (((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
  ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
  ((2) (lambda (v) v)) ((3) (lambda (x) x)))
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
  ((c c c c nil nil nil nil signal nil dial source)
   (c c c c nil nil nil nil power nil shaft-hole sink)))
(footpad
 (default-data)
 (((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
  ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
  ((2) (lambda (v) v)) ((3) (lambda (x) x)))
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil (nil) power (trans) nil bolt source)
  (nil nil (nil) power (trans) nil flat-user-interface sink)))
;(stop
; (DATA1 DATA2 DATA3)
; (()
;  ()
;  ()
;  ())
; (PO-CHANGE PO-CHANGE PO-CHANGE PO-CHANGE)
; ((nil nil (integ) power (trans) nil bolt source) 
;  (nil nil (integ) power (trans) nil bolt sink)))