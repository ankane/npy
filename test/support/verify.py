import numpy as np

arr = np.load("test/support/generated.npy")
arrs = np.load("test/support/generated.npz")
empty = np.load("test/support/generated_empty.npy")

print(arr)
print(arrs["x"])
print(arrs["y"])
print(empty)
print(empty.shape)
