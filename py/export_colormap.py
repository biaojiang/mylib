import matplotlib.pyplot as plt

viridis_cmap = plt.get_cmap("viridis")
colors = viridis_cmap.colors

# Save the colors to a CSV file
with open("data/viridis.csv", "w") as f:
    for color in colors:
        f.write(",".join([str(c) for c in color]) + "\n")
