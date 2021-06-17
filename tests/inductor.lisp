;;; oper tester


(load "initweigh")

(setf 
    design 
  (car (build-scs 
	'(((
	    (((0 300) (goal 0)	(goal 0) (goal 0) (goal 0) (goal 0) (goal 0) (goal 0))
	     ((nil nil (goal (0 0))) ((goal 0) (goal 0) (goal 0)) ((goal 0) (goal 0) (goal 0)) 
				     ((goal 0) (goal 0) (goal 0)) ((goal 0) (goal 0) (goal 0)) ((goal 0) (goal 0) (goal 0))
				     ((goal 0) (goal 0) (goal 0)) ((goal 0) (goal 0) (goal 0)))
	     power trans 
	     ((0 1 0 0) (-1 0 0 0) (0 0 1 0) (0 0 0 1)) feet source 
	     (goal))
	    (((goal bound) (goal bound) (goal bound) (goal bound) (goal 0) (goal 0) (goal 0) (goal 0))
	     (((goal 0) (goal 0) (goal 0)) ((goal 0) (goal 0) (goal 0)) 
					   ((goal 0) (goal 0) (goal 0)) ((goal nil) (goal nil) (goal (0 5))) 
					   ((goal 0) (goal 0) (goal 0)) ((goal 0) (goal 0) (goal 0)) ((goal 0) (goal 0) (goal 0))
					   ((goal 0) (goal 0) (goal 0)))
	     power rotat 
	     ((-1 0 0 1) (0 1 0 5) (0 0 -1 0) (0 0 0 1))
	     dial sink (goal))
	    (nil ((0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)) power trans nil bolt sink (ground)))
	   nil
	   nil
	   nil 
	   nil
	   nil 
	   nil 
	   nil)))))
(setf eb 'inductor)
(setf connect-fps 
  (list nil (nth 2 (sc-graph design))))

(print connect-fps)
(format t "~%~%before...~%")
(print (sc-graph design))
(format t "~%~%updating opers...~%")
(print 
 (update-config 
  eb connect-fps (sc-embodiments design) (sc-graph design)))



