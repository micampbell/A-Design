;;; Evaluations.lisp 
;;; Contains functions called in evaluate in design.lisp
;;; These functions are specified in parameters

(setf *global-ground* nil)
(setf *C_para* 120e-9)
(setf *V_m* 10)
(setf *Vn_circuit* 0.1)
(setf *Boltzman_K_b* 1.381e-23)
(setf *Temp* 298)
(setf *epsilon* 8.854e-12)   ;8.854 pF/m
(setf *freq_range* 10000)
;(require :foreign)
;(load "./c_code/evaluate.lisp")
;(ff:def-foreign-call return_objs ((pc :int fixnum)
;				  (iteration :int fixnum)
;				  (f :foreign-address array))
;		     :returning :int)
(setf *objs-from-c* (make-array 4 :element-type `double-float))


;;; The following functions perform evaluate
(defun evaluate (designs iteration pc)
  (cond ((endp designs) nil)
	(t (format t "Creating netlist...~%")
	   (create-netlist (add-joints-to-design (car designs)))
	   (format t "calling c_code...~%")
	   (cond ((zerop (return_objs pc iteration *objs-from-c*))
		  (setf (sc-evaluations (car designs)) *obj-constraints*))
		 (t (format t "return from c_code...~%")
		    (let* ((Kxx (aref *objs-from-c* 0))
			   (Kyy (aref *objs-from-c* 1))
			   (By (aref *objs-from-c* 2))
			   (My (aref *objs-from-c* 3))
			   (electro-params (find-electro-params 
					    (sc-embodiments (car designs))
					    (sc-components (car designs))))
			   (A_c (car electro-params))
			   (g0 (cadr electro-params))
			   (C0 (cond ((zerop g0) 0)
				     (t (/ (* A_c *epsilon*) g0))))
			   (Sy (calc-sensitivity-y My Kyy C0 g0)))
		      (setf (sc-evaluations (car designs))
			    (list (calc-b-b-area (car designs))
				  (/ 1 Sy)
				  (calc-a-min By My Sy)
				  (/ 1 (calc-a-max Kyy My C0 g0 Sy)))))))
	   (evaluate (cdr designs) iteration pc))))


(defun calc-b-b-area (design)
  (do* ((coords nil (mapcar #'eval (fp-coord (car fps))))
	(max-x 0 (cond ((and (numberp (car coords)) (> (car coords) max-x)) 
			(car coords)) (t max-x)))
	(max-y 0 (cond ((and (numberp (cadr coords)) (> (cadr coords) max-y))
			(car coords)) (t max-y))) 
	(min-x 0 (cond ((and (numberp (car coords)) (< (car coords) min-x))
			(car coords)) (t min-x))) 
	(min-y 0 (cond ((and (numberp (cadr coords)) (< (cadr coords) min-y))
			(cadr coords)) (t min-y))) 
	(fps (sc-graph design) (cdr fps)))
      ((endp fps) (* (- max-x min-x) (- max-y min-y)))))

(defun find-electro-params (ebs comps &optional (A_c 0) (g0 0))
  (cond ((endp ebs) (list A_c g0))
	((or (equal (car ebs) 'h-electrostatic-gap)
	     (equal (car ebs) 'v-electrostatic-gap))
	 (list (+ A_c (* 2 2.0e-6 (third (cadar comps)) (fifth (cadar comps))))
	       (fourth (cadar comps))))
	(t (find-electro-params (cdr ebs) (cdr comps) A_c g0))))
(defun calc-sensitivity-y  (My Kyy C0 g0) 
  (cond ((zerop g0) (/ 1 (second *obj-constraints*)))
	(t
	 (/ (* 2 C0 My *V_m*) (* (+ (* 2 C0) *C_para*) Kyy g0)))))
(defun calc-a-min (By My Sy)
  (cond ((zerop Sy) (third *obj-constraints*))
	(t
	 (sqrt (+ (/ (* *Vn_circuit* *Vn_circuit*) (* Sy Sy)) 
		  (/ (* 4 *Boltzman_K_b* *Temp* By *freq_range*) 
		     (* My My)))))))
(defun calc-a-max (Kyy My C0 g0 Sy)
  (cond ((zerop g0) (/ 1 (fourth *obj-constraints*)))
	(t
	 (let* ((E0 (/ (* C0 *V_m* *V_m*) 2))
		(D (expt (- (* E0 g0 g0 g0 (sqrt (* Kyy Kyy Kyy)) 
			       (sqrt (+ E0 (* g0 g0 Kyy)))) 
			    (* E0 g0 g0 g0 g0 Kyy Kyy)) (/ 1 3)))
		(R (sqrt (- (+ 1 (/ (* 2 D) (* Kyy g0 g0))) (/ (* 2 E0) D)))))
	   (cond ((or (= 1 R) (typep R 'complex))
		  (/ 1 (fourth *obj-constraints*)))
		 (t
		  (/ (* Kyy g0 R (- 1 (/ (* 4 E0) (* Kyy g0 g0 (- 1 (* R R)) 
						     (- 1 (* R R))))))
		     My)))))))
    


;;; This function takes the linked list and actuator data and
;;; creates a netlist of the format recognized by Analogy SABER
;;; software.
(defun create-netlist (design)
  (setf *gensym-counter* 1)
  (setf *global-ground* nil)
  (with-open-file 
   (ofile (make-pathname ;:directory *evaluate-dir*
			 :name "config.sin")
	  :direction :output
	  :if-does-not-exist :create
	  :if-exists :supersede)
   (princ (format nil "vsine.vsine1 p:_n3003 m:0 = offset = 15,") ofile)
   (princ (format nil " ph =90, ac=(1,0), ampl=10, f=10k~%v.v1") ofile)
   (princ (format nil " p:_n3103 m:0 = dc=5~%") ofile)
   (do ((i 0 (1+ i)))
       ((= i (length (sc-embodiments design))))
     (write-mems-component i (sc-graph design) (sc-embodiments design)
			   (sc-components design) ofile))))


(defun write-mems-component (eb-num fps ebs comps ofile)
  (cond ((equal (nth eb-num ebs) 'h-beam)
	 (princ (format nil "beam.beam_~D_ " eb-num) ofile)
	 (write-comp-details 
	  '(("x_a" "y_a" "phi_a" "v_a" "Xa" "Ya" "PHIa") 
	    ("x_b" "y_b" "phi_b" "v_b" "Xb" "Yb" "PHIb"))
	  eb-num fps ebs (backcons 0 (second (nth eb-num comps))) ofile))
	((equal (nth eb-num ebs) 'v-beam)
	 (princ (format nil "beam.beam_~D_ " eb-num) ofile)
	 (write-comp-details 
	  '(("x_a" "y_a" "phi_a" "v_a" "Xa" "Ya" "PHIa") 
	    ("x_b" "y_b" "phi_b" "v_b" "Xb" "Yb" "PHIb"))
	  eb-num fps ebs (backcons 90 (second (nth eb-num comps))) ofile))
	((equal (nth eb-num ebs) 'h-electrostatic-gap)
	 (princ (format nil "combdrive_x.combdrive_x_~D_ " eb-num) ofile)
	 (write-comp-details 
	  '(("x_r" "y_r" "phi_r" "v_r" "Xr" "Yr" "PHIr") 
	    ("x_s" "y_s" "phi_s" "v_s" "Xs" "Ys" "PHIs"))
	  eb-num fps ebs (second (nth eb-num comps)) ofile))
	((equal (nth eb-num ebs) 'v-electrostatic-gap)
	 (princ (format nil "combdrive_y.combdrive_y_~D_ " eb-num) ofile)
	 (write-comp-details 
	  '(("x_r" "y_r" "phi_r" "v_r" "Xr" "Yr" "PHIr") 
	    ("x_s" "y_s" "phi_s" "v_s" "Xs" "Ys" "PHIs"))
	  eb-num fps ebs (second (nth eb-num comps)) ofile))
	((equal (nth eb-num ebs) 'mass)
	 (princ (format nil "plate_mass.plate_mass_~D_ " eb-num) ofile)
	 (princ (format nil "~{~A:freeNet~D~D ~}"
			(do ((i 50 (1+ i))
			     (items nil (append (list (car port) eb-num i)
						items))
			     (port (list "x_se" "y_se" "phi_se" "v_se" "Xse" 
					 "Yse" "PHIse" "x_sw" "y_sw" "phi_sw" 
					 "v_sw" "Xsw" "Ysw" "PHIsw" "x_nw"
					 "y_nw" "phi_nw" "v_nw" "Xnw" "Ynw" 
					 "PHInw") (cdr port)))
			    ((endp port) items))) ofile)
	 (write-comp-details 
	  '(("x_ne" "y_ne" "phi_ne" "v_ne" "Xne" "Yne" "PHIne") 
	    ("x_t" "y_t" "phi_t" "v_t" "Xt" "Yt" "PHIt") 
	    ("x_r" "y_r" "phi_r" "v_r" "Xr" "Yr" "PHIr")
	    ("x_b" "y_b" "phi_b" "v_b" "Xb" "Yb" "PHIb") 
	    ("x_l" "y_l" "phi_l" "v_l" "Xl" "Yl" "PHIl"))
	  eb-num fps ebs (second (nth eb-num comps)) ofile))
	((equal (nth eb-num ebs) 'joint)
	 (princ (format nil "joint.joint_~D_ " eb-num) ofile)
	 (write-comp-details 
	  '(("x_n" "y_n" "phi_n" "vn" "Xn" "Yn" "PHIn") 
	    ("x_w" "y_w" "phi_w" "vw" "Xw" "Yw" "PHIw")	    
	    ("x_s" "y_s" "phi_s" "vs" "Xs" "Ys" "PHIs") 
	    ("x_e" "y_e" "phi_e" "ve" "Xe" "Ye" "PHIe"))
	  eb-num fps ebs (second (nth eb-num comps)) ofile))))


(defun write-comp-details (node_vars eb-num fps ebs values ofile)
  (do* ((connect-fp nil (port-connects-to (list eb-num port-num) fps))
	(node-prefix 
	 nil 
	 (cond ((= (length (fp-index connect-fp)) 1) 
		(mapcar #'(lambda (x) (format nil "freeNet~D~D~D" 
					      (caar (fp-index connect-fp)) 
					      (cadar (fp-index connect-fp))
					      x)) '(0 1 2 3 4 5 6)))
	       ((and (member 'goal (fp-index connect-fp))
		     (equal 'source (fp-direct connect-fp)))
		(mapcar #'(lambda (x) (format nil "_n~D0~D" *max-num-ebs* x))
			'(0 1 2 3 4 5 6)))
	       ((and (member 'goal (fp-index connect-fp))
		     (equal 'sink (fp-direct connect-fp)))
		(mapcar #'(lambda (x) (format nil "_n~D0~D" (1+ *max-num-ebs*)
					      x))
			'(0 1 2 3 4 5 6)))
	       ((member 'ground (fp-index connect-fp))
		(append
		 (mapcar #'(lambda (x) (format nil "_n~D~D~D" 
					      (caar (fp-index connect-fp)) 
					      (cadar (fp-index connect-fp))
					      x)) '(1 2 3 4))
		 (cond (*global-ground*
			(mapcar #'(lambda (x) 
				    (format nil "freeNet~D~D~D" 
					    (caar (fp-index connect-fp)) 
					    (cadar (fp-index connect-fp))
					    x)) '(5 6 7)))
		       (t (setf *global-ground* t) (list "0" "0" "0")))))
	       (t (mapcar #'(lambda (x) (format nil "_n~D~D~D" 
						(caar (fp-index connect-fp)) 
						(cadar (fp-index connect-fp))
						x)) '(0 1 2 3 4 5 6)))))
	(anchors nil (cond ((member 'ground (fp-index connect-fp))
			    (cons node-prefix anchors))
			   (t (cons nil anchors))))
	(write-dummy-var nil 
			 (princ (format nil "~{~A:~A ~}" 
					(apply 
					 #'append
					 (mapcar #'(lambda (x y) (list x y))
						 (nth port-num node_vars)
						 node-prefix))) ofile))
	(port-num 0 (1+ port-num)))
      ((= port-num (length (eb-const-param (eval (nth eb-num ebs)))))
       (write-instantiated-values (eb-data (eval (nth eb-num ebs))) values
				  ofile)
       (write-anchors anchors ofile))))

(defun write-instantiated-values (variables values ofile)
  (do ((write-dummy-var (princ (format nil "= ~(~S~)= ~(~S~)" (car variables) 
				       (car values)) ofile)
			(princ (format nil ", ~(~S~)= ~(~S~)" (car variables) 
				       (car values)) ofile))
       (values (cdr values) (cdr values))
       (variables (cdr variables) (cdr variables)))
      ((endp values) (princ (format nil "~%") ofile))))

(defun write-anchors (anchors ofile)
  (cond ((endp anchors))
	((null (car anchors)) (write-anchors (cdr anchors) ofile))
	(t (princ (format nil "anchor.anchor_~D_ " *gensym-counter*) ofile)
	   (gensym)
	   (princ (format nil "x:~A y:~A phi:~A~%" (caar anchors) 
			  (cadar anchors) (caddar anchors)) ofile))))


(defun add-joints-to-design (design)
  (do* ((connected-ebs nil (mapcar #'(lambda (x) 
				       (cond ((consp x) 
					      (nth (car x) 
						   (sc-embodiments design)))
					     (t x)))
				   (fp-index (car fp))))
	(add-joint nil (and (or (member 'v-beam connected-ebs)
				(member 'v-electrostatic-gap connected-ebs))
			    (or (member 'h-beam connected-ebs)
				(member 'h-electrostatic-gap connected-ebs))))
	(new-eb-counter (1- (length (sc-embodiments design)))
			(cond (add-joint (1+ new-eb-counter)) 
			      (t new-eb-counter)))
	(new-ebs (sc-embodiments design) 
		 (cond (add-joint (backcons 'joint new-ebs))
		       (t new-ebs)))
	(new-comps (sc-components design) 
		   (cond (add-joint (backcons (list 'joint1 (list 90) 0)
					      new-comps))
			 (t new-comps)))
	(new-fps nil (cond (add-joint (append (joint-connecting-fps 
					       connected-ebs (car fp)
					       new-eb-counter)
					      new-fps))
			   (t (cons (car fp) new-fps))))
	(fp (sc-graph design) (cdr fp)))
      ((endp fp) (make-sc :graph new-fps 
			  :embodiments new-ebs
			  :components new-comps))))


(defun joint-connecting-fps (connected-ebs fp joint-eb-num)
  (do* ((joint-fps 
	 nil (cons (car (modify-fp-in-list 
			 fp nil 
			 :index (cond (existing-ports
					(list (list joint-eb-num 
						    (car joint-ports)) 
					      (car existing-ports)))
				      (t (list (list joint-eb-num 
						     (car joint-ports)))))))
		   joint-fps))
	(joint-ports-one (mapcar
			  #'(lambda (eb port)
			      (cond ((and (or (equal eb 'v-beam) 
					      (equal eb 'v-electrostatic-gap))
					  (= (cadr port) 0)) 0)
				    ((and (or (equal eb 'h-beam) 
					      (equal eb 'h-electrostatic-gap))
					  (= (cadr port) 0)) 1)
				    ((and (or (equal eb 'v-beam) 
					      (equal eb 'v-electrostatic-gap))
					  (= (cadr port) 1)) 2)
				    ((and (or (equal eb 'h-beam)
					      (equal eb 'h-electrostatic-gap)) 
					  (= (cadr port) 1)) 3)))
			  connected-ebs 
			  (remove-if #'(lambda (x) (or (equal x 'ground)
						      (equal x 'goal))) 
				     (fp-index fp))))
	(joint-ports (append joint-ports-one 
			     (set-difference '(0 1 2 3) joint-ports-one))
		     (cdr joint-ports))
	(existing-ports (fp-index fp) (cdr existing-ports)))
      ((endp joint-ports) joint-fps)))
