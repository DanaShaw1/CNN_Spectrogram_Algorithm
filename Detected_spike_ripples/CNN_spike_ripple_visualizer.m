%CNN_spike_ripple_visualizer
%Based on: spike_ripple_visualizer.m
%Written by: Dana Shaw
%
%Code to visualize spike-ripple events detected by Use_pretrained_model.ipynb
%
%Input: A .csv file with N rows and columns Var1, image_number, prediction, and
%       probability 
%       A .mat file corresponding to the .csv file with fields dEDF and
%       tEDF

close all
clear
clc

%Name of the file without the .csv extension
filename = 'e_UMHS-0018-0002.day-04_BD3-BD4';

%Read in the .csv file as a table
spike_ripple_table = readtable(strcat(filename,'.csv'));

%Convert the table into a struct
spike_ripples = table2struct(spike_ripple_table);

%Read in the .mat file
cd('C:\Users\danas\Github\CNN_Spectrogram_Algorithm') %where the .mat file is located
load(strcat(filename(3:end),'.mat')); %.mat file does not start with "e_"

%Make a folder
folder_name = filename(3:end);
mkdir(folder_name);

%Get the sampling frequency
Fs = 1/(tEDF(10)-tEDF(9));

%Determine if dEDF should be multiplied by -1
figure
plot(tEDF(1:Fs*10),dEDF(1:Fs*10))
neg_multiply = input('Multiply data by -1? [y/n]: ','s');

if neg_multiply == 'y'
    dEDF = -dEDF; 
end
close gcf

%Design the filter and filter time series data
fprintf('Design the filter ... \n')
fNQ = Fs/2;                                        	%Define Nyquist frequeuncy.
d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',...
    (60)/fNQ,...                                        %Freq @ edge first stop band.
    (100)/fNQ,...                                       %Freq @ edge of start of passband.
    (300)/fNQ,...                                       %Freq @ edge of end of passband
    (350)/fNQ,...                                       %Freq @ edge second stop band
    80,...                                              %Attenuation in the first stop band in decibels
    0.1,...                                         	%Amount of ripple allowed in the pass band.
    40);                                                %Attenuation in the second stop band in decibels
Hd = design(d,'equiripple');                         	%Design the filter
[num, den] = tf(Hd);                               	%Convert filter to numerator, denominator expression.
order = length(num);                                	%Get filter order.

dfilt = filter(num, den, dEDF);                                    %Filter it.
dfilt = [dfilt(floor(order/2)+1:end); zeros(floor(order/2),1)];   %Shift after filtering.

%Go through each of the detected events and plot them
for i = 1:length(spike_ripples)
    %Get the image number and convert it to a double
    image = spike_ripples(i).image_number(10:end-4);
    image_num = str2double(image);
    
    %Get the probability
    prob = spike_ripples(i).probability;
    
    %Get the time stamp
    time_stamp = image_num / 2 - 0.5;
    
    %Find the corresponding time in the tEDF vector
    time_finder = 1;
    while(tEDF(time_finder) < time_stamp)
        time_finder = time_finder + 1;
    end
    
    %Set the start and end indicies for the selected data and time
    start_idx = time_finder;
    end_idx = start_idx + Fs;
    
    %Spectrogram for the given data set
    dspec = dEDF(start_idx - Fs/2:end_idx + Fs/2);
    dspec = dspec - mean(dspec);
    t     = tEDF(start_idx - Fs/2:end_idx + Fs/2);
    
    params.Fs    = Fs;             % Sampling frequency [Hz]
    params.fpass = [30 250];       % Frequencies to visualize in spectra [Hz]
    movingwin    = [0.200,0.005];  % Window size, Step size [s]
    params.tEDF  = t;
    [S0,S_times,S_freq] = hannspecgramc(dspec,movingwin,params);
    %Smooth the spectra.
    t_smooth = 11;%31;
    dt_S     = S_times(2)-S_times(1);
    myfilter = fspecial('gaussian',[1 t_smooth], 1);
    %myfilter = fspecial('gaussian',[t_smooth 1], 1);
    S_smooth = imfilter(S0, myfilter, 'replicate');   % Smooth the spectrum.
    
    %% PLOTS
    
    %Plots for the given detected spike-ripple
    sgtitle(strcat(['Image: ',image, ', with probability: ',num2str(prob)]),'Interpreter','none')
    
    %Plot time series data
    subplot(3,1,1)
    plot(tEDF(start_idx:end_idx),dEDF(start_idx:end_idx))
    xlabel('Time (s)')
    
    %Plot filtered time series
    subplot(3,1,2)
    plot(tEDF(start_idx:end_idx),dfilt(start_idx:end_idx))
    xlabel('Time (s)')
    
    %Plot the spectrogram
    subplot(3,1,3)
    colormap(jet)
    imagesc(S_times,S_freq,log10(S_smooth)')  %, [-3 -0.5])
    axis xy
    xlim([tEDF(start_idx),tEDF(end_idx)])
    xlabel('Time (s)')    
    
    %Save the figure as a .jpg and move it to the correct folder
    file_name = strcat(['image_',num2str(i),'.jpg']);
    saveas(gcf, file_name);
    movefile(file_name,folder_name);
        
    close gcf
end

%Move the folder
dest_folder = 'C:\Users\danas\Github\CNN_Spectrogram_Algorithm\Detected_spike_ripples\Visualizer_images';
movefile(folder_name,dest_folder);

fprintf('Done!\n')
