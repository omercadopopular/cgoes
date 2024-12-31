%Define number of countries and sectors.
@#define NN=6
@#define PP=5

%Variables.
var

@#for i in 1:NN
    C_@{i}                              ${C_{@{i}}}$
@#endfor

@#for i in 1:NN
    w_@{i}__P_@{i}                      ${\frac{w_{@{i}}}{P_{@{i}}}}$
@#endfor

@#for i in 1:NN
    S_@{i}                              ${S_{@{i}}}$
@#endfor

@#for i in 2:NN
    P_@{i}__P_1                        ${\frac{P_{@{i}}}{P_{1}}}$
@#endfor

@#for p in 1:PP
    @#for i in 1:NN
        P_@{i}@{p}__P_@{i}             ${\frac{P_{@{i}@{p}}}{P_{@{i}}}}$
    @#endfor
@#endfor
    
@#for p in 1:PP
    @#for i in 1:NN
        @#for j in 1:NN
            v_@{j}@{i}@{p}            ${v_{@{j}@{i}@{p}}}$
        @#endfor
    @#endfor
@#endfor

@#for p in 1:PP
    @#for i in 1:NN
        @#for j in 1:NN
            n_@{j}@{i}@{p}            ${n_{@{j}@{i}@{p}}}$
        @#endfor
    @#endfor
@#endfor

@#for p in 1:PP
    @#for i in 1:NN
        @#for j in 1:NN
            x_@{j}@{i}@{p}__P_@{i}    ${\frac{x_{@{j}@{i}@{p}}}{P_{@{i}}}}$
        @#endfor
    @#endfor
@#endfor

@#for p in 1:PP
    @#for i in 1:NN
        @#for j in 1:NN
            tau_@{j}@{i}@{p}          ${\tau_{@{j}@{i}@{p}}}$
        @#endfor
    @#endfor
@#endfor

@#for p in 1:PP
    @#for i in 1:NN
        @#for j in 1:NN
            e_@{j}@{i}@{p}          ${e_{@{j}@{i}@{p}}}$
        @#endfor
    @#endfor
@#endfor

; 

%Shocks.
varexo
@#for p in 1:PP
    @#for i in 1:NN
        @#for j in 1:NN
            shock_tau_@{j}@{i}@{p}    ${\varepsilon_{@{j}@{i}@{p}}}$
        @#endfor
    @#endfor
@#endfor
% shock_tau
;

%Parameters.
parameters
beta                ${\beta}$
delta               ${\delta}$
sigma               ${\sigma}$
gamma               ${\gamma}$
chi                 ${\chi}$
b                   ${b}$
rho                 ${\rho}$
E5                  ${E^{5}}$
P_1__P_1           ${\frac{P_{1}}{P_{1}}}$
@#for i in 1:NN
    
    @#for p in 1:PP
    
        alpha_@{i}@{p}                     ${\alpha_{@{i}@{p}}}$ 
        z_@{i}@{p}                         ${z_{@{i}@{p}}}$ 

        @#for j in 1:NN

            omega_@{j}@{i}@{p}            ${\omega_{@{j}@{i}@{p}}}$
            
            kappa_@{j}@{i}@{p}            ${\kappa_{@{j}@{i}@{p}}}$
            ss_tau_@{j}@{i}@{p}           ${\tau^{ss}_{@{j}@{i}@{p}}}$
            
            E1_@{i}@{j}@{p}               ${E^{1}_{@{i}@{j}@{p}}}$
            E2_@{j}@{i}@{p}               ${E^{2}_{@{j}@{i}@{p}}}$
            E3_@{j}@{i}@{p}               ${E^{3}_{@{j}@{i}@{p}}}$
            E4_@{j}@{i}@{p}               ${E^{4}_{@{j}@{i}@{p}}}$
            E6_@{j}@{i}@{p}               ${E^{6}_{@{j}@{i}@{p}}}$

        @#endfor
    
    @#endfor
    
@#endfor
;

%Set parameter values.
load ../../temp_files/parameters_linear.mat;
set_param_value('beta',beta);
set_param_value('delta',delta);
set_param_value('sigma',sigma);
set_param_value('gamma',gamma);
set_param_value('chi',chi);
set_param_value('b',b);
set_param_value('rho',1);
set_param_value('E5',E5);
set_param_value('P_1__P_1',0);
@#for i in 1:NN
    
    @#for p in 1:PP
    
        set_param_value('alpha_@{i}@{p}',alpha_ip(@{i},@{p}));
%         set_param_value('z_@{i}@{p}',z_ip_data(@{i},@{p}));
        set_param_value('z_@{i}@{p}',0);        

        @#for j in 1:NN

