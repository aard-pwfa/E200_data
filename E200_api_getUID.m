function out = E200_api_getUID(struct,datvalue)
	bool = ( struct.dat == datvalue );
	out = struct.UID(bool);
end
