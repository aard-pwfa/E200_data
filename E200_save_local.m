function data=E200_save_local(data,filepath,varargin)
	display('Copying, possibly gigabytes: may take a few minutes...');
	% USE RELATIVE PATHS!
	[path,name,ext]=fileparts(filepath);

	% Get relevant parameters
	expstr=data.raw.metadata.param.dat{1}.experiment;
	set_num=data.raw.scalars.set_num.dat(1);
	set_str=num2str(set_num);
	
	% Delete local data path - don't want multiple files
	datapath=fullfile(path,[name '_files']);

	% try
	%         rmdir(datapath,'s')
	% end

	% Create local data paths
	create_file_tree(datapath);


	% Copy all files out of data into appropriate location and change paths
	data=recurse_save_file(data,datapath);

	% Save file
	save(filepath,'data');
	display('Finished saving!');
end

function struct=recurse_save_file(struct,path)
	% Still needs to be a struct.  If not a struct, don't recurse
	% Second argument handles structure arrays.  Our structures aren't arrays!
	if isstruct(struct) && sum(size(struct))==2
		str=fieldnames(struct);
		% If isfile exists we might need to copy.
		if sum(strcmp('isfile',str))
			% Loop over isfile
			for i=1:size(struct.isfile,2)
				%If isfile is true, we do need to copy
				if struct.isfile(i)
					filestr=struct.dat{i};
					[fpath,fname,fext]=fileparts(filestr);

					newpath = fullfile(path,[fname,fext]);
					[temppath,tempname,tempext]=fileparts(newpath);
					[stat,msg,msgid]=mkdir(temppath);

					if strcmp(struct.format{i},'bin')
						copy_if_missing([filestr '.header'],[newpath '.header']);
						copy_if_missing([filestr '.images'],[newpath '.images']);
					else
						copy_if_missing(filestr,newpath);
					end
					% Also, change dat to new path
					struct.dat{i}=newpath;
					
					% If background_dat exists, copy file too
					if sum(strcmp('background_dat',str))
						filestr=struct.background_dat{i};

						[fpath,fname,fext]=fileparts(filestr);
						newpath = fullfile(path,'backgrounds',[fname,fext]);
						[temppath,tempname,tempext]=fileparts(newpath);
						[stat,msg,msgid]=mkdir(temppath);
						copy_if_missing(filestr,newpath);
						struct.background_dat{i}=newpath;
					end
				end
			end
		% It is a struct, no isfile: recurse
		else
			for i=1:size(str,1)
				name=str{i};
				newpath = fullfile(path,name);
				struct.(name)=recurse_save_file(struct.(name),newpath);
			end
		end
	end
end

function copy_if_missing(fromstr,tostr)
	if exist(tostr)~=2
		display(['Copying file to ' tostr '...']);
		copyfile(fromstr,tostr);
	end
end
