;; Io.lisp - contains all the input and output functions
;;
;; READ FUNCTIONS
;;
(defun read-library ()
  (cond (*library-file*
	 (with-open-file (ifile *library-file* :direction :input)
			 (read-library-elements ifile)))
	(t (format t "No library file specified~%"))))

(defun read-library-elements (ifile)	  
  (let ((data (read ifile nil)))
    (cond (data
	   (set (first data) 
		(make-eb :data (second data)
			 :MG-change (third data)   
			 :PO-change (fourth data)   
			 :class (fifth data)
			 :domain (sixth data)
			 :inter (seventh data)
			 :direct (eighth data)
			 :opers (ninth data)
			 ))
	   (cons (first data) (read-library-elements ifile)))
	  (t nil))))

(defun read-agents ()
  (cond (*input-agents-file*
	 (with-open-file (ifile *input-agents-file* :direction :input)
	   (read ifile nil)))
	(t 
	 (with-open-file (ifile "initagents.lisp" :direction :input)
	   (read ifile nil)))))

(defun read-designs ()
  (cond (*input-designs-file*
	 (build-scs
	  (with-open-file (ifile *input-designs-file* :direction :input)
			  (do ((scs nil (cons sc scs))
			       (sc (read ifile nil) (read ifile nil)))
			      ((null sc) scs)))))
	(t nil)))

(defun read-optimal-designs ()
  (cond (*input-optimal-designs-file*
	 (with-open-file (ifile *input-optimal-designs-file* :direction :input)
	   (read ifile nil)))
	(t nil)))

;;;
;;; BUILD FUNCTIONS
;;;
(defun build-scs (data)
  (cond ((endp data) nil)
	(t
	 (cons
	  (make-sc :graph (build-fps (first (car data)))
		   :behavior-eq (second (car data))
		   :embodiments (third (car data))
		   :c-agents (fourth (car data))
		   :components (fifth (car data))
		   :i-agents (sixth (car data))
		   :f-agents (seventh (car data))
		   :evaluations (eighth (car data)))
	  (build-scs (cdr data))))))

