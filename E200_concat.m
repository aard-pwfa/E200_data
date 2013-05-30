function data=E200_concat(data1,data2)
	data2=copy_bg(data1,data2);

	display('data1')
	display(data1.raw.images.YAG)
	display('data2')
	display(data2.raw.images.YAG)

	% Append things
	data=recurse_append_struct(data1,data2);
end

function data2=copy_bg(data1,data2)
	% Get the cameras 
	camstr=fieldnames(data1.raw.images);
	n_shot=data1.raw.metadata.param.dat{1}.n_shot
	
	% For each camera...
	for i=1:size(camstr,1)
		% Get the fields in it
		names=fieldnames(data1.raw.images.(camstr{i}));

		% Only copy the fields that don't match standard things:
		standard_raw_fields={'dat','format','bin_index','IDtype','UID'};
		for j=1:size(names,1)
			if sum(strcmp(names{j},standard_raw_fields))==0
				% Only copy the appropriate number of shots
				data2.raw.images.(camstr{i}).(names{j})=data1.raw.images.(camstr{i}).(names{j})(1:n_shot);
			end
		end
	end
end

function data=take_first(data)
	if iscell(data)
		data=data{1};
	else
		data=data(1);
	end
end
