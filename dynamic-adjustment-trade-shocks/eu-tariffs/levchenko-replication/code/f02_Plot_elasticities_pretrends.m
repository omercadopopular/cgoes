clear all;
clc;
cd '../output/graphs/temp_files/'
addpath '../../../code/empirics_subroutine/'

%%
%%%%%%%%%%%%%%%%%%%%
%%%Figure 1, Left%%%
%%%%%%%%%%%%%%%%%%%%

%Tariffs, no pretrend controls.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="tariffs_nopre";
opts.DataRange="A2:I18";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_tariffs_nopre=readtable("fig_1.xls", opts, "UseExcel", false);

%Tariffs, pretrend controls.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="tariffs_pre";
opts.DataRange="A2:I18";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_tariffs_pre=readtable("fig_1.xls", opts, "UseExcel", false);

%Plot figure.
fig=figure;
set(gca,'FontSize',13);
hold on;
e0=errorbar(table_tariffs_nopre.horizon, table_tariffs_nopre.b, table_tariffs_nopre.se, '-o', 'Linewidth', 1.5, 'CapSize', 8, 'LineStyle', 'none');
e0.Color=[0.850980392156863 0.325490196078431 0.098039215686274];
e0.MarkerSize=7;
e1=errorbar(table_tariffs_pre.horizon, table_tariffs_pre.b, table_tariffs_pre.se, '-s', 'Linewidth', 1.5, 'CapSize', 8, 'LineStyle', 'none');
e1.Color=[0, 0.4470, 0.7410];
e1.MarkerSize=7;
xlabel("Horizon (years)");
hline=refline([0 0]);
hline.Color='black';
ylabel("Estimates of $\beta^{h}_{\tau}$",'interpreter','latex');
xlim([-6 10]); xticks([-6 -4 -2 0 2 4 6 8 10]);
ylim([-0.4 1.2]); yticks([-0.4 -0.2 0 0.2 0.4 0.6 0.8 1.0 1.2]);
line0=plot(table_tariffs_nopre.horizon, table_tariffs_nopre.b ,'--', 'Color',[0.850980392156863 0.325490196078431 0.098039215686274],'LineWidth',2 );
line1=plot(table_tariffs_pre.horizon, table_tariffs_pre.b, '-', 'Color',[0, 0.4470, 0.7410],'LineWidth',2 );
legend([line0 line1],{'No pretrend controls','Pretrend controls'});
grid on;
hold off;
set(fig, 'PaperUnits', 'inches');
scale=2.0;
x_width=scale*4; y_width=scale*3;
set(fig, 'PaperPosition', [0 0 x_width y_width]); 
print('..\final_files\pretrend_Tl0l1','-dpng','-r300');
print('..\final_files\pretrend_Tl0l1','-depsc','-r300');
print('..\final_files\pretrend_Tl0l1','-dpdf','-r300');

%%
%%%%%%%%%%%%%%%%%%%%%
%%%Figure 1, Right%%%
%%%%%%%%%%%%%%%%%%%%%

%Trade, no pretrend controls.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="ln_trade_val_nopre";
opts.DataRange="A2:I18";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_ln_trade_val_nopre=readtable("fig_1.xls", opts, "UseExcel", false);

%Trade, pretrend controls.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="ln_trade_val_pre";
opts.DataRange="A2:I18";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_ln_trade_val_pre=readtable("fig_1.xls", opts, "UseExcel", false);

