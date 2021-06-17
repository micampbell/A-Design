;;; oper tester


(load "initweigh")

(setf 
    design 
  (car (build-scs 
	'(((
	    
	    (nil ((0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)) power trans nil bolt sink (ground)))
	   nil
	   nil
	   nil 
	   nil
	   nil 
	   nil 
	   nil)))))
(setf eb 'shock-absorber)
(setf connect-fps 
  (list nil (nth 0 (sc-graph design))))

(print connect-fps)
(format t "~%~%before...~%")
(print (sc-graph design))
(format t "~%~%updating opers...~%")
(print 
 (update-config 
  eb connect-fps (sc-embodiments design) (sc-graph design)))



