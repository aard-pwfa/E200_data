function [image_data, cam_name, pulse_id] = readImagesBin(file_name)

[cam_name, pulse_id] =readImagesHeader([file_name '.header']);


tic;

fIMAGES = fopen([file_name '.images']);

image_data = zeros(C{5}(1), C{4}(1), C{3}(end)+1, 'uint16');
for i=1:C{3}(end)+1; image_data(:,:,i) = fread(fIMAGES,[C{4}(1),C{5}(1)], 'uint16', 'b')'; end;

fclose(fIMAGES);

fprintf('Elapsed time for reading images: %.4f s\n', toc);



end









