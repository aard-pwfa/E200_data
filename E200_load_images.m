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
		remote=varargin{1}.VersionInfo.remotefiles.dat;
	else
		remote=true;
	end

	% Get prefix - if not remote, there is no prefix.
	if remote
		prefix=get_remoteprefix();
	else
		prefix=''
	end

	% Initialize cell arrays
	imgs=cell(1,size(imgstruct.UID,2));
	% bin_to_load=cell(1,size(UID,2));
	bin_to_load={};
	imgs_bg={};

	% Find and load each UID given.
	for i=1:size(UID,2)
		bool=(imgstruct.UID==UID(i));
		% Load what we can - not necessarily in order!
		if sum(bool)>0
			switch imgstruct.format{bool}
			case 'mat'
				load(fullfile(prefix,imgstruct.dat{bool}));
				imgs{i}=img;
			case 'bin'
				% Shouldn't load right away.  Instead, build list of bin files to load
				loadstr=fullfile(prefix,imgstruct.dat{bool});
				imgs{i}=loadstr;
				bin_to_load=[bin_to_load, {loadstr}];
			end
			% If backgrounds are requested, load backgrounds
			if nargout==2
				load(fullfile(prefix,imgstruct.background_dat{bool}));
				imgs_bg= [imgs_bg {img}];
			end
		end
	end

	% Load binaries here, prevent redundancy
	% Read each file in
	display(bin_to_load);
	bin_to_load=unique(bin_to_load);
	for j=1:size(bin_to_load,2)
		% Read file
		[image_data, cam_name, pulse_id] = readImagesBin(bin_to_load{j});

		% Get boolean for all shots matching file
		bool_shots=strcmp(bin_to_load{j},imgs);

		% Operate on all shots matching file
		for k=1:size(bool_shots,2)
			if bool_shots(k)
				% Replace filenames with data
				imgs{k}=image_data(:,:,imgstruct.bin_index(k));
			end
		end
	end
end
