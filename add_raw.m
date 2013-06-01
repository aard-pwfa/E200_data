function out=add_raw(dat,UID,IDtype)
	valid_IDtypes = {'EPICS','AIDA','Image'};
	if sum(strcmp(IDtype,valid_IDtypes))<1
		error('Use a valid IDtype.');
	end
	if iscell(dat)
		out=struct();
		out=replace_field(out,'dat',dat,'UID',UID,'IDtype',IDtype);
	else
		out=struct('dat',dat,'UID',UID,'IDtype',IDtype);
	end
end
