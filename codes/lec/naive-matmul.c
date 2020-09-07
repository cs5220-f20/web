#include <stdlib.h>

void fill_matrix(double* A, int n)
{
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < n; ++j)
            A[i+j*n] = (double) rand() / RAND_MAX;
}

int main()
{
    int n = 2400;

    double* A = (double*) calloc(n * n, sizeof(double));
    double* B = (double*) calloc(n * n, sizeof(double));
    double* C = (double*) calloc(n * n, sizeof(double));
    fill_matrix(A, n);
    fill_matrix(B, n);
    
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < n; ++j)
            for (int k = 0; k < n; ++k)
                C[i+j*n] += A[i+k*n] * B[k+j*n];

    return 0;
}
