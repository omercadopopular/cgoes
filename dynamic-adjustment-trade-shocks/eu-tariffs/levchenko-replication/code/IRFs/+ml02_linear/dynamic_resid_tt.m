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

assert(length(T) >= 19);

T(1) = params(265)+params(315)+params(365)+params(415)+params(465)+params(281)+params(331)+params(381)+params(431)+params(481)+params(289)+params(339)+params(389)+params(439)+params(489)+params(297)+params(347)+params(397)+params(447)+params(497)+params(305)+params(355)+params(405)+params(455)+params(505);
T(2) = params(515)+params(565)+params(615)+params(665)+params(715)+params(523)+params(573)+params(623)+params(673)+params(723)+params(539)+params(589)+params(639)+params(689)+params(739)+params(547)+params(597)+params(647)+params(697)+params(747)+params(555)+params(605)+params(655)+params(705)+params(755);
T(3) = params(765)+params(815)+params(865)+params(915)+params(965)+params(773)+params(823)+params(873)+params(923)+params(973)+params(781)+params(831)+params(881)+params(931)+params(981)+params(797)+params(847)+params(897)+params(947)+params(997)+params(805)+params(855)+params(905)+params(955)+params(1005);
T(4) = params(1015)+params(1065)+params(1115)+params(1165)+params(1215)+params(1023)+params(1073)+params(1123)+params(1173)+params(1223)+params(1031)+params(1081)+params(1131)+params(1181)+params(1231)+params(1039)+params(1089)+params(1139)+params(1189)+params(1239)+params(1055)+params(1105)+params(1155)+params(1205)+params(1255);
T(5) = params(1265)+params(1315)+params(1365)+params(1415)+params(1465)+params(1273)+params(1323)+params(1373)+params(1423)+params(1473)+params(1281)+params(1331)+params(1381)+params(1431)+params(1481)+params(1289)+params(1339)+params(1389)+params(1439)+params(1489)+params(1297)+params(1347)+params(1397)+params(1447)+params(1497);
T(6) = 1/(1-params(3));
T(7) = (-params(3));
T(8) = params(3)-1;
T(9) = params(4)*(y(361)-y(1314));
T(10) = 1-params(2);
T(11) = params(1)*T(10);
T(12) = 1-T(11);
T(13) = params(4)*(y(362)-y(1315));
T(14) = params(4)*(y(363)-y(1316));
T(15) = params(4)*(y(364)-y(1317));
T(16) = params(4)*(y(365)-y(1318));
T(17) = params(4)*(y(366)-y(1319));
T(18) = params(2)*params(5);
T(19) = y(367)*T(18);

end
