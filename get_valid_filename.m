function pathstr=get_valid_filename(pathstr)
	switch exist(pathstr)
	case 0
		error('Invalid path, does not exist.');
	case 2
		% 2 indicated a full pathname to any file
	case 7
		% 7 indicates a folder
		% Get .mat files

		% Check for scan_info.mat
		files=dir(fullfile(pathstr,'*scan_info.mat'));
		if size(files,1)==0
			% Check for filenames.mat
			files=dir(fullfile(pathstr,'*filenames.mat'));
			if size(files,1)==0
				error(['Data file not found in path ' pathstr]);
			elseif size(files,1)==1
				pathstr=fullfile(pathstr,files.name);
			else
				error(['Too many filenames.mat files found, but no scan_info.mat file found in ' pathstr]);
			end
		elseif size(files,1)==1
			pathstr=fullfile(pathstr,files.name);
		else
			error(['Too many scan_info.mat files found in ' pathstr]);
		end
	end
	% display(pathstr);
end
