# -*- coding: utf-8 -*-
"""
Created on Mon Mar 17 21:00:51 2025

@author: cbezerradegoes
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
alpha = 0.33    # Capital share
beta = 0.96     # Discount factor
delta = 0.1     # Depreciation rate
sigma = 2.0     # Elasticity of substitution
tau_12 = 1.3    # Iceberg cost from 1 to 2
tau_21 = 1.3    # Iceberg cost from 2 to 1
A1, A2 = 1.0, 1.0  # TFP for countries 1 and 2
L1, L2 = 1.0, 2.0  # Labor (normalized)

# Steady-state functions
def production(K, L, A):
    return A * K*alpha * L*(1 - alpha)

def rental_rate(K, L, A):
    return alpha * A * (K / L)*(alpha - 1)

def wage(K, L, A):
    return (1 - alpha) * A * (K / L)**alpha

def euler_residual(C, C_next, r_next):
    return C*(-sigma) - beta * C_next*(-sigma) * (1 - delta + r_next)

# Steady-state solver
def steady_state(K_init, A, L, tau_in, tau_out):
    tol = 1e-6
    max_iter = 1000
    K = K_init
    for _ in range(max_iter):
        Y = production(K, L, A)
        r = max(10**(-6),rental_rate(K, L, A))
        w = wage(K, L, A)
        
        # Simple trade assumption: fraction of output exported
        X = 0.2 * Y  # Exports (arbitrary share)
        M = X / tau_in  # Imports adjusted for iceberg cost
        
        I = delta * K  # Steady-state investment
        C = Y + M - I - X * tau_out  # Resource constraint
        
        # Check Euler equation in steady state
        res = euler_residual(C, C, r)
        if abs(res) < tol:
            break
        
        # Update capital (simplified adjustment)
        K_new = (w * L + r * K - C) / delta
        if abs(K_new - K) < tol:
            break
        K = 0.5 * K + 0.5 * K_new  # Damping for convergence
    
    return K, C, Y, r, w, X, M

# Simulate steady state for both countries
K1_init, K2_init = 1.0, 1.0
K1_ss, C1_ss, Y1_ss, r1_ss, w1_ss, X1_ss, M1_ss = steady_state(K1_init, A1, L1, tau_12, tau_21)
K2_ss, C2_ss, Y2_ss, r2_ss, w2_ss, X2_ss, M2_ss = steady_state(K2_init, A2, L2, tau_21, tau_12)

# Dynamics (simple simulation)
T = 50
K1_path = np.zeros(T)
K2_path = np.zeros(T)
K1_path[0], K2_path[0] = 0.5 * K1_ss, 0.5 * K2_ss
Y1, r1, w1, X1, M1, I1, C1 = np.zeros(T-1), np.zeros(T-1), np.zeros(T-1), np.zeros(T-1), np.zeros(T-1), np.zeros(T-1), np.zeros(T-1)
Y2, r2, w2, X2, M2, I2, C2 = np.zeros(T-1), np.zeros(T-1), np.zeros(T-1), np.zeros(T-1), np.zeros(T-1), np.zeros(T-1), np.zeros(T-1)

for t in range(T-1):
    Y1[t] = production(K1_path[t], L1, A1)
    r1[t] = rental_rate(K1_path[t], L1, A1)
    w1[t] = wage(K1_path[t], L1, A1)
    X1[t] = 0.2 * Y1[t]
    M1[t] = X1[t] / tau_12
    I1[t] = delta * K1_ss  # Target steady-state investment
    C1[t] = Y1[t] + M1[t] - I1[t] - X1[t] * tau_21
    K1_path[t+1] = (1 - delta) * K1_path[t] + I1[t]
    
    Y2[t] = production(K2_path[t], L2, A2)
    r2[t] = rental_rate(K2_path[t], L2, A2)
    w2[t] = wage(K2_path[t], L2, A2)
    X2[t] = 0.2 * Y2[t]
    M2[t] = X2[t] / tau_21
    I2[t] = delta * K2_ss
    C2[t] = Y2[t] + M2[t] - I2[t] - X2[t] * tau_12
    K2_path[t+1] = (1 - delta) * K2_path[t] + I2[t]

# Plotting
plt.plot(K1_path, label="Country 1 Capital")
plt.plot(K2_path, label="Country 2 Capital")
plt.axhline(K1_ss, color='blue', linestyle='--')
plt.axhline(K2_ss, color='orange', linestyle='--')
plt.xlabel("Time")
plt.ylabel("Capital Stock")
plt.legend()
plt.show()

# Print steady-state values
print("Country 1 Steady State:")
print(f"K = {K1_ss:.2f}, C = {C1_ss:.2f}, Y = {Y1_ss:.2f}, r = {r1_ss:.2f}, w = {w1_ss:.2f}")
print("Country 2 Steady State:")
print(f"K = {K2_ss:.2f}, C = {C2_ss:.2f}, Y = {Y2_ss:.2f}, r = {r2_ss:.2f}, w = {w2_ss:.2f}")
