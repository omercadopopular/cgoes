%Define number of countries and sector.
@#define NN=2
@#define PP=2

%Variables.
var
@#for i in 1:1
    
    C_@{i}
    w_@{i}__P_@{i}
%     P_@{i}__P_1
    S_@{i}
    L_@{i}
    
    @#for p in 1:PP
        
        P_@{i}@{p}__P_@{i}
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            x_@{j}@{i}@{p}__P_@{i}
            n_@{j}@{i}@{p}
            v_@{j}@{i}@{p}
            
            tau_@{j}@{i}@{p}
            kappa_@{j}@{i}@{p}
            
        @#endfor
    @#endfor
    
@#endfor

@#for i in 2:NN
    
    C_@{i}
    w_@{i}__P_@{i}
    P_@{i}__P_1
    S_@{i}
    L_@{i}
    
    @#for p in 1:PP
        
        P_@{i}@{p}__P_@{i}
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            x_@{j}@{i}@{p}__P_@{i}
            n_@{j}@{i}@{p}
            v_@{j}@{i}@{p}
            
            tau_@{j}@{i}@{p}
            kappa_@{j}@{i}@{p}
            
        @#endfor
    @#endfor
    
@#endfor
; 



%Shocks.
varexo
% @#for i in 1:NN
%     @#for j in 1:NN
%         @#for p in 1:PP
%             
%             shock_model_@{j}@{i}@{p}
%             
%         @#endfor
%     @#endfor  
% @#endfor
shock_model
;



%Parameters.
parameters
beta
gamma
delta
sigma
chi
b
P_1__P_1
@#for i in 1:NN
    
    @#for p in 1:PP
    
        alpha_@{i}@{p}
        z_@{i}@{p}

        @#for j in 1:NN

            omega_@{j}@{i}@{p}

        @#endfor
    
    @#endfor
    
@#endfor



%Initial values.
@#for i in 1:1
    
    ss_C_@{i}
    ss_w_@{i}__P_@{i}
%     ss_P_@{i}__P_1
    ss_S_@{i}
    ss_L_@{i}
    
    @#for p in 1:PP
        
        ss_P_@{i}@{p}__P_@{i}
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            ss_x_@{j}@{i}@{p}__P_@{i}
            ss_n_@{j}@{i}@{p}
            ss_v_@{j}@{i}@{p}
            
            ss_tau_@{j}@{i}@{p}
            ss_kappa_@{j}@{i}@{p}
            
        @#endfor
    @#endfor
    
@#endfor

@#for i in 2:NN
    
    ss_C_@{i}
    ss_w_@{i}__P_@{i}
    ss_P_@{i}__P_1
    ss_S_@{i}
    ss_L_@{i}
    
    @#for p in 1:PP
        
        ss_P_@{i}@{p}__P_@{i}
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            ss_x_@{j}@{i}@{p}__P_@{i}
            ss_n_@{j}@{i}@{p}
            ss_v_@{j}@{i}@{p}
            
            ss_tau_@{j}@{i}@{p}
            ss_kappa_@{j}@{i}@{p}
            
        @#endfor
    @#endfor
    
@#endfor



%End values.
@#for i in 1:1
    
    e_C_@{i}
    e_w_@{i}__P_@{i}
%     e_P_@{i}__P_1
    e_S_@{i}
    e_L_@{i}
    
    @#for p in 1:PP
        
        e_P_@{i}@{p}__P_@{i}
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            e_x_@{j}@{i}@{p}__P_@{i}
            e_n_@{j}@{i}@{p}
            e_v_@{j}@{i}@{p}
            
            e_tau_@{j}@{i}@{p}
            e_kappa_@{j}@{i}@{p}
            
        @#endfor
    @#endfor
    
@#endfor

@#for i in 2:NN
    
    e_C_@{i}
    e_w_@{i}__P_@{i}
    e_P_@{i}__P_1
    e_S_@{i}
    e_L_@{i}
    
    @#for p in 1:PP
        
        e_P_@{i}@{p}__P_@{i}
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            e_x_@{j}@{i}@{p}__P_@{i}
            e_n_@{j}@{i}@{p}
            e_v_@{j}@{i}@{p}
            
            e_tau_@{j}@{i}@{p}
            e_kappa_@{j}@{i}@{p}
            
        @#endfor
    @#endfor
    
