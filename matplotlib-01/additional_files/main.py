import matplotlib.pyplot as plt
import numpy as np

x = np.arange(0, 3 * np.pi, 0.1)
y = np.sin(x)

plt.plot(x, y)
plt.savefig("plot.png")
