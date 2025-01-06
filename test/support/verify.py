import numpy as np

arr = np.load("test/support/single.npy")
arrs = np.load("test/support/multiple.npz")
rank0 = np.load("test/support/rank0.npy")

print(arr)
print(arrs["x"])
print(arrs["y"])
print(rank0)
print(rank0.shape)