%Plot figure.
fig=figure;
set(gca,'FontSize',13);
hold on;
e0=errorbar(table_ln_trade_val_nopre.horizon, table_ln_trade_val_nopre.b, table_ln_trade_val_nopre.ci, '-o', 'Linewidth', 1.5, 'CapSize', 8, 'LineStyle', 'none');
e0.Color=[0.850980392156863 0.325490196078431 0.098039215686274];
e0.MarkerSize=7;
e1=errorbar(table_ln_trade_val_pre.horizon, table_ln_trade_val_pre.b, table_ln_trade_val_pre.ci, '-s', 'Linewidth', 1.5, 'CapSize', 8, 'LineStyle', 'none');
e1.Color=[0, 0.4470, 0.7410];
e1.MarkerSize=7;
xlabel("Horizon (years)");
hline=refline([0 0]);
hline.Color='black';
ylabel("Estimates of $\beta^{h}_{X}$",'interpreter','latex');
xlim([-6 10]); xticks([-6 -4 -2 0 2 4 6 8 10]);
ylim([-2 1]); yticks([-2 -1.5 -1 -0.5 0 0.5 1]);
line0=plot(table_ln_trade_val_nopre.horizon, table_ln_trade_val_nopre.b ,'--', 'Color',[0.850980392156863 0.325490196078431 0.098039215686274],'LineWidth',2 );
line1=plot(table_ln_trade_val_pre.horizon, table_ln_trade_val_pre.b, '-', 'Color',[0, 0.4470, 0.7410],'LineWidth',2 );
grid on;
hold off;
set(fig, 'PaperUnits', 'inches');
scale=2.0;
x_width=scale*4; y_width=scale*3;
set(fig, 'PaperPosition', [0 0 x_width y_width]); 
print('..\final_files\pretrend_Xl0l1','-dpng','-r300');
print('..\final_files\pretrend_Xl0l1','-depsc','-r300');
print('..\final_files\pretrend_Xl0l1','-dpdf','-r300');

%%
%%%%%%%%%%%%%%
%%%Figure 2%%%
%%%%%%%%%%%%%%

%Baseline.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="baseline";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_baseline=readtable("fig_2.xls", opts, "UseExcel", false);

%All data / all tariffs.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="all";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double"];
table_all=readtable("fig_2.xls", opts, "UseExcel", false);

%Plot figure.
fig=figure;
set(gca,'FontSize',13);
hold on;
e0=errorbar(table_baseline.horizon, table_baseline.b, table_baseline.ci, '-o', 'Linewidth', 1.5, 'CapSize', 8, 'LineStyle', 'none');
e0.Color=[0, 0.4470, 0.7410];
e0.MarkerSize=7;
e1=errorbar(table_all.horizon, table_all.b, table_all.ci, '-d', 'Linewidth', 1.5, 'CapSize', 8, 'LineStyle', 'none');
e1.Color=[0.850980392156863 0.325490196078431 0.098039215686274];
e1.MarkerSize=7;
xlabel("Horizon (years)");
hline=refline([0 0]);
hline.Color='black';
ylabel("Estimates of $\varepsilon^{h}$",'interpreter','latex');
xlim([0 10]); xticks([0 1 2 3 4 5 6 7 8 9 10]);
ylim([-3 0]); yticks([-3 -2.5 -2 -1.5 -1 -0.5 0]);
line0=plot(table_baseline.horizon, table_baseline.b ,'-', 'Color',[0, 0.4470, 0.7410],'LineWidth',2 );
line1=plot(table_all.horizon, table_all.b, '-', 'Color',[0.850980392156863 0.325490196078431 0.098039215686274],'LineWidth',2 );
text(table_baseline.horizon+0.1, table_baseline.b-0.1, num2str(table_baseline.b,'%.2f'),'Fontsize',10);
text(table_all.horizon+0.1, table_all.b+0.1, num2str(table_all.b,'%.2f'),'Fontsize',10);
legend([line0 line1],{'Baseline','All data / all tariffs 2SLS'});
grid on;
hold off;
set(fig, 'PaperUnits', 'inches');
scale=2.0;
x_width=scale*4; y_width=scale*3;
set(fig, 'PaperPosition', [0 0 x_width y_width]); 
print('..\final_files\trade_elast_comparison_baselinel1','-dpng','-r300');
print('..\final_files\trade_elast_comparison_baselinel1','-depsc','-r300');
print('..\final_files\trade_elast_comparison_baselinel1','-dpdf','-r300');

%%
%%%%%%%%%%%%%%
%%%Figure 3%%%
%%%%%%%%%%%%%%

