function out = E200_api_getdat(struct,UID,varargin)
	bool = ( struct.UID == UID );
	if nargin == 0
		out  = struct.dat{bool};
	else
		varargin{1}
		out  = struct.(varargin{1})(bool);
	end
end
