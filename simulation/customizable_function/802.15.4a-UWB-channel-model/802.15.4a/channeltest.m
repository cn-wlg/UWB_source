clc;
clear;
close all;

no_output_files = 1;
num_channels = 100;
cm_num = 7;  % channel model number from 1 to 8

[Lam,lambda,Lmean,lambda_mode,lambda_1,lambda_2,beta,Gam,gamma_0,Kgamma, ...
 sigma_cluster,nlos,gamma_rise,gamma_1,chi,m0,Km,sigma_m0,sigma_Km, ...
 sfading_mode,m0_sp,std_shdw,kappa,fc,fs] = uwb_sv_params_15_4a( cm_num );

ts = 1/fs;  % sampling frequency

[h_ct,t_ct,t0,np] = uwb_sv_model_ct_15_4a(Lam,lambda,Lmean,lambda_mode,lambda_1, ...
    lambda_2,beta,Gam,gamma_0,Kgamma,sigma_cluster,nlos,gamma_rise,gamma_1, ...
    chi,m0,Km,sigma_m0,sigma_Km,sfading_mode,m0_sp,std_shdw,num_channels,ts);

% now reduce continuous-time result to a discrete-time result
[hN,N] = uwb_sv_cnvrt_ct_15_4a( h_ct, t_ct, np, num_channels, ts );

if N > 1,
  h = resample(hN, 1, N);  % decimate the columns of hN by factor N
else
  h = hN;
end

% prepare to add the frequency dependency
K = 1; % K = Ko*Co^2/(4*pi)^2/d^n
       % since the K is a constant, and the effect will be removed after
       % normalization, so the K is set to be 1
h_len = length(h(:,1));
if (cm_num == 1|cm_num == 2| cm_num == 7|cm_num == 8|cm_num ==9)
  [h]= uwb_sv_freq_depend_ct_15_4a(h,fc,fs,num_channels,kappa);
else
   [h]= uwb_sv_freq_depend_ct_15_4a(h,fc,fs,num_channels,0);
end

t = [0:(h_len-1)] * ts;
figure(1)
plot(t, abs(h));