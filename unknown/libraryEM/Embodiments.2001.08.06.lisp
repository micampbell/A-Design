
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

;;;  New CP representation!!!
;;;  Component ports (CP's) have ALL domains, but are restricted by what they
;;;  do in each respective domain. They can be either differentiators (d), 
;;;  integrators (i), dissipator (r), transformers (t), couplers (c), 
;;;  anti-coupler (a) , or nil.
;;;  If nil then the CP CANNOT connect to an FP that is active in that domain.

(battery
 (step)
 (((4) (lambda (i) i)) nil ((6) (lambda (v1) (cond (v1 (list '+ 'step v1)))))
		       nil ((0) (lambda (i) i)) nil 
  ((2) (lambda (v2) (cond (v2 (list '+ v2 'step))))) nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil (nil) power (elect) nil wire source)
  (nil nil (nil) power (elect) nil wire sink)))
(bearing-rotat-x
 (d-inner d-outer b)
 (((2 4 6) (lambda (v1 f v2) 			;inner shaft torque
	     (cond (f) ((and v1 v2) (list '* 'b (list '- v1 v2)))))) 	
  nil
  ((0 6) (lambda (f v2)                ;inner shaft speed
	   (cond ((and f v2) (list '+ v2 (list '/ f 'b))))))
  nil
  ((2 0 6) (lambda (v1 f v2) 		;outer shaft torque
	     (cond (f) ((and v1 v2) (list '* 'b (list '- v2 v1)))))) 	
  nil
  ((2 4) (lambda (v1 f)                ;outer shaft speed
	   (cond ((and v1 f) (list '+ v1 (list '/ f 'b))))))
  nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
  (((c) c c a nil nil nil nil power nil shaft-hole nil) ; try something like
   ((trans-x 1 c trans-x))
   ;;**************************************************************************
   ;;;for each port beginning port number 0((port 1)(port 2)...(port n)
   ;;;trans/rotate/hydraulic/electric----function
   ;;;coupler = transformer with a transformation ratio of 1 so probably 
   ;;;not need to be explicitly defined.for this the magnitude of the through 
   ;;;andacross variables might be necessary eventually 
   ;;;In case of bearing port 2 is connected to ground so the term anticoupler 
   ;;;might be redundant.
   ;;;Maxmum  number of elements per embodiment = nC2*2*4
   ;;;through variables only could be considered for FS purposes.The definition of the domain(eg trans-x) should be enough to get all the through and across variable dimensions
   
  (c c c a nil nil nil nil power nil bolt nil))	)
(bearing-rotat-y
 (d-inner d-outer b)
 (((2 4 6) (lambda (v1 f v2) 			;inner shaft torque
	     (cond (f) ((and v1 v2) (list '* 'b (list '- v1 v2)))))) 	
  nil
  ((0 6) (lambda (f v2)                ;inner shaft speed
	   (cond ((and f v2) (list '+ v2 (list '/ f 'b))))))
  nil
  ((2 0 6) (lambda (v1 f v2) 		;outer shaft torque
	     (cond (f) ((and v1 v2) (list '* 'b (list '- v2 v1)))))) 	
  nil
  ((2 4) (lambda (v1 f)                ;outer shaft speed
	   (cond ((and v1 f) (list '+ v1 (list '/ f 'b))))))
  nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((c c c nil a nil nil nil power nil shaft-hole nil) 
  (c c c nil a nil nil nil power nil bolt nil))	)
(bearing-rotat-z
 (d-inner d-outer b)
 (((2 4 6) (lambda (v1 f v2) 			;inner shaft torque
	     (cond (f) ((and v1 v2) (list '* 'b (list '- v1 v2)))))) 	
  nil
  ((0 6) (lambda (f v2)                ;inner shaft speed
	   (cond ((and f v2) (list '+ v2 (list '/ f 'b))))))
  nil
  ((2 0 6) (lambda (v1 f v2) 		;outer shaft torque
	     (cond (f) ((and v1 v2) (list '* 'b (list '- v2 v1)))))) 	
  nil
  ((2 4) (lambda (v1 f)                ;outer shaft speed
	   (cond ((and v1 f) (list '+ v1 (list '/ f 'b))))))
  nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((c c c nil a nil nil nil power nil shaft-hole nil) 
  (c c c nil a nil nil nil power nil bolt nil))	)
(bearing-trans-x
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
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((a c c a nil nil nil nil power nil shaft-hole nil) 
  (a c c a nil nil nil nil power nil bolt nil)))
(bearing-trans-y)
(bearing-tranx-z)
(belt-x
 (length dia)
 (((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
  ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
  ((2) (lambda (v) v)) ((3) (lambda (x) x)))
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
  ((c nil nil a a a nil nil power nil belt nil)
   (c nil nil a a a nil nil power nil belt nil)))
(belt-y)
(belt-z)
(chain-x
 (length pitch)
 (((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
  ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
  ((2) (lambda (v) v)) ((3) (lambda (x) x)))
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
  ((c nil nil nil nil a nil nil power nil chain nil)
   (c nil nil nil nil a nil nil power nil chain nil)))
 (chain-y)
(chain-z)
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
  ((nil nil nil nil nil nil d nil power nil wire nil) 
   (nil nil nil nil nil nil d nil power nil wire nil))) 
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
(gear-x)
(gear-y 
 (dia shaft-dia teeth pitch)
 (((4) (lambda (m) (cond (m (list '/ m (list '/ 'dia 2))))))
  ((5) (lambda (a) (cond (a (list '* a (list '/ 'dia 2)))))) 
  ((6) (lambda (w) (cond (w (list '* w (list '/ 'dia 2))))))
  ((7) (lambda (h) (cond (h (list '* h (list '/ 'dia 2))))))
  ((0) (lambda (f) (cond (f (list '* f (list '/ 'dia 2))))))
  ((1) (lambda (a) (cond (a (list '/ a (list '/ 'dia 2))))))
  ((2) (lambda (v) (cond (v (list '/ v (list '/ 'dia 2)))))) 
  ((3) (lambda (x) (cond (x (list '/ x (list '/ 'dia 2)))))))
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((t r nil nil nil nil nil nil power nil gear-teeth nil)
  (t r nil nil nil nil nil nil power nil gear-teeth nil)
  (nil r t nil nil nil nil nil power nil gear-teeth nil)
  (nil r t nil nil nil nil nil power nil gear-teeth nil)
  (nil nil nil nil t nil nil nil power nil shaft-hole nil)))
(gear-z)
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
(lever-x
 (lengtha lengthb)
 (((4) (lambda (f) (cond (f (list '* f (list '/ 'lengthb 'lengtha))))))
  ((5) (lambda (a) (cond (a (list '* a (list '/ 'lengtha 'lengthb)))))) 
  ((6) (lambda (v) (cond (v (list '* v (list '/ 'lengtha 'lengthb))))))
  ((7) (lambda (x) (cond (x (list '* x (list '/ 'lengtha 'lengthb))))))
  ((0) (lambda (f) (cond (f (list '* f (list '/ 'lengtha 'lengthb))))))
  ((1) (lambda (a) (cond (a (list '* a (list '/ 'lengthb 'lengtha))))))
  ((2) (lambda (v) (cond (v (list '* v (list '/ 'lengthb 'lengtha)))))) 
  ((3) (lambda (x) (cond (x (list '* x (list '/ 'lengthb 'lengtha)))))))
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((c c nil nil nil a nil nil power nil bolt nil)
  (c c nil nil nil a nil nil power nil bolt nil)))
(lever-y)
(lever-z)

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
 ((nil nil (nil) power (elect) nil wire source)
  (nil nil (nil) power (elect) nil wire sink)	
  (nil nil (nil) power (rotat) nil shaft source)))
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
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil (nil) power (hydra) nil male-pipe nil)
  (nil nil (nil) power (hydra) nil male-pipe nil)))
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
 ((nil nil (nil) power (hydra) nil female-pipe nil)
  (nil nil (nil) power (trans) nil bolt nil)))
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
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil (nil) power (trans) nil pulley nil)
  (nil nil (nil) power (rotat) nil shaft-hole nil)))
(rack
 (pitch length)
 (((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
  ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
  ((2) (lambda (v) v)) ((3) (lambda (x) x)))
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil (nil) power (trans) nil bolt nil) 
  (nil nil (nil) power (trans) nil gear-teeth nil)))
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
 ((
trans-x nil
trans-y nil
trans-z nil
rotat-x nil
rotat-y nil
rotat-z nil
elect damper
hydra nil


nil nil (none) power (elect) nil wire nil)
  (nil nil (none) power (elect) nil wire nil)))
(shaft
 (length diameter)
 (((4) (lambda (f) f)) ((5) (lambda (a) a)) ((6) (lambda (v) v))
  ((7) (lambda (x) x)) ((0) (lambda (f) f)) ((1) (lambda (a) a))
  ((2) (lambda (v) v)) ((3) (lambda (x) x)))
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil (nil) power (rotat) nil shaft nil)
  (nil nil (nil) power (rotat) nil shaft nil)))
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
(spring-x
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
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((i nil nil nil nil nil nil nil (integ) power (trans) nil bolt nil)
  (i nil nil nil nil nil nil nil (integ) power (trans) nil bolt nil)))
(spring-y
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
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil i nil nil nil nil nil nil (integ) power (trans) nil bolt nil)
  (nil i nil nil nil nil nil nil (integ) power (trans) nil bolt nil)))
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
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil (nil) power (trans) nil sprocket-teeth nil)
  (nil nil (nil) power (rotat) nil shaft-hole nil)))
;(stop
; (DATA1 DATA2 DATA3)
; (()
;  ()
;  ()
;  ())
; (PO-CHANGE PO-CHANGE PO-CHANGE PO-CHANGE)
; ((nil nil (integ) power (trans) nil bolt source) 
;  (nil nil (integ) power (trans) nil bolt sink)))
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
 ((nil nil (integ) power (hydra) nil female-pipe nil)
  (nil nil (integ) power (hydra) nil female-pipe nil)))
;(torsion-spring 
; (k length)
; (((3 4 7) (lambda (x1 f x2)                       ;torque1
;	     (cond (f) ((and x1 x2) (list '* 'k (list '- x1 x2))))))
;  nil nil
;  ((0 7) (lambda (f x2)                            ;angle1
;	   (cond ((and f x2) (list '+ x2 (list '/ f 'k))))))
;  ((3 0 7) (lambda (x1 f x2)                       ;torque2
;	     (cond (f) ((and x1 x2) (list '* 'k (list '- x2 x1))))))
;  nil nil
;  ((3 4) (lambda (x1 f)                            ;angle2
;	   (cond ((and x1 f) (list '+ x1 (list '/ f 'k)))))))
; (0.0 length 0.0 0.0)
; ((nil nil (integ) power (rotat) nil shaft-hole nil)
;  (nil nil (integ) power (rotat) nil bolt nil)))
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
;(valve-rotat-control
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
; ((nil nil (integ) power (rotat) nil shaft sink)
;  (nil nil (none) power (hydra) nil pipe nil) 
;  (nil nil (none) power (hydra) nil pipe nil)))
(worm-gear 
 (pitch dia angle)
 (((4) (lambda (m) (cond (m (list '/ m (list '/ 'dia 2) 
				  (list 'sin 'angle) (list 'cos 'angle))))))
  ((5) (lambda (a) (cond (a (list '* a (list '/ 'dia 2) (list 'tan 'angle)))))) 
  ((6) (lambda (w) (cond (w (list '* w (list '/ 'dia 2) (list 'tan 'angle))))))
  ((7) (lambda (h) (cond (h (list '* h (list '/ 'dia 2) (list 'tan 'angle))))))
  nil nil nil nil)
  ((nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)))
  (((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) nil))
 ((nil nil (nil) power (trans) nil worm-teeth source)
  (nil nil (nil) power (rotat) nil shaft-hole sink)))


