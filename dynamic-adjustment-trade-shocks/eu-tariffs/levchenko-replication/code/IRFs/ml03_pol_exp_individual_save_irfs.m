% Policy experiment 1: Consider individual tariff changes for one importer
% of goods on one sector and vis-a-vis an individual exporter

%=========================================================================% 
% Individual tariff changes: save impulse response functions
%=========================================================================% 

clear all
clc

%Load results.
load ../../temp_files/results_dynare.mat;

%Preliminaries 1.
nplot=16;
dat=(0:nplot-1)';
sigma=M_.params(strmatch('sigma',M_.param_names,'exact'));
chi=M_.params(strmatch('chi',M_.param_names,'exact'));
delta=M_.params(strmatch('delta',M_.param_names,'exact'));
dynamic_trade_elasticity_pe=-sigma-sigma*chi*(1-(1-delta).^dat);
country_names=[{'USA'}, {'CAN'}, {'CHN'}, {'EUR'}, {'JPN'}, {'ROW'}];

%Reaction to state variables.
param_states_t=transpose(oo_.dr.ghx);
for i=1:size(oo_.dr.order_var,1)
    param_states(:,oo_.dr.order_var(i))=[param_states_t(:,i)];
end

%Reaction to shocks.
param_shocks_t=transpose(oo_.dr.ghu);
for i=1:size(oo_.dr.order_var,1)
    param_shocks(:,oo_.dr.order_var(i))=[param_shocks_t(:,i)];
end

%Policy function parameters.
param_policy=([param_states;param_shocks]);

for dest_c=1:N
    
    %Preliminaries 2.
    irfs.year=(0:nplot-1)';
    irfs.trade=zeros(length(irfs.year),25);
    irfs.im_ex_sec=zeros(3,25);
    irfs.trade_pe=dynamic_trade_elasticity_pe;

    index=1;
    for source_c=1:N
        if (source_c~=dest_c)
            for sector=1:P

                %Define shocks.
                vars_shock=zeros(size(param_shocks,1),length(dat)+1);
                vars_shock(strmatch(strcat('shock_tau_',num2str(dest_c),num2str(source_c),num2str(sector)),M_.exo_names,'exact'))=1;

                %Generate matrix of variables.
                vars_endo=zeros(size(oo_.dr.ghx,1),length(dat)+1);

                %Generate matrix of state variables.
                vars_state=zeros(size(oo_.dr.ghx,2),length(dat)+1);
                vars_state=[vars_state;vars_shock];

                for per=1:length(dat)+1

                    %Calculate endogenous variables in current period.
                    vars_endo_per=param_policy'*vars_state(:,per);
                    vars_endo(:,per)=vars_endo_per;

                    %Declare state variables for next period.
                    for ii=1:length(oo_.dr.state_var)
                        vars_state(ii,per+1)=vars_endo(oo_.dr.state_var(ii),per);
                    end

                end

                vars_endo=vars_endo(:,1:end-1);            

                irfs.trade(:,index)=vars_endo(strmatch(strcat('x_',num2str(dest_c),num2str(source_c),num2str(sector),'__P_',num2str(source_c)),M_.endo_names,'exact'),:)'+ ...
                                    vars_endo(strmatch(strcat('n_',num2str(dest_c),num2str(source_c),num2str(sector)),M_.endo_names,'exact'),:)';

                irfs.im_ex_sec(1,index)=dest_c;
                irfs.im_ex_sec(2,index)=source_c;
                irfs.im_ex_sec(3,index)=sector;

                index=index+1;

            end
        end
    end

    filename=strrep(strcat('irfs_sig',num2str(sigma,'%4.2f'),'_chi',num2str(chi,'%4.2f')),'.','p');
    save(strcat('../../temp_files/',string(country_names(dest_c)),'ind_',filename),'irfs');

end