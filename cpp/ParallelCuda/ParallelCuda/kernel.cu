
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include <vector>
#include <fstream>


#define V 333
#define E 800
#define MAX_WEIGHT 1000000
#define TRUE    1
#define FALSE   0

typedef int boolean;

struct Edge {
    int u;
    int v;
};

struct Vertex {
    int title;
    boolean visited;
};


__global__ void Find_Vertex(Vertex* vertices, Edge* edges, double* weights, double* length, double* updateLength, int* path) {
    int u = blockIdx.x * blockDim.x + threadIdx.x;
    if (u < V && vertices[u].visited == FALSE) {
        vertices[u].visited = TRUE;

        int uTitle = vertices[u].title;
        int lengthU = length[u];

        for (int i = 0; i < E; i++) {
            if (edges[i].u == uTitle) {
                int v = edges[i].v;
                double weight = weights[i];

                if (weight < MAX_WEIGHT) {
                    double potentialLength = lengthU + weight;

                    if (updateLength[v] > potentialLength) {
                        updateLength[v] = potentialLength;
                        int k = 0;
                        while (path[u * V + k] != MAX_WEIGHT)
                        {
                            path[v * V + k] = path[u * V + k];
                            k++;
                        }
                        path[v * V + k] = u;
                        path[v * V + k + 1] = MAX_WEIGHT;
                    }
                }
            }
        }
    }
}

__global__ void Update_Paths(Vertex* vertices, double* length, double* updateLength)
{
    int u = blockIdx.x * blockDim.x + threadIdx.x;

    if (u < V && length[u] > updateLength[u]) {
        length[u] = updateLength[u];
        vertices[u].visited = FALSE;
    }
    updateLength[u] = length[u];
}

void printArray(int* array) {
    for (int i = 0; i < V; i++) {
        std::cout << "Shortest Path to Vertex " << i << " is " << array[i] << std::endl;
    }
}
int konvertuj(std::string parametar)
{
    int broj = 0;
    for (int i = 0; parametar[i] != '\0'; i++)
    {
        broj = broj * 10 + parametar[i] - 48;
    }
    return broj;
}
std::vector<int> flattenVector(const std::vector<std::vector<int>>& input) {
    std::vector<int> result;
    for (const auto& innerVector : input) {
        result.insert(result.end(), innerVector.begin(), innerVector.end());
    }
    return result;
}

int main(int brojParametara, char* parametri[]) {
    if (brojParametara < 3)
        return 0;

    int firstNode = konvertuj(parametri[1]);
    int lastNode = konvertuj(parametri[2]);
    if (firstNode > lastNode) {
        int temp = firstNode;
        firstNode = lastNode;
        lastNode = temp;
    }
    std::vector<Vertex> vertices(V);
    std::vector<Edge> edges(E);
    std::vector<double> weights(E);
    std::vector<double> len(V, MAX_WEIGHT);
    std::vector<double> updateLength(V, MAX_WEIGHT);
    std::vector<int> path((V * V), MAX_WEIGHT);


    cudaEvent_t timeStart, timeEnd;
    float runningTime;

    cudaEventCreate(&timeStart);
    cudaEventCreate(&timeEnd);



    for (int i = 0; i < V; ++i) {
        Vertex a = { i, FALSE };
        vertices[i] = a;
    }

    std::ifstream mapa("mapa.txt");
    if (!mapa.is_open())
    {
        std::cout << "Nemoguce otvoriti mapu";
        return 0;
    }
    double c;
    int a, b;
    int broj = 0;
    while (mapa >> a >> b >> c) {
        Edge e = { a, b };
        edges[broj] = e;
        weights[broj] = c;
        broj++;
    }


    Vertex* d_V;
    Edge* d_E;
    double* d_W;
    double* d_L;
    double* d_C;
    int* d_P;

    cudaMalloc((void**)&d_P, sizeof(int) * V * V);

    //cudaMalloc((void**)&d_P, sizeof(int) * V);
    cudaMalloc((void**)&d_V, sizeof(Vertex) * V);
    cudaMalloc((void**)&d_E, sizeof(Edge) * E);
    cudaMalloc((void**)&d_W, sizeof(double) * E);
    cudaMalloc((void**)&d_L, sizeof(double) * V);
    cudaMalloc((void**)&d_C, sizeof(double) * V);
    //cudaMemcpy(path.data(), d_P, sizeof(int) * V * V, cudaMemcpyDeviceToHost);

    cudaMemcpy(d_P, path.data(), sizeof(int) * V * V, cudaMemcpyHostToDevice);
    //cudaMemcpy(d_P, flattenedPath.data(), sizeof(int) * flattenedPath.size(), cudaMemcpyHostToDevice);
    cudaMemcpy(d_V, vertices.data(), sizeof(Vertex) * V, cudaMemcpyHostToDevice);
    cudaMemcpy(d_E, edges.data(), sizeof(Edge) * E, cudaMemcpyHostToDevice);
    cudaMemcpy(d_W, weights.data(), sizeof(double) * E, cudaMemcpyHostToDevice);
    cudaMemcpy(d_L, len.data(), sizeof(double) * V, cudaMemcpyHostToDevice);
    cudaMemcpy(d_C, updateLength.data(), sizeof(double) * V, cudaMemcpyHostToDevice);

    Vertex root = { firstNode, FALSE };
    root.visited = TRUE;

    len[root.title] = 0;
    updateLength[root.title] = 0;
    cudaMemcpy(d_L, len.data(), sizeof(int) * V, cudaMemcpyHostToDevice);
    cudaMemcpy(d_C, updateLength.data(), sizeof(int) * V, cudaMemcpyHostToDevice);

    cudaEventRecord(timeStart, 0);

    for (int i = 0; i < V; i++) {

        Find_Vertex << <(V + 255) / 256, 256 >> > (d_V, d_E, d_W, d_L, d_C, d_P);
        cudaDeviceSynchronize();
        Update_Paths << <(V + 255) / 256, 256 >> > (d_V, d_L, d_C);
        cudaDeviceSynchronize();

    }

    cudaEventRecord(timeEnd, 0);
    cudaEventSynchronize(timeEnd);
    cudaEventElapsedTime(&runningTime, timeStart, timeEnd);

    cudaMemcpy(len.data(), d_L, sizeof(int) * V, cudaMemcpyDeviceToHost);


    cudaMemcpy(path.data(), d_P, sizeof(int) * V * V, cudaMemcpyDeviceToHost);

    for (int i = 0; i < V; i++)
    {
        int j = 0;
        if (i == lastNode)
        {
            std::cout << "[";
            while (i == lastNode && path[i * V + j] != MAX_WEIGHT)
            {
                std::cout << path[i * V + j] << ",";
                j++;
            }
            std::cout << lastNode << "]";
        }
    }

    cudaFree(d_V);
    cudaFree(d_E);
    cudaFree(d_W);
    cudaFree(d_L);
    cudaFree(d_C);
    cudaFree(d_P);
    cudaEventDestroy(timeStart);
    cudaEventDestroy(timeEnd);

    return 0;
}