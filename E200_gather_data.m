function data=E200_gather_data(path,varargin)
	if nargin>1
		scan_step=varargin{1};
	else
		scan_step=1;
	end

	% Get path and filename
	% path='/nas/nas-li20-pm01/E200/2013/20130520/E200_11209/E200_11209_2013-05-20-22-32-18_filenames.mat';
	% path='/nas/nas-li20-pm01/E200/2013/20130514/E200_11159/E200_11159_scan_info.mat';
	[Pathname,name,extension]=fileparts(path);
	Filename=[name extension];

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

	% Get param so I can get experiment so I can initialize paths
	% Also, load files needed later
	switch settype
	case 'scan'
	        % Load scan_info file
	        load(path);

		% Find one step file
		stepfiles=dir(fullfile(Pathname,'*_filenames.mat'));
		steppath=fullfile(Pathname,stepfiles(1).name);

		% Load one step file
		load([steppath(1:end-14) '.mat']);

	case 'daq'
	        % Load file
	        load(fullfile(Pathname,[Filename(1:end-14) '.mat']));
	        load(path);
	end
	% param now exists!
	experimentstr=param.experiment;

	% Strip experiment from filename
	str=Filename(size(experimentstr,2)+1:end);
	% Find underscores
	underscore_ind=strfind(str,'_');
	% Extract number between underscores
	datasetstr=str(underscore_ind(1)+1:underscore_ind(2)-1);

	% basedataset=[param.experiment]
	basedataset=[experimentstr '_' datasetstr];

	create_file_tree(Pathname,experimentstr,datasetstr);

	% Initialize data structure
	data             = struct();
	data.Version = 0.1;

	data.raw         = struct();
	data.raw.images  = struct();
	data.raw.scalars = struct();
	data.raw.vectors = struct();
	data.raw.arrays  = struct();

	data.processed   = data.raw;

	data.user=struct();


	% Save some info for development purposes
	data.user.dev.path=path;
	data.user.dev.Pathname=Pathname;
	data.user.dev.Filename=Filename;
	
	
	% Type-specific Initialization
	switch settype
	    case 'scan'
	
		n_steps=size(scan_info,2);

		data=E200_gather_data(fullfile(Pathname,stepfiles(1).name),1);
		data=add_scan_info(data,scan_info(1));
		for i=2:n_steps
		% for i=2:2
			steppath=fullfile(Pathname,stepfiles(i).name);
			data_append=E200_gather_data(steppath,i);
			data_append=add_scan_info(data_append,scan_info(i));
			
			data=E200_concat(data,data_append);
		end
		data.user.dev.stepfiles=stepfiles;
		data.user.dev.scan_info=scan_info;

	    case 'daq'

		% Convert epics_data to a list
		n_e_shots      = size(epics_data,2);
		epics_data_mat = cell2mat(squeeze(struct2cell(epics_data)));

		% Assume image list will be as long as requested
		n_i_shots=param.n_shot;

		% Generate epics-type UID
		bool        = strcmp('PATT_SYS1_1_PULSEID',fieldnames(epics_data));
		e_PID       = epics_data_mat(bool,:);
		e_scan_step = ones(1,n_e_shots)*scan_step;
		% setstr      = str2num(param.save_name(1:10));
		dataset     = str2num(datasetstr);
		e_dataset   = dataset * ones(1,n_e_shots);
		UIDs        = assign_UID(e_PID,e_scan_step,e_dataset);
		e_UID       = UIDs.epics_UID;

		% Put in epics_data
		names=fieldnames(epics_data);
		for i=1:size(names,1)
			data.raw.scalars.(names{i})=add_raw(epics_data_mat(i,:),e_UID,'EPICS');
		end

		% Save these things to the struct
		data.raw.scalars.step_num       = add_raw(e_scan_step,e_UID,'EPICS');
		data.raw.scalars.dataset_number = add_raw(e_dataset, e_UID, 'EPICS');

		% Extract and save backgrounds if they exist(consistency)
		if isstruct(cam_back)
			% Save backgrounds to file
			camstr=fieldnames(cam_back);
			for i=1:size(camstr,1)
				% bgname=[camstr{i} '_set' num2str(dataset) '_step' num2str(scan_step) '.mat'];
				% bg_name=bgname(camstr{i},dataset,scan_step);
				% bgpath=fullfile(imgpath,bg_name);
				bgpathstr=bgpath(experimentstr,camstr{i},dataset,scan_step,Pathname);
				% Save if backgrounds don't exist
				if ~( exist(bgpathstr)==2 )
					display('Saving background file...');
					img=cam_back.(camstr{i}).img;
					save(bgpathstr,'img');
				end
				cam_back.(camstr{i})=rmfield(cam_back.(camstr{i}),'img');
			end
		end

		% Initialize data.raw.images.(name)
		format=cell_construct('bin',1,n_i_shots);
		for i=1:size(param.cams,1)
			str=param.cams{i,1};
			data.raw.images.(str)=struct();
			data.raw.images.(str)=replace_field(data.raw.images.(str),...
							'dat'			, cell_construct(filenames.(str),1,n_i_shots),...
							'format'		, format, ...
							'isfile'		, ones(1,n_i_shots), ...
							'bin_index'		, [1:n_i_shots], ...
							'IDtype'		, 'Image');
			% Add the remaining info from cam_back
			if isstruct(cam_back)
				data.raw.images.(str)=replace_field(data.raw.images.(str),...
							'background_dat'	, cell_construct(...
												bgpath(experimentstr,str,datasetstr,scan_step,Pathname),...
												1,n_i_shots),...
							'background_format'	, cell_construct('mat',1,n_i_shots));
				names=fieldnames(cam_back.(str));
				for i=1:size(names,1)
					toadd=cam_back.(str).(names{i});
					if iscell(toadd)
						data.raw.images.(str).(names{i})=cell_construct(toadd,1,n_i_shots);
					else
						data.raw.images.(str).(names{i})=ones(1,n_i_shots)*toadd;
					end
				end
			end
		end


		% Add metadata
		data.raw.metadata.param=add_raw(cell_construct(param,1,n_e_shots), e_UID,'EPICS');
	        
	    case 'none'
		    error('Filetype not understood.');
	end
	
	% All file initializations
	if ~strcmp(settype,'none')
	end
end

function out=bgpath(experiment,imgname,set,step,basepath)
	out=['Background_' imgname '_set' num2str(set) '_step' num2str(step) '.mat'];
	out=fullfile(basepath,[experiment '_' num2str(set) '_files'],'raw','images','backgrounds',out);
end

function data=add_scan_info(data,scan_info)
	UID=data.raw.scalars.step_num.UID;
	size_UID = size(UID,2);
	data=add_step_info(data,scan_info.Control_PV_name{1},scan_info.Control_PV);
	data.raw.metadata.scan_info=add_raw(cell_construct(scan_info,1,size_UID),UID,'EPICS');
end
