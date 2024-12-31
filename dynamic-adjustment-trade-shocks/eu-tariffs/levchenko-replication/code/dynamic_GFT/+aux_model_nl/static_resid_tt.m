function T = static_resid_tt(T, y, x, params)
% function T = static_resid_tt(T, y, x, params)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T         [#temp variables by 1]  double   vector of temporary terms to be filled by function
%   y         [M_.endo_nbr by 1]      double   vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1]       double   vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1]     double   vector of parameter values in declaration order
%
% Output:
%   T         [#temp variables by 1]  double   vector of temporary terms
%

assert(length(T) >= 72);

T(1) = params(7)/y(29);
T(2) = (1/params(8)*y(5))^params(8);
T(3) = (1/params(12)*y(6))^params(12);
T(4) = (1/params(16)*y(32))^params(16);
T(5) = (1/params(20)*y(33))^params(20);
T(6) = params(4)/(params(4)-1);
T(7) = (T(6)*y(10)*y(11)/params(9)*y(2))^(1-params(4));
T(8) = y(29)*T(6)*y(37)*y(38)/params(17)*y(28)/params(7);
T(9) = T(8)^(1-params(4));
T(10) = params(10)*y(8)*T(7)+y(35)*params(18)*T(9);
T(11) = 1/(1-params(4));
T(12) = (y(2)*T(6)*y(15)*y(16)/params(13))^(1-params(4));
T(13) = y(29)*y(28)*T(6)*y(42)*y(43)/params(21)/params(7);
T(14) = T(13)^(1-params(4));
T(15) = params(14)*y(13)*T(12)+y(40)*params(22)*T(14);
T(16) = params(7)*y(2)*T(6)*y(20)*y(21)/params(9)/y(29);
T(17) = T(16)^(1-params(4));
T(18) = (y(28)*T(6)*y(47)*y(48)/params(17))^(1-params(4));
T(19) = y(18)*params(11)*T(17)+y(45)*params(19)*T(18);
T(20) = params(7)*y(2)*T(6)*y(25)*y(26)/params(13)/y(29);
T(21) = T(20)^(1-params(4));
T(22) = (y(28)*T(6)*y(52)*y(53)/params(21))^(1-params(4));
T(23) = y(23)*params(15)*T(21)+y(50)*params(23)*T(22);
T(24) = y(10)^(-params(4));
T(25) = y(2)*T(6)*y(11)/params(9)/y(5);
T(26) = T(25)^(1-params(4));
T(27) = params(8)*params(10)*T(24)*T(26);
T(28) = y(15)^(-params(4));
T(29) = y(2)*T(6)*y(16)/params(13)/y(6);
T(30) = T(29)^(1-params(4));
T(31) = params(12)*params(14)*T(28)*T(30);
T(32) = y(20)^(-params(4));
T(33) = y(2)*T(6)*y(21)/params(9)/y(32);
T(34) = T(33)^(1-params(4));
T(35) = T(1)^(-params(4));
T(36) = y(25)^(-params(4));
T(37) = y(2)*T(6)*y(26)/params(13)/y(33);
T(38) = T(37)^(1-params(4));
T(39) = y(37)^(-params(4));
T(40) = y(28)*T(6)*y(38)/params(17)/y(5);
T(41) = T(40)^(1-params(4));
T(42) = params(8)*params(18)*T(39)*T(41);
T(43) = (y(29)/params(7))^(-params(4));
T(44) = T(42)*T(43);
T(45) = y(42)^(-params(4));
T(46) = y(28)*T(6)*y(43)/params(21)/y(6);
T(47) = T(46)^(1-params(4));
T(48) = params(12)*params(22)*T(45)*T(47);
T(49) = T(43)*T(48);
T(50) = y(47)^(-params(4));
T(51) = y(28)*T(6)*y(48)/params(17)/y(32);
T(52) = T(51)^(1-params(4));
T(53) = params(16)*params(19)*T(50)*T(52);
T(54) = y(52)^(-params(4));
T(55) = y(28)*T(6)*y(53)/params(21)/y(33);
T(56) = T(55)^(1-params(4));
T(57) = params(20)*params(23)*T(54)*T(56);
T(58) = 1/params(4);
T(59) = params(6)^params(5);
T(60) = y(9)/y(2);
T(61) = y(14)/y(2);
T(62) = y(19)/y(2);
T(63) = y(24)/y(2);
T(64) = y(36)/y(28);
T(65) = y(41)/y(28);
T(66) = y(46)/y(28);
T(67) = y(51)/y(28);
T(68) = (params(4)-1)/params(4);
T(69) = 1/y(2);
T(70) = T(68)*T(69);
T(71) = 1/y(28);
T(72) = params(5)*T(59)/(1+params(5));

end
