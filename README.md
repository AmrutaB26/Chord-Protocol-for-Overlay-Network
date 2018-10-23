# CHORD PROTOCOL IMPLEMENTATION

**Includes an algorithm for distributed hash table protocol and lookups**

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
</br>**Output:** Average number of hops per request </br>
**mix run main.exs numNodes numRequests** </br>
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
	1. 	Initially a network was created using 2 nodes.</br>
	2.	Additional nodes upto the total number of nodes were added using join and stabilize functions as stated in the paper.</br>
	3.	Finger tables for the node contained the 160-bit SHA-1 hash nodeIPs and are of the size 160 each.</br>
	4. 	Lookup was then performed for keys in the network with each node generating numRequests number of requests per second. The process exits when the desired number of requests have been performed by each node</br>
6. The largest network managed for number of nodes and number of requests are as follows:</br>
  push-sum -> 1000 for all topologies</br>
  gossip -> 9000 for all topologies
