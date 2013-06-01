function [cam_name,pulse_id]=readImagesHeader(path)
	% tic;
	% display(path);
	fHEAD   = fopen(path);
	C = textscan(fHEAD,'%*s # Camera:%s %*s %*s # PULSEID: %f # Sequence #%f %f %f %*s','Delimiter','\n');
	fclose(fHEAD);

	cam_name = C{1}{1};
	pulse_id = C{2};
	% toc;
end
