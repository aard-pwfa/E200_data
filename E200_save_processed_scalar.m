%% E200_save_processed_scalar
% Adds a scalar to the 'processed' sub-struct in the data
% and save to the remote disk storage accordingly.
%
% Inputs:
%
% data  : main data struct as obtained by E200_load_data
% myvar : scalar variable struct to be added to data
%
% M.Litos Oct.25, 2013
function [ data ] = E200_save_processed_scalar( data, myvar, myvar_name )

% check for the minimally required fields
if ~isfield(myvar,'dat')
    disp('Processed scalar struct missing .dat field.');
    disp('Did not save new scalar struct to disk.');
    return;
end
if ~isfield(myvar,'UID')
    disp('Processed scalar struct missing .UID field.');
    disp('Did not save new scalar struct to disk.');
    return;
end
if ~isfield(myvar,'IDtype')
    disp('Processed scalar struct missing .IDtype field.');
    disp('Did not save new scalar struct to disk.');
    return;
end

eval(sprintf('data.processed.scalars.%s = myvar;',myvar_name));

% save the new data struct to disk
data=E200_save_remote(data);

end

