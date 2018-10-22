# CHORD PROTOCOL IMPLEMENTATION

**Includes an algorithm for resilience towards node joins and leaves and searching for a key in a network in O(logn) time**

## Group info
| Name  | UFID  |
|---|---|
| Amruta Basrur | 44634819  |
|  Shreya Singh| 79154462  |

## Instructions

1. Unzip Amruta_Shreya.zip file and navigate to Amruta_Shreya folder.
2. Open the command promt and enter the below mix command to compile and run the code.
</br>**Input:** Enter numNodes, numRequests 
</br> Here numNodes are the total number of nodes in a network and numRequests are the total number of requests which each node performs sending 1 request per second.
</br>**Output:** Convergence value along with final s/w value for push-sum algorithm </br>
**mix run main.exs numNodes topology algorithm** </br>
3. **Input:**
mix run main.exs 400 torus push-sum</br>
**Output**
</br>Convergence reached at 10063ms
</br>Nodes converged: 340
</br>Total nodes: 400
</br>Convergence ratio S/W 200.26505554316893 </br></br>
**Input:**
mix run main.exs 400 torus gossip</br>
**Output**
</br>Convergence reached at 418ms
4. Number of nodes vs convergence time graph is plotted in project report along with interesting observation and implementation details </br>
5. Working:</br>
	1. 	Convergence of Gossip algorithm for all topologies.</br>
	2. 	Convergence of Push-Sum algorithm for all topologies.</br>
  6. We are taking the next perfect cube for 3D and perfect square for rand 2D</br>
  7. Random 2D gives correct results for value much greater than 1000 </br>
  8. The largest network managed for each topology and algorithm are as follows:</br>
  push-sum -> 1000 for all topologies</br>
  gossip -> 9000 for all topologies
