% clear all
% clc

%%

beta = 0.97;        % discount factor
delta = 0.25;       % depreciation rate
gamma = 1;          % coefficient of relative risk aversion / inverse of intertemporal elasticity of substitution
b = 1;              % maximum of inverse Pareto for sunk costs

omega_data_jip=1/N*ones(N,N,P);

% Load expenditure shares
alpha_ip_table = readtable("../../temp_files/wiod_spending_sector_55.csv");
alpha_ip = reshape(alpha_ip_table.share_sp,N,P);

% Load import shares
share_im_table = readtable('../../temp_files/wiod_import_sector_55.csv');
source_shares_data_jip = reshape(share_im_table.share_im,N,N,P);

% Load tariff data
tariff_table = readtable('../../temp_files/tariffs_55.csv');
tariff_data_jip = reshape(tariff_table.mean_ahs_st_w,N,N,P);

% Load sector productivity
z_table = readtable('../../temp_files/klems_sector_norm_55.csv');
z_ip_data = reshape(z_table.VA_H_EMP,N,P);

%Load size of economy
C_table = readtable('../../temp_files/pwt_calibration.csv');
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

SMC = table(C_table.countrycode,MC.CP_i,MC.P_i,MC.C_i,MC.w_i,MC.S_i,MC.L_i);
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

%%

E1_ijp=zeros(N,N,P);
E1_ijp_alt=zeros(N,N,P);
for j=1:N
    for i=1:N
        for p=1:P
            E1_ijp(i,j,p)=(MC.P_i(j)/MC.P_i(i))*MC.n_jip(i,j,p)*MC.x_jip(i,j,p)/MC.C_i(i);
        end
    end
end
for j=1:N
    for i=1:N
        for p=1:P
            E1_ijp_alt(i,j,p)=(1/tariff_data_jip(i,j,p))*source_shares_data_jip(i,j,p)*alpha_ip(i,p);
        end
    end
end
E1_ijp_check=max(max(max(abs(E1_ijp-E1_ijp_alt))))


E2_jip=zeros(N,N,P);
E2_jip_alt=zeros(N,N,P);
for j=1:N
    for i=1:N
        for p=1:P
            E2_jip(j,i,p)=MC.n_jip(j,i,p)*MC.x_jip(j,i,p)/MC.C_i(i);
        end
    end
end
for j=1:N
    for i=1:N
        for p=1:P
            E2_jip_alt(j,i,p)=(1/tariff_data_jip(j,i,p))*source_shares_data_jip(j,i,p)*alpha_ip(j,p)*MC.CP_i(j)/MC.CP_i(i);
        end
    end
end
E2_jip_check=max(max(max(abs(E2_jip-E2_jip_alt))))

E3_jip=zeros(N,N,P);
for j=1:N
    for i=1:N
        for p=1:P
            E3_jip(j,i,p)=source_shares_data_jip(j,i,p);
        end
    end
end

E4_jip=zeros(N,N,P);
E4_jip_alt=zeros(N,N,P);
for i=1:N
    temp=0;
    for j=1:N
        for p=1:P
            temp=temp+(MC.n_jip(j,i,p)*MC.x_jip(j,i,p));
        end
    end
    for j=1:N
        for p=1:P
            E4_jip(j,i,p)=(MC.n_jip(j,i,p)*MC.x_jip(j,i,p))/temp;
        end
    end
end
for i=1:N
    temp=0;
    for j=1:N
        for p=1:P
            temp=temp+((1/tariff_data_jip(i,j,p))*source_shares_data_jip(i,j,p)*alpha_ip(i,p));
        end
    end
    for j=1:N
        for p=1:P
            E4_jip_alt(j,i,p)=((1/tariff_data_jip(j,i,p))*source_shares_data_jip(j,i,p)*alpha_ip(j,p)*MC.CP_i(j)/MC.CP_i(i))/temp;
        end
    end
end
E4_jip_check=max(max(max(abs(E4_jip-E4_jip_alt))))


E5_i=zeros(N,1);
den=zeros(N,1);
for i=1:N
    temp=0;
    for j=1:N
        for p=1:P
            temp=temp+(MC.n_jip(j,i,p)*MC.x_jip(j,i,p));
        end
    end
    den(i)=temp;
    E5_i(i)=(sigma/(sigma-1))*MC.w_i(i)*MC.S_i(i)/den(i);
end
E5=max(E5_i);
E5_alt=(sigma/(sigma-1))*(chi/(chi+1))*(delta/sigma)/((1/beta)-(1-delta));
E5_check=E5-E5_alt


E6_jip=zeros(N,N,P);
E6_jip_alt=zeros(N,N,P);
for j=1:N
    for i=1:N
        for p=1:P
            E6_jip(j,i,p)=chi*(b^chi)/MC.S_i(i)*((MC.v_jip(j,i,p)/MC.w_i(i))^(chi+1));
        end
    end
end
for i=1:N
    temp=0;
    for j=1:N
        for p=1:P
            temp=temp+((1/tariff_data_jip(i,j,p))*source_shares_data_jip(i,j,p)*alpha_ip(i,p));
        end
    end
    for j=1:N
        for p=1:P
            E6_jip_alt(j,i,p)=((chi+1)*((1/tariff_data_jip(j,i,p))*source_shares_data_jip(j,i,p)*alpha_ip(j,p)*MC.CP_i(j)/MC.CP_i(i)))/temp;
        end
    end
end
E6_jip_check=max(max(max(abs(E6_jip-E6_jip_alt))))


%%

%Save parameters.
save ../../temp_files/parameters_linear.mat;