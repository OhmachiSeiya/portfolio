import numpy as np
import matplotlib.pyplot as plt

class Cumfreq:
    def __call__(self):
        return 'Cumfreqqqq'

    def plot_cumfreq(self,data,color="blue",bins=50,figsize=(10,6),density=True):
        data = np.array(data, dtype=float)
        counts, bin_edges = np.histogram(data, bins=bins,density=density)
        cdf = np.cumsum(counts)
      
        plt.figure(figsize=figsize)
        ax = plt.subplot(111)
        ax.set_title("Cumfreq")
        ax.plot(bin_edges[1:], cdf, color=color)

if __name__ == '__main__':
    main()
