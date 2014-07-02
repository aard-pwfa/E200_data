function out = E200_api_getdat(struct,UID,varargin)
	bool = ismember(struct.UID,UID);
	if nargin == 2
		if strcmp(class(struct.dat),'cell')
			out  = struct.dat{bool};
		else
			out  = struct.dat(bool);
		end
	else
		varargin{1}
		out  = struct.(varargin{1})(bool);
	end
end
