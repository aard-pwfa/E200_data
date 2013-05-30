function out=replace_field(struct,varargin)
	if nargin < 3
		error('Not enough input arguments.');
	elseif mod(nargin-1,2)~=0
		error('Need pairs of fields to add.');
	else
		out=struct;
		for i=[1:((nargin-1)/2)]
			% Get str for struct field name
			str=varargin{2*i-1};
			out.(str)=varargin{2*i};
		end
	end
end
