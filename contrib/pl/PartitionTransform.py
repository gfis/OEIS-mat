import operator
from enum import Enum
from typing import Callable
from itertools import accumulate
from inspect import getsource
def PartitionTransform(dim: int, a, inverse: bool=False, accu: bool=False) -> list:
    # Compensate the different indexing with a shift in the argument
    # and cache the input sequence.
    A = [a(i + 1) for i in range(dim - 1)]
    if accu: A = list(accumulate(A, operator.mul)) 
    print("In:", A)
    C = [[0 for k in range(m + 1)] for m in range(dim)]
    C[0][0] = 1
    if inverse:
        for m in range(1, dim):
            C[m][m] = C[m - 1][m - 1] // A[0]
            for k in range(m - 1, 0, -1):
                C[m][k] = (C[m - 1][k - 1] - 
                          sum(A[i] * C[m][k + i] 
                          for i in range(m - k + 1))) // A[0]
    else:
        for m in range(1, dim):
            C[m][m] = C[m - 1][m - 1] * A[0]
            for k in range(m - 1, 0, -1):
                C[m][k] = (sum(A[i] * C[m - i - 1][k - 1] 
                           for i in range(m - k + 1)))
    return C

def CompositionalInverse(dim, a):
    M = PartitionTransform(dim + 1, a, inverse=True)
    return [M[n + 1][1] for n in range(dim)]
print("\nA078812")
for row in PartitionTransform(7, lambda n: n, False, False): print(row)
print("\n~A039598, signed")
for row in PartitionTransform(7, lambda n: n, True , False): print(row)
print("\nA130595")
for row in PartitionTransform(7, lambda n: 1, True , False): print(row)
print("\nA167560")
for row in PartitionTransform(7, lambda n: n, False, True ): print(row)
print("\nA130595")
for row in PartitionTransform(7, lambda n: 1, True , True ): print(row)
