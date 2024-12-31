clear all;
clc;
cd '../output/graphs/temp_files/'

%%
%%%%%%%%%%%%%%%%
%%%Figure B7%%%%
%%%%%%%%%%%%%%%%

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

%Define horizon.
horizon_sec=section1_iv_0.horizon;

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

clear opts tbl

%make a matrix
section_b = [b_Baseline_4 b_Baseline_6 b_Baseline_7 ...
    b_Baseline_8 b_Baseline_10 b_Baseline_11 ...
    b_Baseline_12 b_Baseline_13 ...
    b_Baseline_16 b_Baseline_agg];

eps_section = median(section_b(8:end,:))' + 1;

%Ossa elasticities.
ossa_elasticity = 1-[2.27,3.625,2.2866667,2.56,3.08875,3.325,2.5914286,3.22,2.8414286,3.4513559]';
ossa_elasticityw = 1-[2.3393365,3.5830434,2.3075269,2.56,3.5061424,3.505581,2.4741514,2.5543318,3.1514531,2.7057653]';

%% Get the trade shares
lambda_data = readtable('../../../temp_files/wiod_shares.xlsx','Sheet','lambda');
cons_sh_data = readtable('../../../temp_files/wiod_shares.xlsx','Sheet','cons_sh');
N=size(lambda_data,1);

lambda=zeros(10,N);
cons_sh=zeros(10,N);
ctry={};
for n=1:N
    lambda(:,n) = table2array(lambda_data(n,2:end))';
    cons_sh(:,n) = table2array(cons_sh_data(n,2:end))';
    ctry(n,1) = table2array(lambda_data(n,1));
end


%% Compute gains from trade 

gains_from_trade = @(lambd,bet,epsilo) 1-exp( (-bet'./epsilo')*log(lambd) );

GFT=zeros(N,4);
GFT_ossa = zeros(N,2);
for n=1:N
    GFT(n,1) = gains_from_trade(lambda(:,n),cons_sh(:,n),eps_section);
    GFT_ossa(n,2) = gains_from_trade(lambda(:,n),cons_sh(:,n),ossa_elasticityw);
end

%% Plot
close all 

[sorted_GFT1, order_GFT1] = sort(-GFT(:,1));

fig3 = figure(3);
h=bar([GFT(order_GFT1,1) GFT_ossa(order_GFT1,2)])

ylabel('Gains from trade','Fontsize',14)
I = legend('Sectoral long-run elasticities', ...
       'Ossa (2015) elasticities')
set(I,'interpreter','latex','Orientation','horizontal','Location','southoutside'); %set Latex interpreter
set(gca,'xticklabel',ctry(order_GFT1))
xtickangle(45) 
xticks(1:N)
set(gcf, 'Position',  [100, 100, 4500, 600]) 
print('..\final_files\bar_GFT_compareOssa','-depsc','-r300')
print('..\final_files\bar_GFT_compareOssa','-dpng','-r300')
