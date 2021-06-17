;;; update-coord tester




(defun test (name)
  (let ((design 
	 (car (build-scs
	       (with-open-file (ifile (make-pathname :name name) :direction :input)
		 (read ifile nil))))))
    (format t "before...")
    (print (sc-graph design))
    (format t "~%updating coords...~%")
    (format t "...after~%")
    (print (update-coordinates (sc-graph design) (sc-embodiments design)))
     (print (sc-embodiments design)))
    'done)

(load "initweigh")

