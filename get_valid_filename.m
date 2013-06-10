function pathstr=get_valid_filename(pathstr)
	switch exist(pathstr)
	case 0
		% error('Invalid path, does not exist.');
		% If file didn't exist, maybe it needs a prefix
		if ispref('FACET_data','prefix')
			prefix=getpref('FACET_data','prefix');
			pathstr=fullfile(prefix,pathstr);
			% If file exists, try again
			if exist(pathstr)
				pathstr=get_valid_filename(pathstr)
			% If file doesn't exist, offer to change prefix.
			else
				answers={'Change prefix for this machine.','Locate file'};
				button='';
				button=questdlg(sprintf(['File doesn''t exist:\n\n' pathstr]),'File Doesn''t Exist',answers{1},answers{2},answers{1})
				if strcmp(button,'')
					error('No valid option selected.');
				end

				switch button
				case answers{1}
					prefix=uigetdir(prefix,answers{1});
					if prefix==0
						error('No valid option selected.');
					end
					setpref('FACET_data','prefix',prefix);
					pathstr=get_valid_filename(pathstr);
				case answers{2}
					pathstr=uigetfile(prefix,answers{2});
					if prefix==0
						error('No valid option selected.');
					end
					pathstr=get_valid_filename(pathstr);
				end
			end
		else
			% If pref isn't set, set it and try again.
			setpref('FACET_data','prefix','/Volumes/PWFA_4big');
			pathstr=get_valid_filename(pathstr);
		end
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