%             set_param_value('omega_@{j}@{i}@{p}',omega_data_jip(@{j},@{i},@{p}));
%             set_param_value('kappa_@{j}@{i}@{p}',MC.kappa_jip(@{j},@{i},@{p}));
%             set_param_value('ss_tau_@{j}@{i}@{p}',tariff_data_jip(@{j},@{i},@{p}));
            set_param_value('omega_@{j}@{i}@{p}',0);
            set_param_value('kappa_@{j}@{i}@{p}',0);
            set_param_value('ss_tau_@{j}@{i}@{p}',0);
            
            set_param_value('E1_@{i}@{j}@{p}',E1_ijp(@{i},@{j},@{p}));
            set_param_value('E2_@{j}@{i}@{p}',E2_jip(@{j},@{i},@{p}));
            set_param_value('E3_@{j}@{i}@{p}',E3_jip(@{j},@{i},@{p}));
            set_param_value('E4_@{j}@{i}@{p}',E4_jip(@{j},@{i},@{p}));
            set_param_value('E6_@{j}@{i}@{p}',E6_jip(@{j},@{i},@{p}));

        @#endfor
    
    @#endfor
    
@#endfor

%Model.
model(linear);

%Equation 1.
@#for i in 2:NN
0=
    (P_@{i}__P_1*(0
        @#for j in 1:NN
            @#for p in 1:PP
                @#if j!=i
                    +(E1_@{i}@{j}@{p})
                @#endif
            @#endfor
        @#endfor
    ))
    -(0
        @#for j in 1:NN
            @#if j!=i
                +(P_@{j}__P_1*(0
                @#for p in 1:PP
                    +E1_@{i}@{j}@{p}
                @#endfor
                ))
            @#endif
        @#endfor
    )
    +(0
        @#for j in 1:NN
            @#for p in 1:PP
                @#if j!=i
                    +(E2_@{j}@{i}@{p}*(x_@{j}@{i}@{p}__P_@{i}+n_@{j}@{i}@{p}(-1)))
                @#endif
            @#endfor
        @#endfor
    )
    -(0
        @#for j in 1:NN
            @#for p in 1:PP
                @#if j!=i
                    +(E1_@{i}@{j}@{p}*(x_@{i}@{j}@{p}__P_@{j}+n_@{i}@{j}@{p}(-1)))
                @#endif
            @#endfor
        @#endfor
    )
    ;                  
@#endfor

%Equation 2.
@#for i in 1:NN
    0=      0      
            @#for p in 1:PP
                +(alpha_@{i}@{p}*P_@{i}@{p}__P_@{i})
            @#endfor
            ;
@#endfor

%Equation 3.
@#for j in 1:NN
    @#for p in 1:PP
        P_@{j}@{p}__P_@{j}=    ((1/(1-sigma))*(0
                                @#for i in 1:NN
                                    +(E3_@{j}@{i}@{p}*(omega_@{j}@{i}@{p}+n_@{j}@{i}@{p}(-1)))
                                @#endfor
                                ))+(0
                                @#for i in 1:NN
                                    +(E3_@{j}@{i}@{p}*(tau_@{j}@{i}@{p}+kappa_@{j}@{i}@{p}-z_@{i}@{p}+w_@{i}__P_@{i}))
                                @#endfor
                                )+(0
                                @#for i in 1:NN
                                    @#if i!=j
                                        +(E3_@{j}@{i}@{p}*P_@{i}__P_1)
                                    @#endif
                                @#endfor
                                )-P_@{j}__P_1*(0
                                @#for i in 1:NN
                                    @#if i!=j
                                        +(E3_@{j}@{i}@{p})
                                    @#endif
                                @#endfor
                                )
                                ;
    @#endfor
@#endfor

%Equation 4.
@#for j in 1:NN
    @#for p in 1:PP
        @#for i in 1:NN
            x_@{j}@{i}@{p}__P_@{i}=   (-sigma*tau_@{j}@{i}@{p})-((sigma-1)*(kappa_@{j}@{i}@{p}-z_@{i}@{p}+w_@{i}__P_@{i}-P_@{j}@{p}__P_@{j}))
                                        +omega_@{j}@{i}@{p}-(sigma*(P_@{i}__P_1-P_@{j}__P_1))+C_@{j};
        @#endfor
    @#endfor
@#endfor

%Equation 5.
@#for i in 1:NN
    @#for j in 1:NN
        @#for p in 1:PP
            v_@{j}@{i}@{p}=   ((gamma)*(-C_@{i}(+1)+C_@{i}))+((1-(beta*(1-delta)))*x_@{j}@{i}@{p}__P_@{i}(+1))+((beta*(1-delta))*v_@{j}@{i}@{p}(+1));
        @#endfor
    @#endfor
@#endfor

%Equation 6.
@#for i in 1:NN
    @#for j in 1:NN
        @#for p in 1:PP
            n_@{j}@{i}@{p}=   ((1-delta)*n_@{j}@{i}@{p}(-1))+(chi*delta*v_@{j}@{i}@{p})-(chi*delta*w_@{i}__P_@{i});
%             n_@{j}@{i}@{p}(+1)=   ((1-delta)*n_@{j}@{i}@{p})+(chi*delta*v_@{j}@{i}@{p})-(chi*delta*w_@{i}__P_@{i});
        @#endfor
    @#endfor
