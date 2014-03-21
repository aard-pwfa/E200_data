function datafull=E200_gather_data(param,QC_INFO,epics_data,scanbool,E200_state,cam_back)
	experimentstr=param.experiment;

	% create_file_tree(pathstr);

	% ================================================
	% Initialize data structure
	% ================================================
	data         = struct();
	data.VersionInfo = struct('Version',0.2);

	data.raw          = struct();
	data.raw.images   = struct();
	data.raw.scalars  = struct();
	data.raw.vectors  = struct();
	data.raw.arrays   = struct();
	data.raw.metadata = struct();

	data.processed   = data.raw;

	data.user=struct();

	datafull=data;

	% ================================================
	% Initialize data structure
	% ================================================
	for scan_step=1:param.n_step
		% ================================================
		% Convert epics_data to a list
		% ================================================
		n_e_shots      = size(epics_data{scan_step},2);
		epics_data_mat = cell2mat(squeeze(struct2cell(epics_data{scan_step})));

		% ================================================
		% Generate epics-type UID
		% ================================================
		bool        = strcmp('PATT_SYS1_1_PULSEID',fieldnames(epics_data{scan_step}));
		e_PID       = epics_data_mat(bool,:);
		e_scan_step = ones(1,n_e_shots)*scan_step;
		dataset     = param.n_saves;
		e_dataset   = dataset * ones(1,n_e_shots);
		UIDs        = assign_UID(e_PID,e_scan_step,e_dataset);
		e_UID       = UIDs.epics_UID;

		% ================================================
		% Put in epics_data
		% ================================================
		names=fieldnames(epics_data{scan_step});
		for i=1:size(names,1)
			data.raw.scalars.(names{i})=add_raw(epics_data_mat(i,:),e_UID,'EPICS');
		end

		% ================================================
		% Save these things to the struct
		% ================================================
		data.raw.scalars.step_num = add_raw(e_scan_step,e_UID,'EPICS');
		data.raw.scalars.set_num  = add_raw(e_dataset, e_UID, 'EPICS');
		if scanbool
			data.raw.scalars.step_value = add_raw(param.PV_scan_list(scan_step)*ones(1,n_e_shots),e_UID,'EPICS');
		end

		% ================================================
		% Extract and save backgrounds 
		% if they exist(consistency)
		% ================================================
		camstr=fieldnames(cam_back);
		for i=1:size(camstr,1)
			structstr = camstr{i};
			bgpathstr=fullfile(param.save_path,structstr,'backgrounds',['Background_' structstr '_set' num2str(dataset) '.mat']);
			cam_back.(structstr).background_dat=bgpathstr;
			cam_back.(structstr).background_format='mat';
			% Save if backgrounds don't exist
			if ~( exist(bgpathstr)==2 )
				display('Saving background file...');
				% display(structstr)
				img=cam_back.(structstr).img;
				[bgpathdir,temp,temp]=fileparts(bgpathstr);
				mkdir(bgpathdir)
				save(bgpathstr,'img');
			end
			% cam_back.(camstr{i})=rmfield(cam_back.(camstr{i}),'img');
		end

		% ================================================
		% Extract E200_state and facet_state if 
		% they exist(consistency)
		% ================================================
		if isstruct(E200_state)
			data.raw.metadata.E200_state=add_raw(cell_construct(E200_state,1,n_e_shots), e_UID,'EPICS');
			fields=fieldnames(E200_state);
			for i=1:length(fields)
				curfield=fields{i};
				data.raw.scalars.(curfield)=add_raw(cell_construct(E200_state.(curfield),1,n_e_shots), e_UID,'EPICS');
			end
		end

		% ================================================
		% Initialize data.raw.images.(name)
		% ================================================
		% If param.cam_UNIQ exists, use it.
		if isfield(param,'cam_UNIQ')
			camnames = param.cam_UNIQ;
		else
			camnames = param.cams;
		end

	
			% ================================================
			% Add metadata
			% ================================================
			data.raw.metadata.param=add_raw(cell_construct(param,1,n_e_shots), e_UID,'EPICS');
			
			if scan_step==1
        			datafull=data;
			else
				datafull=E200_concat(datafull,data);
			end
			
		end
	
	datafull.raw.images=QC_INFO.IMAGES;
	camstr=fieldnames(cam_back);
	for i=1:size(camstr,1)
		structstr = camstr{i};
		n_i_shots=QC_INFO.IMAGES.(structstr).N_IMGS;
		datafull.raw.images.(structstr)=replace_field(datafull.raw.images.(structstr),...
					'background_dat'	, cell_construct(...
										cam_back.(structstr).background_dat,...
										1,n_i_shots),...
					'background_format'	, cell_construct('mat',1,n_i_shots));
		cam_back.(structstr) = rmfield(cam_back.(structstr),'img');
		cam_back.(structstr) = rmfield(cam_back.(structstr),'background_dat');
		cam_back.(structstr) = rmfield(cam_back.(structstr),'background_format');
		names=fieldnames(cam_back.(structstr));
		for j=1:size(names,1)
	                       toadd=cam_back.(structstr).(names{j});
			if iscell(toadd)
				datafull.raw.images.(structstr).(names{j})=cell_construct(toadd,1,n_i_shots);
			else 
				datafull.raw.images.(structstr).(names{j})=ones(1,n_i_shots)*toadd;
			end          	
		end                          
	end                          	
                                     	
	% ================================================
	% All file initializations   
	% ================================================
	if scanbool                  	
		% Change to correct settype.
		datafull.raw.metadata.settype='scan';
		datafull.raw.metadata.n_steps=param.n_step;
	else
		datafull.raw.metadata.settype='daq';
	end
end

function out=bgpath(experiment,imgname,set,step,basepath)
	display(['Basepath: ' basepath])
	out=['Background_' imgname '_set' num2str(set) '_step' num2str(step) '.mat'];
	out=fullfile(basepath,[experiment '_' num2str(set) '_files'],'raw','images',imgname,'backgrounds',out);
	% [outpath,name,ext]=fileparts(out);
	% [stat,msg,msgid]=mkdir(outpath);
end

function data=add_scan_info(data,scan_info)
	UID=data.raw.scalars.step_num.UID;
	size_UID = size(UID,2);
	if iscell(scan_info(1).Control_PV_name)
		Control_PV_name = scan_info(1).Control_PV_name;
	else
		Control_PV_name = {scan_info(1).Control_PV_name};
	end
	data=add_step_info(data,Control_PV_name,scan_info.Control_PV);
	data.raw.metadata.scan_info=add_raw(cell_construct(scan_info(1),1,size_UID),UID,'EPICS');
end
