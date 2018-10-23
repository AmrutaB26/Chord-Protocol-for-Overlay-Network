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
mix run main.exs 100 5</br>
**Output**
</br>Created 100 nodes network
</br>Performing join and stabilizing network
</br>Keys generated
</br>Performing lookup
</br>Average number of hops = 7.380952380952381</br></br>
**Input:**
mix run main.exs 1000 2</br>
**Output**
</br>Created 1000 nodes network
</br>Performing join and stabilizing network
</br>Keys generated
</br>Performing lookup
</br>Average number of hops = 10.0255</br>
5. Working:</br>
	1. 	Initially a network is created of a small amount of totaL number of nodes. </br>
	2.  	Remaining nodes join the network using Join and stabilization functionality of Chord protocol
	3.	Finger tables for the node contained the 160-bit SHA-1 hash nodeIPs and are of the size 160 each.</br>
	4. 	Lookup was then performed for keys in the network with each node generating numRequests number of requests per second. 			The process exits when the desired number of requests have been performed by each node </br>
	5. 	The largest network managed for number of nodes and number of requests is 5000, 5</br>
