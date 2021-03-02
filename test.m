%Run test EEG through semi-automated code
close all
clear
clc

file_name = 'UMHS-0018-0002.day-04_BD1-BD2.mat';
%file_name = 'pBECTS003_5_C3.mat';
load(file_name)

[res,diagnostics] = spike_ripple_detector(dEDF()',tEDF()', 0.85);

[expert_classify] = spike_ripple_visualizer(dEDF()', tEDF()', res, diagnostics);