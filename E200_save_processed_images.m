function data = E200_save_processed_images(proc_img_array,proc_img_struct,data,struct_str,raw_field)


orig_path = data.VersionInfo.originalpath;
proc_file = strtok(data.VersionInfo.originalfilename,'.');
prfx = get_remoteprefix;
proc_path = [orig_path '/' proc_file '_files/processed/images/' struct_str '/'];
if ~exist([prfx '/' proc_path],'dir'); mkdir([prfx '/' proc_path]); end;

num_imgs = numel(proc_img_array);
proc_img_struct.raw_field = cell(1,num_imgs);

for i=1:numel(proc_img_array)
    
    fname = [struct_str '_' num2str(proc_img_struct.UID(i)) '.mat'];
    proc_fname = [proc_path fname];
    img = proc_img_array{i};
    display(['Saving image ' num2str(i) ' of ' num2str(num_imgs)]);
    save([prfx '/' proc_fname],'img');

    proc_img_struct.dat{i} = proc_fname;
    proc_img_struct.raw_field{i} = raw_field;
end

data.processed.images.(struct_str) = proc_img_struct;
data=E200_save_remote(data);