@#endfor



%Shock scales.
@#for i in 1:NN
    
    shock_size_L_@{i}
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            shock_size_tau_@{j}@{i}@{p}
            shock_size_kappa_@{j}@{i}@{p}
            
        @#endfor
    @#endfor
@#endfor
;



%Set parameter values.
load ss_dynare.mat;
set_param_value('beta',beta);
set_param_value('gamma',gamma);
set_param_value('delta',delta);
set_param_value('sigma',sigma);
set_param_value('chi',chi);
set_param_value('b',b);
set_param_value('P_1__P_1',1);
@#for i in 1:NN
    
    @#for p in 1:PP
    
        set_param_value('alpha_@{i}@{p}',alpha_ip(@{i},@{p}));
        set_param_value('z_@{i}@{p}',z_ip_data(@{i},@{p}));

        @#for j in 1:NN
            
            set_param_value('omega_@{j}@{i}@{p}',omega_data_jip(@{j},@{i},@{p}));
            
        @#endfor
    
    @#endfor
    
@#endfor



%Set initial values.
@#for i in 1:1
    
    set_param_value('ss_C_@{i}',AC.C_i(@{i}));
    set_param_value('ss_w_@{i}__P_@{i}',AC.w_i(@{i}));
%     set_param_value('ss_P_@{i}__P_1',AC.P_i(@{i}));
    set_param_value('ss_S_@{i}',AC.S_i(@{i}));                   %%%%
    set_param_value('ss_L_@{i}',AC.L_i(@{i}));
    
    @#for p in 1:PP
        
        set_param_value('ss_P_@{i}@{p}__P_@{i}',AC.P_ip(@{i},@{p}));  
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            set_param_value('ss_x_@{j}@{i}@{p}__P_@{i}',AC.x_jip(@{j},@{i},@{p}));         %%%%
            set_param_value('ss_n_@{j}@{i}@{p}',AC.n_jip(@{j},@{i},@{p}));                 %%%%
            set_param_value('ss_v_@{j}@{i}@{p}',AC.v_jip(@{j},@{i},@{p}));                 %%%%
            set_param_value('ss_tau_@{j}@{i}@{p}',tariff_data_jip(@{j},@{i},@{p}));                 %%%%
            set_param_value('ss_kappa_@{j}@{i}@{p}',AC.kappa_jip(@{j},@{i},@{p}));

        @#endfor
    @#endfor
    
@#endfor

@#for i in 2:NN
    
    set_param_value('ss_C_@{i}',AC.C_i(@{i}));
    set_param_value('ss_w_@{i}__P_@{i}',AC.w_i(@{i}));
    set_param_value('ss_P_@{i}__P_1',AC.P_i(@{i}));
    set_param_value('ss_S_@{i}',AC.S_i(@{i}));                   %%%%
    set_param_value('ss_L_@{i}',AC.L_i(@{i}));
    
    @#for p in 1:PP
        
        set_param_value('ss_P_@{i}@{p}__P_@{i}',AC.P_ip(@{i},@{p}));  
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            set_param_value('ss_x_@{j}@{i}@{p}__P_@{i}',AC.x_jip(@{j},@{i},@{p}));         %%%%
            set_param_value('ss_n_@{j}@{i}@{p}',AC.n_jip(@{j},@{i},@{p}));                 %%%%
            set_param_value('ss_v_@{j}@{i}@{p}',AC.v_jip(@{j},@{i},@{p}));                 %%%%
            set_param_value('ss_tau_@{j}@{i}@{p}',tariff_data_jip(@{j},@{i},@{p}));                 %%%%
            set_param_value('ss_kappa_@{j}@{i}@{p}',AC.kappa_jip(@{j},@{i},@{p}));

        @#endfor
    @#endfor
    
@#endfor


