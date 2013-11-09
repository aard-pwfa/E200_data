function out = E200_api_getdat(struct,UID)
	bool = ( struct.UID == UID );
	out  = struct.dat{bool};
end
