function T = static_g1_tt(T, y, x, params)
% function T = static_g1_tt(T, y, x, params)
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

assert(length(T) >= 110);

T = aux_model_nl.static_resid_tt(T, y, x, params);

T(73) = getPowerDeriv(T(6)*y(10)*y(11)/params(9)*y(2),1-params(4),1);
T(74) = getPowerDeriv(T(10),T(11),1);
T(75) = getPowerDeriv(y(2)*T(6)*y(15)*y(16)/params(13),1-params(4),1);
T(76) = getPowerDeriv(T(15),T(11),1);
T(77) = getPowerDeriv(T(16),1-params(4),1);
T(78) = getPowerDeriv(T(19),T(11),1);
T(79) = getPowerDeriv(T(20),1-params(4),1);
T(80) = getPowerDeriv(T(23),T(11),1);
T(81) = getPowerDeriv(T(25),1-params(4),1);
T(82) = getPowerDeriv(T(29),1-params(4),1);
T(83) = getPowerDeriv(T(33),1-params(4),1);
T(84) = getPowerDeriv(T(37),1-params(4),1);
T(85) = getPowerDeriv(T(60),params(5),1);
T(86) = getPowerDeriv(T(61),params(5),1);
T(87) = getPowerDeriv(T(62),params(5),1);
T(88) = getPowerDeriv(T(63),params(5),1);
T(89) = getPowerDeriv(T(60),1+params(5),1);
T(90) = getPowerDeriv(T(61),1+params(5),1);
T(91) = getPowerDeriv(T(62),1+params(5),1);
T(92) = getPowerDeriv(T(63),1+params(5),1);
T(93) = getPowerDeriv(T(40),1-params(4),1);
T(94) = getPowerDeriv(T(46),1-params(4),1);
T(95) = getPowerDeriv(T(8),1-params(4),1);
T(96) = getPowerDeriv(T(13),1-params(4),1);
T(97) = getPowerDeriv(y(28)*T(6)*y(47)*y(48)/params(17),1-params(4),1);
T(98) = getPowerDeriv(y(28)*T(6)*y(52)*y(53)/params(21),1-params(4),1);
T(99) = getPowerDeriv(T(51),1-params(4),1);
T(100) = getPowerDeriv(T(55),1-params(4),1);
T(101) = getPowerDeriv(T(64),params(5),1);
T(102) = getPowerDeriv(T(65),params(5),1);
T(103) = getPowerDeriv(T(66),params(5),1);
T(104) = getPowerDeriv(T(67),params(5),1);
T(105) = getPowerDeriv(T(64),1+params(5),1);
T(106) = getPowerDeriv(T(65),1+params(5),1);
T(107) = getPowerDeriv(T(66),1+params(5),1);
T(108) = getPowerDeriv(T(67),1+params(5),1);
T(109) = (-params(7))/(y(29)*y(29))*getPowerDeriv(T(1),(-params(4)),1);
T(110) = 1/params(7)*getPowerDeriv(y(29)/params(7),(-params(4)),1);

end
