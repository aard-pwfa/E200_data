function bool = isfs20()
	[status,hostname]=unix('hostname');
	hostname = strrep(hostname,sprintf('\n'),'');
	bool=strcmp(hostname,'facet-srv20');
end
