function T = dynamic_g1_tt(T, y, x, params, steady_state, it_)
% function T = dynamic_g1_tt(T, y, x, params, steady_state, it_)
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

assert(length(T) >= 118);

T = aux_model_nl.dynamic_resid_tt(T, y, x, params, steady_state, it_);

T(75) = getPowerDeriv(y(80)/y(27),(-params(2)),1);
T(76) = params(1)*(-y(80))/(y(27)*y(27))*T(75);
T(77) = params(1)*T(75)*1/y(27);
T(78) = getPowerDeriv(T(6)*y(36)*y(37)/params(9)*y(28),1-params(4),1);
T(79) = getPowerDeriv(T(10),T(11),1);
T(80) = getPowerDeriv(y(28)*T(6)*y(41)*y(42)/params(13),1-params(4),1);
T(81) = getPowerDeriv(T(15),T(11),1);
T(82) = getPowerDeriv(T(16),1-params(4),1);
T(83) = getPowerDeriv(T(19),T(11),1);
T(84) = getPowerDeriv(T(20),1-params(4),1);
T(85) = getPowerDeriv(T(23),T(11),1);
T(86) = getPowerDeriv(T(25),1-params(4),1);
T(87) = getPowerDeriv(T(29),1-params(4),1);
T(88) = getPowerDeriv(T(33),1-params(4),1);
T(89) = getPowerDeriv(T(37),1-params(4),1);
T(90) = getPowerDeriv(T(62),params(5),1);
T(91) = getPowerDeriv(T(63),params(5),1);
T(92) = getPowerDeriv(T(64),params(5),1);
T(93) = getPowerDeriv(T(65),params(5),1);
T(94) = getPowerDeriv(T(62),1+params(5),1);
T(95) = getPowerDeriv(T(63),1+params(5),1);
T(96) = getPowerDeriv(T(64),1+params(5),1);
T(97) = getPowerDeriv(T(65),1+params(5),1);
T(98) = getPowerDeriv(T(40),1-params(4),1);
T(99) = getPowerDeriv(T(46),1-params(4),1);
T(100) = getPowerDeriv(y(89)/y(53),(-params(2)),1);
T(101) = params(1)*(-y(89))/(y(53)*y(53))*T(100);
T(102) = params(1)*T(100)*1/y(53);
T(103) = getPowerDeriv(T(8),1-params(4),1);
T(104) = getPowerDeriv(T(13),1-params(4),1);
T(105) = getPowerDeriv(y(54)*T(6)*y(73)*y(74)/params(17),1-params(4),1);
T(106) = getPowerDeriv(y(54)*T(6)*y(78)*y(79)/params(21),1-params(4),1);
T(107) = getPowerDeriv(T(51),1-params(4),1);
T(108) = getPowerDeriv(T(55),1-params(4),1);
T(109) = getPowerDeriv(T(66),params(5),1);
T(110) = getPowerDeriv(T(67),params(5),1);
T(111) = getPowerDeriv(T(68),params(5),1);
T(112) = getPowerDeriv(T(69),params(5),1);
T(113) = getPowerDeriv(T(66),1+params(5),1);
T(114) = getPowerDeriv(T(67),1+params(5),1);
T(115) = getPowerDeriv(T(68),1+params(5),1);
T(116) = getPowerDeriv(T(69),1+params(5),1);
T(117) = (-params(7))/(y(55)*y(55))*getPowerDeriv(T(1),(-params(4)),1);
T(118) = 1/params(7)*getPowerDeriv(y(55)/params(7),(-params(4)),1);

end