(defun build-fps (data)
  (cond ((endp data) nil)
	(t
	 (cons 
	  (apply 'create-fp (car data))
	  (build-fps (cdr data))))))

;;
;; WRITE FUNCTIONS
;;
(defun write-iter-info (iter pareto good poor radius agent-data pc todo taboo)
  (cond ((zerop iter)
	 (format t "Population = ~D.~%" *design-pop*) 
	 (format t "No. of Iterations = ~D.~%~%" *tot-iter*)
	 (with-open-file (ofile (make-pathname :directory *output-dir*
					       :name "iter.out")
			  :direction :output 
			  :if-does-not-exist :create
			  :if-exists :rename)
	   (princ (format nil "Population = ~D.~%" *design-pop*) ofile)
	   (princ (format nil "No. of Iterations = ~D.~%~%" *tot-iter*) ofile)
	   (princ (format nil "Random Seed is ~A.~%~%" *random-seed*) ofile)))
	(t
	 (format t "Iteration ~D.~%" iter)
	 (format t "Population = ~D.~%" 
		 (+ (length pareto) (length good) (length poor))) 
	 (format t "Pareto has ~D member~:P.~%" (length pareto))
	 (format t "Pareto changed by ~D.~%" pc)
	 (format t "   The ave. pareto values are ~A.~%" 
		 (average (return-evals pareto)))
	 (format t "   The best pareto values are ~A.~%"
		 (list-min (return-evals pareto)))
	 (format t "Good has ~D member~:P.~%" (length good))
	 (format t "   The radius is ~A.~%" radius)
	 (format t "Poor has ~D member~:P.~%" (length poor))
	 (format t "Todo has ~D member~:P.~%" (length todo))
	 (format t "Taboo has ~D member~:P.~%" (length taboo))
;	 (format t "Concept Agents: ave = ~F st.dev. = ~F total = ~F~%" 
;		 (average (mapcar 'cdr (car agent-data)))
;		 (standard-deviation (mapcar 'cdr (car agent-data)))
;		 (find-population (car agent-data)))
;	 (format t "Instantiation Agents: ave = ~F st.dev. = ~F total = ~F~%" 
;		 (average (mapcar 'cdr (cadr agent-data)))
;		 (standard-deviation (mapcar 'cdr (cadr agent-data)))
;		 (find-population (cadr agent-data)))
;	 (format t "Fragment Agents: ave = ~F st.dev. = ~F total = ~F~%" 
;		 (average (mapcar 'cdr (caddr agent-data)))
;		 (standard-deviation (mapcar 'cdr (caddr agent-data)))
;		 (find-population (caddr agent-data)))
	 (with-open-file (ofile (make-pathname :directory *output-dir*
					       :name "iter.out")
			  :direction :output 
			  :if-does-not-exist :create
			  :if-exists :append)
	   (princ (format nil "Iteration ~D.~%" iter) ofile)
	   (princ (format nil "Population = ~D.~%" 
			  (+ (length pareto) (length good) (length poor)))
		  ofile)
	   (princ (format nil "Pareto has ~D member~:P.~%" (length pareto)) 
		  ofile)
	   (princ (format nil "Pareto changed by ~D.~%" pc) ofile)
	   (princ (format nil "   The ave. pareto values are ~A.~%" 
			  (average (return-evals pareto))) ofile)
	   (princ (format nil "   The best pareto values are ~A.~%"
			  (list-min (return-evals pareto))) ofile)
	   (princ (format nil "Good has ~D member~:P.~%" (length good)) ofile)
	   (princ (format nil "   The radius is ~A.~%" radius) ofile)
	   (princ (format nil "Poor has ~D member~:P.~%" (length poor))
		  ofile)
	   (princ (format nil "Todo has ~D member~:P.~%" (length todo)) ofile)
	   (princ (format nil "Taboo has ~D member~:P.~%~%" (length taboo)) 
		  ofile)))))



(defun write-design-data (iteration pareto pc good poor radius agent-data todo taboo)
  ;; PARETO.OUT
  (with-open-file (ofile (make-pathname :directory *output-dir*
					:name "pareto.out")
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :append)
    (cond ((null pareto) nil)
	  (t
	   (mapcar #'(lambda (x) (mapcar 
				  #'(lambda (y) 
				      (princ (format nil "~F~10,10T" y) ofile))
				  (cons iteration (sc-evaluations (eval x))))
		       (princ (format nil "~%") ofile))
		   pareto))))
  ;; GOOD.OUT
  (with-open-file (ofile (make-pathname :directory *output-dir*
					:name "good.out") 
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :append)
    (cond ((null good) nil)
	  (t
	   (mapcar #'(lambda (x) (mapcar 
				  #'(lambda (y) 
				      (princ (format nil "~F~10,10T" y) ofile))
				  (cons iteration (sc-evaluations (eval x))))
		       (princ (format nil "~%") ofile))
	    good))))
  ;; POOR.OUT
  (with-open-file (ofile (make-pathname :directory *output-dir*
					:name "poor.out")
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :append)
    (cond ((null poor) nil)
	  (t
	   (mapcar #'(lambda (x) (mapcar 
				  #'(lambda (y) 
				      (princ (format nil "~F~10,10T" y) ofile))
				  (cons iteration (sc-evaluations (eval x))))
			     (princ (format nil "~%") ofile))
		   poor))))
  ;; PARETOAVG.OUT
  (with-open-file (ofile (make-pathname :directory *output-dir*
					:name "paretoavg.out")
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :append)
    (cond ((null pareto) nil)  
	  (t
	   (mapcar #'(lambda (y) 
		       (princ (format nil "~F~10,10T" y) ofile))
		   (cons iteration (average (return-evals pareto))))
	   (princ (format nil "~%") ofile))))
  ;; PARETOCHG.OUT
  (with-open-file (ofile (make-pathname :directory *output-dir*
					:name "paretochg.out")
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :append)
    (cond ((null pareto) nil)  
	  (t
	   (mapcar #'(lambda (y) 
		       (princ (format nil "~F~10,10T" y) ofile))
		   (list iteration pc))
	   (princ (format nil "~%") ofile))))
  ;; PARETOSTDEV.OUT
  (with-open-file (ofile (make-pathname :directory *output-dir*
					:name "paretostdev.out")
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :append)
    (cond ((null pareto) nil)
	  (t
	   (mapcar #'(lambda (y) 
		       (princ (format nil "~F~10,10T" y) ofile))
		   (cons iteration (standard-deviation (return-evals pareto))))
	   (princ (format nil "~%") ofile))))
  ;; LENGTHS.OUT
  (with-open-file (ofile (make-pathname :directory *output-dir*
					:name "lengths.out")
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :append)
    (mapcar #'(lambda (y) 
		(princ (format nil "~F~10,10T" y) ofile))
	    (list iteration (length pareto) (length good) (length poor)
		  (length todo) (length taboo)))
    (princ (format nil "~%") ofile))
  ;; TOP_DATA.OUT
  (with-open-file (ofile (make-pathname :directory *output-dir*
					:name "top_data.out")
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :append)    
    (cond ((null (append pareto good)) nil)
	  (t
	   (mapcar #'(lambda (x)
		       (mapcar #'(lambda (y) 
				   (princ (format nil "~F~10,10T" y) ofile))
			       (cons iteration (sc-evaluations (eval x))))
		       (princ (format nil "~F~10,10T~%" 
				      (apply #'+ (mapcar '* 
							 (car *M-weights-M*)
							 (sc-evaluations 
							  (eval x))))) ofile))
		   (order-designs (append pareto good) *topdesigns-num*)))))
  ;; CAGENTDATA.OUT
