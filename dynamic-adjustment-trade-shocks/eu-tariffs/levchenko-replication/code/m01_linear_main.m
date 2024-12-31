clear all;
clc;
cd './IRFs/'

%Set parameters.
N = 6; %number of countries
P = 5; %number of products

sigmas=[1.1, 3];
chis=[0.82 1];

for vals=1:length(sigmas)
    
    %Define parameters.
    sigma=sigmas(vals);
    chi=chis(vals);

    %Calibration.
    ml01_calibration;

    %Simulate model.
    dynare ml02_linear.mod;

    %IRFs.
    ml03_pol_exp_individual_save_irfs;
    ml04_pol_exp_all_sectors_save_irfs;
    ml05_pol_exp_all_cntrs_save_irfs;
    ml06_pol_exp_allcntrs_allsec_save_irfs;
    
end

%Plot IRFs.
ml07_plotall_figs_USA;
ml08_plotall_figs_CAN;