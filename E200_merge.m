function data_new = E200_merge(data_src,data_dest)
	% Validate compatibility
	merge_compatible(data_src,data_dest);

	% Recursively add on fields in everything but raw
	data_new = add_fields_main(data_src,data_dest);

end

function merge_compatible(data_src,data_dest)
	% Test version
	if data_src.VersionInfo.Version ~= data_dest.VersionInfo.Version
		error('Data structures are not the same version.');
	end
end

function data_dest=add_fields_main(data_src,data_dest)
	% Fields to ignore
	% 	Note: we do want to copy raw, we just want to be strict:
	% 	No overwriting allowed.
	ignorefields={'VersionInfo'};
	no_overwrite_fields={'raw'};

	% Get all fields
	copy_fields=fieldnames(data_src);

	% Iterate over fields
	for i=1:size(copy_fields,1)
		copystr=copy_fields{i};
		% Ignore certain fields
		if sum(strcmp(copystr,ignorefields))==0
			% Overwrite these
			if sum(strcmp(copystr,no_overwrite_fields))==0
				% overwrite_bool=true;
				overwrite_bool=true;
			% Don't overwrite these
			else
				overwrite_bool=false;
			end
			data_dest.(copystr)=copy_recurse(data_src.(copystr),data_dest.(copystr),overwrite_bool);
			
		end
	end
end

function [dest,diff]=copy_recurse(src,dest,overwrite_bool)
	% Not tip of tree
	% display(overwrite_bool)
	% overwrite_bool
	if isstruct(src)
		% Compare.  If equal, move on.
		if isequaln(src,dest)
			return;
		% Structs not equal. Iterate over names
		else
			% Get fields of both.
			fieldstr_src=fieldnames(src);
			fieldstr_dest=fieldnames(dest);

			% Iterate over source fields
			for i=1:size(fieldstr_src,1)
				namestr=fieldstr_src{i};
				sub_src=src.(namestr);
				% Look for match
				bool=strcmp(namestr,fieldstr_dest);
				% If name match is found, recurse.
				if sum(bool)==1
					dest.(namestr)=copy_recurse(sub_src,dest.(namestr),overwrite_bool);
				% If name match isn't found, copy.
				else
					dest.(namestr)=sub_src;
				end
			end
		end
	% Tip of tree: cell
	elseif iscell(src) || isnumeric(src) || ischar(src) || islogical(src)
		% Compare.  If equal, move on.
		if isequaln(src,dest)
			return;
		% Cells not equal.
		else
			if overwrite_bool
				% overwrite_bool
				warning('Overwriting data...');
				dest=src;
			else
				error('Requested to overwrite disallowed field. Check in data.raw and data.VersionInfo.');
			end
		end
	else
		error('Data type not handled.');
	end
end

% function check_type(src,dest)
