# -*- coding: utf-8 -*-
"""
Created on Wed Nov 27 20:49:36 2024

@author: andre
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def epsilonh(theta, zeta, sigma, h):
    return -theta * (1 - (1 - zeta)**(h + 1)) - (sigma - 1) * (1 - zeta)**(h + 1)

def epsilonf(theta, zeta, sigma, r, f):
    return -(theta - (sigma - 1)) * (1 - r - zeta) * ((1 - zeta) / (1 + r))**f * zeta

# Parameters
theta = 7
sigma = 1.5
h = 1
r = 0.01
f = 1

# Create linspace for zeta
zeta_values = np.linspace(0, 1, 500)

# Compute epsilonh and epsilonf for each zeta
epsilonh_values = [epsilonh(theta, zeta, sigma, h) for zeta in zeta_values]
epsilonf_values = [epsilonf(theta, zeta, sigma, r, f) for zeta in zeta_values]

# Plot the results
plt.figure(figsize=(10, 6))
plt.rcParams['text.usetex'] = False
plt.plot(zeta_values, epsilonh_values, label='epsilonh', color='blue')
plt.plot(zeta_values, epsilonf_values, label='epsilonf', color='green')
plt.axhline(0, color='black', linewidth=0.5, linestyle='--')
plt.xlabel('Zeta')
plt.ylabel('Function Value')
plt.title('Epsilonh and Epsilonf vs. Zeta')
plt.legend()
plt.grid(alpha=0.3)
plt.show()


# Parameters
sigma = 1.5
r = 0.01
theta = 7

# Create linspace for zeta and theta
zeta_values = np.linspace(0, 1, 100)
f_values = np.linspace(1, 10, 10)  # Avoiding theta=0 to prevent potential singularities

# Create meshgrid for 3D plot
zeta_grid, f_grid = np.meshgrid(zeta_values, f_values)

# Compute epsilonf for each (zeta, theta) pair
epsilonf_values = epsilonf(theta, zeta_grid, sigma, r, f_grid)

# Plotting
fig = plt.figure(figsize=(12, 8))
ax = fig.add_subplot(111, projection='3d')

# Surface plot
surf = ax.plot_surface(zeta_grid, f_grid, epsilonf_values, cmap='viridis', edgecolor='k', alpha=0.5)

# Labels and title
ax.set_xlabel('Zeta')
ax.set_ylabel('f')
ax.set_zlabel('Epsilonf')
ax.set_title('Epsilon f vs. Zeta and f')

# Color bar
fig.colorbar(surf, shrink=0.5, aspect=10)

plt.show()




# Plot the results
plt.figure(figsize=(10, 6))
plt.rcParams['text.usetex'] = False
plt.plot(zeta_values, epsilonf_values[0,:], label='epsilonf, f=1', color='blue')
plt.plot(zeta_values, epsilonf_values[-1,:], label='epsilonf, f=10', color='green')
plt.axhline(0, color='black', linewidth=0.5, linestyle='--')
plt.xlabel('Zeta')
plt.ylabel('Function Value')
plt.title('Epsilonf vs. Zeta at different horizons')
plt.legend()
plt.grid(alpha=0.3)
plt.show()




# Parameters
sigma = 1.5
theta = 7

# Create linspace for zeta and theta
zeta_values = np.linspace(0, 1, 100)
h_values = np.linspace(1, 10, 10)  # Avoiding theta=0 to prevent potential singularities

# Create meshgrid for 3D plot
zeta_grid, h_grid = np.meshgrid(zeta_values, h_values)

# Compute epsilonf for each (zeta, theta) pair
epsilonh_values = epsilonh(theta, zeta_grid, sigma, h_grid)

# Plotting
fig = plt.figure(figsize=(12, 8))
ax = fig.add_subplot(111, projection='3d')

# Surface plot
surf = ax.plot_surface(zeta_grid, h_grid, epsilonh_values, cmap='viridis', edgecolor='k', alpha=0.5)

# Labels and title
ax.set_xlabel('Zeta')
ax.set_ylabel('h')
ax.set_zlabel('Epsilonh')
ax.set_title('Epsilon h vs. Zeta and h')

# Color bar
fig.colorbar(surf, shrink=0.5, aspect=10)

plt.show()



# Plot the results
plt.figure(figsize=(10, 6))
plt.rcParams['text.usetex'] = False
plt.plot(zeta_values, epsilonh_values[0,:], label='epsilonh, h=1', color='blue')
plt.plot(zeta_values, epsilonh_values[-1,:], label='epsilonh, h=10', color='green')
plt.axhline(0, color='black', linewidth=0.5, linestyle='--')
plt.xlabel('Zeta')
plt.ylabel('Function Value')
plt.title('Epsilonh vs. Zeta at different horizons')
plt.legend()
plt.grid(alpha=0.3)
plt.show()
