;;; INIT.LISP - Contains data structures and constants used throughout the
;;; process.  This can be called with the (a-design) executable or loaded 
;;; beforehand to run a multitude of tests {just remember to comment the
;;; (load "control.init") in design.lisp}.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The following are constants used by the process.  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(sys:resize-areas :new 100000000 :old 200000000)
;;(sys::resize-areas :old 210000000 :verbose t :global-gc t)
;; this sets up the RAM needed to run this space-extensive program


(setf *random-seed* (make-random-state t))
(setf *random-state* *random-seed*)
;; seed the random generator so that no two runs are the same
;; save the initial seed in a separate variable such that it can be stored  
;; for a particular run.

(setf *num-of-objectives* 4)
;; the number of objectives in the design problem.

(setf *obj-constraints* (make-list *num-of-objectives* 
				   :initial-element 1000000.0))
;; the ceiling of the design spaces, any designs above this are
;; automatically eliminated from the process

(setf *obj-constraints* '(1000.0 1000.0 100000.0 100000.0))
;; the ceiling of the design spaces, any designs above this are
;; automatically eliminated from the process

(setf *attempts-to-reconstruct* 15)
;; after designs are fragmentted sometimes they are impossible to repair. This
;; constant sets how many attempts at reconstructing a design are performed 
;; before giving up on it.

(setf *design-pop* 100)
;; the maximum number of designs at any given time.

(setf *designs-per-config* 4)
;; the maximum number of designs at any given time.

(setf *pareto-cap* (/ *design-pop* 3))
;; the maximum number of designs in the pareto before pruning.

(setf *good-cap* (/ *design-pop* 4))
;; the maximum number of designs at any given time.

(setf *tot-iter* 20)
;; total number of iterations for the process.

(setf *topdesigns-num* 25)
;; the number of top designs reported for a completed run.

(setf *iter_dump_designs*  10)
;; the number of iterations at which to dump the design population

(setf *percent-kept* 0.75)
;; the approximate percentage of designs kept from one iteration
;; to the next.

(setf *converged* 0.9)
;; the process stops when the convergence is higher than this value.

(setf *remove-similar-designs* t)
;; boolean that determines whether or not to prune designs when
;; the population caps are reached.

(setf *min-agent-U* 0.1)
;; the minimum value an agent population can have.
;; if <= to min-agent-pop then = to min-agent-pop.

(setf *num-of-discretize-points* 20)
;; the number of points in the range that define the objective calc-range

(setf *max-num-ebs* 15)
;; the maximum number of ebs that can be put into one design

(setf *gravity* 9.81)
(setf *pi* 3.1416)
(setf *pi/4* 0.7854)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The following are structures used by the process. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The FUNCTIONAL PARAMETER, FP describes the energy state used in all 
;;; connections and ports in all the systems.  Borrowed from the Welch&Dixon
;;; representation but expanded with the interface character and direction
;;; character.  By the way, the 9 variables that make up the FP are known
;;; as characters or characteristics.
;;; Create-fp is the constructor for making an FP.   
(defstruct (fp (:constructor create-fp 
			     (&optional through across class domain coord 
					inter direct index)))
  (THROUGH nil)	;0		        ;once effort, now through
					;it's a list of the 8 through 
					;variables for each of the domains
					;trans-x trans-y trans-z rot-x rot-y
					;rot-z elect hyra
  (ACROSS nil)	;1	  		;once flow, now across 
					;it's a list of 8 triples - one for
					;each domain. The triples are: the
					;deriv of across, the across, and the
					;integral of the across
  ;; Each element in the through and across lists are either:
  ;; nil - which corresponds to unbound
  ;; bound - value converges to finite number, but number is not known
  ;; # - value has a specific v
  ;; (# #) - range
  ;; in addition to these four possibilities each can be prefaced by
  ;; "goal" - citing it not as the actual value, but what is desired
  ;; when a goal state is met it becomes "goal-met"
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
  )


;;; Hey, we don't need CP anymore. just put all the data in the eb's!

;;;***************************************************************************
;;; The CONSTRAINT PARAMETER, CP is a functional parameter for constraints 
;;; on component connections.  It identifies the bounds that a particular
;;; FP must have to match a connection and provides the information needed 
;;; to update a design.
;(defstruct (cp (:constructor create-cp (&optional domain inter direct 
;						  prime-oper sec-opers)))
;  ;;; new idea
;  domain				; a symbol of the 1-D energy domain
;  inter					; a symbol from interface-list
;  direct				; a symbol either source, sink, or nil
;  opers				; a list of lists made up of the 
;					; following elements
;					; a list of one or more operator types
;					; d, r, i, t, a
;					; d = differentiator,
;					; i = integrator, 
;					; r = dissipator
;					; t = transformer,
;					; a = anti-coupler
;					; the port that this 1-d energy to
;					; changed to 
;					; the domain of that port
;  )

;;; The EMBODIMENT, EB structure is used to describe all components read in 
;;; by the catalog.  Borrowed form the W&D representation with a behavior
;;; change, constraints and evaluations.  For simplifying the structure, 
;;; behavior is split into three things on this level: MG-change, PO-change, 
;;; and BG.

;;;***********************************************************************************************************************************************************
;;; the PO-change in the embodiments can be a list of lists.Ech sub'list
;;;corresponds to each port of the embodiment.The moment one embodiment is
;;;connected to a "chain" of embodiments which have formed a part of the design then that corresponding "sub-list" would be updated using the corresponding transformation matrix.That way we can always know where each port of that embodiment is in 3D space wrt  origin.
;;;***********************************************************************************************************************************************************

(defstruct eb
  data					;characteristic data for the 
					;following device
  MG-change				;matrix for overall change in 
					;magnitude of component
  PO-change				;matrix for position change of 
					;component
;; we don't need this anymore. Go through code and remove all "cp-" references
  ;;  const-param				;list = (DO MG-limit OT PO IT) 
;;					;if not constrained
;;					;by one of these then nil
  class					;a list of the classes for each port
					;currently everything is power, but
					;for simplicity all component have nil
  domain				;a list of the domains for each port
					; a symbol of the 1-D energy domain
  inter					;a list of the interfaces for each port
					; a symbol from interface-list
  direct				;a list of the (required directions)  for each port
					; a symbol either source, sink, or nil
  opers					; a list of lists made up of the 
					; following elements
					; a list of one or more operator types
					; d, r, i, t, a
					; d = differentiator,
					; i = integrator, 
					; r = dissipator
					; t = transformer,
					; a = anti-coupler
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
  embodiments                           ;list of emobidments in the design
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
;;; If an interface doesn't match with any on the list than it is assumed to;;;
;;; only match with itself.                                                 ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setf *interface-list* '(((belt pulley))
                         ;((gear-teeth gear-teeth) . gear-teeth)
                         ;((male-pipe female-pipe))
                         ;((pipe pipe))
                         ((chain sprocket-teeth))
                         ((eye dialface))
                         ((feet flat-user-interface))
                         ((hand flat-user-interface))
                         ((hand handle-user-interface))
                         ((hand button-user-interface))
                         ((bolt hole) . bolt)
                         ((bolt belt) . bolt)
                         ((bolt bolt) . bolt)
                         ((wire wire) . wire)
                         ((gear-teeth-pos gear-teeth-neg))
                         ((shaft-surface shaft-surface) . shaft-surface)
                         ;((shaft-neg shaft-pos) . shaft-surface)
                         ;((shaft-hole-pos shaft-neg))
                         ;((shaft-hole-neg shaft-pos))
                         ((shaft-surface shaft-hole))
                          ((male-pipe-pos female-pipe-neg))
                         ))

		       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The following are the files and design desicription used by the process.;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setf *output-dir* '(:relative "EMoutput"))
;; directory name of output files
(setf *library-dir* '(:relative "libraryEM"))
;; directory name of where the library of components/embodiments is stored
(setf *code-dir* '(:relative "codeEM"))
;; directory name of domain specific code mostly agent code

(setf *library-file* 
      (make-pathname :directory *library-dir* :name "Embodiments.lisp"))

(setf *input-agents-file* (make-pathname :directory '(:relative "output")
					 :name "agents"
					 :type "out"))
(setf *input-designs-file* (make-pathname :directory '(:relative "output")
					  :name "alldesigns"
					  :type "out"))
(setf *input-optimal-designs-file* (make-pathname 
				    :directory '(:relative "output")
				    :name "topdesigns"
				    :type "out"))

(setf *input-agents-file* (make-pathname :directory *code-dir*
					 :name "initagents"
					 :type "lisp"))
(setf *input-designs-file* nil)

(setf *input-optimal-designs-file* nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Load in the other lisp files involved in the process,
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(load "codeGeneral/design")
(load "codeGeneral/design")
(load "codeGeneral/create")
(load "codeGeneral/io")
(load "codeGeneral/functions")
(load "codeGeneral/magents")
(load "codeGeneral/trend")
(load "codeGeneral/update")
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
       '((nil (((0 120) (0 120) (0 120))) power (elect) nil
	  three-prong-outlet source nil)
	 (nil ((0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)) power (trans) nil bolt sink (ground))
	 (nil ((0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)) power (rotat) nil bolt sink (ground))
	 (nil ((0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)) power (rotat) nil shaft-hole sink (ground))
	 (nil ((0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)) power (hydra) nil female-pipe sink (ground))
	 (nil ((0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)) power (elect) nil wire sink (ground)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Finally, state the design problem at hand in terms of inputs and
;;; outputs of the system.  nil can be placed anywhere to denote
;;; no particular specification.	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setf *io-fps*
  (build-fps ;start
   '((((nil nil nil nil nil nil nil (0 0)))
(nil nil nil nil nil nil nil ((0 1)))
(nil nil nil nil ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) NIL SOURCE ((0 0) GOAL)))
nil
(SHAFT)
nil
nil
nil
nil
nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setf *target-state-vars* '((0 across 0 2) (1 across 3 2)))
