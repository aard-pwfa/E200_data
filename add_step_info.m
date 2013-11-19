function data=add_step_info(data,step_name,step_value)
	UID=data.raw.scalars.step_num.UID;
	size_UID = size(UID,2);
	data.raw.scalars.step_name=add_raw(cell_construct(step_name,1,size_UID),UID,'EPICS');

	% data.raw.scalrs.([step_name '_step_name']) = 
	% In case there are multiple step names and values
	% save_step_values = {};
	% for i=1:length(step_values)
	%         save_step_values = [save_step_values, step_value(i)*ones(1,size_uid)];

	data.raw.scalars.step_value=add_raw(cell_construct(step_value,1,size_UID),UID,'EPICS');
end
