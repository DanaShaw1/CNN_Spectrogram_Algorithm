% file_name should correspond to a .mat file with two components
% dEDF: the data (Nx1 vector)
% tEDF: the time (Nx1 vector)

file_name = 'UMHS-0018-0002.day-04.mat';
load(file_name)
Fs =  1/(tEDF(10)-tEDF(9));

%Make noise data
% Fs = 1000;
% dEDF = randn(50000,1);
% tEDF = (1:50000)/Fs;

winSize = round(Fs);
winStep = round(Fs/2);

S = {};
i_stop = 1;
i = 1; counter=1;

folder_name = 'UMHS-0018-0002.day-04_ch1_1000s';
mkdir(folder_name)

disp('Working...')

while tEDF(i_stop) < 1000%600 % only looking at the first 600 seconds, can change to any value

    i_start = i;
    i_stop  = i_start + winSize - 1;

    dspec = dEDF(i_start:i_stop);
    dspec = dspec - mean(dspec);
    t     = tEDF(i_start:i_stop);

    params.Fs    = Fs;             % Sampling frequency [Hz]
    params.fpass = [30 250];       % Frequencies to visualize in spectra [Hz]
    movingwin    = [0.200,0.005];  % Window size, Step size [s]
    params.tEDF  = t;
    [S0,S_times,S_freq] = hannspecgramc(dspec,movingwin,params);
    %Smooth the spectra.
    t_smooth = 11;
    dt_S     = S_times(2)-S_times(1);
    myfilter = fspecial('gaussian',[1 t_smooth], 1);
    S_smooth = imfilter(S0, myfilter, 'replicate');   % Smooth the spectrum.

    A = log10(S_smooth);
    str = ['img_', num2str(counter), '.jpg'];
    imwrite( ind2rgb(im2uint8(mat2gray(A)), jet(256)), str)
    movefile(str,folder_name)
    
    i = i_start + winStep;
    counter=counter+1;
end
     
disp('Done.')
