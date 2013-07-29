function [dir_beg, dir_mid, filename]=get_valid_filename(pathstr,varargin)
% PATHSTR=GET_VALID_FILENAME  Gets a valid filename given an input path.
	switch exist(pathstr)
	% File doesn't exist
	% This case must terminate in us trying again.
	case 0
		% If file didn't exist, maybe it needs a prefix
		% Check if prefix is defined
		if ispref('FACET_data','prefix')
			% Append prefix
			% prefix=getpref('FACET_data','prefix');
			prefix=get_remoteprefix();
			pathstr=fullfile(prefix,pathstr);
			% Appending the prefix worked
			if ~exist(pathstr)
				% Ask if the user wants to fix the problem
				answers={'Change prefix for this machine.','Locate file','Try again'};
				button='';
				button=questdlg(sprintf(['File doesn''t exist:\n\n' pathstr '\n\n(External drive may not be mounted.)\n']),'File Doesn''t Exist',answers{1},answers{2},answers{3},answers{1});
				if strcmp(button,'')
					error('No valid option selected.');
				end

				% Perform which action user requested.
				switch button
				% Change prefix
				case answers{1}
					prefix=uigetdir(prefix,answers{1});
					if prefix==0
						error('No valid option selected.');
					end
					setpref('FACET_data','prefix',prefix);
				% Locate file manually
				case answers{2}
					pathstr=locate_file(prefix,answers{2});
				% Modifies nothing - will try same settings again.
				case answers{3}
				end
			end
		% Prefix isn't defined
		else
			setpref('FACET_data','prefix','/Volumes/PWFA_4big');
		end

		[dir_beg,dir_mid,filename]=get_valid_filename(pathstr);
		return;

	% 7 indicates a folder
	% We need to find a file.
	case 7
		patterns={'*scan_info.mat','*filenames.mat'};
		for i=1:size(patterns,2)
			[bool,new_pathstr]=check_dir(pathstr,patterns{i});
			if bool
				[dir_beg,dir_mid,filename]=get_valid_filename(new_pathstr);
				return;
			end
		end

		% If you get here, no file was found
		answers={'Locate file','Exit'};
		button=questdlg('No valid file found in folder. Locate manually?','File Not Found',answers{1},answers{2},answers{1});
		switch button
		case answers{1}
			pathstr=locate_file(pathstr,answers{1});
		otherwise
			error('Exited (no valid file provided)...');
		end

	% 2 indicated a full pathname to any file
	% We need to check if it's valid, and extract dirs.
	case 2
		if nargin==2 && varargin{1}==false
			% Check for string endings
			if ~(~isempty(regexp(pathstr,'scan_info.mat$')) || ~isempty(regexp(pathstr,'filenames.mat$')))
				error('Neither a scan_info.mat file nor a filenames.mat file.');
			end
	
			% Check this is a data file.
			% Must have /nas/nas-li20-pm01
			startind=regexp(pathstr,'/nas/nas-li20-pm01');
			if isempty(startind)
				error('Does not point to a file with /nas/nas-li20-pm01 in its path.');
			end
			startind=startind(1);
		else
			startind=1;
		end

		% Get the directories
		[dirstr,namestr,extstr]=fileparts(pathstr);
		dir_beg=dirstr(1:startind);
		dir_mid=dirstr(startind+1:end);

		% Construct filename
		filename=[namestr,extstr];
	end
end

function [bool,pathstr]=check_dir(dirstr,pattern)
% Return without error only if there's one file matching the pattern

	% Check for pattern in dir.
	files=dir(fullfile(dirstr,pattern));

	% No pattern found
	if size(files,1)==0
		bool=false;
		pathstr='';
	% One pattern found
	elseif size(files,1)==1
		% Use that 
		bool=true;
		pathstr=fullfile(dirstr,files.name);
	% Multiple patterns found
	else
		error(['Too many ' pattern ' files found in ' dirstr]);
	end
end

function pathstr=locate_file(prefix,text)
	pathstr=uigetfile(prefix,text);
	if prefix==0
		error('No valid option selected.');
	end
end
