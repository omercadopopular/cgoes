% File to solve for the steady state of GE model in Draft\GE_model.tex
% March 2022
% Nitya and Chris

% clear all
% clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global N P beta delta sigma b chi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Options and parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fsolve_options1 = optimoptions('fsolve','Display','iter-detailed', ...
    'MaxIterations',10000,'MaxFunctionEvaluations',10000, ...
    'StepTolerance',1.0e-12,'FunctionTolerance',1e-12);

fsolve_options2 = optimoptions('fsolve','Display','iter-detailed', ...
    'MaxIterations',10000,'MaxFunctionEvaluations',10000,...
    'TolFun',1e-20,'TolX',1e-20);

%'Algorithm','levenberg-marquardt'

% Test with a small set of countries and products
N = 2; %number of countries
P = 2; %number of products


%%% Externally calibrated parameters %%%
beta = 0.97;
delta = 0.25;
% sigma = 1.10;

% Distribution of fixed costs
% for now assuming Pareto, b and chi
% chi = 0.82;
% chi = 2/sigma-1;
b = 1; 

% Main calibration
% In this version real GDP is is used to calibrate the level of consumption,
% which is the correct analogue in the data

omega_data_jip = 1/N*ones(N,N,P);

% Load expenditure shares
s=sprintf('readtable(''%s'')', ['../../temp_files/wiod_spending_sector_' countries{xx} '.csv']);
alpha_ip_table=eval(s);
alpha_ip = reshape(alpha_ip_table.share_sp,N,P);

% Load import shares
s=sprintf('readtable(''%s'')', ['../../temp_files/wiod_import_sector_' countries{xx} '.csv']);
share_im_table=eval(s);
source_shares_data_jip = reshape(share_im_table.share_im,N,N,P);

% check = zeros(N,P);
% for j = 1:N
%    for p = 1:P
%        for i = 1:N
%           check(j,p) = check(j,p) + source_shares_data_jip(j,i,p);
%        end
%    end
% end

% Load tariff data
s=sprintf('readtable(''%s'')', ['../../temp_files/tariffs_' countries{xx} '.csv']);
tariff_table=eval(s);
tariff_data_jip = reshape(tariff_table.mean_ahs_st_w,N,N,P);
% tariff_data_jip = 1.0*ones(N,N,P);
% % the following is a temporary solution that assigns equal tariff values
% for j = 1:N
%    for i = 1:N
%       for p = 1:P
%           if (tariff_data_jip(j,i,p) == 1001)
%             tariff_data_jip(j,i,p) = 1;
%           end
%       end
%    end
% end

% Load sector productivity
s=sprintf('readtable(''%s'')', ['../../temp_files/klems_sector_' countries{xx} '.csv']);
z_table=eval(s);
z_ip_data = reshape(z_table.VA_H_EMP,N,P);

%Load size of economy
s=sprintf('readtable(''%s'')', ['../../temp_files/pwt_calibration_' countries{xx} '.csv']);
C_table=eval(s);
MC.C_i = reshape(C_table.rgdpe,N,1);

% tariff_data_jip = ones(N,N,P); % to check
const1 = zeros(N,1);
for i = 1:1:N
    for j = 1:1:N
        for p = 1:1:P 
            const1(i) = const1(i) + 1/tariff_data_jip(i,j,p)*source_shares_data_jip(i,j,p)*alpha_ip(i,p);
        end
    end
end

const2 = (sigma-1)*(1/beta - (1 - delta)) + chi/(chi+1)*delta;

const3 = zeros(N,1);
for i = 1:1:N
    for p = 1:1:P 

        const3(i) = const3(i) + alpha_ip(i,p)*log(source_shares_data_jip(i,i,p)^(-1/(sigma-1)*1/(chi+1))*...
                            (z_ip_data(i,p)*alpha_ip(i,p)^(1+chi/(chi+1)*1/(sigma-1))));
    end
end
const3 = exp(const3);

MC.L_i = ((MC.C_i*N^(1/(sigma-1))*(delta)^(1/(chi+1)*1/(sigma-1)))./ ...
        ((sigma-1)*(b)^(chi/(chi+1)*1/(sigma-1))*(1/beta - (1-delta))*const3)).^(1/(1+chi/(chi+1)*1/(sigma-1)))*const2.*const1;

