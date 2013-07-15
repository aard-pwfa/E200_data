%
% Basic usage 
%
%% E. Adli, June 5, 2013
%%   First version!

% specify dataset
filename = '/Volumes/PWFA 4big/nas/nas-li20-pm01/E200/2013/20130429/E200_10970/'

% load data (automatically converts if needed)
mydata = E200_load_data(filename);

% plot BPM2445X vs pyro
plot(mydata.raw.scalars.BLEN_LI20_3014_BRAW.dat, mydata.raw.scalars.BPMS_LI20_2445_X.dat, 'x');

% look at an image
load(mydata.raw.images.CELOSS.dat{1}); imagesc(flipud(img'));

% save data to local harddrive and take home
filename_save = '~/temp/savetest/saved.mat'

mydata_local = E200_save_local(mydata, filename_save);
