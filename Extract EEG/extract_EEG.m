%Extract the EEG data from a .dat file
clear
clc

filename = 'UMHS-0018-0002.day-04.lay';

%Get header from .lay file (also need corresponding .dat file to run this
%line)
header = lay_hdr_read(filename, 0);
Fs = header.samplingrate;

%Total number of data points
total_data_pts = header.datapoints;

%get data for the first 1000 seconds
data = lay_data_read( header, 1, Fs * 1000 );

%Extract data specified channels
% d1 = data(13,:);
% d2 = data(14,:);

dEDF = data(14,:);

%Time axis
tEDF = (1:size(dEDF,2))/Fs;

%Plot data
plot(tEDF,dEDF)

%Save the data into a new file
newfile = 'UMHS-0018-0002.day-04_BD4.mat';
save(newfile,'dEDF', 'tEDF');
