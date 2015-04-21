function data=save_data(data,filepath,relative)
	display('Copying, possibly gigabytes: may take a few minutes...');
	% USE RELATIVE PATHS!
	[path,name,ext]=fileparts(filepath);

	% Get relevant parameters
	if isfield(data.raw.metadata.param,'dat')
		expstr  = data.raw.metadata.param.dat{1}.experiment;
		set_num = data.raw.scalars.set_num.dat(1);
		set_str = num2str(set_num);
	else
		expstr = data.raw.metadata.param.experiment;
		set_num = data.raw.scalars.set_num.dat(1);
		set_str = num2str(set_num);
	end
	
	datapath=fullfile(path,[name '_files']);

	% Create local data paths
	create_file_tree(datapath);

	% Copy all files out of data into appropriate location and change paths
	display(datapath)
	display(relative)
	data=recurse_save_file(data,datapath,relative);

	% Save file
	% save(filepath,'data');
	display('Starting to save, starting stopwatch...');
	tic;
	save(filepath,'data','-v7.3');
	toc
	display('Finished saving!');
end

function local_struct=recurse_save_file(local_struct,path,relative)
	% Still needs to be a struct.  If not a struct, don't recurse
	% Second argument handles structure arrays.  Our structures aren't arrays!
	if isstruct(local_struct) && length(fieldnames(local_struct)) == 0
		% Empty struct
		% display('Empty!');
		return
	elseif isstruct(local_struct) && sum(size(local_struct))==2
		str=fieldnames(local_struct);
		% If isfile exists we might need to copy.
		if sum(strcmp('isfile',str))
			% Loop over isfile
			for i=1:size(local_struct.isfile,2)
				%If isfile is true, we do need to copy
				if local_struct.isfile(i)
					filestr=local_struct.dat{i};
					[fpath,fname,fext]=fileparts(filestr);

					newpath = fullfile(path,[fname,fext]);
					[temppath,tempname,tempext]=fileparts(newpath);
					[stat,msg,msgid]=mkdir(temppath);

					if strcmp(local_struct.format{i},'bin')
						copy_if_missing([filestr '.header'],[newpath '.header']);
						copy_if_missing([filestr '.images'],[newpath '.images']);
					else
						copy_if_missing(filestr,newpath);
					end

					local_struct.dat{i}=strip_if_relative(newpath,relative);
					
					% If background_dat exists, copy file too
					if sum(strcmp('background_dat',str))
						% Original path
						filestr=local_struct.background_dat{i};
						% Split into parts
						[fpath,fname,fext]=fileparts(filestr);
						% Insert 'backgrounds'
						newpath = fullfile(path,'backgrounds',[fname,fext]);
						[temppath,tempname,tempext]=fileparts(newpath);
						[stat,msg,msgid]=mkdir(temppath);
						copy_if_missing(filestr,newpath);
						local_struct.background_dat{i}=strip_if_relative(newpath,relative);
					end
				end
			end

		% It is a struct, no isfile: recurse
		else
			for i=1:size(str,1)
				name=str{i};
				newpath = fullfile(path,name);
				% display('Recursing...');
				% display(name);
				% if strcmp(name,'user')
				%         keyboard;
				% end
				local_struct.(name)=recurse_save_file(local_struct.(name),newpath,relative);
			end
		end
	end
end

function copy_if_missing(fromstr,tostr)
	if exist(fromstr)~=2
		tryfromstr = fullfile(get_remoteprefix(),fromstr);
		if exist(tryfromstr)~=2
			error(['File to be copied doesn''t exist: ' fromstr])
		else
			fromstr = tryfromstr;
		end
	end
	% [dir_beg,dir_mid,filename]=get_valid_filename(fromstr);
	% fromstr=fullfile(dir_beg,dir_mid,filename);
	
	if exist(tostr)~=2
		display(['Copying file to ' tostr '...']);
		try
			copyfile(fromstr,tostr);
			display(['Success!']);
		end
	end
end

function newpath=strip_if_relative(newpath,relative)
	if relative==true
		ind=regexp(newpath,'(?<=.*)_files/');
		inds=regexp(newpath,'/');
		bool=ind>inds;
		if sum(bool) == 0
			return;
		else
			ind=inds(ind>inds);
			newpath=newpath(ind(end)+1:end);
		end
	else
		ind=regexp(newpath,'processed_data');
		newpath=newpath(ind:end);
	end
end
