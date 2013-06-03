function data=E200_convert_images()
	images=data.raw.images;
	names=fieldnames(images);
	% Loop over cameras
	for i=1:size(names,1)
		cam=images.(names{i});
		% Get boolean for all binaries
		bool_bin=strcmp('bin',cam.format);
		% Get all unique file names for binaries
		toread=unique(cam.dat(bool_bin));
		% Read each file in
		for j=1:size(toread,2)
			% Read file and then delete
			[image_data, cam_name, pulse_id] = readImagesBin(toread{j});

			% Get boolean for all shots matching file
			bool_shots=strcmp(toread{j},cam.dat);
			for k=1:size(bool_shots,2)
				if bool_shots(k)
					img=image_data(:,:,cam.bin_index(k));
					[path,name,ext]=fileparts(cam.dat{k});
					cam.dat{k}=fullfile(path,[names{i} '_' num2str(cam.UID(k)) '.mat']);
					cam.format{k}='mat';
					if exist(cam.dat{k})~=2
						save(cam.dat{k},'img');
					end
				end
			end
			% Delete old files
			% delete([toread{j} '*']);
		end
		% Push changes back to data
		data.raw.images.(names{i})=cam;
	end
end
