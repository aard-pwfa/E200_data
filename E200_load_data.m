function data=E200_load_data(pathstr)
% E200_LOAD_DATA  Convert original, binary data into a new file format and load into memory
%   DATA = E200_LOAD_DATA(FILENAME) converts FILENAME 
%   into the new file format and loads it into memory.
%
% Inputs:
%	FILENAME:	Relative or absolute location of
% 			a directory, scan, or filenames.mat file
%
% Outputs:
%	DATA:		E200 data structure


	% Get valid parts of filename to use
	[dir_beg,dir_mid,filename]=get_valid_filename(pathstr);
	
	% Full path to file to load
	loadpath=fullfile(dir_beg,dir_mid,filename);

	% Split filename into root, extension
	[discard,filename_rt,filename_ext]=fileparts(filename);
	filename_final=[filename_rt '_processed' filename_ext];

	% Processed file info
	processed_file_dir = fullfile(dir_beg,dir_mid);
	processed_file_dir = regexprep(processed_file_dir,'nas/nas-li20-pm0.','processed_data');
	processed_file_path=fullfile(processed_file_dir,filename_final);

	% Get the hostname of the computer.
	[status,hostname]=unix('hostname');
	hostname = strrep(hostname,sprintf('\n'),'');
	isfs20=strcmp(hostname,'facet-srv20');
	
	% Run certain things depending on which machine you're on.
	% facet-srv20 gets special treatment: no files saved!
	already_exists=(exist(processed_file_path)==2 || exist(processed_file_path)==7);
	if isfs20
		data=E200_gather_data(loadpath);
	else
		% If the file doesn't exist, create it.
		if already_exists
			load(processed_file_path);
			return;
		else
			% Path to save final mat files
			savepath=fullfile(processed_file_dir,[filename_rt '_processed_files']);
			data=E200_gather_data(loadpath);
	
			data=E200_convert_images(data,savepath);
		end
	end

	% Info that this comes from a HDD
	data.VersionInfo.remotefiles.dat=true;
	data.VersionInfo.remotefiles.comment = 'Indicates whether files are stored on a remote disk (and getpref(''FACET_data'',''prefix'') should be used.';
	data.VersionInfo.originalfilename=filename_final;
	data.VersionInfo.originalpath=regexprep(dir_mid,'nas/nas-li20-pm0.','processed_data');
	data.VersionInfo.loadrequest=pathstr;
	
	if ~isfs20 && ~already_exists
		data=save_data(data,processed_file_path,false);
	end
end
