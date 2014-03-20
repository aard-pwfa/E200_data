% set header (will change depending on where your data is stored)
header = '/Volumes/PWFA_4big';

% set path to data
data_path='/nas/nas-li20-pm01/E200/2014/20140316/E200_12037/E200_12037.mat';

% load data
load([header data_path]);

% scalar data (EPICS PVs) are stored in data.raw.images
pyro = data.raw.scalars.BLEN_LI20_3014_BRAW.dat;
bpm_2445_x = data.raw.scalars.BPMS_LI20_2445_X.dat;

% plot BPM2445X vs pyro
figure(1);
plot(pyro, bpm_2445_x, '*');

% image data is stored as a path to a data file (in this case a .tif file)
image = imread([header data.raw.images.SYAG.dat{1}]);
figure(2);
imagesc(image);

% you can use the X_ORIENT and Y_ORIENT options to display the data the way
% it is shown in the profile monitor guis
X_ORIENT = data.raw.images.SYAG.X_ORIENT(1);
Y_ORIENT = data.raw.images.SYAG.Y_ORIENT(1);
if X_ORIENT
    image = fliplr(image);
end
if Y_ORIENT
    image = flipud(image);
end
figure(3);
imagesc(image);

% look at lot's of images, do a computation
figure(4);
for i = 1:numel(data.raw.images.SYAG.dat)
    
    image = imread([header data.raw.images.SYAG.dat{i}]);
    pixel_sum(i) = sum(image(:));
    imagesc(image);
    pause(0.1);
    
end

% Compare image data with EPICS data using the UID
EPICS_UID = data.raw.scalars.PATT_SYS1_1_PULSEID.UID;
SYAG_UID = data.raw.images.SYAG.UID;

% generate a set of indices for matching shots (in other words,
% EPICS_UID(EPICS_index) is guaranteed to be the same set of shots as
% SYAG_UID(SYAG_index).
[~,EPICS_index,SYAG_index] = intersect(EPICS_UID,SYAG_UID);

% plot EPICS variable vs index matched image variable
figure(5);
plot(pyro(EPICS_index), pixel_sum(SYAG_index), '*');

