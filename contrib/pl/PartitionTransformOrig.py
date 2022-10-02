import operator
from enum import Enum
from typing import Callable
from itertools import accumulate
from inspect import getsource
from sage.all import SR, PolynomialRing, expand, flatten
def PartitionTransform(dim: int, a: Callable=None, norm: Callable=None, 
        inverse: bool=False, accu: bool=False) -> list:
    if a == None: a = lambda n: var('x' + str(n))
    # Compensate the different indexing with a shift in the argument
    # and cache the input sequence.
    A = [a(i + 1) for i in range(dim - 1)]
    if accu: A = list(accumulate(A, operator.mul)) 
    print("In:", A)
    C = [[0 for k in range(m + 1)] for m in range(dim)]
    C[0][0] = 1
    if inverse:
        for m in range(1, dim):
            C[m][m] = C[m - 1][m - 1] / A[0]
            for k in range(m - 1, 0, -1):
                C[m][k] = expand(C[m - 1][k - 1] - 
                          sum(A[i] * C[m][k + i] 
                              for i in range(m - k + 1))) / A[0]
    else:
        for m in range(1, dim):
            C[m][m] = C[m - 1][m - 1] * A[0]
            for k in range(m - 1, 0, -1):
                C[m][k] = expand(sum(A[i] * C[m - i - 1][k - 1] 
                                    for i in range(m - k + 1)))
    if norm == None: return C
    for m in range(1, dim):
        for k in range(1, m + 1):
            C[m][k] = C[m][k] * norm(m, k)
    return C

for row in PartitionTransform(7, lambda n: -n, False, True): print(row)
# PartitionTransform(7, lambda n: -n)

for row in PartitionTransform(5): print(row)
	
# a = [1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862, 16796, 58786, 208012, 742900, 2674440]
# PartitionTransform(10, a)
