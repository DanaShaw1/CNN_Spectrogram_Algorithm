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
d1 = data(11,:);
d2 = data(12,:);

%dEDF = transpose(data(41,:));
dEDF = transpose(d1 - d2);

%Time axis
tEDF = transpose((1:size(dEDF,1))/Fs);

%Plot data
plot(tEDF,dEDF)

%Save the data into a new file
newfile = 'UMHS-0018-0002.day-04_BD1-BD2_transpose.mat';
save(newfile,'dEDF', 'tEDF');
