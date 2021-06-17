;;; oper tester


(load "initweigh")

(setf design 
  (car (build-scs 
	'(((((nil nil nil 30 nil nil nil nil)
	     (((goal 0) (goal 0) (goal 0)) ((goal 0) (goal 0) (goal 0)) ((goal 0) (goal 0) (goal 0)) 
		(nil nil (goal bound)) ((goal 0) (goal 0) (goal 0)) ((goal 0) (goal 0) (goal 0)) nil nil)
	     power rotat
	     nil shaft source 
	     ((0 0) (2 0)))
	    (nil nil power rotat nil shaft source ((0 1) (1 0) (4 0)))
	    (nil nil power rotat nil shaft source ((1 1) (3 0)))
	    (nil ((0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0))
		 power rotat nil shaft sink ((2 1) ground))
	    (nil ((0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0))
		 power rotat nil shaft sink ((3 1) ground))
	    (nil nil power trans nil gear-teeth source ((4 1)))
	    (nil nil power trans nil gear-teeth source ((4 2)))
	    (nil nil power trans nil gear-teeth source ((4 3)))
	    (nil nil power trans nil gear-teeth source ((4 4)))
	    (nil nil power rotat nil shaft source ((5 0) (7 0)))
	    (nil nil power rotat nil shaft source ((5 1) (6 0)))
	    (nil nil power rotat ((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1)) shaft source ((6 1) (8 0) (9 0)))
	    (nil nil
		 power rotat nil shaft sink ((7 1)))
	    (nil nil
		 power rotat nil shaft sink ((8 1)))
	    (nil ((0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0)(0 0 0))
		 power rotat nil bolt sink ((9 1) ground))
		 )
	nil (shaft shaft bearing-rotat bearing-rotat gear shaft shaft bearing-rotat bearing-rotat torsion-spring)
	nil nil nil nil nil)))))
(setf eb 'gear)
(setf connect-fps (list (nth 10 (sc-graph design)) nil nil nil (nth 6 (sc-graph design))))

(print connect-fps)
(format t "~%~%before...~%")
(print (sc-graph design))
(format t "~%~%updating opers...~%")
(print 
 (update-config 
  eb connect-fps (sc-embodiments design) (sc-graph design)))



