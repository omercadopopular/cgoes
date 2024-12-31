clear all;
clc;
cd '../output/graphs/temp_files/'
addpath '../../../code/empirics_subroutine/'

%%
%%%%%%%%%%%%%%%%
%%%Figure 7%%%%%
%%%%%%%%%%%%%%%%

CHN_lambda = 0.91549164;
DEU_lambda = 0.85538307;
USA_lambda = 0.93986941;
avg_lambda = 0.85593072;
 
gains_from_trade = @(lambda,epsilon) lambda.^(1./epsilon) - 1;

epsilon_base    = -1;
epsilon_5       = -5;

lambda_vec = 1:-0.005:0.75;

N = 6;
C = linspecer(N);

fig1 = figure(1);
plot(lambda_vec,gains_from_trade(lambda_vec,epsilon_base),'-','color','Blue', 'LineWidth', 3); 
hold on
plot(lambda_vec,gains_from_trade(lambda_vec,epsilon_5),'--','color','Red', 'LineWidth', 3); 
deu = xline(DEU_lambda,'--','Germany', 'color', [.5 .5 .5], 'Fontsize', 15, 'LineWidth', 1,'LabelHorizontalAlignment','left');
us = xline(USA_lambda,'--','US', 'color', [.5 .5 .5], 'Fontsize', 15, 'LineWidth', 1,'LabelHorizontalAlignment','left');
chn = xline(CHN_lambda,'--','China', 'color', [.5 .5 .5], 'Fontsize', 15, 'LineWidth', 1,'LabelHorizontalAlignment','left');
avg = xline(avg_lambda,'-','World median', 'color', 'black', 'Fontsize', 15, 'LineWidth', 1,'LabelHorizontalAlignment','right','FontWeight','bold');
ylabel('Gains from trade','Fontsize',15)
xlabel('$\lambda_{jj}$','Interpreter','latex','Fontsize',15)
legend('Baseline','High elasticity','Location','northeast','Fontsize',15,'Interpreter','latex')
set(fig1,'position',[10,10,1200,1000])
ax = gca
ax.FontSize = 15

print('..\final_files\GFT','-depsc','-r300')
print('..\final_files\GFT','-dpng','-r300')
