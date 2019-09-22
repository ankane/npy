import numpy as np

arr = np.load("test/support/generated.npy")
arrs = np.load("test/support/generated.npz")
rank0 = np.load("test/support/generated_rank0.npy")

print(arr)
print(arrs["x"])
print(arrs["y"])
print(rank0)
print(rank0.shape)
