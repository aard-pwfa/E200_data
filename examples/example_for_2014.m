close('all');

% set path to data
data_path='/nas/nas-li20-pm01/E200/2014/20140316/E200_12037/E200_12037.mat';

% load data
data=E200_load_data(data_path);

% scalar data (EPICS PVs) are stored in data.raw.images
pyro = data.raw.scalars.BLEN_LI20_3014_BRAW.dat;
bpm_2445_x = data.raw.scalars.BPMS_LI20_2445_X.dat;

% plot BPM2445X vs pyro
figure(1);
plot(pyro, bpm_2445_x, '*');
addlabels('Pyro Signal','BPM 2445 X','X Orbit at BPM2445 vs. Pyro');

% image data is stored as a path to a data file (in this case a .tif file)
SYAG_struct = data.raw.images.SYAG;
image = E200_load_images(SYAG_struct,SYAG_struct.UID(1));
image = image{1};
figure(2);
imagesc(image);
title('First SYAG Shot');

% you can use the X_ORIENT and Y_ORIENT options to display the data the way
% it is shown in the profile monitor guis
X_ORIENT = SYAG_struct.X_ORIENT(1);
Y_ORIENT = SYAG_struct.Y_ORIENT(1);
if X_ORIENT
	image = fliplr(image);
end
if Y_ORIENT
	image = flipud(image);
end
figure(3);
imagesc(image);
title('Reoriented SYAG Shot');

% look at lot's of images, do a computation
figure(4);
images = E200_load_images(SYAG_struct,SYAG_struct.UID);
for i = 1:numel(images)
	image = images{i};
	pixel_sum(i) = sum(image(:));
	imagesc(image);
	title('Image to be Summed');
	pause(0.1);
end

% Compare image data with EPICS data using the UID
PYRO_UID = data.raw.scalars.BLEN_LI20_3014_BRAW.UID;
SYAG_UID = data.raw.images.SYAG.UID;

% generate a set of indices for matching shots (in other words,
% EPICS_UID(EPICS_index) is guaranteed to be the same set of shots as
% SYAG_UID(SYAG_index).
[~,PYRO_index,SYAG_index] = intersect(PYRO_UID,SYAG_UID);

% plot EPICS variable vs index matched image variable
figure(5);
plot(pyro(PYRO_index), pixel_sum(SYAG_index), '*');
addlabels('Pyro','Pixel Sum','Camera Signal vs. Pyro Signal');