%Set final values.
@#for i in 1:1
    
    set_param_value('e_C_@{i}',MC.C_i(@{i}));
    set_param_value('e_w_@{i}__P_@{i}',MC.w_i(@{i}));
%     set_param_value('e_P_@{i}__P_1',MC.P_i(@{i}));
    set_param_value('e_S_@{i}',MC.S_i(@{i}));                   %%%%
    set_param_value('e_L_@{i}',MC.L_i(@{i}));
    
    @#for p in 1:PP
        
        set_param_value('e_P_@{i}@{p}__P_@{i}',MC.P_ip(@{i},@{p}));  
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            set_param_value('e_x_@{j}@{i}@{p}__P_@{i}',MC.x_jip(@{j},@{i},@{p}));         %%%%
            set_param_value('e_n_@{j}@{i}@{p}',MC.n_jip(@{j},@{i},@{p}));                 %%%%
            set_param_value('e_v_@{j}@{i}@{p}',MC.v_jip(@{j},@{i},@{p}));                 %%%%
            set_param_value('e_tau_@{j}@{i}@{p}',tariff_data_jip(@{j},@{i},@{p}));                 %%%%
            set_param_value('e_kappa_@{j}@{i}@{p}',MC.kappa_jip(@{j},@{i},@{p}));

        @#endfor
    @#endfor
    
@#endfor

@#for i in 2:NN
    
    set_param_value('e_C_@{i}',MC.C_i(@{i}));
    set_param_value('e_w_@{i}__P_@{i}',MC.w_i(@{i}));
    set_param_value('e_P_@{i}__P_1',MC.P_i(@{i}));
    set_param_value('e_S_@{i}',MC.S_i(@{i}));                   %%%%
    set_param_value('e_L_@{i}',MC.L_i(@{i}));
    
    @#for p in 1:PP
        
        set_param_value('e_P_@{i}@{p}__P_@{i}',MC.P_ip(@{i},@{p}));  
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            set_param_value('e_x_@{j}@{i}@{p}__P_@{i}',MC.x_jip(@{j},@{i},@{p}));         %%%%
            set_param_value('e_n_@{j}@{i}@{p}',MC.n_jip(@{j},@{i},@{p}));                 %%%%
            set_param_value('e_v_@{j}@{i}@{p}',MC.v_jip(@{j},@{i},@{p}));                 %%%%
            set_param_value('e_tau_@{j}@{i}@{p}',tariff_data_jip(@{j},@{i},@{p}));                 %%%%
            set_param_value('e_kappa_@{j}@{i}@{p}',MC.kappa_jip(@{j},@{i},@{p}));

        @#endfor
    @#endfor
    
@#endfor



%Shock scales.
@#for i in 1:NN
    
    set_param_value('shock_size_L_@{i}',MC.L_i(@{i})-AC.L_i(@{i}));
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            set_param_value('shock_size_tau_@{j}@{i}@{p}',tariff_data_jip(@{j},@{i},@{p})-tariff_data_jip(@{j},@{i},@{p}));
            set_param_value('shock_size_kappa_@{j}@{i}@{p}',MC.kappa_jip(@{j},@{i},@{p})-AC.kappa_jip(@{j},@{i},@{p}));
            
        @#endfor
    @#endfor
@#endfor



%Model.
model;

%Equation 1.
@#for i in 2:NN
    0
    @#for j in 1:NN
        @#for p in 1:PP
            +((P_@{j}__P_1/P_@{i}__P_1)*n_@{i}@{j}@{p}(-1)*x_@{i}@{j}@{p}__P_@{j})
        @#endfor
    @#endfor
    =0
    @#for j in 1:NN
        @#for p in 1:PP
            +(n_@{j}@{i}@{p}(-1)*x_@{j}@{i}@{p}__P_@{i})
        @#endfor
    @#endfor
    ;    
@#endfor

%Equation 2.
@#for i in 1:NN
    1=      1
            @#for p in 1:PP
                *(((1/alpha_@{i}@{p})*P_@{i}@{p}__P_@{i})^alpha_@{i}@{p})
            @#endfor
            ;
@#endfor

