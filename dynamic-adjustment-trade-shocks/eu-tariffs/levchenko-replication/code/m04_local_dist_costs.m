clear all;
clc;
cd './model_subroutines/'

% Estimates
data = readtable('../../output/graphs/temp_files/fig_5.xls','ReadRowNames',true,'Sheet','new');

% Model Paramers     
sigma       = 1.1;
delta       = 0.25;     	% depreciation rate of customers
R           = 1.03;         % gross interest rate
rho         = 0.955;      	% persistence of tariff shock 0.9637

theta_sr    = -sigma;
theta_lr    = -2;

chi      = -(theta_lr-theta_sr)/sigma; % adustment costs

% Other Parameters
nplot   = 10;    	% periods to be plotted
dat=(0:nplot)';                             % Date variable for plotting 
N = 6;
C = linspecer(N);



% Analytic model solution

% For permanent after 1 year
dynamic_trade_elasticity_c1s = -sigma - sigma*chi*(1 - (1-delta).^dat);

% For AR(1)
tariffsAR1 = rho.^dat;

dynamic_trade_elasticity_AR1 = -sigma -sigma*chi*...
    (delta + R -1)*delta/((R - rho*(1-delta))*(1-((1-delta)/rho)))*...
    (1-((1-delta)/rho).^dat);


fig2 = figure(2);

subplot(1,2,1)
plot(dat,[1; 0.75*ones(10,1)],'-','color',C(1,:), 'LineWidth', 2);
hold on
plot(dat,tariffsAR1,'-','color',C(2,:), 'LineWidth', 2); 
plot(dat,data.tariffs,'-','color',C(3,:), 'LineWidth', 2);  
yline(0);
hold off
title('Tariffs')
xlabel('Years')
ylim([-0.1 1.1])
xlim([0 10])
grid on
legend('Model - constant after 1 period','Model - AR(1)','Data','Location','Southwest','Fontsize',10)


subplot(1,2,2)
plot(dat,dynamic_trade_elasticity_c1s,'-','color',C(1,:), 'LineWidth', 2); 
hold on
plot(dat,dynamic_trade_elasticity_AR1,'-','color',C(2,:), 'LineWidth', 2); 
plot(dat,[data.elasticity_implied(2:end); nan],'-','color',C(3,:), 'LineWidth', 2); 
yline(0);
yll = yline(theta_lr,'-','Long-run trade elasticity');
yll.LabelHorizontalAlignment = 'left';
yll.LabelVerticalAlignment = 'top';
yll.Color = C(5,:);
yll.LineWidth = 2;
yls = yline(theta_sr,'-','Short-run trade elasticity');
yls.LabelHorizontalAlignment = 'right';
yls.LabelVerticalAlignment = 'top';
yls.Color = C(6,:);
yls.LineWidth = 2;
hold off
title('Trade elasticity')
xlabel('Years')
ylim([-2.5 0.1])
xlim([0 10])
grid on

scale_factor = 1;
set(fig2, 'PaperUnits', 'inches');
x_width=10*scale_factor; y_width=4*scale_factor;
set(fig2, 'PaperPosition', [0 0 x_width y_width]); 
print(fig2,'-dpng','-r300','../../output/graphs/final_files/trade_elasticities_.png')
print(fig2,'-depsc','-r300','../../output/graphs/final_files/trade_elasticities_.eps')

  