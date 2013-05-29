function [image_data, cam_name, pulse_id] = E200_readImages(file_name)

fHEAD   = fopen([file_name '.header']);
fIMAGES = fopen([file_name '.images']);

C = textscan(fHEAD,'%*s # Camera:%s %*s %*s # PULSEID: %f # Sequence #%f %f %f %*s','Delimiter','\n');

cam_name = C{1}{1};
pulse_id = C{2};

tic;
image_data = zeros(C{5}(1), C{4}(1), C{3}(end)+1, 'uint16');
for i=1:C{3}(end)+1; image_data(:,:,i) = fread(fIMAGES,[C{4}(1),C{5}(1)], 'uint16', 'b')'; end; 
fprintf('Elapsed time for reading images: %.4f s\n', toc);

fclose(fHEAD);
fclose(fIMAGES);


end









