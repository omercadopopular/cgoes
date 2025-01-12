import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def plot_ir(variables, shocks, irf, lower_errband = [], upper_errband = [], show_plot = False, save_plot = False, plot_path = ''):
    """
    Plot impulse response functions in a grid.

    Parameters:
    - irf: List of 2D arrays containing impulse response functions for each shock and variable.
    - lower_errband & upper_errband: Lists of 2D arrays containing confidence bands for each shock and variable.
    - shocks: List of shock names.
    - variables: List of variable names.
    """
    sns.set(style="whitegrid")  # Set Seaborn style

    num_shocks = len(shocks)
    num_variables = len(variables)

    # Set up subplots
    fig, axes = plt.subplots(num_variables, num_shocks, figsize=(num_shocks * 5, num_variables * 3), sharex=True)

    for i, var in enumerate(variables):
        for j, shock in enumerate(shocks):
            ax = axes[j, i]

            # Plot impulse response function
            ax.plot(irf[:, i, j], color=sns.color_palette("husl")[i])

            # Plot confidence bands if available
            if len(lower_errband) > 0 and len(upper_errband) > 0:
                ax.fill_between(np.arange(len(irf)), lower_errband[:, i, j], upper_errband[:, i, j], alpha=0.2, color='gray')

            ax.axhline(0, color='black', linestyle='--', linewidth=0.5)
            ax.set_title(f"{var} response to {shock}")

    plt.tight_layout()
    if save_plot:
        plt.savefig(plot_path+'impulse_response.png')
    if show_plot:
        plt.show()