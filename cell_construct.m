function out=cell_construct(value,dim1,varargin)
	str=num2str(dim1);
	for i=1:nargin-2
		str=[str ',' num2str(varargin{i})];
	end
	eval(['out=cell(' str ');']);
	[out{:}]=deal(value);
end