%Section 1.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section1l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section1_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 2.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section2l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section2_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 3.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section3l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section3_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 4.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section4l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section4_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 5.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section5l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section5_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 6.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section6l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section6_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 7.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section7l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section7_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 8.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section8l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section8_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 9.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section9l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section9_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 10.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section10l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section10_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 11.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section11l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section11_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 12.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section12l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section12_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 13.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section13l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section13_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 14.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section14l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section14_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 15.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section15l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section15_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 16.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section16l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section16_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 17.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section17l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section17_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 18.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section18l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section18_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 19.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section19l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section19_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 20.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section20l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section20_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 21.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section21l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section21_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Aggregate.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section_aggnonl1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
sectionagg_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Define values.
b_Baseline_1=section1_iv_0.b;
b_Baseline_2=section2_iv_0.b;
b_Baseline_3=section3_iv_0.b;
b_Baseline_4=section4_iv_0.b;
b_Baseline_5=section5_iv_0.b;
b_Baseline_6=section6_iv_0.b;
b_Baseline_7=section7_iv_0.b;
b_Baseline_8=section8_iv_0.b;
b_Baseline_9=section9_iv_0.b;
b_Baseline_10=section10_iv_0.b;
b_Baseline_11=section11_iv_0.b;
b_Baseline_12=section12_iv_0.b;
b_Baseline_13=section13_iv_0.b;
b_Baseline_14=section14_iv_0.b;
b_Baseline_15=section15_iv_0.b;
b_Baseline_16=section16_iv_0.b;
b_Baseline_17=section17_iv_0.b;
b_Baseline_18=section18_iv_0.b;
b_Baseline_19=section19_iv_0.b;
b_Baseline_20=section20_iv_0.b;
b_Baseline_21=section21_iv_0.b;
b_Baseline_agg=sectionagg_iv_0.b;

%Define horizon.
horizon_sec=section1_iv_0.horizon;
horizon_sec2=[horizon_sec; 11; 12];

%Divide by groups from lowest to highest.
long_run=[b_Baseline_7(end-3:end) b_Baseline_8(end-3:end) b_Baseline_9(end-3:end) b_Baseline_10(end-3:end) b_Baseline_11(end-3:end) b_Baseline_13(end-3:end) b_Baseline_15(end-3:end) b_Baseline_16(end-3:end) b_Baseline_18(end-3:end) b_Baseline_20(end-3:end) b_Baseline_agg(end-3:end)];
long_run=median(long_run);
[a b]=sort(long_run);

%Figure.
fig=figure;
set(gca,'FontSize',13);
hold on;
s7=plot(horizon_sec2,[b_Baseline_7; nan ;median(b_Baseline_7(end-3:end))],'+','LineWidth',2,'DisplayName','Sec 7');
s8=plot(horizon_sec2,[b_Baseline_8; nan ;median(b_Baseline_8(end-3:end))],'o','LineWidth',2,'DisplayName','Sec 8');
s9=plot(horizon_sec2,[b_Baseline_9; nan ;median(b_Baseline_9(end-3:end))],'o','LineWidth',2,'DisplayName','Sec 9');
s10=plot(horizon_sec2,[b_Baseline_10; nan ;median(b_Baseline_10(end-3:end))],'+','LineWidth',2,'DisplayName','Sec 10');
s11=plot(horizon_sec2,[b_Baseline_11; nan ;median(b_Baseline_11(end-3:end))],'o','LineWidth',2,'DisplayName','Sec 11');
s13=plot(horizon_sec2,[b_Baseline_13; nan ;median(b_Baseline_13(end-3:end))],'o','LineWidth',2,'DisplayName','Sec 13');
s15=plot(horizon_sec2,[b_Baseline_15; nan ;median(b_Baseline_15(end-3:end))],'+','LineWidth',2,'DisplayName','Sec 15');
s16=plot(horizon_sec2,[b_Baseline_16; nan ;median(b_Baseline_16(end-3:end))],'*','LineWidth',2,'DisplayName','Sec 16');
s18=plot(horizon_sec2,[b_Baseline_18; nan ;median(b_Baseline_18(end-3:end))],'*','LineWidth',2,'DisplayName','Sec 18');
s20=plot(horizon_sec2,[b_Baseline_20; nan ;median(b_Baseline_20(end-3:end))],'*','LineWidth',2,'DisplayName','Sec 20');
sagg=plot(horizon_sec2,[b_Baseline_agg; nan ;median(b_Baseline_agg(end-3:end))],'+','LineWidth',2,'DisplayName','Sec agg');
sline=yline(0);
sline.Color='black';
lgd=legend('Plastics (7)','Leather (8)','Wood (9)','Paper (10)','Textile (11)','Stone (13)','Base metals (15)','Machinery (16)','Optics (18)','Misc Manuf. (20)','Sec agg','Location', 'southwest');
lgd.NumColumns=10;
xlabel('Horizon (year)')
xticks([0:1:10 12])
xticklabels({'0','1','2','3','4','5','6','7','8','9','10','median 7-10'})
ylim([-8 0]);
xlim([-.5 13]);
grid on
hold off
set(fig, 'PaperUnits', 'inches');
scale=2.0;
x_width=scale*6; y_width=scale*3.5;
set(fig, 'PaperPosition', [0 0 x_width y_width]); 
print('..\final_files\scatter_sector_l1','-dpng','-r300');
print('..\final_files\scatter_sector_l1','-depsc','-r300');
print('..\final_files\scatter_sector_l1','-dpdf','-r300');

