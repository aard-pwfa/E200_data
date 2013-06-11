function bg_sub()
	% Make sure E200_data is on my path.
	addpath('../../');

	% Path to the dataset I want.
	% Note that it doesn't need the prefix to the location of /nas anymore!
	path='/nas/nas-li20-pm01/E200/2013/20130428/E200_10794';
	
	% Load this data.
	data=E200_load_data(path);

	% I want to load data from YAG.
	imgstruct=data.raw.images.YAG;

	% I want to load only images from the 2nd step
	bool1=(data.raw.scalars.step_num.dat==2);

	% I want the UIDs of the 2nd step
	wanted_UIDs = data.raw.images.YAG.UID(bool1);

	% Load those images
	% Note: The third argument, data, is optional.
	%	But including it allows E200_load_images
	%	to determine if the images are saved
	%	remotely or locally.
	display(['Loading ' num2str(2*size(wanted_UIDs,2)) ' images ...']);
	tic;
	[img,bg]=E200_load_images(imgstruct,wanted_UIDs,data);
	toc;
	display('');
	
	% Loop over my images
	% Note: only show first 5.
	display('Click on the image to continue.');
	for i=1:5
		display(['Image ' num2str(i) '...']);
		% Plot the image
		imagesc(img{i}-uint16(bg{i}));
		% Wait for the user to press a key
		waitforbuttonpress;
	end

	% Close the figures.
	close('all');
end
