function [filestr,structstr]=cams2filenames(str)
	if strcmp(str,'ELANEX')
		filestr   = 'PHOSPHOR';
		structstr = 'ELANEX';
	elseif strcmp(str,'PHOSPHOR')
		filestr   = 'PHOSPHOR';
		structstr = 'ELANEX';
	else
		filestr   = str;
		structstr = str;
	end
end
