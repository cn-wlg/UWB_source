%%
clc
clear
close all

%% Data preparation
data = randi([0 1], 999, 1);
PSDULength = ceil(length(data)/8);
data_pad = [data;zeros(PSDULength*8-length(data),1)];
PSDU = data_pad;

%% Parameter setting
cfg = HRPConfig();
cfg.Mode = 'BPRF';
cfg.PSDULength = PSDULength;
cfg.CodeIndex = 9;
cfg.ConstraintLength = 3;

%% PHR generation
PHR = createPHR(cfg);

%% Convolutional Encoding
convolCW = convolEnc(PHR, PSDU, cfg);

%% Symbol Mapper (Modulation)
symbols = symbolMapper(convolCW, cfg);