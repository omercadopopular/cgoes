import numpy as np
import matplotlib.pyplot as plt

# === Parameters ===
alpha = 0.33
beta = 0.96
delta = 0.08
A = 1.0
sigma = 2.0
T = 50 # Time horizon

# === Steady State ===
k_star = (alpha * A / (1 / beta - 1 + delta)) ** (1 / (1 - alpha))
c_star = A * k_star ** alpha - delta * k_star

# === Backward simulation from steady state ===
def simulate_backward_fixed(k_T, c_T, k_0):
    k = np.zeros(T + 1)
    c = np.zeros(T + 1)
    k[T] = k_T
    c[T] = c_T

    for t in reversed(range(T)):
        # Invert Euler equation to get c_t from c_{t+1}
        Rt = alpha * A * k[t + 1] ** (alpha - 1) + 1 - delta
        c[t] = c[t + 1] / (beta * Rt) ** (1 / sigma)

        # Invert capital accumulation: k_{t+1} = A k_t^alpha + (1 - delta) k_t - c_t
        # Solve for k_t given k_{t+1} and c_t
        rhs = k[t + 1] + c[t]

        def capital_fn(k_guess):
            return A * k_guess ** alpha + (1 - delta) * k_guess - rhs

        # Use bisection method to find root
        k_low, k_high = 1e-4, 2 * k_star
        for _ in range(100):
            k_mid = 0.5 * (k_low + k_high)
            if capital_fn(k_mid) > 0:
                k_high = k_mid
            else:
                k_low = k_mid
        k[t] = 0.5 * (k_low + k_high)

        if k[t] <= 0 or c[t] <= 0 or np.isnan(k[t]) or np.isnan(c[t]):
            return None, None, np.inf

    error = abs(k[0] - k_0)
    return k, c, error

# === Backward shooting over terminal consumption ===
def backward_shooting_fixed(k_T, c_min, c_max, k_0, n_grid=200):
    c_grid = np.linspace(c_min, c_max, n_grid)
    best_error = np.inf
    best_c_T = None
    best_k, best_c = None, None

    for c_T in c_grid:
        k_path, c_path, error = simulate_backward_fixed(k_T, c_T, k_0)
        if error < best_error:
            best_error = error
            best_c_T = c_T
            best_k = k_path
            best_c = c_path

    return best_c_T, best_k, best_c, best_error

# === Run the backward shooting ===
k_0 = 0.5 * k_star
cT_opt, k_path, c_path, error = backward_shooting_fixed(k_star, 0.5 * c_star, 1.5 * c_star, k_0)

# === Plot results ===
if k_path is not None and c_path is not None:
    t_grid = np.arange(T + 1)
    plt.figure(figsize=(10, 5))
    plt.plot(t_grid, k_path, label='Capital $k_t$')
    plt.plot(t_grid, c_path, label='Consumption $c_t$')
    plt.axhline(k_star, color='gray', linestyle='--', label='Steady State $k^*$')
    plt.axhline(c_star, color='gray', linestyle='--', label='Steady State $c^*$')
    plt.xlabel("Time")
    plt.title("Backward Shooting Algorithm (Discrete Time)")
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()
else:
    print("Backward shooting failed: all trajectories invalid.")
