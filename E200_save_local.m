function data=E200_save_local(data,filename)
	[pathstr,name,ext]=fileparts(filename);

	% Changing directories means filenames will be relative.
	% curpath=pwd;
	% cd(pathstr);
	% data=save_data(data,[name ext]);
	% cd(curpath);
	data=save_data(data,filename,true);
end