C_i_check = (sigma-1)*b^(chi/(chi+1)*1/(sigma-1))*(1/beta - (1-delta))/...
        (N^(1/(sigma-1))*delta^(1/(chi+1)*1/(sigma-1)) * const2^(1+chi/(chi+1)*1/(sigma-1))).*...
        const3.*(MC.L_i./const1).^((1+chi/(chi+1)*1/(sigma-1)));


MC.w_i = MC.C_i./MC.L_i*((sigma-1)/sigma + chi/(chi+1)*delta/(sigma*(1/beta-(1-delta)))).*const1;

clear const2 const3

% solve for real exchange rates

A_ji = zeros(N,N);
for j = 1:1:N
    for i = 1:1:N
        for p = 1:1:P 
            A_ji(j,i) = A_ji(j,i) + 1/tariff_data_jip(j,i,p)*source_shares_data_jip(j,i,p)*alpha_ip(j,p) ;
        end
    end
end

D_i = const1;
B_i = -MC.C_i(1)*A_ji(1,2:end);
AA_ji = A_ji(2:end,2:end) - diag(D_i(2:end));

CP_i = linsolve(AA_ji',B_i');

MC.CP_i = [MC.C_i(1); CP_i];

MC.P_i = MC.CP_i./MC.C_i;

% check on steady state
check = zeros(N,1);
for i = 1:N
    temp2 = 0;
    for j = 1:N
        temp2 = temp2 + MC.CP_i(j)*A_ji(j,i);
    end
    check(i) = - MC.CP_i(i)*D_i(i) + temp2;
end
clear check D_i B_i AA_ji CP_i


MC.x_jip = zeros(N,N,P);
for j = 1:N
   for i = 1:N
       for p = 1:P
            MC.x_jip(j,i,p) = (MC.w_i(i)^chi*delta*(sigma/b*(1/beta - (1-delta)))^chi...
            *1/tariff_data_jip(j,i,p)*source_shares_data_jip(j,i,p)*alpha_ip(j,p)*...
                MC.CP_i(j)/MC.P_i(i))^(1/(chi+1));
       end
   end
end 

MC.n_jip = zeros(N,N,P);
for j = 1:N
   for i = 1:N
       for p = 1:P
            MC.n_jip(j,i,p) = (1/delta)/(sigma/b*(1/beta - (1-delta)))^chi...
                *(MC.x_jip(j,i,p)/MC.w_i(i))^chi;
       end
   end
end 

MC.S_i = delta/((chi+1)/chi*(sigma-1)*(1/beta-(1-delta))+delta)*MC.L_i;

MC.P_ip = zeros(N,P);
for i = 1:N
    for p = 1:P
         MC.P_ip(i,p) = sigma/(sigma-1)*MC.w_i(i)/z_ip_data(i,p)*...
             (N*source_shares_data_jip(i,i,p)/MC.n_jip(i,i,p))^(1/(sigma-1));
    end
end

MC.v_jip = ((1/sigma)/((1/beta)-(1-delta)))*MC.x_jip;

SMC = table(C_table.country,MC.CP_i,MC.P_i,MC.C_i,MC.w_i,MC.S_i,MC.L_i);
SMC.Properties.VariableNames = {'Country','CP_i','P_i','C_i','w_i','S_i','L_i'};

% other objects that we need later
MC.PHI_jip = zeros(N,N,P);
MC.kappa_jip = zeros(N,N,P);

for j = 1:1:N 
    for i = 1:1:N 
        for p = 1:1:P  
        
            MC.PHI_jip(j,i,p) =  source_shares_data_jip(j,i,p)/( MC.n_jip(j,i,p)*(sigma/(sigma-1)...
                    *MC.w_i(i)/MC.P_ip(j,p)*MC.P_i(i)/MC.P_i(j))^(1-sigma));

            MC.kappa_jip(j,i,p) = z_ip_data(i,p)/tariff_data_jip(j,i,p)*...
                                  (MC.PHI_jip(j,i,p)/omega_data_jip(j,i,p))^(1/(1-sigma));
        
        end
    end
end

%%%%%%%%%Note: Some of the kappas are less than one. This is fine, because
%%%%%%%%%we can always scale the productivity parameters to ensure the
%%%%%%%%%kappas are greater than one.

%% Implement check that model equations hold

% Equation 1: Trade balance

