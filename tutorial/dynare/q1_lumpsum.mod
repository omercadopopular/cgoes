% Carlos Góes

%----------------------------------------------------------------
% 0. HOUSEKEEPING
%----------------------------------------------------------------

close all;

%----------------------------------------------------------------
% 1. VARIABLES AND PARAMETERS
%----------------------------------------------------------------

% VARIABLE DEFINITIONS

%   y = output
%   c = consumption
%   i = investment
%   k = capital stock, end of period
%   n = hours
%   z = labor-augmenting technological progress
%   gc = government consumption purchases
%   gi = public investment
%   gk = public capital
%   w = wages
%   r = rents
%   varphi = lump-sum transfers

%  ENDOGENOUS VARIABLES

var y c k i n w r gc varphi gi gk;  

% EXOGENOUS VARIABLES

varexo e;

% PARAMETERS

parameters beta phi sigma delta alpha psi z rho;  
parameters tauk taun deltag theta;  
parameters ky_ss iy_ss cy_ss gcy_ss gc_ss n_ss y_ss r_ss varphi_ss varphiy_ss w_ss giy_ss gky_ss gi_ss gk_ss;

%----------------------------------------------------------------
% 2. CALIBRATION: PARAMETER VALUES AND DEFINITIONS
%----------------------------------------------------------------

alpha   = 0.36;            %  exponent on capital
theta  = .05;             % public capital prod. fn exponent
sigma   = 1;               %  inverse of the intertemporal elasticity of substitution
beta    = 0.99;            %  discount factor
delta   = 0.015;           %  depreciation rate on capital
deltag   = 0.01;           %  depreciation rate on public capital
psi      = 1;               %  parameter on labor disutility
phi     = 0.25;            %  inverse Frisch elasticity
rho    = 0.95;            % AR(1) on government spending/apportionments
z       = 1;               % Labor-augmenting technology
taun = 0;                % labor-income tax rate
tauk = 0;                % capital-income tax rate

%----------------------------------------------------------------
% 3. STEADY-STATE VALUES
%----------------------------------------------------------------

z_ss = 1; // SS technology

r_ss = ( (1-beta*(1-(1-tauk)*delta)) / ((1-tauk)*beta) ); // SS interest rate
ky_ss = alpha / r_ss; // SS capital-output ratio
iy_ss = delta*ky_ss; // SS investment-output ratio

gcy_ss = 0.14; // government expenditures (as a % of steady state output)

giy_ss = 0.035;  // SS public investment-output ratio (exogenous)
gky_ss = giy_ss/deltag;  // SS public capital-output ratio

varphiy_ss = (1-alpha)*taun + tauk*(r_ss-delta)*ky_ss - giy_ss - gcy_ss; // lump sum transfers

cy_ss = 1 - gcy_ss - giy_ss - iy_ss; // steady state private consumption to output ratio

n_ss = ((1/psi) * cy_ss^(-sigma) * (1-taun) * (1-alpha))^((1-alpha-theta)/((1-alpha-theta)*(1+phi)-(1-alpha)*(1-sigma))) * (z * ky_ss^alpha * gky_ss^theta )^((1-sigma)/((1-alpha-theta)*(1+phi) - (1-alpha)*(1-sigma))); // SS hours

y_ss = ( z_ss * ky_ss^alpha * n_ss^(1-alpha) * gky_ss^theta  ) ^( 1/(1-alpha-theta) ); // SS output

w_ss = (1-alpha)*y_ss/n_ss; // SS wages

c_ss = cy_ss*y_ss;
k_ss = ky_ss*y_ss;

gc_ss = gcy_ss*y_ss;
varphi_ss = varphiy_ss*y_ss;
gk_ss = gky_ss*y_ss;
gi_ss = giy_ss*y_ss;

i_ss = iy_ss*y_ss;

%----------------------------------------------------------------
% 4. MODEL
%----------------------------------------------------------------

model; 

%----------------------------------------------------------------
% Expressions for use in model equations
%----------------------------------------------------------------


% 1) CONSUMPTION EULER EQUATION 

 (c/c(+1))^(-sigma) = beta*(r(+1) - tauk*(r(+1) - delta) + (1-delta));

% 2) LABOR LEISURE CONDITION

psi * n^phi = c^(-sigma) * (1-taun)* w;

% 3) LABOR DEMAND

 (1-alpha) * y / n = w;

% 4) CAPITAL DEMAND

alpha * y / k(-1) = r;

% 5) PRIVATE CAPITAL ACCUMULATION

  i = k - (1-delta)*k(-1);

% 6) EXOGENOUS INVESTMENT PROCESS

  gi = gi_ss;

% 7) PUBLIC CAPITAL ACCUMULATION

  gi = gk - (1-deltag)*gk(-1);

% 8) RESOURCE CONSTRAINT

   y = c + i + gc + gi;  

% 9) PRODUCTION FUNCTION

  y = z*(k(-1))^(alpha)*n^(1-alpha)*(gk(-1))^(theta);

% 10) GOVERNMENT SPENDING PROCESS

%  Shock to government spending

gc = (1-rho)*(gc_ss) + rho*gc(-1) + e;

% 11) GOVERNMENT RESOURCE CONSTRAINT

 varphi = taun * w * n + tauk*(r-delta)*k(-1) - gi - gc;

end;

%----------------------------------------------------------------
% 5. COMPUTATION
%----------------------------------------------------------------

initval;
  y = y_ss;
  c = c_ss;
  k = k_ss;
  i = i_ss;
  w = w_ss;
  r = r_ss;
  n = n_ss;
  gc = gc_ss;
  gi = gi_ss;
  gk = gk_ss;
  varphi = varphi_ss;
end;

 check;
 steady; 

 shocks;
% var e; stderr 1*y_ss;
 var e;
 periods 1;
 values (.01*y_ss);
 end;

%stoch_simul(loglinear, order = 1, irf=100);
perfect_foresight_setup(periods=400);
perfect_foresight_solver;

%A = [oo_.exo_simul, oo_.endo_simul'];
A = [oo_.exo_simul, gc, y, c, i, n, k] ;