%Equation 3.
@#for j in 1:NN
    @#for p in 1:PP
        P_@{j}@{p}__P_@{j}=    (0
                                @#for i in 1:NN
                                    +(omega_@{j}@{i}@{p}*n_@{j}@{i}@{p}(-1)*((sigma/(sigma-1))*tau_@{j}@{i}@{p}*kappa_@{j}@{i}@{p}/z_@{i}@{p}*w_@{i}__P_@{i}*P_@{i}__P_1/P_@{j}__P_1)^(1-sigma))
                                @#endfor
                                )^(1/(1-sigma));
    @#endfor
@#endfor

%Equation 4.
@#for i in 1:NN
    @#for j in 1:NN
        @#for p in 1:PP
            x_@{j}@{i}@{p}__P_@{i}=   (tau_@{j}@{i}@{p}^(-sigma))*
                                        (((sigma/(sigma-1))*kappa_@{j}@{i}@{p}/z_@{i}@{p}*w_@{i}__P_@{i}/P_@{j}@{p}__P_@{j})^(1-sigma))
                                        *omega_@{j}@{i}@{p}*alpha_@{j}@{p}*((P_@{i}__P_1/P_@{j}__P_1)^(-sigma))*C_@{j};
        @#endfor
    @#endfor
@#endfor

%Equation 5.
@#for i in 1:NN
    @#for j in 1:NN
        @#for p in 1:PP
            v_@{j}@{i}@{p}=   beta*((C_@{i}(+1)/C_@{i})^(-gamma))*(((1/sigma)*x_@{j}@{i}@{p}__P_@{i}(+1))+((1-delta)*v_@{j}@{i}@{p}(+1)));
        @#endfor
    @#endfor
@#endfor

%Equation 6.
@#for i in 1:NN
    @#for j in 1:NN
        @#for p in 1:PP
%             n_@{j}@{i}@{p}(+1)=   ((1-delta)*n_@{j}@{i}@{p})+((b^chi)*((v_@{j}@{i}@{p}/w_@{i}__P_@{i})^chi));
            n_@{j}@{i}@{p}=   ((1-delta)*n_@{j}@{i}@{p}(-1))+((b^chi)*((v_@{j}@{i}@{p}/w_@{i}__P_@{i})^chi));
        @#endfor
    @#endfor
@#endfor

%Equation 7.
@#for i in 1:NN
    L_@{i}= S_@{i}+(((sigma-1)/sigma)*(1/w_@{i}__P_@{i})*(
            @#for j in 1:NN
                @#for p in 1:PP
                    (n_@{j}@{i}@{p}(-1)*x_@{j}@{i}@{p}__P_@{i})+
                @#endfor
            @#endfor
            0));                   
@#endfor

%Equation 8.
@#for i in 1:NN
    S_@{i}= ((chi*(b^chi))/(chi+1))*(
            @#for j in 1:NN
                @#for p in 1:PP
                    ((v_@{j}@{i}@{p}/w_@{i}__P_@{i})^(chi+1))+
                @#endfor
            @#endfor
            0);
@#endfor

%Others.
@#for i in 1:NN
    @#for j in 1:NN
        @#for p in 1:PP
            
            tau_@{j}@{i}@{p}=tau_@{j}@{i}@{p}(-1)+shock_size_tau_@{j}@{i}@{p}*shock_model;
            kappa_@{j}@{i}@{p}=kappa_@{j}@{i}@{p}(-1)+shock_size_kappa_@{j}@{i}@{p}*shock_model;
            
        @#endfor
    @#endfor  
@#endfor

@#for i in 1:NN
    
    L_@{i}=L_@{i}(-1)+shock_size_L_@{i}*shock_model;
    
@#endfor

end;



%Initial values.
initval;
@#for i in 1:1
    
    C_@{i}=ss_C_@{i};
    w_@{i}__P_@{i}=ss_w_@{i}__P_@{i};
