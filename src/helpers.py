import matplotlib.pyplot as plt
import numpy as np

def scatter_plot(df, x, y, xlabel, ylabel, title):
    fig, ax = plt.subplots(figsize = (12,12))
    ax.plot(df[x], df[y], ls = "", marker = 'o', markersize = 2)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    return fig


def logistic_map(x, d, k):
    return 1 - d + 2 * d / (1 + np.exp(-k * (x - 1)))