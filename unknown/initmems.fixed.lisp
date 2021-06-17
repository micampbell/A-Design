;;; INIT.LISP - Contains data structures and constants used throughout the
;;; process.  This can be called with the (a-design) executable or loaded 
;;; beforehand to run a multitude of tests {just remember to comment the
;;; (load "init.lisp") in design.lisp}.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The following are constants used by the process.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(sys:resize-areas :new 10000000 :old 15000000)
;; this sets up the RAM needed to run this space-extensive program

(setf *random-seed* (make-random-state t))
(setf *random-state* *random-seed*)
;; seed the random generator so that no two runs are the same
;; save the initial seed in a separate variable such that it can be stored 
;; for a particular run.

(setf *weights* '(1.0 10000.0 1.0))
;(setf *weights* '(5.0 2.0 10.0 100.0))
;(setf *weights* '(1.0 20.0 100.0 1.0))
;; the user determined preference weighting between objectives, 
;; this includes any normalization as well.

(setf *num-of-objectives* 4)
;; the number of objectives in the design problem.

(setf *obj-constraints* (make-list *num-of-objectives* 
				   :initial-element 1000000.0))
;; the ceiling of the design spaces, any designs above this are
;; automatically eliminated from the process

(setf *attempts-to-reconstruct* 15)
;; after designs are fragmentted sometimes they are impossible to repair. This
;; constant sets how many attempts at reconstructing a design are performed 
;; before giving up on it.

(setf *design-pop* 80)
;; the maximum number of designs at any given time.

(setf *designs-per-config* 10)
;; the maximum number of designs at any given time.

(setf *pareto-cap* (/ *design-pop* 4))
;; the maximum number of designs in the pareto before pruning.

(setf *good-cap* (/ *design-pop* 4))
;; the maximum number of designs at any given time.

(setf *tot-iter* 100)
;; total number of iterations for the process.

(setf *topdesigns-num* 25)
;; the number of top designs reported for a completed run.

(setf *iter_dump_designs*  5)
;; the number of iterations at which to dump the design population

(setf *iter_magent_interact*  5)
;; the number of iterations at which to interact with user

(setf *percent-kept* 0.75)
;; the approximate percentage of designs kept from one iteration
;; to the next.

(setf *converged* 0.9)
;; the process stops when the convergence is higher than this value.

(setf *remove-similar-designs* t)
;; boolean that determines whether or not to prune designs when
;; the population caps are reached.

(setf *min-agent-pop* 1.0)
;; the minimum value an agent population can have.
;; if <= to min-agent-pop then = to min-agent-pop.

(setf *num-of-discretize-points* 20)
;; the number of points in the range that define the objective calc-range

(setf *max-num-ebs* 20)
;; the maximum number of ebs that can be put into one design

(setf *gravity* 9.81)
(setf *pi* 3.1416)
(setf *pi/2* 1.5708)
(setf *pi/4* 0.7854)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The following are structures used by the process. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The FUNCTIONAL PARAMETER, FP describes the energy state used in all 
;;; connections and ports in all the systems.  Borrowed from the Welch&Dixon
;;; representation but expanded with the interface character and direction
;;; character.  By the way, the 7 variables that make up the FP are known
;;; as characters or characteristics.
;;; Create-fp is the constructor for making an FP.   
(defstruct (fp (:constructor create-fp 
			     (&optional through across class domain coord 
					inter direct index)))
  (THROUGH nil)	;0		        ;once effort, now through
					;it's a list of lists of lists
					;list of the through variable for each
					;connection in index repeated for each
					;domain in domain
  (ACROSS nil)	;1	  		;once flow, now across 
					;it's a list of lists of lists
					;list of the time differentiation of
					;the across variable for each
					;domain in domain
  (CLASS nil)	;2			;class = {signal power material}
  (DOMAIN nil)	;3			;energy domain 
					;can be a list if more than one domain
					;= {trans, rotat, elect, hydra, therm}
					;= {trans-x, trans-y, rot-z, etc.}
  (COORD nil)	;4			;4 x 4 coord frame position
  (INTER nil)	;5			;interface = {any accepted interface 
					;symbol eg. 9/16-in-bolt}
  (DIRECT nil)	;6			;direction of energy flow 
					;= {sink, source}
  (INDEX nil)	;7			;index of components connecting to 
  )	                                ;this fp 
  

;;; The CONSTRAINT PARAMETER, CP is a functional parameter for constraints 
;;; on component connections.  It identifies the bounds that a particular
;;; FP must have to match a connection.  Any character of an FP can be 
;;; constrained.  In the through/across pair of FP is identified in TY, and
;;; its maximum magnitude is identified by MG.  If TY = across, then MG is
;;; a triple noting the maximum magnitudes of the (integral none derivative)
;;; of the across variable.
(defstruct (cp (:constructor create-cp (&optional throughrange acrossranges 
						  oper class domain coord 
						  inter direct)))
  (THROUGHRANGE nil)		       	;range of through var.
  (ACROSSRANGES nil)		        ;ranges of across vars. - triple list
  (OPER nil)				;time operator 
					;= {deriv none integ}
  (CLASS nil)				;class = {signal power material}
  (DOMAIN nil)				;energy domain 
					;= {trans, rotat, elect, hydra, therm}
  (COORD nil)		        	;4 x 4 coord frame position
  (INTER nil)				;interface = {any accepted interface 
 					;symbol eg. 9/16-in-bolt}
  (DIRECT nil)				;direction of flow = {source, sink} 
					;not what is supplied by that
  )					;component but what is required


;;; The EMBODIMENT, EB structure is used to describe all components read in 
;;; by the catalog.  Borrowed form the W&D representation with a behavior
;;; change, constraints and evaluations.  For simplifying the structure, 
;;; behavior is split into three things on this level: MG-change, PO-change, 
;;; and BG.
(defstruct eb
  data					;characteristic data for the 
					;following device
  MG-change				;matrix for overall change in 
					;magnitude of component
  PO-change				;matrix for position change of 
					;component
  const-param				;list = (DO MG-limit OT PO IT) 
					;if not constrained
					;by one of these then nil
  )


;;; The COMPONENT, COMP structure is used to describe all components read in 
;;; by the catalog.  Borrowed form the W&D representation with a behavior
;;; change, constraints and evaluations.  For simplifying the structure, 
;;; behavior is split into three things on this level: MG-change, PO-change, 
;;; and BG.
(defstruct comp 
  data                                  ;list of values of data in the EB's
  evals 				;list = (cost weight efficiency etc.)
  )


;;; The SYSTEM CONFIGURATION, SC structure holds a complete or possibly 
;;; incomplete design state.  The graph contains the information about the
;;; systems components and connectivity including components and FP's.  The
;;; c-agents holds the responsible maker-agents for the device.  The c-agents 
;;; holds the responsible fragment-agents for the device.  And evaluations
;;; contains the final evaluations of the device as determined in the
;;; evaluate stage of the process.
(defstruct sc
  graph					;list of fps' involved in design
  behavior-eq				;list of functionality of inter-
					;acting component characters 
					;in FP-ID found in graph
  embodiments                           ;list of embodiments in the design
  c-agents				;list of conceptual agents 
					;responsible for design
  components                            ;list of components in the design
  i-agents				;list of instantiation agents 
					;responsible for design
  f-agents				;list of fragment agents
					;responsible for design
  evaluations                   	;list of evaluatable criteria
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The interface-list contains the possible matches of interface types.    ;;;
;;; If an interface doesn't match with any on the list than it is assumed   ;;;
;;; to only match with itself.                                              ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setf *interface-list* '((east west) 
			 (north south) 
			 (up down)))
		       

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The following are the files and design directories used by the process.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setf *output-dir* '(:relative "MEMSoutput"))
;; directory name of output files
(setf *evaluate-dir* '(:relative "c_code"))
;; directory name of SABER evaluation files
(setf *library-dir* '(:relative "libraryNODAS1"))
;; directory name of where the library of components/embodiments is stored
(setf *code-dir* '(:relative "codeMEMS"))
;; directory name of domain specific code mostly agent code

(setf *library-file* 
      (make-pathname :directory *library-dir* :name "Embodiments"))

;(setf *input-agents-file* (make-pathname :directory '(:relative "output")
;					 :name "agents"
;					 :type "out"))
(setf *input-agents-file* (make-pathname :directory *code-dir*
					 :name "initagents"
					 :type "lisp"))


(setf *input-designs-file* nil)

(setf *input-optimal-designs-file* nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Load in the other lisp files involved in the process,
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(load "codeGeneral/design.lisp")
(load "codeGeneral/create.lisp")
(load "codeGeneral/io.lisp")
(load "codeGeneral/functions.lisp")
(load "codeGeneral/magents.lisp")
(load "codeGeneral/trend.lisp")
(load "codeGeneral/update.lisp")
(load (make-pathname :directory *code-dir* :name "cagents"))
(load (make-pathname :directory *code-dir* :name "fagents"))
(load (make-pathname :directory *code-dir* :name "iagents"))
(load (make-pathname :directory *code-dir* :name "equer"))
(load (make-pathname :directory *code-dir* :name "evaluate"))

(setf *eb-library* (read-library))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Set the all-important grounds for the system
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setf *new-connects*
      (build-fps 
       '(((nil nil nil nil) ((0 0 0) (0 0 0) (0 0 0) (0 0 0)) power 
	  (trans-x trans-y rot-z elect) nil 
	  (west north east south up down) sink (ground)))))
      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Finally, stats the design problem at hand in terms of inputs and
;;; outputs of the system.  nil can be placed anywhere to denote
;;; no particular specification.	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setf *io-fps*
  (build-fps 
   '(((nil nil nil nil) 
      ((nil nil (goal (0 0))) (nil nil (goal (0 1)))
       (nil nil (goal (0 0))) nil)
      power (trans-x trans-y rot-z elect) (0 0 0 1) (down) sink (goal))
     ((nil nil nil nil) (nil nil nil ((goal (0 25)) nil nil))
      power (trans-x trans-y rot-z elect) nil 
      (west north east south up down) source (goal)))))
