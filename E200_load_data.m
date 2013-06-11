function data=E200_load_data(filename)
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

	% Extract the destination path string
	data=struct();
	switch exist(filename)
	case 2
		% Get the directory of the filename
		[pathstr,name,ext]=fileparts(filename);
	case 7
		% The filename is already a directory
		pathstr=filename;
		filename=get_valid_filename(filename);
		[pathstr,name,ext]=fileparts(filename);
	case 0
		filename=get_valid_filename(filename);
		[pathstr,name,ext]=fileparts(filename);
	otherwise
		error('File does not exist.');
	end
	% Pathstr example: /Volumes/PWFA_4big/nas/nas-li20-pm01/E200/2013/20130514/E200_11145

	% Put new files in processed_data instead of nas
	% newpath example: /Volumes/PWFA_4big/processed_data/E200/2013/20130514/E200_11145
	newpath=regexprep(pathstr,'nas/nas-li20-pm0.','processed_data');

	% New file is newpath/(name)_processed.(ext)
	% newfile example: /Volumes/PWFA_4big/processed_data/E200/2013/20130514/E200_11145_processed
	newfile=fullfile(newpath,[name '_processed' ext]);

	% If the file doesn't exist, create it.
	if exist(newfile)~=2 && exist(newfile)~=7
	% if true
		data=E200_gather_data(filename);

		savepath=fullfile(newpath,[name '_processed_files']);
		data=E200_convert_images(data,savepath);

		% Info that this comes from a HDD
		data.VersionInfo.remotefiles.dat=true;
		data.VersionInfo.remotefiles.comment = 'Indicates whether files are stored on a remote disk (and getpref(''FACET_data'',''prefix'') should be used.';
		
		data=save_data(data,newfile,false);

	end
	
	load(newfile);
end
