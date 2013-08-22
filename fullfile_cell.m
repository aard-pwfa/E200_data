function out=fullfile_cell(path,cellpath)
	out={};
	for i=1:size(cellpath,2)
		out=[out, {fullfile(path,cellpath{i})}];
	end
end
