(
;;; CONCEPTUAL-AGENTS	
;;; Agents are named based on how they derive solutions.
;;; For example, in this first agent, agent-bfs-mg-forward
;;; the agent chooses to work from a source fp and then preforming a 
;;; breadth-first-search starting first with the operator (deriv, none, integ)
;;; and then finally based on choosing which component from that set at random.
 (((agent-source-series-connect-1 
    (0.2 0.2 0.2 0.2 0.2) nil source series connect) . 50)
  ((agent-sink-series-connect-1
    (0.2 0.2 0.2 0.2 0.2) nil sink series connect) . 50)
  ((agent-source-parallel-connect-1
    (0.2 0.2 0.2 0.2 0.2) nil source parallel connect) . 50)
  ((agent-sink-parallel-connect-1 
    (0.2 0.2 0.2 0.2 0.2) nil sink parallel connect) . 50)
  ((agent-source-series-dangle-1
    (0.2 0.2 0.2 0.2 0.2) nil source series dangle) . 50)
  ((agent-sink-series-dangle-1
    (0.2 0.2 0.2 0.2 0.2) nil sink series dangle) . 50)
  ((agent-source-parallel-dangle-1
    (0.2 0.2 0.2 0.2 0.2) nil source parallel dangle) . 50)
  ((agent-sink-parallel-dangle-1 
    (0.2 0.2 0.2 0.2 0.2) nil sink parallel dangle) . 50)
  ((agent-source-series-ground-1
    (0.2 0.2 0.2 0.2 0.2) nil source series ground) . 50)
  ((agent-sink-series-ground-1
    (0.2 0.2 0.2 0.2 0.2) nil sink series ground) . 50)
  ((agent-source-parallel-ground-1
    (0.2 0.2 0.2 0.2 0.2) nil source parallel ground) . 50)
  ((agent-sink-parallel-ground-1
   (0.2 0.2 0.2 0.2 0.2) nil sink parallel ground) . 50)
  ((agent-source-series-connect-2 
    (0.6 0.1 0.1 0.1 0.1) nil source series connect) . 50)
  ((agent-sink-series-connect-2
    (0.6 0.1 0.1 0.1 0.1) nil sink series connect) . 50)
  ((agent-source-parallel-connect-2
    (0.6 0.1 0.1 0.1 0.1) nil source parallel connect) . 50)
  ((agent-sink-parallel-connect-2 
    (0.6 0.1 0.1 0.1 0.1) nil sink parallel connect) . 50)
  ((agent-source-series-dangle-2
    (0.6 0.1 0.1 0.1 0.1) nil source series dangle) . 50)
  ((agent-sink-series-dangle-2
    (0.6 0.1 0.1 0.1 0.1) nil sink series dangle) . 50)
  ((agent-source-parallel-dangle-2
    (0.6 0.1 0.1 0.1 0.1) nil source parallel dangle) . 50)
  ((agent-sink-parallel-dangle-2 
    (0.6 0.1 0.1 0.1 0.1) nil sink parallel dangle) . 50)
  ((agent-source-series-ground-2
    (0.6 0.1 0.1 0.1 0.1) nil source series ground) . 50)
  ((agent-sink-series-ground-2
    (0.6 0.1 0.1 0.1 0.1) nil sink series ground) . 50)
  ((agent-source-parallel-ground-2
    (0.6 0.1 0.1 0.1 0.1) nil source parallel ground) . 50)
  ((agent-sink-parallel-ground-2
   (0.6 0.1 0.1 0.1 0.1) nil sink parallel ground) . 50)
  ((agent-source-series-connect-3 
    (0.1 0.6 0.1 0.1 0.1) nil source series connect) . 50)
  ((agent-sink-series-connect-3
    (0.1 0.6 0.1 0.1 0.1) nil sink series connect) . 50)
  ((agent-source-parallel-connect-3
    (0.1 0.6 0.1 0.1 0.1) nil source parallel connect) . 50)
  ((agent-sink-parallel-connect-3 
    (0.1 0.6 0.1 0.1 0.1) nil sink parallel connect) . 50)
  ((agent-source-series-dangle-3
    (0.1 0.6 0.1 0.1 0.1) nil source series dangle) . 50)
  ((agent-sink-series-dangle-3
    (0.1 0.6 0.1 0.1 0.1) nil sink series dangle) . 50)
  ((agent-source-parallel-dangle-3
    (0.1 0.6 0.1 0.1 0.1) nil source parallel dangle) . 50)
  ((agent-sink-parallel-dangle-3 
    (0.1 0.6 0.1 0.1 0.1) nil sink parallel dangle) . 50)
  ((agent-source-series-ground-3
    (0.1 0.6 0.1 0.1 0.1) nil source series ground) . 50)
  ((agent-sink-series-ground-3
    (0.1 0.6 0.1 0.1 0.1) nil sink series ground) . 50)
  ((agent-source-parallel-ground-3
    (0.1 0.6 0.1 0.1 0.1) nil source parallel ground) . 50)
  ((agent-sink-parallel-ground-3
   (0.1 0.6 0.1 0.1 0.1) nil sink parallel ground) . 50)
  ((agent-source-series-connect-4 
    (0.1 0.1 0.6 0.1 0.1) nil source series connect) . 50)
  ((agent-sink-series-connect-4
    (0.1 0.1 0.6 0.1 0.1) nil sink series connect) . 50)
  ((agent-source-parallel-connect-4
    (0.1 0.1 0.6 0.1 0.1) nil source parallel connect) . 50)
  ((agent-sink-parallel-connect-4 
    (0.1 0.1 0.6 0.1 0.1) nil sink parallel connect) . 50)
  ((agent-source-series-dangle-4
    (0.1 0.1 0.6 0.1 0.1) nil source series dangle) . 50)
  ((agent-sink-series-dangle-4
    (0.1 0.1 0.6 0.1 0.1) nil sink series dangle) . 50)
  ((agent-source-parallel-dangle-4
    (0.1 0.1 0.6 0.1 0.1) nil source parallel dangle) . 50)
  ((agent-sink-parallel-dangle-4 
    (0.1 0.1 0.6 0.1 0.1) nil sink parallel dangle) . 50)
  ((agent-source-series-ground-4
    (0.1 0.1 0.6 0.1 0.1) nil source series ground) . 50)
  ((agent-sink-series-ground-4
    (0.1 0.1 0.6 0.1 0.1) nil sink series ground) . 50)
  ((agent-source-parallel-ground-4
    (0.1 0.1 0.6 0.1 0.1) nil source parallel ground) . 50)
  ((agent-sink-parallel-ground-4
   (0.1 0.1 0.6 0.1 0.1) nil sink parallel ground) . 50))

 

;;; INSTANTIATION-AGENTS
 ((agent-1-upper-mg-most-used-datum . 250)
  (agent-1-middle-mg-most-used-datum . 250)
  (agent-1-lower-mg-most-used-datum . 250)
  (agent-2-upper-mg-most-used-datum . 0)
  (agent-2-middle-mg-most-used-datum . 0)
  (agent-2-lower-mg-most-used-datum . 0)
  (agent-3-upper-mg-most-used-datum . 0)
  (agent-3-middle-mg-most-used-datum . 0)
  (agent-3-lower-mg-most-used-datum . 0)
  (agent-1-upper-mg-least-used-datum . 250)
  (agent-1-middle-mg-least-used-datum . 250)
  (agent-1-lower-mg-least-used-datum . 250)
  (agent-2-upper-mg-least-used-datum . 0)
  (agent-2-middle-mg-least-used-datum . 0)
  (agent-2-lower-mg-least-used-datum . 0)
  (agent-3-upper-mg-least-used-datum . 0)
  (agent-3-middle-mg-least-used-datum . 0)
  (agent-3-lower-mg-least-used-datum . 0))
 
;;; FRAGMENT-AGENTS
 ((agent-low1-low1-in-comps . 250)
  (agent-high1-low1-in-comps . 250)
  (agent-low2-low2-in-comps . 0)
  (agent-high2-low2-in-comps . 0)
  (agent-low3-low3-in-comps . 0)
  (agent-high3-low3-in-comps . 0)
  (agent-low1-doubles-in-comps . 250)
  (agent-high1-doubles-in-comps . 250)
  (agent-low2-doubles-in-comps . 250)
  (agent-high2-doubles-in-comps . 250)
  (agent-low3-doubles-in-comps . 250)
  (agent-high3-doubles-in-comps . 250)
  (agent-low1-dangles-in-graph . 250)
  (agent-high1-dangles-in-graph . 250)
  (agent-low2-dangles-in-graph . 250)
  (agent-high2-dangles-in-graph . 250)
  (agent-low3-dangles-in-graph . 250)
  (agent-high3-dangles-in-graph . 250)
  (agent-low1-low1-in-graph . 250)
  (agent-high1-low1-in-graph . 250)
  (agent-low2-low2-in-graph . 0)
  (agent-high2-low2-in-graph . 0)
  (agent-low3-low3-in-graph . 0)
  (agent-high3-low3-in-graph . 0)
  (agent-low1-doubles-in-graph . 250)
  (agent-high1-doubles-in-graph . 250)
  (agent-low2-doubles-in-graph . 250)
  (agent-high2-doubles-in-graph . 250)
  (agent-low3-doubles-in-graph . 250)
  (agent-high3-doubles-in-graph . 250))

;;; FEEDBACK-OP
 +

;;; FEEDBACK-DATA 
 (3.0 1.0 -1.0))

