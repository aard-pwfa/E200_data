function struct1=recurse_append_struct(struct1,struct2)
	if ~isstruct(struct2)
		error('too far');
	end

	% Get this level's field names
	names1=fieldnames(struct1);
	names2=fieldnames(struct2);
	% Iterate over fields to be appended
	for i=1:size(names2,1)
		str=names2{i};
		toappend = struct2.(str);
		% If this name isn't in struct1, just copy:
		if sum(strcmp(str,names1))==0
			struct1.(str)=toappend;
		% Otherwise, concatenate:
		else
			% If this is not the tip of the tree, recurse:
			if isstruct(toappend)
				struct1.(str)=recurse_append_struct(struct1.(str),toappend);
			% If this is the tip of the tree:
			else
				% Don't append certain types:
				if ischar(toappend)
					if ~strcmp(str,'IDtype')
						struct1.(str)=[struct1.(str), {toappend}];
					end
				else
					struct1.(str)=[struct1.(str), [toappend]];
				end
			end
		end
	end
end
