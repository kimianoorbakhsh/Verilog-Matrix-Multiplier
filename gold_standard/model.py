import struct
import numpy as np
from numpy import linalg as LA
from sys import argv


def read_matrix(file_path: str, n: int, m: int) -> np.ndarray:
    with open(file_path, "rb") as file:
        matrix = np.zeros(shape=(n, m))
        for i in range(n):
            for j in range(m):
                byte = file.read(4)
                matrix[i][j] = struct.unpack('>f', byte)[0]
        return matrix

assert len(argv) == 7, "Usage: python model.py path_a path_b path_result n k m"

path_a = argv[1]        # n * k
path_b = argv[2]        # k * m
path_result = argv[3]   # n * m
n = int(argv[4])
k = int(argv[5])
m = int(argv[6])

matrix_a = read_matrix(path_a, n, k)
print(f'A:\n{matrix_a}')
matrix_b = read_matrix(path_b, k, m)
print(f'B:\n{matrix_b}')
matrix_result = read_matrix(path_result, n, m)
print(f'Actual:\n{matrix_result}')
real_result = np.matmul(matrix_a, matrix_b)
print(f'Expected:\n{real_result}')

print(np.max(np.abs(real_result - matrix_result)) < 1e-6)
