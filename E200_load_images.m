function [imgs,imgs_bg]=E200_load_images(imgstruct,UID,varargin)
% E200_LOAD_IMAGES  Loads images, accounts for remote/local paths
%   [IMGS, (IMG_BG)] = E200_LOAD_IMAGES(IMGSTRUCT,UID) Loads images, assumes they are remote
%   [IMGS, (IMG_BG)] = E200_LOAD_IMAGES(IMGSTRUCT,UID,DATA) Loads images, determines if they are remote from DATA.
% 
%   IMGSTRUCT:	Struct holding images.  E.g. data.raw.images.YAG
%   UID:	A cell array of UIDs desired from this IMGSTRUCT
%   (DATA):	Optional, the entire data structure varaible.
%   
%   IMGS:	A cell array of matrices representing the images loaded.
%   IMGS_BG:	A cell array of matrices representing the background images loaded.

	% Assume that it's remote by default,
	% but allow attaching data to specify.
	if nargin==3
		data=varargin{1};
		if isfield(data.VersionInfo,'remotefiles')
			remote=varargin{1}.VersionInfo.remotefiles.dat;
		else
			remote=true;
		end
	else
		remote=true;
	end

	% Get prefix - if not remote, there is no prefix.
	if remote
		prefix=get_remoteprefix();
	else
		prefix='';
	end

	% Initialize cell arrays
	% num_imgs=size(imgstruct.UID,2)

	% Valid UIDs
	[valid_UID, img_UID_ind, UID_ind]=intersect(imgstruct.UID,UID);
	num_imgs=length(img_UID_ind);
	% display(['Loading ' num2str(num_imgs) ' images via E200_load_images...']);

	imgs=cell(1,num_imgs);
	% bin_to_load=cell(1,size(UID,2));
	bin_to_load={};
	imgs_bg={};

	% Find and load valid UID given.
	for i=1:num_imgs
		cur_img_ind=img_UID_ind(i);
		% Load what we can - not necessarily in order!
		fmt = imgstruct.format{cur_img_ind};
		switch fmt
		case 'mat'
			load(fullfile(prefix,imgstruct.dat{cur_img_ind}));
			imgs{i}=img;
		case 'bin'
			% Shouldn't load right away.  Instead, build list of bin files to load
			loadstr=fullfile(prefix,imgstruct.dat{cur_img_ind});
			imgs{i}=loadstr;
			bin_to_load=[bin_to_load, {loadstr}];
		case {'CMOS','tif'}
			loadstr = fullfile(prefix,imgstruct.dat{cur_img_ind});
			imgs{i} = imread(loadstr);
		otherwise
			warning(['Image format (' fmt ') not recognized.']);
		end
		% If backgrounds are requested, load backgrounds
		if nargout==2
			if isfield(imgstruct,'background_dat')
				switch imgstruct.background_format{cur_img_ind}
				case 'mat'
					load(fullfile(prefix,imgstruct.background_dat{cur_img_ind}));
				case 'tif'
					display(imgstruct.background_dat{cur_img_ind})
					loadstr = fullfile(prefix,imgstruct.background_dat{cur_img_ind});
					img = imread(loadstr);
				end
			else % if no background available, make zero
				img = 0;
			end
			imgs_bg= [imgs_bg {img}];

			% Rotate image to correct orientation
			if size(imgs{i},1) == size(imgs_bg{i},2)
				imgs_bg{i} = rot90(imgs_bg{i});
			end
		end

		if imgstruct.X_ORIENT(cur_img_ind)
			imgs{i}=fliplr(imgs{i});
			if nargout==2
				imgs_bg{i}=fliplr(imgs_bg{i});
			end
		end
		if imgstruct.Y_ORIENT(cur_img_ind)
			imgs{i}=flipud(imgs{i});
			if nargout==2
				imgs_bg{i}=flipud(imgs_bg{i});
			end
		end
	end

	% Load binaries here, prevent redundancy
	% Read each file in
	bin_to_load=unique(bin_to_load);
	if ~isempty(bin_to_load)
		for j=1:size(bin_to_load,2)
			% Read file
			[image_data, cam_name, pulse_id] = readImagesBin(bin_to_load{j});
	
			% Get boolean for all shots matching file
			bool_shots=strcmp(bin_to_load{j},imgs);
	
			% Operate on all shots matching file
			for k=1:num_imgs
				if bool_shots(k)
					% Replace filenames with data
					imgs{k}=image_data(:,:,imgstruct.bin_index(k));
				end
			end
		end
	end

end
