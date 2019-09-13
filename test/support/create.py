import numpy as np

x = np.arange(10)
y = x * 2

np.save("test/support/single.npy", x)
np.save("test/support/constant.npy", np.array(1))
np.savez("test/support/multiple.npz", x=x, y=y)

x2 = np.load("test/support/single.npy")
print(x2)

data = np.load("test/support/multiple.npz")
print([str(k) for k in data.keys()])
print(data["x"])
print(data["y"])

types = [
  "int8", "int16", "int32", "int64",
  "uint8", "uint16", "uint32", "uint64",
  "float16", "float32", "float64",
  "complex64", "complex128"
]
for t in types:
  path = "test/support/types/" + t + ".npy"
  np.save(path, x.astype(t))
  print(np.load(path).dtype)