%     P_@{i}__P_1=ss_P_@{i}__P_1;
    S_@{i}=ss_S_@{i};
    L_@{i}=ss_L_@{i};
    
    @#for p in 1:PP
        
        P_@{i}@{p}__P_@{i}=ss_P_@{i}@{p}__P_@{i};
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            x_@{j}@{i}@{p}__P_@{i}=ss_x_@{j}@{i}@{p}__P_@{i};
            n_@{j}@{i}@{p}=ss_n_@{j}@{i}@{p};
            v_@{j}@{i}@{p}=ss_v_@{j}@{i}@{p};
            
        @#endfor
    @#endfor
    
@#endfor

@#for i in 2:NN
    
    C_@{i}=ss_C_@{i};
    w_@{i}__P_@{i}=ss_w_@{i}__P_@{i};
    P_@{i}__P_1=ss_P_@{i}__P_1;
    S_@{i}=ss_S_@{i};
    L_@{i}=ss_L_@{i};
    
    @#for p in 1:PP
        
        P_@{i}@{p}__P_@{i}=ss_P_@{i}@{p}__P_@{i};
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            x_@{j}@{i}@{p}__P_@{i}=ss_x_@{j}@{i}@{p}__P_@{i};
            n_@{j}@{i}@{p}=ss_n_@{j}@{i}@{p};
            v_@{j}@{i}@{p}=ss_v_@{j}@{i}@{p};
            
        @#endfor
    @#endfor
    
@#endfor

@#for i in 1:NN
    @#for j in 1:NN
        @#for p in 1:PP
            
            tau_@{j}@{i}@{p}=ss_tau_@{j}@{i}@{p};
            kappa_@{j}@{i}@{p}=ss_kappa_@{j}@{i}@{p};
            
        @#endfor
    @#endfor  
@#endfor

end;

options_.dynatol.f=1e-4;
options_.solve_tolf=1e-4;
steady(solve_algo=4);



%End values.
endval;
@#for i in 1:1
    
    C_@{i}=e_C_@{i};
    w_@{i}__P_@{i}=e_w_@{i}__P_@{i};
%     P_@{i}__P_1=e_P_@{i}__P_1;
    S_@{i}=e_S_@{i};
    L_@{i}=e_L_@{i};
    
    @#for p in 1:PP
        
        P_@{i}@{p}__P_@{i}=e_P_@{i}@{p}__P_@{i};
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            x_@{j}@{i}@{p}__P_@{i}=e_x_@{j}@{i}@{p}__P_@{i};
            n_@{j}@{i}@{p}=e_n_@{j}@{i}@{p};
            v_@{j}@{i}@{p}=e_v_@{j}@{i}@{p};
            
        @#endfor
    @#endfor
    
@#endfor

@#for i in 2:NN
    
    C_@{i}=e_C_@{i};
    w_@{i}__P_@{i}=e_w_@{i}__P_@{i};
    P_@{i}__P_1=e_P_@{i}__P_1;
    S_@{i}=e_S_@{i};
    L_@{i}=e_L_@{i};
    
    @#for p in 1:PP
        
        P_@{i}@{p}__P_@{i}=e_P_@{i}@{p}__P_@{i};
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            x_@{j}@{i}@{p}__P_@{i}=e_x_@{j}@{i}@{p}__P_@{i};
            n_@{j}@{i}@{p}=e_n_@{j}@{i}@{p};
            v_@{j}@{i}@{p}=e_v_@{j}@{i}@{p};
            
        @#endfor
    @#endfor
    
@#endfor

@#for i in 1:NN
    @#for j in 1:NN
        @#for p in 1:PP
            
            tau_@{j}@{i}@{p}=e_tau_@{j}@{i}@{p};
            kappa_@{j}@{i}@{p}=e_kappa_@{j}@{i}@{p};
            
        @#endfor
    @#endfor  
@#endfor

end;

options_.dynatol.f=1e-4;
options_.solve_tolf=1e-4;
steady(solve_algo=4);



%Shocks.
shocks;
var shock_model;
periods 1;
values (1);
end;

%Simulation.
% simul(periods=20);
perfect_foresight_setup(periods=50);
perfect_foresight_solver(linear_approximation);
% perfect_foresight_solver(lmmcp);