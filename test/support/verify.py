import numpy as np

arr = np.load("test/support/generated.npy")
arrs = np.load("test/support/generated.npz")

print(arr)
print(arrs["x"])
print(arrs["y"])
