function residual = static_resid(T, y, x, params, T_flag)
% function residual = static_resid(T, y, x, params, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T         [#temp variables by 1]  double   vector of temporary terms to be filled by function
%   y         [M_.endo_nbr by 1]      double   vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1]       double   vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1]     double   vector of parameter values in declaration order
%                                              to evaluate the model
%   T_flag    boolean                 boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = aux_model_nl.static_resid_tt(T, y, x, params);
end
residual = zeros(53, 1);
lhs = T(1)*y(18)*y(17)+T(1)*y(23)*y(22)+y(45)*y(44)+y(50)*y(49);
rhs = y(50)*y(49)+y(45)*y(44)+y(35)*y(34)+y(40)*y(39);
residual(1) = lhs - rhs;
lhs = 1;
rhs = T(2)*T(3);
residual(2) = lhs - rhs;
lhs = 1;
rhs = T(4)*T(5);
residual(3) = lhs - rhs;
lhs = y(5);
rhs = T(10)^T(11);
residual(4) = lhs - rhs;
lhs = y(6);
rhs = T(15)^T(11);
residual(5) = lhs - rhs;
lhs = y(32);
rhs = T(19)^T(11);
residual(6) = lhs - rhs;
lhs = y(33);
rhs = T(23)^T(11);
residual(7) = lhs - rhs;
lhs = y(7);
rhs = T(27)*y(1);
residual(8) = lhs - rhs;
lhs = y(12);
rhs = y(1)*T(31);
residual(9) = lhs - rhs;
lhs = y(17);
rhs = params(16)*params(11)*T(32)*T(34)*T(35)*y(27);
residual(10) = lhs - rhs;
lhs = y(22);
rhs = y(27)*T(35)*params(20)*params(15)*T(36)*T(38);
residual(11) = lhs - rhs;
lhs = y(34);
rhs = y(1)*T(44);
residual(12) = lhs - rhs;
lhs = y(39);
rhs = y(1)*T(49);
residual(13) = lhs - rhs;
lhs = y(44);
rhs = y(27)*T(53);
residual(14) = lhs - rhs;
lhs = y(49);
rhs = y(27)*T(57);
residual(15) = lhs - rhs;
lhs = y(9);
rhs = params(1)*(y(7)*T(58)+y(9)*(1-params(3)));
residual(16) = lhs - rhs;
lhs = y(14);
rhs = params(1)*(y(12)*T(58)+(1-params(3))*y(14));
residual(17) = lhs - rhs;
lhs = y(19);
rhs = params(1)*(y(17)*T(58)+(1-params(3))*y(19));
residual(18) = lhs - rhs;
lhs = y(24);
rhs = params(1)*(y(22)*T(58)+(1-params(3))*y(24));
residual(19) = lhs - rhs;
lhs = y(36);
rhs = params(1)*(y(34)*T(58)+(1-params(3))*y(36));
residual(20) = lhs - rhs;
lhs = y(41);
rhs = params(1)*(y(39)*T(58)+(1-params(3))*y(41));
residual(21) = lhs - rhs;
lhs = y(46);
rhs = params(1)*(y(44)*T(58)+(1-params(3))*y(46));
residual(22) = lhs - rhs;
lhs = y(51);
rhs = params(1)*(y(49)*T(58)+(1-params(3))*y(51));
residual(23) = lhs - rhs;
lhs = y(8);
rhs = y(8)*(1-params(3))+T(59)*T(60)^params(5);
residual(24) = lhs - rhs;
lhs = y(13);
rhs = y(13)*(1-params(3))+T(59)*T(61)^params(5);
residual(25) = lhs - rhs;
lhs = y(18);
rhs = y(18)*(1-params(3))+T(59)*T(62)^params(5);
residual(26) = lhs - rhs;
lhs = y(23);
rhs = y(23)*(1-params(3))+T(59)*T(63)^params(5);
residual(27) = lhs - rhs;
lhs = y(35);
rhs = y(35)*(1-params(3))+T(59)*T(64)^params(5);
residual(28) = lhs - rhs;
lhs = y(40);
rhs = y(40)*(1-params(3))+T(59)*T(65)^params(5);
residual(29) = lhs - rhs;
lhs = y(45);
rhs = y(45)*(1-params(3))+T(59)*T(66)^params(5);
residual(30) = lhs - rhs;
lhs = y(50);
rhs = y(50)*(1-params(3))+T(59)*T(67)^params(5);
residual(31) = lhs - rhs;
lhs = y(4);
rhs = y(3)+T(70)*(y(8)*y(7)+y(13)*y(12)+y(18)*y(17)+y(23)*y(22));
residual(32) = lhs - rhs;
lhs = y(31);
rhs = y(30)+(y(50)*y(49)+y(45)*y(44)+y(35)*y(34)+y(40)*y(39))*T(68)*T(71);
residual(33) = lhs - rhs;
lhs = y(3);
rhs = T(72)*(T(60)^(1+params(5))+T(61)^(1+params(5))+T(62)^(1+params(5))+T(63)^(1+params(5)));
residual(34) = lhs - rhs;
lhs = y(30);
rhs = T(72)*(T(64)^(1+params(5))+T(65)^(1+params(5))+T(66)^(1+params(5))+T(67)^(1+params(5)));
residual(35) = lhs - rhs;
lhs = y(10);
rhs = y(10)+params(131)*x(1);
residual(36) = lhs - rhs;
lhs = y(11);
rhs = y(11)+x(1)*params(132);
residual(37) = lhs - rhs;
lhs = y(15);
rhs = y(15)+x(1)*params(133);
residual(38) = lhs - rhs;
lhs = y(16);
rhs = y(16)+x(1)*params(134);
residual(39) = lhs - rhs;
lhs = y(20);
rhs = y(20)+x(1)*params(135);
residual(40) = lhs - rhs;
lhs = y(21);
rhs = y(21)+x(1)*params(136);
residual(41) = lhs - rhs;
lhs = y(25);
rhs = y(25)+x(1)*params(137);
residual(42) = lhs - rhs;
lhs = y(26);
rhs = y(26)+x(1)*params(138);
residual(43) = lhs - rhs;
lhs = y(37);
rhs = y(37)+x(1)*params(140);
residual(44) = lhs - rhs;
lhs = y(38);
rhs = y(38)+x(1)*params(141);
residual(45) = lhs - rhs;
lhs = y(42);
rhs = y(42)+x(1)*params(142);
residual(46) = lhs - rhs;
lhs = y(43);
rhs = y(43)+x(1)*params(143);
residual(47) = lhs - rhs;
lhs = y(47);
rhs = y(47)+x(1)*params(144);
residual(48) = lhs - rhs;
lhs = y(48);
rhs = y(48)+x(1)*params(145);
residual(49) = lhs - rhs;
lhs = y(52);
rhs = y(52)+x(1)*params(146);
residual(50) = lhs - rhs;
lhs = y(53);
rhs = y(53)+x(1)*params(147);
residual(51) = lhs - rhs;
lhs = y(4);
rhs = y(4)+x(1)*params(130);
residual(52) = lhs - rhs;
lhs = y(31);
rhs = y(31)+x(1)*params(139);
residual(53) = lhs - rhs;
if ~isreal(residual)
  residual = real(residual)+imag(residual).^2;
end
end
