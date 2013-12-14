function data=E200_concat(data1,data2)
	data2=copy_bg(data1,data2);

	% Append things
	data=recurse_append_struct(data1,data2);
end

function data2=copy_bg(data1,data2)
	% Get the cameras 
	camstr=fieldnames(data1.raw.images);
	n_shot=data1.raw.metadata.param.dat{1}.n_shot;
	
	% For each camera...
	for i=1:size(camstr,1)
		% Get the fields in it
		names=fieldnames(data1.raw.images.(camstr{i}));

		% Get the number of shots stored in data2
		n_shot = size(data2.raw.images.(camstr{i}).dat,2);

		% Only copy the fields that don't match standard things:
		standard_raw_fields={'dat','format','bin_index','IDtype','UID','PID'};
		for j=1:size(names,1)
			if sum(strcmp(names{j},standard_raw_fields))==0
				% Only copy the appropriate number of shots
				thisdat = data1.raw.images.(camstr{i}).(names{j});
				if iscell(thisdat)
					data2.raw.images.(camstr{i}).(names{j})=cell_construct(thisdat{1},1,n_shot);
				else
					data2.raw.images.(camstr{i}).(names{j})=thisdat(1)*ones(1,n_shot);
				end
			end
		end
	end
end
