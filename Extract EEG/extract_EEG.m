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

start_idx = 1;
end_idx = Fs * 100;
increment = Fs*100;
done = false;
dEDF = [];

while ~done
    if end_idx > total_data_pts
        done = true;
        end_idx = total_data_pts;
    end
    
    %get data for the all channles in increments
    data = lay_data_read( header, start_idx, end_idx );
    
    %Extract data specified channels
    d1 = data(21,:);
    d2 = data(22,:);
    
    %Clear the data variable
    clear data
    
    %Get the difference between the 2 channels
    d1d2_diff = d1 - d2;
    
    %Concatenate the extracted channels to the rest
    dEDF = horzcat(dEDF, d1d2_diff);
    
    %Increment the indicies
    start_idx = start_idx + increment;
    end_idx = end_idx + increment;
    disp(end_idx);
end


%Transpose the data
dEDF = transpose(dEDF);

%Time axis
tEDF = transpose((1:size(dEDF,1))/Fs);

%Plot data
plot(tEDF,dEDF)
xlabel('Time (s)')

%Save the data into a new file
newfile = 'UMHS-0018-0002.day-04_CD1-CD2.mat';
save(newfile,'dEDF', 'tEDF');