@#endfor

%Equation 7.
@#for i in 1:NN
    w_@{i}__P_@{i}=(0
            @#for j in 1:NN
                @#for p in 1:PP
                    +(E4_@{j}@{i}@{p}*(x_@{j}@{i}@{p}__P_@{i}+n_@{j}@{i}@{p}(-1)))
                @#endfor
            @#endfor
            )+(E5*S_@{i});              
@#endfor

%Equation 8.
@#for i in 1:NN
    S_@{i}= 0
            @#for j in 1:NN
                @#for p in 1:PP
                    +(E6_@{j}@{i}@{p}*(v_@{j}@{i}@{p}-w_@{i}__P_@{i}))
                @#endfor
            @#endfor
            ;
@#endfor

%Equation 9.
@#for j in 1:NN
    @#for i in 1:NN
        @#for p in 1:PP
            tau_@{j}@{i}@{p}=   rho*tau_@{j}@{i}@{p}(-1)+e_@{j}@{i}@{p};
        @#endfor
    @#endfor
@#endfor

@#for j in 1:NN
    @#for i in 1:NN
        @#for p in 1:PP
            e_@{j}@{i}@{p}=   shock_tau_@{j}@{i}@{p};
        @#endfor
    @#endfor
@#endfor

end;

%Initial values.
initval;
@#for i in 1:1
    
    C_@{i}=0;
    w_@{i}__P_@{i}=0;
%     P_@{i}__P_1=0;
    S_@{i}=0;
    
    @#for p in 1:PP
        
        P_@{i}@{p}__P_@{i}=0;
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            x_@{j}@{i}@{p}__P_@{i}=0;
            n_@{j}@{i}@{p}=0;
            v_@{j}@{i}@{p}=0;
            
            tau_@{j}@{i}@{p}=0;
            e_@{j}@{i}@{p}=0;
            
        @#endfor
    @#endfor
    
@#endfor

@#for i in 2:NN
    
    C_@{i}=0;
    w_@{i}__P_@{i}=0;
    P_@{i}__P_1=0;
    S_@{i}=0;
    
    @#for p in 1:PP
        
        P_@{i}@{p}__P_@{i}=0;
        
    @#endfor
    
    @#for j in 1:NN
        @#for p in 1:PP
            
            x_@{j}@{i}@{p}__P_@{i}=0;
            n_@{j}@{i}@{p}=0;
            v_@{j}@{i}@{p}=0;
            
            tau_@{j}@{i}@{p}=0;
            e_@{j}@{i}@{p}=0;
            
        @#endfor
    @#endfor
    
@#endfor

end;
steady(solve_algo=4);

%Shocks.
shocks;
var shock_tau_123;  stderr 0.01;
end;

%Stochastic simulation.
stoch_simul(irf=16, nocorr, nomoments, nodecomposition, nograph, nofunctions);

%Save results.
% save results\oo_.mat oo_;
% save results\M_.mat M_;
save ../../temp_files/results_dynare.mat;

%Latex.
write_latex_original_model;
collect_latex_files;

% figure;
% subplot(2,3,1);
% hold on;
% plot(oo_.irfs.tau_123_shock_tau_123*100);
% plot(zeros(length(oo_.irfs.tau_123_shock_tau_123)),'Color','Black','LineWidth',2);
% title('tau_123','Interpreter','None');
% xlim([1 (length(oo_.irfs.tau_123_shock_tau_123))]);
% subplot(2,3,2);
% hold on;
% plot(oo_.irfs.x_123__P_2_shock_tau_123*100);
% plot(zeros(length(oo_.irfs.tau_123_shock_tau_123)),'Color','Black','LineWidth',2);
% title('x_123__P_2','Interpreter','None');
% xlim([1 (length(oo_.irfs.tau_123_shock_tau_123))]);
% subplot(2,3,3);
% hold on;
% plot(oo_.irfs.n_123_shock_tau_123*100);
% plot(zeros(length(oo_.irfs.tau_123_shock_tau_123)),'Color','Black','LineWidth',2);
% title('n_123','Interpreter','None');
% xlim([1 (length(oo_.irfs.tau_123_shock_tau_123))]);
% subplot(2,3,4);
% hold on;
% plot(oo_.irfs.x_123__P_2_shock_tau_123*100+oo_.irfs.n_123_shock_tau_123*100);
% plot(zeros(length(oo_.irfs.tau_123_shock_tau_123)),'Color','Black','LineWidth',2);
% title('x_123__P_2+n_123','Interpreter','None');
% xlim([1 (length(oo_.irfs.tau_123_shock_tau_123))]);
% subplot(2,3,5);
% hold on;
% plot(oo_.irfs.v_123_shock_tau_123*100);
% plot(zeros(length(oo_.irfs.tau_123_shock_tau_123)),'Color','Black','LineWidth',2);
% title('v_123','Interpreter','None');
% xlim([1 (length(oo_.irfs.tau_123_shock_tau_123))]);