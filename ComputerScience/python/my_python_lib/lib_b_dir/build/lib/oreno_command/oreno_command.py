def main(data,color="blue",bins=50,figsize=(10,6),density=True):
  counts, bin_edges = np.histogram(data, bins=bins,density=density)
  cdf = np.cumsum(counts)
  
  plt.figure(figsize=figsize)
  # 経験分布の累積密度関数
  ax = plt.subplot(111)
  ax.set_title("Cumfreq")
  ax.plot(bin_edges[1:], cdf, color=color)

if __name__ == '__main__':
    main()
