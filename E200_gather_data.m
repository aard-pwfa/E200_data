function data=E200_gather_data(path)
	% Initialize data structure
	data             = struct();
	data.Version = 0.1;

	data.raw         = struct();
	data.raw.images  = struct();
	data.raw.scalars = struct();
	data.raw.arrays  = struct();
	data.raw.lists   = struct();

	data.processed   = data.raw;

	data.user=struct();

	% Get path and filename
	% path='/nas/nas-li20-pm01/E200/2013/20130511/E200_11071/E200_11071_scan_info.mat';
	% path='/nas/nas-li20-pm01/E200/2013/20130520/E200_11208/E200_11208_2013-05-20-19-04-30_filenames.mat';
	path='/nas/nas-li20-pm01/E200/2013/20130520/E200_11209/E200_11209_2013-05-20-22-32-18_filenames.mat';
	[Pathname,name,extension,versn]=fileparts(path);
	Filename=[name extension versn];

	display(fullfile(Pathname, Filename));

	data.user.dev.path=path;
	data.user.dev.Pathname=Pathname;
	data.user.dev.Filename=Filename;
	
	% Determine which file type is being used.
	settype='none';
	searchlist = {{'scan_info.mat','scan'},{'filenames.mat','daq'}};
	% searchlist = {{'scan_info.mat','scan'}};
	if (Filename~=0)
		for searchstr=searchlist
			if ~isempty(strfind(Filename,searchstr{1}{1}))
				settype=searchstr{1}{2};
	        	end
		end
	else
	    error('File not valid.');
	end
	
	% Type-specific Initialization\
	switch settype
	    case 'scan'
	
	        % Load scan_info file
	        load(path);
	        
	        % Load first filename file
	        dirs=dir(fullfile(Pathname,'*_2013*.mat'));
	        load(fullfile(Pathname,dirs(1).name));

		data.user.dev.load=fullfile(Pathname,dirs(1).name);
		
		% Initialize data.raw.images
		

	        n_steps=size(scan_info,2);
	
		% handles.scan.scan_info=scan_info;
		% handles.scan.n_steps=n_steps;
	        
	    case 'daq'
	        % Load file
	        load(fullfile(Pathname,[Filename(1:end-14) '.mat']));
	        load(path);

		% Convert epics_data to a list
		n_shots=size(epics_data,2);
		epics_data_mat=cell2mat(squeeze(struct2cell(epics_data)));
		
		% Put in epics_data
		names=fieldnames(epics_data);
		for i=1:size(names,1)
			data.raw.scalars.(names{i}).dat=epics_data_mat(i,:);
		end
		PulseID=data.raw.scalars.PATT_SYS1_1_PULSEID;

		% Only one step
		data.raw.scalars.step=struct('dat',ones(1,n_shots), ...
						'PulseID',PulseID, ...
						'type','Epics');

		% Initialize data.raw.images.(name)
		for i=1:size(param.cams,1)
			str=param.cams{i,1};
			data.raw.images.(str).dat=filenames.(str);
			% data.raw.images.(str).
		end

	        
	        handles.daq.filenames=filenames;
	    case 'none'
	end
	
	% All file initializations
	if ~strcmp(settype,'none')
	
	    % handles.param=param;
	    % handles.cam_back=cam_back;
	    
	end
end
