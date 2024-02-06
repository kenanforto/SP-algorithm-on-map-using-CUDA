# Visual interpretation of Dijkstra's algorithm on map using CUDA
-------------------------
This project was created for the purpose of parallel implementation of the shortest path algorithm for use in maps. C++ was used for the backend,
which was connected to the frontend via Node.js. In the C++ code, the sequential code of the Dijkstra algorithm was parallelized.
JavaScript was used for the frontend. By using Leaflet (https://leafletjs.com/), we had a map of Sarajevo covered with markers. 
By clicking on 2 markers, the algorithm finds the shortest path between those 2 markers. The image shows the operation of our algorithm where the red line indicates the shortest path between 2 points. 
The table shows result of sequential and parallel code on two computers.

![Snimka zaslona 2024-01-23 173308](https://github.com/kenanforto/SP-algorithm-on-map-using-CUDA/assets/132957986/c6059fab-7745-4187-87cc-b9c787b61365)

![Snimka zaslona 2024-02-06 204426](https://github.com/kenanforto/SP-algorithm-on-map-using-CUDA/assets/132957986/c407d954-b0f1-4d19-bd8e-0da4d68899fa)

We can see that the algorithm demonstrates better results after parallelization.

## Run and build

* Install CUDA (https://developer.nvidia.com/cuda-downloads)
* Run C++ code on VS (Folder in project: cpp)
* Install node (version v20.10.0)
* Change the path of the .exe file inside of server.js
* Run server.js
