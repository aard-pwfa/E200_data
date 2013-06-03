function create_file_tree(pathstr)
	% Initialize file tree at path of loaded file
	% (if it doesn't exist)
	[stat,msg,msgid]=mkdir(fullfile(pathstr,'raw','images'));
	[stat,msg,msgid]=mkdir(fullfile(pathstr,'raw','scalars'));
	[stat,msg,msgid]=mkdir(fullfile(pathstr,'raw','vectors'));
	[stat,msg,msgid]=mkdir(fullfile(pathstr,'raw','arrays'));
	[stat,msg,msgid]=mkdir(fullfile(pathstr,'raw','metadata'));
	
	[stat,msg,msgid]=mkdir(fullfile(pathstr,'processed','images'));
	[stat,msg,msgid]=mkdir(fullfile(pathstr,'processed','scalars'));
	[stat,msg,msgid]=mkdir(fullfile(pathstr,'processed','vectors'));
	[stat,msg,msgid]=mkdir(fullfile(pathstr,'processed','arrays'));
	[stat,msg,msgid]=mkdir(fullfile(pathstr,'processed','metadata'));

	[stat,msg,msgid]=mkdir(fullfile(pathstr,'user'));
end
