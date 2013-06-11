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
	display('hi');
	% Get prefix - if not remote, there is no prefix.
	if remote
		prefix=get_remoteprefix();
	else
		prefix=''
	end

	% Initialize cell arrays
	imgs={};
	imgs_bg={};

	% Find and load each UID given.
	for i=UID
		bool=(imgstruct.UID==i);
		load(fullfile(prefix,imgstruct.dat{bool}));
		imgs=[imgs {img}];
		if nargout==2
			load(fullfile(prefix,imgstruct.background_dat{bool}));
			imgs_bg= [imgs_bg {img}];
		end
	end

end

