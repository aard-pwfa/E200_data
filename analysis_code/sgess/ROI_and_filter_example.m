% Example script for using adaptive ROI and flat filter tools

head = '/Volumes/PWFA_4big/';
date = '20130510';
set = '11029';
filename = ['nas/nas-li20-pm01/E200/2013/' date '/E200_' set '/'];
mydata = E200_load_data(filename);

CELOSS_struct = mydata.raw.images.CELOSS;
CELOSS_UID    = mydata.raw.images.CELOSS.UID;
CELOSS_imgs = E200_load_images(CELOSS_struct,CELOSS_UID,mydata);

img = CELOSS_imgs{1};

% display original image
figure(1);
imagesc(img);

% adaptively ROI the image
bufferzone = 0; % you can expand ROI'd image with buffer zone
tic;
[clippedImg1, xx, yy] = ImageClipper(img,bufferzone);
toc;

% display ROI'd image
figure(2)
imagesc(clippedImg1)

% select threshold region for flat filter
threshhold = 100; % need to select threshhold appropriately
useImg1 = clippedImg1 > threshhold;

% display filter region
figure(3);
imagesc(useImg1);

% apply flat filter
tic;
Xout1 = flatFilter(useImg1);
toc;

% display region after filtering
figure(4);
imagesc(Xout1);

% final analysis image for use with analysis e.g. cher gain/loss
clippedImg1(~Xout1)=0;
figure(5);
imagesc(clippedImg1);