sum_p_sum_j_nx = zeros(N,1);
sum_p_sum_j_RERnx = zeros(N,1);
for i = 1:N
    for j = 1:N
       for p = 1:P
           sum_p_sum_j_nx(i) = sum_p_sum_j_nx(i) + MC.n_jip(j,i,p)*MC.x_jip(j,i,p);
           sum_p_sum_j_RERnx(i) = sum_p_sum_j_RERnx(i) + MC.P_i(j)/MC.P_i(i)*MC.n_jip(i,j,p)*MC.x_jip(i,j,p);
       end
    end
end

f1 = sum_p_sum_j_RERnx - sum_p_sum_j_nx;

% Equation 2: Country price index

f2 = sum(alpha_ip.*log(MC.P_ip./alpha_ip),2);

% Equation 3: Sector price index

f3 = zeros(N,P);
for i = 1:N
    for p = 1:P
        temp = 0;
        for j = 1:N
            temp = temp + MC.PHI_jip(i,j,p)*MC.n_jip(i,j,p)*...
                    (MC.w_i(j)*MC.P_i(j)/MC.P_i(i))^(1-sigma);
        end
        f3(i,p) = -MC.P_ip(i,p) + sigma/(sigma-1)*(temp)^(1/(1-sigma));
    end
end
clear temp
% Note that the low accuracy for this equation comes from the low
% alpha_ip(5,1), a low expenditure share on this sector for Japan, together
% with a low elasticity sigma

% Equation 4: sales per firm

f4 = zeros(N,N,P);
for i = 1:N
    for j = 1:N
       for p = 1:P
           f4(j,i,p) = -MC.x_jip(j,i,p) + MC.PHI_jip(j,i,p)/tariff_data_jip(j,i,p)*alpha_ip(j,p)*...
                       (sigma/(sigma-1)*MC.w_i(i)/MC.P_ip(j,p))^(1-sigma)*...
                       MC.C_i(j)*(MC.P_i(i)/MC.P_i(j))^(-sigma);
       end
    end
end

% Equation 5: firm value

f5 = -MC.v_jip + ((1/sigma)/((1/beta)-(1-delta)))*MC.x_jip;

% Equation 6: number of firms

f6 = zeros(N,N,P);
for i = 1:N
    for j = 1:N
       for p = 1:P
           f6(j,i,p) = -MC.n_jip(j,i,p) + 1/delta*b^chi*(MC.v_jip(j,i,p)/MC.w_i(i))^chi;
       end
    end
end

% Equation 7: Labor market clearing

f7 = -MC.L_i + (sigma-1)/sigma*sum_p_sum_j_nx./MC.w_i + MC.S_i;

% Equation 8: Sunk costs

f8 = zeros(N,1);
for i = 1:N
    temp = 0;
    for j = 1:N
        for p = 1:P
            temp = temp + (MC.v_jip(j,i,p)/MC.w_i(i))^(chi+1);
        end
    end
    f8(i) = -MC.S_i(i) + chi/(chi+1)*b^chi*temp;
end
clear temp

max(abs(f1))
max(abs(f2))
max(max(abs(f3)))
max(max(max(abs(f4))))
max(max(max(abs(f5))))
max(max(max(abs(f6))))
max(abs(f7))
max(abs(f8))

%% Autarky steady state

source_shares_aut_jip = 1/10000*ones(N,N,P);

% source_shares_aut_jip = 1/1000000*source_shares_data_jip;

for p = 1:P
    for j = 1:N
        temp = 0;
        for i = 1:N
            if (i ~= j)
                temp = temp + source_shares_aut_jip(j,i,p);
            end
        end
        source_shares_aut_jip(j,j,p) = 1 - temp;
    end
end
clear temp

AC.L_i = MC.L_i;

const1_aut = zeros(N,1);
for i = 1:1:N
    for j = 1:1:N
        for p = 1:1:P 
            const1_aut(i) = const1_aut(i) + 1/tariff_data_jip(i,j,p)*source_shares_aut_jip(i,j,p)*alpha_ip(i,p);
        end
    end
end

const2_aut = (sigma-1)*(1/beta - (1 - delta)) + chi/(chi+1)*delta;

const3_aut = zeros(N,1);
for i = 1:1:N
    for p = 1:1:P 

        const3_aut(i) = const3_aut(i) + alpha_ip(i,p)*log(source_shares_aut_jip(i,i,p)^(-1/(sigma-1)*1/(chi+1))*...
                            (z_ip_data(i,p)*alpha_ip(i,p)^(1+chi/(chi+1)*1/(sigma-1))));
    end
end
const3_aut = exp(const3_aut);