;  (with-open-file (ofile (make-pathname :directory *output-dir*
;					:name "cagentdata.out")
;		   :direction :output
;		   :if-does-not-exist :create
;		   :if-exists :append)
;    (mapcar #'(lambda (y) 
;		(princ (format nil "~F~10,10T" y) ofile))
;	    (list iteration
;		  (average (mapcar 'cdr (first agent-data)))
;		  (standard-deviation (mapcar 'cdr (first agent-data)))))
;    (princ (format nil "~%") ofile))
;  ;; IAGENTDATA.OUT
;  (with-open-file (ofile (make-pathname :directory *output-dir*
;					:name "iagentdata.out")
;		   :direction :output
;		   :if-does-not-exist :create
;		   :if-exists :append)
;    (mapcar #'(lambda (y) 
;		(princ (format nil "~F~10,10T" y) ofile))
;	    (list iteration
;		  (average (mapcar 'cdr (second agent-data)))
;		  (standard-deviation (mapcar 'cdr (second agent-data)))))
;    (princ (format nil "~%") ofile))
;  ;; FAGENTDATA.OUT
;  (with-open-file (ofile (make-pathname :directory *output-dir*
;					:name "fagentdata.out")
;		   :direction :output
;		   :if-does-not-exist :create
;		   :if-exists :append)
;    (mapcar #'(lambda (y) 
;		(princ (format nil "~F~10,10T" y) ofile))
;	    (list iteration
;		  (average (mapcar 'cdr (third agent-data)))
;		  (standard-deviation (mapcar 'cdr (third agent-data)))))
;    (princ (format nil "~%") ofile))
  ;; RADIUS.OUT
  (with-open-file (ofile (make-pathname :directory *output-dir*
					:name "radius.out")
			 :direction :output
			 :if-does-not-exist :create
			 :if-exists :append)
		  (mapcar #'(lambda (y) 
			      (princ (format nil "~F~10,10T" y) ofile))
			  (list iteration
				(cond ((null radius) 0.0) (t radius)) 
				(length good)))
		  (princ (format nil "~%") ofile))
  ;; CONCAVITY.OUT
  (with-open-file (ofile (make-pathname :directory *output-dir*
					:name "concavity.out")
			 :direction :output
			 :if-does-not-exist :create
			 :if-exists :append)
		  (cond ((null pareto) nil)
			(t
			 (mapcar #'(lambda (y) 
				     (princ (format nil "~F~10,10T" y) ofile))
				 (cons iteration
				       (concavity pareto)))
			 (princ (format nil "~%") ofile))))
  ;; DESIGNS_N.OUT
  (cond ((zerop (mod iteration *iter_dump_designs*))
	 (with-open-file 
	  (ofile (make-pathname :directory *output-dir*
				:name (format nil "designs_~D.out" iteration)
				:version :newest)
	  :direction :output
	  :if-does-not-exist :create
	  :if-exists :new-version)
	  (mapcar #'(lambda (x) 
		      (print 
		       (list 
			(mapcar 
			 #'(lambda (xx) (list (fp-through xx) (fp-across xx) 
					      (fp-class xx) (fp-domain xx) 
					      (fp-coord xx) (fp-inter xx) 
					      (fp-direct xx) (fp-index xx)))
			 (sc-graph x))
			(sc-behavior-eq x) 
			(sc-embodiments x) 
			(sc-c-agents x) 
			(sc-components x)
			(sc-i-agents x)
			(sc-f-agents x)
			(sc-evaluations x)) ofile))
		  (append pareto good poor)))
	 (with-open-file (ofile (make-pathname 
				 :directory *output-dir*
				 :name (format nil "agents_~D.out" iteration)
				 :version :newest)
				:direction :output
				:if-does-not-exist :create
				:if-exists :new-version)
			 (print agent-data ofile)))))


(defun print-table (data iteration ofile)
  (mapcar #'(lambda (y) (princ (format nil "~F~10,10T" y) ofile))
	  (cond (iteration
		 (cons iteration data))
		(t data)))
  (princ (format nil "~%") ofile))

  
(defun write-results (designs agent-data)
  (with-open-file 
   (ofile (make-pathname :directory *output-dir*
			 :name "alldesigns.out"
			 :version :newest)
	  :direction :output
	  :if-does-not-exist :create
	  :if-exists :new-version)
   (mapcar #'(lambda (x) 
	       (print 
		(list 
		 (mapcar 
		  #'(lambda (xx) (list (fp-through xx) (fp-across xx) 
				       (fp-class xx) (fp-domain xx) 
				       (fp-coord xx) (fp-inter xx) 
				       (fp-direct xx) (fp-index xx)))
		  (sc-graph x))
		 (sc-behavior-eq x) 
		 (sc-embodiments x) 
		 (sc-c-agents x) 
		 (sc-components x)
		 (sc-i-agents x)
		 (sc-f-agents x)
		 (sc-evaluations x)) ofile))
	    designs))
  (with-open-file (ofile (make-pathname :directory *output-dir*
					:name "agents.out"
					:version :newest)
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :new-version)
    (print agent-data ofile))
  (with-open-file (ofile (make-pathname :directory *output-dir*
					:name "topdesigns.out"
					:version :newest)
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :new-version)
    (mapcar #'(lambda (x) 
		(print
		 (list
		  (mapcar 	
		   #'(lambda (xx) (list (fp-through xx) (fp-across xx) 
					(fp-class xx) (fp-domain xx) 
					(fp-coord xx) (fp-inter xx) 
					(fp-direct xx) (fp-index xx)))
		   (sc-graph x)) 
		  (sc-behavior-eq x) 
		  (sc-embodiments x) 
		  (sc-c-agents x) 
		  (sc-components x)
		  (sc-i-agents x)
		  (sc-f-agents x)
		  (sc-evaluations x)) ofile))
	    (order-designs designs *topdesigns-num*))))


