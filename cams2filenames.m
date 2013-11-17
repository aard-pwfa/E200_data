function [filestr,structstr]=cams2filenames(str,time_stamp)

cher_switch = [2013 11 13 12 0 0];

if strcmp(str,'ELANEX')
    filestr   = 'PHOSPHOR';
    structstr = 'ELANEX';
elseif strcmp(str,'PHOSPHOR')
    filestr   = 'PHOSPHOR';
    structstr = 'ELANEX';
elseif strcmp(str,'CNEAR') & datenum(time_stamp) > datenum(cher_switch)
    filestr = 'CELOSS';
    structstr = 'CNEAR';
else
    filestr   = str;
    structstr = str;
end