%%
%%%%%%%%%%%%%%%
%%%Figure B1%%%
%%%%%%%%%%%%%%%

%Baseline.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="baseline";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_baseline=readtable("fig_2.xls", opts, "UseExcel", false);

%Section 1.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section1l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section1_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 2.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section2l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section2_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 3.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section3l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section3_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 4.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section4l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section4_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 5.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section5l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section5_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 6.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section6l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section6_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 7.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section7l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section7_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 8.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section8l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section8_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 9.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section9l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section9_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 10.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section10l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section10_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 11.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section11l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section11_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 12.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section12l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section12_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 13.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section13l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section13_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 14.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section14l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section14_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 15.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section15l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section15_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 16.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section16l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section16_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 17.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section17l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section17_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 18.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section18l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section18_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 19.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section19l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section19_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 20.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section20l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section20_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Section 21.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section21l1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
section21_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Aggregate.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="iv_0_baseline_section_aggnonl1";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
sectionagg_iv_0=readtable("fig_3.xls", opts, "UseExcel", false);

%Define values.
b_Baseline_pool=table_baseline.b;
b_Baseline_1=section1_iv_0.b;
b_Baseline_2=section2_iv_0.b;
b_Baseline_3=section3_iv_0.b;
b_Baseline_4=section4_iv_0.b;
b_Baseline_5=section5_iv_0.b;
b_Baseline_6=section6_iv_0.b;
b_Baseline_7=section7_iv_0.b;
b_Baseline_8=section8_iv_0.b;
b_Baseline_9=section9_iv_0.b;
b_Baseline_10=section10_iv_0.b;
b_Baseline_11=section11_iv_0.b;
b_Baseline_12=section12_iv_0.b;
b_Baseline_13=section13_iv_0.b;
b_Baseline_14=section14_iv_0.b;
b_Baseline_15=section15_iv_0.b;
b_Baseline_16=section16_iv_0.b;
b_Baseline_17=section17_iv_0.b;
b_Baseline_18=section18_iv_0.b;
b_Baseline_19=section19_iv_0.b;
b_Baseline_20=section20_iv_0.b;
b_Baseline_21=section21_iv_0.b;
b_Baseline_agg=sectionagg_iv_0.b;

%Weights (import value in 2006).
weights = [1.68e+08 1.87e+08 4.07e+07 2.39e+08 1.19e+09 9.31e+08 4.57e+08 ...
    6.17e+07 9.14e+07 2.04e+08 4.70e+08 6.78e+07 1.06e+08 1.57e+08 8.68e+08 ...
    2.78e+09 1.14e+09 3.49e+08 5284256 2.20e+08 1.48e+07]';

