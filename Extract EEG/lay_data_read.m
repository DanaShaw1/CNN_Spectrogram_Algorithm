function data = lay_data_read( hdr, index1, index2 )
% input - file name of a .lay file that corresponds to a lay-dat pair
% output:   data - EEG data from .dat file
%
% Based on layread.m from Percyst
%
%
  

%-------------------
%     dat file
%-------------------

  %% open the file
  dat_file_ID = fopen(hdr.rawheader.fileinfo.actual_filename);
  
  %% read either int32 or short data type
  if (hdr.rawheader.fileinfo.datatype=='7')
    precision = 'int32';
    nBytes = 4;
  else
    precision = 'short';
    nBytes = 2;
  end

  %% externally indexed from 1, but internally indexed from 0
  index1 = index1 - 1;
  index2 = index2 - 1;
  
  %% get to the position in the file
  offset = index1*nBytes*hdr.nChan;
  fseek( dat_file_ID, offset, 'bof' );
  
  %% read data from .dat file into vector of correct size, then calibrate
  %fprintf('position moved from %d, %d', offset, ftell( dat_file_ID ) );
  data = double(fread(dat_file_ID,[hdr.nChan,index2-index1+1],precision));
  %fprintf(' to %d\n', ftell( dat_file_ID ) );
  
  if( abs(hdr.calibration-1) > 10*eps )
    data = data * hdr.calibration;
  end
  
  fclose(dat_file_ID);
end




