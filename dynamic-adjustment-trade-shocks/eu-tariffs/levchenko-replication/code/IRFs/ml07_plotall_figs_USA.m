close all

% preliminaries
lightness1 = 0.00;
light_grey1 = lightness1*[1 1 1] + (1-lightness1)*[0 0 0];
light_red1 = lightness1*[1 1 1] + (1-lightness1)*[1 0 0];
light_blue1 = lightness1*[1 1 1] + (1-lightness1)*[0 0 1];

hFig = figure(1);
%                      left bottom width height
set(hFig, 'Position', [100  100   1000   1000])
%%
%%% Part 1 %%%
load ../../temp_files/USAind_irfs_sig1p10_chi0p82

subplot(2,2,1)
plot(irfs.year,irfs.trade_pe,'Color','blue', 'LineWidth', 2);
hold on

irf_min = min(irfs.trade,[],2);
irf_max = max(irfs.trade,[],2);
ciplot(irf_min,irf_max,irfs.year,light_blue1);


load ../../temp_files/USAind_irfs_sig3p00_chi1p00

plot(irfs.year,irfs.trade_pe,'Color','red','LineStyle','--','LineWidth', 2);

irf_min = min(irfs.trade,[],2);
irf_max = max(irfs.trade,[],2);
ciplot(irf_min,irf_max,irfs.year,light_red1);

hold off
title('Panel A: 1% tariff hike on one product from one exporter')
yline(0,'Color',[0.2 0.2 0.2])

xticks([0:2:14])
xlabel('Years')

ylabel({'Bilateral product-specific imports targeted by tariff'; '(percent deviation from steady state)'})
ylim([-6 0.5])
grid on 


%%
%%% Part 2 %%%
subplot(2,2,2)

load ../../temp_files/USAall_sectors_irfs_sig1p10_chi0p82

plot(irfs.year,irfs.trade_pe,'Color','blue', 'LineWidth', 2);
hold on

irf_min = min(irfs.trade,[],2);
irf_max = max(irfs.trade,[],2);
ciplot(irf_min,irf_max,irfs.year,light_blue1);


load ../../temp_files/USAall_sectors_irfs_sig3p00_chi1p00

plot(irfs.year,irfs.trade_pe,'Color','red','LineStyle','--','LineWidth', 2);

irf_min = min(irfs.trade,[],2);
irf_max = max(irfs.trade,[],2);
ciplot(irf_min,irf_max,irfs.year,light_red1);

hold off
title('Panel B: 1% tariff hike on all products from one exporter')
yline(0,'Color',[0.2 0.2 0.2])


xticks([0:2:14])
xlabel('Years')
ylabel({'Bilateral product-specific imports targeted by tariffs'; '(percent deviation from steady state)'})
ylim([-6 0.5])
grid on 


%%
%%% Part 3 %%%
subplot(2,2,3)

load ../../temp_files/USAall_cntrs_irfs_sig1p10_chi0p82

plot(irfs.year,irfs.trade_pe,'Color','blue', 'LineWidth', 2);
hold on

irf_min = min(irfs.trade,[],2);
irf_max = max(irfs.trade,[],2);
ciplot(irf_min,irf_max,irfs.year,light_blue1);


load ../../temp_files/USAall_cntrs_irfs_sig3p00_chi1p00

plot(irfs.year,irfs.trade_pe,'Color','red','LineStyle','--','LineWidth', 2);

irf_min = min(irfs.trade,[],2);
irf_max = max(irfs.trade,[],2);
ciplot(irf_min,irf_max,irfs.year,light_red1);


hold off
title('Panel C: 1% tariff hike on one product from all exporters')

xticks([0:2:14])
xlabel('Years')
ylabel({'Bilateral product-specific imports targeted by tariffs'; '(percent deviation from steady state)'})
ylim([-6 0.5])
grid on 

lgd = legend('Baseline calibration, PE response', ...
    'Baseline calibration, GE range USA', ...
    'High elasticity, PE response',...
    'High elasticity, GE range USA',...
    'location','none','Box','on','Interpreter','latex','Fontsize',11);

lgd.NumColumns = 2;
% lgd.Position = [0.214807436918991,0.001686123527596,0.586831355736708,0.051491567782391];
lgd.Position = [0.315,0.022,0.4,0.03];
% lgd.Position = [0.315,0.025,0.2,0.03];

%%
%%% Part 4 %%%

subplot(2,2,4)

load ../../temp_files/USAallcntrs_allsec_irfs_sig1p10_chi0p82

plot(irfs.year,irfs.trade_pe,'Color','blue', 'LineWidth', 2);
hold on

irf_min = min(irfs.trade,[],2);
irf_max = max(irfs.trade,[],2);
ciplot(irf_min,irf_max,irfs.year,light_blue1);


load ../../temp_files/USAallcntrs_allsec_irfs_sig3p00_chi1p00

plot(irfs.year,irfs.trade_pe,'Color','red','LineStyle','--','LineWidth', 2);

irf_min = min(irfs.trade,[],2);
irf_max = max(irfs.trade,[],2);
ciplot(irf_min,irf_max,irfs.year,light_red1);


hold off
title('Panel D: 1% tariff hike on all products from all exporters')

% lgd2.Position = [0.699268858463093,0.161278735632184,0.20204014926571,0.120797409785205];
xticks([0:2:14])
xlabel('Years')
ylabel({'Bilateral product-specific imports targeted by tariffs'; '(percent deviation from steady state)'})
ylim([-6 0.5])
grid on 



set(figure(1), 'PaperUnits', 'inches');
scale = 1.2;
x_width=9*scale; y_width=9*scale;
set(figure(1), 'PaperPosition', [0 0 x_width y_width]); 
print(figure(1),'-dpng','-r600',strcat('../../output/graphs/final_files/fig_all4_','USA','.png'))
print(figure(1),'-depsc','-r600',strcat('../../output/graphs/final_files/fig_all4_','USA','.eps'))