%To keep:  7, 8, 9, 10, 11, 13, 15, 16, 18, 20.
w_tokeep = weights([7,8,9,10,11,13,15,16,18,20]);
w_tokeep=w_tokeep/sum(w_tokeep);
elasticities = [b_Baseline_7 b_Baseline_8 b_Baseline_9 b_Baseline_10 b_Baseline_11 b_Baseline_13 b_Baseline_15 b_Baseline_16 b_Baseline_18 b_Baseline_20];
wmed_elasticities = zeros(size(elasticities,1),1);
for i =1:size(elasticities,1)
    wmed_elasticities(i) = weightedMedian(elasticities(i,:)',w_tokeep)
end
wavg_sections = (1/sum(w_tokeep))*[b_Baseline_7 b_Baseline_8 b_Baseline_9 b_Baseline_10 b_Baseline_11 b_Baseline_13 b_Baseline_15 b_Baseline_16 b_Baseline_18 b_Baseline_20]*w_tokeep;
avg_sections = (1/sum(ones(size(w_tokeep))))*[b_Baseline_7 b_Baseline_8 b_Baseline_9 b_Baseline_10 b_Baseline_11 b_Baseline_13 b_Baseline_15 b_Baseline_16 b_Baseline_18 b_Baseline_20]*ones(size(w_tokeep));
med_sections = median([b_Baseline_7 b_Baseline_8 b_Baseline_9 b_Baseline_10 b_Baseline_11 b_Baseline_13 b_Baseline_15 b_Baseline_16 b_Baseline_18 b_Baseline_20],2);
wmed_sections = wmed_elasticities;

%Set horizon.
horizon_sec2 = [horizon_sec; 11; 12];

%Figure.
fig=figure;
set(gca,'FontSize',13);
hold on;
plot_pool = plot(horizon_sec2,[b_Baseline_pool; nan ;median(b_Baseline_pool(end-3:end))],'o','LineWidth',2,'DisplayName','Sec 7');
plot_section_wavg = plot(horizon_sec2,[wavg_sections; nan ;median(wavg_sections(end-3:end))],'o','LineWidth',2,'DisplayName','Sec 7');
plot_section_savg = plot(horizon_sec2,[wmed_sections; nan ;median(wmed_sections(end-3:end))],'o','LineWidth',2,'DisplayName','Sec 7');
sline = yline(0);
sline.Color = 'black';
lgd = legend('Baseline','Weighted section average','Weighted section median','Location', 'southwest');
%ylim([-7.5,1]);
xlabel('Horizon (year)')
xticks([0:1:10 12])
xticklabels({'0','1','2','3','4','5','6','7','8','9','10','median 7-10'})
ylim([-4 0]);
xlim([-.5 13]);
grid on
hold off
set(fig, 'PaperUnits', 'inches');
scale = 2.0;
x_width = scale*6; y_width=scale*3.5;
set(fig, 'PaperPosition', [0 0 x_width y_width]); 
print('..\final_files\section_wavg_wmed_elasticities','-dpng','-r300');
print('..\final_files\section_wavg_wmed_elasticities','-depsc','-r300');
print('..\final_files\section_wavg_wmed_elasticities','-dpdf','-r300');

%%
%%%%%%%%%%%%%%%
%%%Figure B4%%%
%%%%%%%%%%%%%%%

%Baseline.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="baseline";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_baseline=readtable("fig_b4.xls", opts, "UseExcel", false);

%No FE.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="bfe_no";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_bfe_no=readtable("fig_b4.xls", opts, "UseExcel", false);

%Imp/Exp FE.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="bfe";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_bfe=readtable("fig_b4.xls", opts, "UseExcel", false);

%Imp/Exp HS2 FE.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="bfe_hs2";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_bfe_hs2=readtable("fig_b4.xls", opts, "UseExcel", false);

%Imp/Exp HS3 FE.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="bfe_hs3";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_bfe_hs3=readtable("fig_b4.xls", opts, "UseExcel", false);

%Coefficients.
horizon = table_baseline.horizon;
b_Baseline_l1 = table_baseline.b;
se_Baseline_l1 = table_baseline.ci;
obs_Baseline_l1 = table_baseline.obs;
b_nofe = table_bfe_no.b;
se_nofe = table_bfe_no.ci;
obs_nofe = table_bfe_no.obs;
b_fe_imp_exp = table_bfe.b;
se_fe_imp_exp = table_bfe.ci;
obs_fe_imp_exp = table_bfe.obs;
b_fe_imp_exp_hs2 = table_bfe_hs2.b;
se_fe_imp_exp_hs2 = table_bfe_hs2.ci;
obs_fe_imp_exp_hs2 = table_bfe_hs2.obs;
b_fe_imp_exp_hs3 = table_bfe_hs3.b;
se_fe_imp_exp_hs3 = table_bfe_hs3.ci;
obs_fe_imp_exp_hs3 = table_bfe_hs3.obs;

%Plot figure.
fig=figure;
set(gca,'FontSize',13);
hold on;
color_type1 = [0 0.447058823529412 0.741176470588235];
color_type2 = [0.850980392156863 0.325490196078431 0.098039215686274];
color_type3 = [0.9290    0.6940    0.1250];
color_type4 = [0.4940    0.1840    0.5560];
color_type5 = [0.4660    0.6740    0.1880];
h1=errorbar(horizon,b_Baseline_l1,se_Baseline_l1,'-o','Linewidth',1.5,'CapSize',8, 'LineStyle', 'none','Color', color_type1);
h1.MarkerSize = 8;
h2=plot(horizon,b_Baseline_l1,'-o','LineWidth',2,'LineStyle',':','DisplayName','Baseline','Color',color_type1)
h3=errorbar(horizon,b_nofe,se_nofe,'-d','Linewidth',1.5,'CapSize',8, 'LineStyle', 'none','Color',color_type2);
h3.MarkerSize = 8;
h4=plot(horizon,b_nofe,'-d','LineWidth',2, 'LineStyle',':', 'DisplayName','No FE','Color',color_type2)
h5=errorbar(horizon,b_fe_imp_exp,se_fe_imp_exp,'-d','Linewidth',1.5,'CapSize',8, 'LineStyle', 'none','Color',color_type3);
h5.MarkerSize = 8;
h6=plot(horizon,b_fe_imp_exp,'-d','LineWidth',2, 'LineStyle',':','DisplayName','FE','Color',color_type3)
h7=errorbar(horizon,b_fe_imp_exp_hs2,se_fe_imp_exp_hs2,'-d','Linewidth',1.5,'CapSize',8, 'LineStyle', 'none','Color',color_type4);
h7.MarkerSize = 8;
h8=plot(horizon,b_fe_imp_exp_hs2,'-d','LineWidth',2, 'LineStyle',':','DisplayName','HS2 FE','Color',color_type4)
h9=errorbar(horizon,b_fe_imp_exp_hs3,se_fe_imp_exp_hs3,'-d','Linewidth',1.5,'CapSize',8, 'LineStyle', 'none','Color',color_type5);
h9.MarkerSize = 8;
h10=plot(horizon,b_fe_imp_exp_hs3,'-d','LineWidth',2, 'LineStyle',':', 'DisplayName','HS3 FE','Color',color_type5)
xlabel("Horizon (years)");
hline=refline([0 0]);
hline.Color='black';
ylabel("Estimates of $\varepsilon^{h}$",'interpreter','latex');
xlim([0 10]); xticks([0 1 2 3 4 5 6 7 8 9 10]);
ylim([-3.5 0.5]); yticks([-3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5]);
grid on;
legend([h2 h4 h6 h8 h10],{'Baseline','No FE','Imp/exp FE','Imp/exp HS2 FE','Imp/exp HS3 FE'})
hold off;
set(fig, 'PaperUnits', 'inches');
scale = 2.0;
x_width=scale*4; y_width=scale*3;
set(fig, 'PaperPosition', [0 0 x_width y_width]); 
print('..\final_files\trade_elast_comparison_fe','-dpng','-r300');
print('..\final_files\trade_elast_comparison_fe','-depsc','-r300');
print('..\final_files\trade_elast_comparison_fe','-dpdf','-r300');

%%
%%%%%%%%%%%%%%%%
%%%Figure B5%%%
%%%%%%%%%%%%%%%%

%Baseline.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="baseline";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_baseline=readtable("fig_b5.xls", opts, "UseExcel", false);

%No FE.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="mfe_no";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_mfe_no=readtable("fig_b5.xls", opts, "UseExcel", false);

%Imp/Exp FE.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="mfe";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_mfe=readtable("fig_b5.xls", opts, "UseExcel", false);

%Imp/Exp HS2 FE.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="mfe_hs2";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_mfe_hs2=readtable("fig_b5.xls", opts, "UseExcel", false);

%Imp/Exp HS3 FE.
opts=spreadsheetImportOptions("NumVariables", 9);
opts.Sheet="mfe_hs3";
opts.DataRange="A2:I12";
opts.VariableNames=["horizon", "b", "se", "blag", "selag", "F1", "F2", "obs", "ci"];
opts.VariableTypes=["double", "double", "double", "double", "double", "double", "double", "double", "double"];
table_mfe_hs3=readtable("fig_b5.xls", opts, "UseExcel", false);

%Coefficients.
horizon = table_baseline.horizon;
b_Baseline_l1 = table_baseline.b;
se_Baseline_l1 = table_baseline.ci;
obs_Baseline_l1 = table_baseline.obs;
b_nofe = table_mfe_no.b;
se_nofe = table_mfe_no.ci;
obs_nofe = table_mfe_no.obs;
b_fe_imp_exp = table_mfe.b;
se_fe_imp_exp = table_mfe.ci;
obs_fe_imp_exp = table_mfe.obs;
b_fe_imp_exp_hs2 = table_mfe_hs2.b;
se_fe_imp_exp_hs2 = table_mfe_hs2.ci;
obs_fe_imp_exp_hs2 = table_mfe_hs2.obs;
b_fe_imp_exp_hs3 = table_mfe_hs3.b;
se_fe_imp_exp_hs3 = table_mfe_hs3.ci;
obs_fe_imp_exp_hs3 = table_mfe_hs3.obs;

%Plot figure.
fig=figure;
set(gca,'FontSize',13);
hold on;
color_type1 = [0 0.447058823529412 0.741176470588235];
color_type2 = [0.850980392156863 0.325490196078431 0.098039215686274];
color_type3 = [0.9290    0.6940    0.1250];
color_type4 = [0.4940    0.1840    0.5560];
color_type5 = [0.4660    0.6740    0.1880];
h1=errorbar(horizon,b_Baseline_l1,se_Baseline_l1,'-o','Linewidth',1.5,'CapSize',8, 'LineStyle', 'none','Color', color_type1);
h1.MarkerSize = 8;
h2=plot(horizon,b_Baseline_l1,'-o','LineWidth',2,'LineStyle',':','DisplayName','Baseline','Color',color_type1)
h3=errorbar(horizon,b_nofe,se_nofe,'-d','Linewidth',1.5,'CapSize',8, 'LineStyle', 'none','Color',color_type2);
h3.MarkerSize = 8;
h4=plot(horizon,b_nofe,'-d','LineWidth',2, 'LineStyle',':', 'DisplayName','No FE','Color',color_type2)
h5=errorbar(horizon,b_fe_imp_exp,se_fe_imp_exp,'-d','Linewidth',1.5,'CapSize',8, 'LineStyle', 'none','Color',color_type3);
h5.MarkerSize = 8;
h6=plot(horizon,b_fe_imp_exp,'-d','LineWidth',2, 'LineStyle',':','DisplayName','FE','Color',color_type3)
h7=errorbar(horizon,b_fe_imp_exp_hs2,se_fe_imp_exp_hs2,'-d','Linewidth',1.5,'CapSize',8, 'LineStyle', 'none','Color',color_type4);
h7.MarkerSize = 8;
h8=plot(horizon,b_fe_imp_exp_hs2,'-d','LineWidth',2, 'LineStyle',':','DisplayName','HS2 FE','Color',color_type4)
h9=errorbar(horizon,b_fe_imp_exp_hs3,se_fe_imp_exp_hs3,'-d','Linewidth',1.5,'CapSize',8, 'LineStyle', 'none','Color',color_type5);
h9.MarkerSize = 8;
h10=plot(horizon,b_fe_imp_exp_hs3,'-d','LineWidth',2, 'LineStyle',':', 'DisplayName','HS3 FE','Color',color_type5)
xlabel("Horizon (years)");
hline=refline([0 0]);
hline.Color='black';
ylabel("Estimates of $\varepsilon^{h}$",'interpreter','latex');
xlim([0 10]); xticks([0 1 2 3 4 5 6 7 8 9 10]);
ylim([-4.5 1.5]);
grid on;
legend([h2 h4 h6 h8 h10],{'Baseline','No MRT FE','Imp-time + Exp-time FE','Imp-HS2-time + Exp-HS2-time FE','Imp-HS3-time + Exp-HS3-time FE'})
hold off;
set(fig, 'PaperUnits', 'inches');
scale = 2.0;
x_width=scale*4; y_width=scale*3;
set(fig, 'PaperPosition', [0 0 x_width y_width]); 
print('..\final_files\trade_elast_comparison_fe_BIL4new','-dpng','-r300');
print('..\final_files\trade_elast_comparison_fe_BIL4new','-depsc','-r300');
print('..\final_files\trade_elast_comparison_fe_BIL4new','-dpdf','-r300');
