function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
% function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double   vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double   vector of endogenous variables in the order stored
%                                                     in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double   matrix of exogenous variables (in declaration order)
%                                                     for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double   vector of steady state values
%   params        [M_.param_nbr by 1]        double   vector of parameter values in declaration order
%   it_           scalar                     double   time period for exogenous variables for which
%                                                     to evaluate the model
%   T_flag        boolean                    boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = aux_model_nl.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(53, 1);
lhs = T(1)*y(8)*y(43)+T(1)*y(11)*y(48)+y(21)*y(70)+y(24)*y(75);
rhs = y(24)*y(75)+y(21)*y(70)+y(15)*y(60)+y(18)*y(65);
residual(1) = lhs - rhs;
lhs = 1;
rhs = T(2)*T(3);
residual(2) = lhs - rhs;
lhs = 1;
rhs = T(4)*T(5);
residual(3) = lhs - rhs;
lhs = y(31);
rhs = T(10)^T(11);
residual(4) = lhs - rhs;
lhs = y(32);
rhs = T(15)^T(11);
residual(5) = lhs - rhs;
lhs = y(58);
rhs = T(19)^T(11);
residual(6) = lhs - rhs;
lhs = y(59);
rhs = T(23)^T(11);
residual(7) = lhs - rhs;
lhs = y(33);
rhs = T(27)*y(27);
residual(8) = lhs - rhs;
lhs = y(38);
rhs = y(27)*T(31);
residual(9) = lhs - rhs;
lhs = y(43);
rhs = params(16)*params(11)*T(32)*T(34)*T(35)*y(53);
residual(10) = lhs - rhs;
lhs = y(48);
rhs = y(53)*T(35)*params(20)*params(15)*T(36)*T(38);
residual(11) = lhs - rhs;
lhs = y(60);
rhs = y(27)*T(44);
residual(12) = lhs - rhs;
lhs = y(65);
rhs = y(27)*T(49);
residual(13) = lhs - rhs;
lhs = y(70);
rhs = y(53)*T(53);
residual(14) = lhs - rhs;
lhs = y(75);
rhs = y(53)*T(57);
residual(15) = lhs - rhs;
lhs = y(35);
rhs = T(58)*(T(59)*y(81)+(1-params(3))*y(82));
residual(16) = lhs - rhs;
lhs = y(40);
rhs = T(58)*(T(59)*y(83)+(1-params(3))*y(84));
residual(17) = lhs - rhs;
lhs = y(45);
rhs = T(58)*(T(59)*y(85)+(1-params(3))*y(86));
residual(18) = lhs - rhs;
lhs = y(50);
rhs = T(58)*(T(59)*y(87)+(1-params(3))*y(88));
residual(19) = lhs - rhs;
lhs = y(62);
rhs = T(60)*(T(59)*y(90)+(1-params(3))*y(91));
residual(20) = lhs - rhs;
lhs = y(67);
rhs = T(60)*(T(59)*y(92)+(1-params(3))*y(93));
residual(21) = lhs - rhs;
lhs = y(72);
rhs = T(60)*(T(59)*y(94)+(1-params(3))*y(95));
residual(22) = lhs - rhs;
lhs = y(77);
rhs = T(60)*(T(59)*y(96)+(1-params(3))*y(97));
residual(23) = lhs - rhs;
lhs = y(34);
rhs = y(2)*(1-params(3))+T(61)*T(62)^params(5);
residual(24) = lhs - rhs;
lhs = y(39);
rhs = y(5)*(1-params(3))+T(61)*T(63)^params(5);
residual(25) = lhs - rhs;
lhs = y(44);
rhs = y(8)*(1-params(3))+T(61)*T(64)^params(5);
residual(26) = lhs - rhs;
lhs = y(49);
rhs = y(11)*(1-params(3))+T(61)*T(65)^params(5);
residual(27) = lhs - rhs;
lhs = y(61);
rhs = y(15)*(1-params(3))+T(61)*T(66)^params(5);
residual(28) = lhs - rhs;
lhs = y(66);
rhs = y(18)*(1-params(3))+T(61)*T(67)^params(5);
residual(29) = lhs - rhs;
lhs = y(71);
rhs = y(21)*(1-params(3))+T(61)*T(68)^params(5);
residual(30) = lhs - rhs;
lhs = y(76);
rhs = y(24)*(1-params(3))+T(61)*T(69)^params(5);
residual(31) = lhs - rhs;
lhs = y(30);
rhs = y(29)+T(72)*(y(2)*y(33)+y(5)*y(38)+y(8)*y(43)+y(11)*y(48));
residual(32) = lhs - rhs;
lhs = y(57);
rhs = y(56)+(y(24)*y(75)+y(21)*y(70)+y(15)*y(60)+y(18)*y(65))*T(70)*T(73);
residual(33) = lhs - rhs;
lhs = y(29);
rhs = T(74)*(T(62)^(1+params(5))+T(63)^(1+params(5))+T(64)^(1+params(5))+T(65)^(1+params(5)));
residual(34) = lhs - rhs;
lhs = y(56);
rhs = T(74)*(T(66)^(1+params(5))+T(67)^(1+params(5))+T(68)^(1+params(5))+T(69)^(1+params(5)));
residual(35) = lhs - rhs;
lhs = y(36);
rhs = y(3)+params(131)*x(it_, 1);
residual(36) = lhs - rhs;
lhs = y(37);
rhs = y(4)+x(it_, 1)*params(132);
residual(37) = lhs - rhs;
lhs = y(41);
rhs = y(6)+x(it_, 1)*params(133);
residual(38) = lhs - rhs;
lhs = y(42);
rhs = y(7)+x(it_, 1)*params(134);
residual(39) = lhs - rhs;
lhs = y(46);
rhs = y(9)+x(it_, 1)*params(135);
residual(40) = lhs - rhs;
lhs = y(47);
rhs = y(10)+x(it_, 1)*params(136);
residual(41) = lhs - rhs;
lhs = y(51);
rhs = y(12)+x(it_, 1)*params(137);
residual(42) = lhs - rhs;
lhs = y(52);
rhs = y(13)+x(it_, 1)*params(138);
residual(43) = lhs - rhs;
lhs = y(63);
rhs = y(16)+x(it_, 1)*params(140);
residual(44) = lhs - rhs;
lhs = y(64);
rhs = y(17)+x(it_, 1)*params(141);
residual(45) = lhs - rhs;
lhs = y(68);
rhs = y(19)+x(it_, 1)*params(142);
residual(46) = lhs - rhs;
lhs = y(69);
rhs = y(20)+x(it_, 1)*params(143);
residual(47) = lhs - rhs;
lhs = y(73);
rhs = y(22)+x(it_, 1)*params(144);
residual(48) = lhs - rhs;
lhs = y(74);
rhs = y(23)+x(it_, 1)*params(145);
residual(49) = lhs - rhs;
lhs = y(78);
rhs = y(25)+x(it_, 1)*params(146);
residual(50) = lhs - rhs;
lhs = y(79);
rhs = y(26)+x(it_, 1)*params(147);
residual(51) = lhs - rhs;
lhs = y(30);
rhs = y(1)+x(it_, 1)*params(130);
residual(52) = lhs - rhs;
lhs = y(57);
rhs = y(14)+x(it_, 1)*params(139);
residual(53) = lhs - rhs;

end
