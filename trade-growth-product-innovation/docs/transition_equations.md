# Transition dynamics: core equations (EK × Romer)

This page lists the equilibrium relationships to include in a perfect-foresight sequence-of-static-equilibria (SSE) solver.

Notation: countries s,k,d ∈ {1,…,N}; parameters θ (EK), α (labor share in final), η=1/(1−α) (intermediate CES), ψ (R&D productivity), ρ (discount rate), T_s (EK scale), L_s (labor). State: M_s(t). Control (kept): C_s(t). Trade costs τ_sd(t).

1) Final-good unit cost and price index
- c_s(t) = PM_s(t)^α · w_s(t)^(1−α)
- P_d(t) = [ Σ_s T_s · (c_s(t) · τ_sd(t))^(−θ) ]^(−1/θ)

2) EK final-good shares
- λ^F_sd(t) = T_s (c_s(t) τ_sd(t))^(−θ) / Σ_n T_n (c_n(t) τ_nd(t))^(−θ)

3) Intermediate pricing and composite price
- p^M_ks(t) = τ_ks(t) · P_k(t) / α
- PM_s(t) = [ Σ_k M_k(t) · (p^M_ks(t))^(1−η) ]^(1/(1−η))

4) Intermediate trade shares
- λ^M_sd(t) = M_s(t) · (p^M_sd(t))^(1−η) / Σ_k M_k(t) (p^M_kd(t))^(1−η)

5) Profits, GDP, and expenditure identities (nominal)
- Π_s(t) = (α/η) · Σ_d λ^M_sd(t) · P_d(t) Y_d(t)
- P_s(t) Y_s(t) = w_s(t) L_s + Π_s(t)
- P_s(t) Y_s(t) = Σ_d [ (1−α) λ^F_sd(t) + (α/η) λ^M_sd(t) ] · P_d(t) Y_d(t)
- Trade balance: net exports_s(t) = 0 (zero international asset markets)

6) No-arbitrage (equity) and flow profits per variety
- π_s(t) = Π_s(t) / M_s(t)
- r_s(t)/P_s(t) = ψ · π_s(t)/P_s(t) + d ln P_s(t)/dt

7) Dynamics (log preferences)
- d ln C_s(t)/dt = r_s(t)/P_s(t) − ρ
- dM_s(t)/dt = (r_s(t)/P_s(t)) · M_s(t) + ψ · (w_s(t)/P_s(t)) · L_s − ψ · C_s(t)

8) Boundary and normalization
- Initial: M_s(0)=M_s0; optionally C_s(0) from the wealth rule
- Terminal (perfect foresight): M_T = M*_∞, C_T = C*_∞ or r_T/P_T ≈ ρ, no explosive assets
- Per-date normalization: fix P_1(t)=1 (or w_1(t)=1)