AC.C_i = (sigma-1)*b^(chi/(chi+1)*1/(sigma-1))*(1/beta - (1-delta))/...
        (N^(1/(sigma-1))*delta^(1/(chi+1)*1/(sigma-1)) * const2_aut^(1+chi/(chi+1)*1/(sigma-1))).*...
        const3_aut.*(MC.L_i./const1_aut).^((1+chi/(chi+1)*1/(sigma-1)));


AC.w_i = AC.C_i./AC.L_i*((sigma-1)/sigma + chi/(chi+1)*delta/(sigma*(1/beta-(1-delta)))).*const1_aut;

clear const2_aut const3_aut

% solve for real exchange rates

A_ji_aut = zeros(N,N);
for j = 1:1:N
    for i = 1:1:N
        for p = 1:1:P 
            A_ji_aut(j,i) = A_ji_aut(j,i) + 1/tariff_data_jip(j,i,p)*source_shares_aut_jip(j,i,p)*alpha_ip(j,p) ;
        end
    end
end

D_i_aut = const1_aut;
B_i_aut = -AC.C_i(1)*A_ji_aut(1,2:end);
AA_ji_aut = A_ji_aut(2:end,2:end) - diag(D_i_aut(2:end));

CP_i_aut = linsolve(AA_ji_aut',B_i_aut');

AC.CP_i = [AC.C_i(1); CP_i_aut];

AC.P_i = AC.CP_i./AC.C_i;

% check on steady state
check = zeros(N,1);
for i = 1:N
    temp2 = 0;
    for j = 1:N
        temp2 = temp2 + AC.CP_i(j)*A_ji_aut(j,i);
    end
    check(i) = - AC.CP_i(i)*D_i_aut(i) + temp2;
end
clear check D_i_aut B_i_aut AA_ji_aut CP_i_aut

AC.x_jip = zeros(N,N,P);
for j = 1:N
   for i = 1:N
       for p = 1:P
            AC.x_jip(j,i,p) = (AC.w_i(i)^chi*delta*(sigma/b*(1/beta - (1-delta)))^chi...
            *1/tariff_data_jip(j,i,p)*source_shares_aut_jip(j,i,p)*alpha_ip(j,p)*...
                AC.CP_i(j)/AC.P_i(i))^(1/(chi+1));
       end
   end
end 

AC.n_jip = zeros(N,N,P);
for j = 1:N
   for i = 1:N
       for p = 1:P
            AC.n_jip(j,i,p) = (1/delta)/(sigma/b*(1/beta - (1-delta)))^chi...
                *(AC.x_jip(j,i,p)/AC.w_i(i))^chi;
       end
   end
end 

AC.S_i = delta/((chi+1)/chi*(sigma-1)*(1/beta-(1-delta))+delta)*AC.L_i;

AC.P_ip = zeros(N,P);
for i = 1:N
    for p = 1:P
         AC.P_ip(i,p) = sigma/(sigma-1)*AC.w_i(i)/z_ip_data(i,p)*...
             (N*source_shares_aut_jip(i,i,p)/AC.n_jip(i,i,p))^(1/(sigma-1));
    end
end

AC.v_jip = ((1/sigma)/((1/beta)-(1-delta)))*AC.x_jip;

SAC = table(C_table.country,AC.CP_i,AC.P_i,AC.C_i,AC.w_i,AC.S_i,AC.L_i);
SAC.Properties.VariableNames = {'Country','CP_i','P_i','C_i','w_i','S_i','L_i'};

disp('Main Calibration')
disp(SMC)
disp('Autarky Calibration')
disp(SAC)

AC.PHI_jip = zeros(N,N,P);
AC.kappa_jip = zeros(N,N,P);

for j = 1:1:N 
    for i = 1:1:N 
        for p = 1:1:P  
        
            AC.PHI_jip(j,i,p) =  source_shares_aut_jip(j,i,p)/( AC.n_jip(j,i,p)*(sigma/(sigma-1)...
                    *AC.w_i(i)/AC.P_ip(j,p)*AC.P_i(i)/AC.P_i(j))^(1-sigma));

            AC.kappa_jip(j,i,p) = z_ip_data(i,p)/tariff_data_jip(j,i,p)*...
                                  (AC.PHI_jip(j,i,p)/omega_data_jip(j,i,p))^(1/(1-sigma));
        
        end
    end
end

%% Gains from trade

ss_GfT_num = MC.C_i./AC.C_i;

%Save results.
save ss_dynare.mat;
