import struct
import numpy as np


def read_matrix(file_path):
    file = open(file_path, "rb")
    matrix = np.zeros(shape=(m, m))
    for i in range(m):
        for j in range(m):
            byte = file.read(4)
            matrix[i][j] = struct.unpack('>f', byte)[0]
    return matrix


path_a = "../data/seq_input_a.bin"
path_b = "../data/seq_input_b.bin"
m = 4

matrix_a = read_matrix(path_a)
matrix_b = read_matrix(path_b)
result = np.matmul(matrix_a, matrix_b)

