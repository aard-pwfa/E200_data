function data = E200_save_processed_images(proc_img_array,proc_img_struct,data,struct_str,raw_field)
% proc_img_array: array of images to be saved
% proc_img_struct: The structure where the original info came from
% data: original data structure loaded from hard drive
% struct_str: name of new substruct, e.g. data.raw.processed.(struct_str)
% raw_field:  ???

% Retrieve original path info
orig_path = data.VersionInfo.originalpath;
proc_file = strtok(data.VersionInfo.originalfilename,'.');
prfx = get_remoteprefix;

% Construct new directory for processed images
proc_path = [orig_path '/' proc_file '_files/processed/images/' struct_str '/'];

% Create directory if it doesn't exist already
if ~exist([prfx '/' proc_path],'dir'); mkdir([prfx '/' proc_path]); end;

% Make raw_field a cell array (???)
num_imgs = numel(proc_img_array);
proc_img_struct.raw_field = cell(1,num_imgs);

% Loop over images
for i=1:numel(proc_img_array)
    % Unique file name (fname) for every image
    fname = [struct_str '_' num2str(proc_img_struct.UID(i)) '.mat'];

    % Full path and filename of image
    proc_fname = fullfile(proc_path,fname);

    % Store image to variable img
    % (expected saved variable in file)
    img = proc_img_array{i};

    % Notify user
    display(['Saving image ' num2str(i) ' of ' num2str(num_imgs)]);

    % Save img variable to the file
    save(fullfile(prfx,proc_fname),'img');

    % Save filename to .dat field per convention for images
    proc_img_struct.dat{i} = proc_fname;

    % Save any miscellaneous info
    proc_img_struct.raw_field{i} = raw_field;
end

data.processed.images.(struct_str) = proc_img_struct;
data=E200_save_remote(data);
