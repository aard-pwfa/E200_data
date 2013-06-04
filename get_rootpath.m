function rootpath=get_rootpath(Pathname)
	% Get root path
	curpath=pwd;
	cd(Pathname);
	filepath=pwd;
	cd(curpath);
	rootpath=filepath(1:strfind(filepath,'/nas/')-1);
end
