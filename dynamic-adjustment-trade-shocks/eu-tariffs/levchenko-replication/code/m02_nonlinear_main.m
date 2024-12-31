clear all;
clc;
cd './dynamic_GFT/'

%Define countries.
countries={'AUT' 'BEL' 'CAN' 'CHN' 'CZE' 'DEU' 'DNK' 'ESP' 'FIN' 'FRA' 'GBR' 'GRC' 'IRL' 'ITA' 'JPN' 'KOR' 'NLD' 'POL' 'PRT' 'SVK' 'SVN' 'SWE' 'USA'};

%Define parameters.
gamma=2;
sigmas=[1.1 3];
chis=[0.82 1];
cases={'1' '2'};

%Run Dynare code.
for ii=1:length(sigmas)
    
    sigma=sigmas(ii);
    chi=chis(ii);

    for xx=1:numel(countries)

        display(countries(xx))

        %Solve for steady state.
        aux_calibration;

        %Solve model.
        dynare aux_model_nl.mod;
        
        %Save consumption.
        eval(['C_1_', countries{xx}, '_', cases{ii}, '=C_1;']);
        
        %Save kappa.
        eval(['kappa_', countries{xx}, '_', cases{ii}, '=MC.kappa_jip;']);

    end

end

%Generate number of periods.
len=length(tau_111);
T=len-1;
t=[1:T];

%Generate discount rate.
betas=ones(T-1,1);
for t=1:T
    betas(t)=beta^(t-1);
end

%Define consumption function.
func_c=@(c) c.^(1-gamma);

%Welfare results.
for ii=1:length(sigmas)
    
    w=[];
    for xx=1:numel(countries)
        
        %Define consumption.
        eval(['C_=C_1_', countries{xx}, '_', cases{ii}, ';']);
        C_ini=C_(1);
        C_=C_(2:end);
        
        %Drop cases where consumption is negative.
        min_C=min(C_);
        max_C=max(C_);
        if min_C>=0 && max_C<=1.01
        
            %Calculate value in initial steady state.
            w_ini=C_ini;

            %Calculate value in transition + final steady state.
            value_func_c=func_c(C_);
            value_disc=betas.*value_func_c;
            w_end=((1-beta)*sum(value_disc(1:end-1)))+(value_disc(end));
            w_end=w_end^(1/(1-gamma));
            
            %Generate percentage difference.
            w_dif=(w_end-w_ini)/w_ini;
            disp('Welfare gains')
            disp(w_dif)
            
        else
            
            w_ini=NaN;
            w_end=NaN;
            w_dif=NaN;
            
        end
        
        %Save results.
        s=sprintf('[''%s'']', [countries{xx}]);
        country=cellstr(eval(s));
        eval(['w_', countries{xx}, '=table(country,w_ini,w_end,w_dif);']);
        eval(['w=[w; w_', countries{xx}, '];']);
        
    end
        
    
    %Save results.
    eval(['save ../../temp_files/w_', cases{ii}, '.mat w;']);
    s=sprintf('writetable(w, ''%s'')', ['../../temp_files/w_' cases{ii} '.csv']);
    eval(s);
  
    
end

delete ss_dynare.mat;
