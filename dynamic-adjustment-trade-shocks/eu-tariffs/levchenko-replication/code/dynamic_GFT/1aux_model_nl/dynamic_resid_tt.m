function T = dynamic_resid_tt(T, y, x, params, steady_state, it_)
% function T = dynamic_resid_tt(T, y, x, params, steady_state, it_)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double  vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double  vector of endogenous variables in the order stored
%                                                    in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double  matrix of exogenous variables (in declaration order)
%                                                    for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double  vector of steady state values
%   params        [M_.param_nbr by 1]        double  vector of parameter values in declaration order
%   it_           scalar                     double  time period for exogenous variables for which
%                                                    to evaluate the model
%
% Output:
%   T           [#temp variables by 1]       double  vector of temporary terms
%

assert(length(T) >= 74);

T(1) = params(7)/y(55);
T(2) = (1/params(8)*y(31))^params(8);
T(3) = (1/params(12)*y(32))^params(12);
T(4) = (1/params(16)*y(58))^params(16);
T(5) = (1/params(20)*y(59))^params(20);
T(6) = params(4)/(params(4)-1);
T(7) = (T(6)*y(36)*y(37)/params(9)*y(28))^(1-params(4));
T(8) = y(55)*T(6)*y(63)*y(64)/params(17)*y(54)/params(7);
T(9) = T(8)^(1-params(4));
T(10) = params(10)*y(2)*T(7)+y(15)*params(18)*T(9);
T(11) = 1/(1-params(4));
T(12) = (y(28)*T(6)*y(41)*y(42)/params(13))^(1-params(4));
T(13) = y(55)*y(54)*T(6)*y(68)*y(69)/params(21)/params(7);
T(14) = T(13)^(1-params(4));
T(15) = params(14)*y(5)*T(12)+y(18)*params(22)*T(14);
T(16) = params(7)*y(28)*T(6)*y(46)*y(47)/params(9)/y(55);
T(17) = T(16)^(1-params(4));
T(18) = (y(54)*T(6)*y(73)*y(74)/params(17))^(1-params(4));
T(19) = y(8)*params(11)*T(17)+y(21)*params(19)*T(18);
T(20) = params(7)*y(28)*T(6)*y(51)*y(52)/params(13)/y(55);
T(21) = T(20)^(1-params(4));
T(22) = (y(54)*T(6)*y(78)*y(79)/params(21))^(1-params(4));
T(23) = y(11)*params(15)*T(21)+y(24)*params(23)*T(22);
T(24) = y(36)^(-params(4));
T(25) = y(28)*T(6)*y(37)/params(9)/y(31);
T(26) = T(25)^(1-params(4));
T(27) = params(8)*params(10)*T(24)*T(26);
T(28) = y(41)^(-params(4));
T(29) = y(28)*T(6)*y(42)/params(13)/y(32);
T(30) = T(29)^(1-params(4));
T(31) = params(12)*params(14)*T(28)*T(30);
T(32) = y(46)^(-params(4));
T(33) = y(28)*T(6)*y(47)/params(9)/y(58);
T(34) = T(33)^(1-params(4));
T(35) = T(1)^(-params(4));
T(36) = y(51)^(-params(4));
T(37) = y(28)*T(6)*y(52)/params(13)/y(59);
T(38) = T(37)^(1-params(4));
T(39) = y(63)^(-params(4));
T(40) = y(54)*T(6)*y(64)/params(17)/y(31);
T(41) = T(40)^(1-params(4));
T(42) = params(8)*params(18)*T(39)*T(41);
T(43) = (y(55)/params(7))^(-params(4));
T(44) = T(42)*T(43);
T(45) = y(68)^(-params(4));
T(46) = y(54)*T(6)*y(69)/params(21)/y(32);
T(47) = T(46)^(1-params(4));
T(48) = params(12)*params(22)*T(45)*T(47);
T(49) = T(43)*T(48);
T(50) = y(73)^(-params(4));
T(51) = y(54)*T(6)*y(74)/params(17)/y(58);
T(52) = T(51)^(1-params(4));
T(53) = params(16)*params(19)*T(50)*T(52);
T(54) = y(78)^(-params(4));
T(55) = y(54)*T(6)*y(79)/params(21)/y(59);
T(56) = T(55)^(1-params(4));
T(57) = params(20)*params(23)*T(54)*T(56);
T(58) = params(1)*(y(80)/y(27))^(-params(2));
T(59) = 1/params(4);
T(60) = params(1)*(y(89)/y(53))^(-params(2));
T(61) = params(6)^params(5);
T(62) = y(35)/y(28);
T(63) = y(40)/y(28);
T(64) = y(45)/y(28);
T(65) = y(50)/y(28);
T(66) = y(62)/y(54);
T(67) = y(67)/y(54);
T(68) = y(72)/y(54);
T(69) = y(77)/y(54);
T(70) = (params(4)-1)/params(4);
T(71) = 1/y(28);
T(72) = T(70)*T(71);
T(73) = 1/y(54);
T(74) = params(5)*T(61)/(1+params(5));

end
