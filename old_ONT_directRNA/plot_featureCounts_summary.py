import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import argparse
import os

def main(filename):
    # Read the data file
    data = pd.read_csv(filename, sep='\t')
    
    # Extract statuses and columns
    statuses = data['Status']
    columns = data.columns[1:]
    
    # Use base names for columns
    base_columns = [os.path.basename(col) for col in columns]

    # Prepare data for plotting
    values = data[columns].values
    
    # Plotting
    fig, ax = plt.subplots(figsize=(16, 12))
    
    # Stack bar plot
    bottom = np.zeros(values.shape[1])
    colors = plt.cm.tab20(np.linspace(0, 1, len(statuses)))

    for i, status in enumerate(statuses):
        ax.bar(base_columns, values[i], bottom=bottom, label=status, color=colors[i])
        bottom += values[i]

    # Adding labels and title
    ax.set_ylabel('Counts')
    ax.set_xlabel('Alignment Files')
    ax.set_title('Stacked Bar Plot of Alignment Status')
    ax.legend(loc='upper left', bbox_to_anchor=(1, 1))

    plt.xticks(rotation=90)
    # Adjust y-axis tick label size
    ax.tick_params(axis='x', labelsize=6)

    plt.tight_layout()
    
    # Save plot
    plot_file = filename + '.png'
    plt.savefig(plot_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Plot alignment status from a given TSV file.')
    parser.add_argument('filename', type=str, help='The path to the TSV file containing alignment data')
    args = parser.parse_args()
    
    main(args.filename)
