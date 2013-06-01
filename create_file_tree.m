function create_file_tree(Pathname,experiment,basedataset)
	% Initialize file tree at path of loaded file
	% (if it doesn't exist)
	[stat,msg,msgid]=mkdir(fullfile(Pathname,[experiment '_' basedataset '_files'],'raw','images','backgrounds'));
	[stat,msg,msgid]=mkdir(fullfile(Pathname,[experiment '_' basedataset '_files'],'raw','scalars'));
	[stat,msg,msgid]=mkdir(fullfile(Pathname,[experiment '_' basedataset '_files'],'raw','vectors'));
	[stat,msg,msgid]=mkdir(fullfile(Pathname,[experiment '_' basedataset '_files'],'raw','arrays'));
	[stat,msg,msgid]=mkdir(fullfile(Pathname,[experiment '_' basedataset '_files'],'raw','metadata'));
	
	[stat,msg,msgid]=mkdir(fullfile(Pathname,[experiment '_' basedataset '_files'],'processed','images'));
	[stat,msg,msgid]=mkdir(fullfile(Pathname,[experiment '_' basedataset '_files'],'processed','scalars'));
	[stat,msg,msgid]=mkdir(fullfile(Pathname,[experiment '_' basedataset '_files'],'processed','vectors'));
	[stat,msg,msgid]=mkdir(fullfile(Pathname,[experiment '_' basedataset '_files'],'processed','arrays'));
	[stat,msg,msgid]=mkdir(fullfile(Pathname,[experiment '_' basedataset '_files'],'processed','metadata'));

	[stat,msg,msgid]=mkdir(fullfile(Pathname,[experiment '_' basedataset '_files'],'user'));
end
