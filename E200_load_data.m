function data=E200_load_data(filename)
	% Check if you have a valid file
	if exist(filename)~=2
		error('File does not exist.');
	end
	
	% Extract the destination path string
	[pathstr,name,ext]=fileparts(filename);	
	prefix=get_rootpath(pathstr);
	newpath=[regexprep(pathstr,'nas/nas-li20-pm01','processed_data')];
	newfile=fullfile(newpath,[name '_processed' ext]);

	% If the file doesn't exist, create it.
	if exist(newfile)~=2
		data=E200_gather_data(filename);

		savepath=fullfile(newpath,[name '_processed_files']);
		data=E200_convert_images(data,savepath);
		data=save_data(data,newfile,false);
	end
	
	load(newfile);
end
