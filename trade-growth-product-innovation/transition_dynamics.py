
import numpy as np
from dataclasses import dataclass
from typing import Dict, Tuple, List, Any
from scipy.optimize import least_squares

# ============================
# Parameters
# ============================

@dataclass
class Params:
    theta: float = 4.0     # EK shape
    alpha: float = 0.36    # labor share in final (implies eta=1/(1-alpha))
    psi: float = 0.5       # R&D productivity (adjust in calibration)
    rho: float = 0.03      # discount rate

# ============================
# Static block (paper version)
# ============================

def static_block_paper(M: np.ndarray, Tscale: np.ndarray, tau: np.ndarray, L: np.ndarray, params: Params,
                       normalize_price_index: bool = True) -> Dict[str, np.ndarray]:
    """
    Inputs
    ------
    M : (N,)    variety stocks
    Tscale : (N,)  Frechet scale parameters for final goods
    tau : (N,N) iceberg costs
    L : (N,)    labor
    params : Params

    Returns
    -------
    dict with: w, P, PM, lambdaF, lambdaM, Y, Pi, r_over_P

    Conventions (paper-consistent):
      pM_ks = tau_ks * P_k / alpha
      PM_s = [ Σ_k M_k pM_ks^(1-eta) ]^(1/(1-eta))
      λ^M_sd = M_s * (pM_sd)^(1-eta) / [ Σ_k M_k * (pM_kd)^(1-eta) ]
      c_s = PM_s^alpha * w_s^(1-alpha)
      P_d = [ Σ_k Tscale_k * (c_k^(-theta) * tau_kd^(-theta)) ]^(-1/theta)
      λ^F_sd = Tscale_s * (c_s^(-theta) * tau_sd^(-theta)) / [ Σ_k ... ]
      Π_s=(α/η) Σ_d λ^M_sd P_d Y_d
      r/P = ψ * (Π_s / M_s) / P_s   (inflation added in dynamics layer)
    """
    N = len(M)
    theta, alpha = params.theta, params.alpha
    eta = 1.0 / (1.0 - alpha)

    # Initialize wages and prices
    w = np.ones(N)
    P = np.ones(N)

    def compute_PM(P_now: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        # Unit cost for M from source k to destination s
        pM = (tau * (P_now[None, :] / alpha))  # shape (k,s)
        # CES price index across sources for each destination s
        base = np.sum(M[:, None] * np.power(np.maximum(pM, 1e-18), (1.0 - eta)), axis=0)
        PM = np.power(np.maximum(base, 1e-18), 1.0 / (1.0 - eta))
        return PM, pM

    for _ in range(200):
        PM, pM = compute_PM(P)
        # Final-goods composite unit cost
        c = np.power(PM, alpha) * np.power(w, (1.0 - alpha))
        # Final-goods price index via EK
        numer = (Tscale[:, None] * np.power(np.maximum(c[:, None] * tau, 1e-18), -theta))
        denom = np.sum(numer, axis=0, keepdims=True)
        P_new = np.power(np.maximum(denom, 1e-18), -1.0 / theta).ravel()
        if normalize_price_index and P_new[0] != 0.0:
            P_new = P_new / P_new[0]
        # λ^M and λ^F
        lambdaM_num = (M[:, None] * np.power(np.maximum(pM, 1e-18), (1.0 - eta)))
        lambdaM_den = np.sum(lambdaM_num, axis=0, keepdims=True)
        lambdaM = lambdaM_num / np.maximum(lambdaM_den, 1e-18)

        lambdaF_num = numer
        lambdaF = lambdaF_num / np.maximum(denom, 1e-18)

        # Expenditure mapping A: shares of PY going to country s
        A = (1.0 - alpha) * lambdaF + (alpha / eta) * lambdaM

        # Power method for PY (principal right eigenvector of A^T)
        PY = np.ones(N)
        base = max(PY[0], 1e-14)
        PY /= base
        for __ in range(200):
            PY_next = A @ PY
            base = max(PY_next[0], 1e-14)
            PY_next = PY_next / base
            if np.max(np.abs(PY_next - PY)) < 1e-12:
                PY = PY_next
                break
            PY = 0.5 * PY + 0.5 * PY_next

        Pi = (alpha / eta) * (lambdaM @ PY)
        # GDP identity: P*Y = PY  ->  Y = (PY) / P
        P_safe = np.maximum(P_new, 1e-18)
        Y = PY / P_safe

        # Factor income: wL = PY - Pi  -> update w
        w_new = (PY - Pi) / np.maximum(L, 1e-18)
        w_new = np.maximum(w_new, 1e-12)

        # Damping
        w = 0.5 * w + 0.5 * w_new
        P = 0.5 * P + 0.5 * P_new

        if max(np.max(np.abs(w_new - w)), np.max(np.abs(P_new - P))) < 1e-12:
            break

    # Recompute final objects
    PM, pM = compute_PM(P)
    c = np.power(PM, alpha) * np.power(w, (1.0 - alpha))
    numer = (Tscale[:, None] * np.power(np.maximum(c[:, None] * tau, 1e-18), -theta))
    denom = np.sum(numer, axis=0, keepdims=True)
    lambdaF = numer / np.maximum(denom, 1e-18)
    lambdaM_num = (M[:, None] * np.power(np.maximum(pM, 1e-18), (1.0 - eta)))
    lambdaM_den = np.sum(lambdaM_num, axis=0, keepdims=True)
    lambdaM = lambdaM_num / np.maximum(lambdaM_den, 1e-18)
    A = (1.0 - alpha) * lambdaF + (alpha / eta) * lambdaM

    PY = np.ones(N)
    base = max(PY[0], 1e-14); PY /= base
    for __ in range(200):
        PY_next = A @ PY
        base = max(PY_next[0], 1e-14)
        PY_next = PY_next / base
        if np.max(np.abs(PY_next - PY)) < 1e-14:
            PY = PY_next
            break
        PY = 0.5 * PY + 0.5 * PY_next

    Pi = (alpha / eta) * (lambdaM @ PY)
    P_safe = np.maximum(P, 1e-18)
    Y = PY / P_safe
    r_over_P = params.psi * (Pi / np.maximum(M, 1e-18)) / P_safe  # add inflation in dynamics layer

    return dict(w=w, P=P, PM=PM, lambdaF=lambdaF, lambdaM=lambdaM, Y=Y, Pi=Pi, r_over_P=r_over_P)

# ============================
# Residual builder (time path)
# ============================

def build_residuals_path(M_path: np.ndarray, C_path: np.ndarray, Tscale: np.ndarray, tau_t: np.ndarray, L: np.ndarray,
                         params: Params, dt: float) -> Tuple[np.ndarray, Dict[str, List[Dict[str, np.ndarray]]]]:
    """
    Build stacked residuals for forward Euler discretization.
    Inputs:
      - M_path: (T+1, N)
      - C_path: (T+1, N)
      - Tscale: (N,)
      - tau_t: (T+1, N, N) trade costs per date
      - L: (N,)
      - params
      - dt: time step
    Returns:
      - residual vector (shape (2*T*N + N,))
      - cache dict with static outputs per t
    """
    Tn, N = M_path.shape[0]-1, M_path.shape[1]
    res_list = []
    cache: Dict[str, Any] = {"static": []}

    prev_P = None
    for t in range(Tn+1):
        M_t = M_path[t]
        st = static_block_paper(M_t, Tscale, tau_t[t], L, params)
        cache["static"].append(st)
        # inflation term d ln P/dt (backward diff for t>=1)
        if prev_P is None:
            infl = np.zeros(N)
        else:
            infl = (np.log(np.maximum(st["P"], 1e-18)) - np.log(np.maximum(prev_P, 1e-18))) / dt
        st["r_over_P_full"] = st["r_over_P"] + infl
        prev_P = st["P"].copy()

    # Residuals for t=0..T-1 using forward Euler
    for t in range(Tn):
        st = cache["static"][t]
        rP = st["r_over_P_full"]
        w = st["w"]
        P = np.maximum(st["P"], 1e-18)

        M_next = M_path[t+1]
        M_curr = M_path[t]
        C_curr = C_path[t]

        # dM residual: M_{t+1} - M_t - dt*( (r/P)M + ψ*(w/P)L - ψ*C )
        dM = M_next - M_curr - dt * (rP * M_curr + params.psi * (w / P) * L - params.psi * C_curr)
        res_list.append(dM)

        # dC residual: C_{t+1} - C_t - dt*( C_t*(r/P - ρ) )
        dC = C_path[t+1] - C_curr - dt * (C_curr * (rP - params.rho))
        res_list.append(dC)

    # Terminal Euler condition r_T/P_T ≈ ρ
    stT = cache["static"][-1]
    term = stT["r_over_P_full"] - params.rho
    res_list.append(term)

    res = np.concatenate(res_list, axis=0)
    return res, cache

# ============================
# Utilities: tau path & initial guesses
# ============================

def solve_bgp_stub(M_guess: np.ndarray, Tscale: np.ndarray, tau: np.ndarray, L: np.ndarray, params: Params) -> Dict[str, np.ndarray]:
    """Lightweight BGP anchor using static block at constant (M, tau)."""
    return static_block_paper(M_guess, Tscale, tau, L, params)

def make_initial_paths(Tn: int, N: int, M0: np.ndarray, C0: np.ndarray,
                       Mstar: np.ndarray = None, Cstar: np.ndarray = None, bridge: float = 0.9):
    M_path = np.tile(M0, (Tn+1, 1)).astype(float)
    C_path = np.tile(C0, (Tn+1, 1)).astype(float)
    if Mstar is not None:
        for t in range(1, Tn+1):
            w = 1.0 - bridge**t
            M_path[t] = (1-w)*M0 + w*Mstar
    if Cstar is not None:
        for t in range(1, Tn+1):
            w = 1.0 - bridge**t
            C_path[t] = (1-w)*C0 + w*Cstar
    return M_path, C_path

def build_tau_path(tau0: np.ndarray, tau1: np.ndarray, Tn: int, half_life: float = 3.0):
    tau_t = np.zeros((Tn+1,) + tau0.shape, dtype=float)
    for t in range(Tn+1):
        w = 1.0 - np.exp(-t / max(half_life, 1e-9))
        tau_t[t] = (1-w) * tau0 + w * tau1
    return tau_t

def pack_paths(M_path: np.ndarray, C_path: np.ndarray) -> np.ndarray:
    return np.concatenate([np.log(np.clip(M_path, 1e-12, None)).ravel(),
                           np.log(np.clip(C_path, 1e-12, None)).ravel()])

def unpack_paths(U: np.ndarray, Tn: int, N: int) -> Tuple[np.ndarray, np.ndarray]:
    size = (Tn+1)*N
    x = U[:size]; y = U[size:]
    M = np.exp(x.reshape(Tn+1, N))
    C = np.exp(y.reshape(Tn+1, N))
    return M, C

# ============================
# Main transition solver
# ============================

def solve_transition(M0: np.ndarray, C0: np.ndarray, Tscale: np.ndarray, tau0: np.ndarray, tau1: np.ndarray, L: np.ndarray,
                     params: Params, Tn: int = 60, dt: float = 1.0,
                     Mstar: np.ndarray = None, Cstar: np.ndarray = None,
                     homotopy_steps: Tuple[float, ...] = (0.3, 0.6, 1.0),
                     tau_half_life: float = 2.0) -> Tuple[np.ndarray, np.ndarray, Dict[str, Any]]:
    """
    Solves the perfect-foresight transition using least-squares on stacked residuals.
    Returns M_path, C_path, and a cache with static objects per t for the final solve.
    """
    N = len(M0)

    st0 = solve_bgp_stub(M0, Tscale, tau0, L, params)
    st1 = solve_bgp_stub(M0, Tscale, tau1, L, params)

    M_path, C_path = make_initial_paths(Tn, N, M0, C0, Mstar, Cstar, bridge=0.9)
    U = pack_paths(M_path, C_path)

    final_cache = {}
    for mu in homotopy_steps:
        tau_mu1 = tau0 + mu * (tau1 - tau0)
        tau_path = build_tau_path(tau0, tau_mu1, Tn, half_life=tau_half_life)

        def F(Uvec: np.ndarray) -> np.ndarray:
            M, C = unpack_paths(Uvec, Tn, N)
            res, cache = build_residuals_path(M, C, Tscale, tau_path, L, params, dt)
            # keep a reference cache for the last evaluation (for diagnostics)
            nonlocal final_cache
            final_cache = cache
            return res

        sol = least_squares(F, U, method="trf", xtol=1e-10, ftol=1e-10, gtol=1e-10, max_nfev=500)
        U = sol.x

    M_sol, C_sol = unpack_paths(U, Tn, N)
    return M_sol, C_sol, final_cache
