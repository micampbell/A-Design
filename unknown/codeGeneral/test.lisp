;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TEST.LISP 
;;; provides a testbed for developing and debugging the m-agents.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (load "initweigh")

(defun test ()

  (setf *input-agents-file* (make-pathname :directory '(:relative "EMoutput")
					    :name "agents_42"
					    :type "out"))
  (let* ((agent-data (M-find-next-agent-M  (car (read-agents)))))
    (print agent-data)))
