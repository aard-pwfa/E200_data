function data=E200_load_data(filename)
	% Extract the destination path string
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
	prefix=get_rootpath(pathstr);
	newpath=[regexprep(pathstr,'nas/nas-li20-pm01','processed_data')];
	newfile=fullfile(newpath,[name '_processed' ext]);

	% If the file doesn't exist, create it.
	if exist(newfile)~=2 && exist(newfile)~=7
		data=E200_gather_data(filename);

		savepath=fullfile(newpath,[name '_processed_files']);
		data=E200_convert_images(data,savepath);
		data=save_data(data,newfile,false);
	end
	
	load(newfile);
end
