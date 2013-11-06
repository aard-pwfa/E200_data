function data = E200_resave_CMOS(cmos_dir,dataset)


mydata = E200_load_data(dataset);
ALL_PID = mydata.raw.scalars.PATT_SYS1_1_PULSEID.dat;
ALL_UID = mydata.raw.scalars.PATT_SYS1_1_PULSEID.UID;


cmos_head = 'data_img_';
cmos_ext  = '.tif';

data_head = '/Volumes/PWFA_4big/';
data_path = [mydata.VersionInfo.originalpath '/'];
data_file = strtok(mydata.VersionInfo.originalfilename,'.');
cmos_file = '_files/raw/images/CMOS/';
cmos_name = 'CMOS_';
full_path = [data_head data_path data_file cmos_file];
if ~exist(full_path,'dir'); mkdir(full_path); end;

cmos_files = dir([cmos_dir '*' cmos_ext]);
cmos_fnums = zeros(1,length(cmos_files));

for i = 1:length(cmos_files)
    
    cmos_fnums(i)=str2double(strtok(cmos_files(i).name,cmos_head));
    
end

odds = rem(cmos_fnums,10);
odds_inds = find(odds == 9);
cmos_fnums(odds_inds) = cmos_fnums(odds_inds) + 1;

[~,~,ind2] = intersect(cmos_fnums,ALL_PID);
cmos_UID = ALL_UID(ind2);

CMOS_struct.UID = cmos_UID;
CMOS_struct.PID = cmos_fnums;
CMOS_struct.IDtype = 'Image';

for i = 1:length(cmos_files)

    img = imread([cmos_dir cmos_files(i).name]);
    img = uint16(img);
    fname = [full_path cmos_name num2str(cmos_UID(i)) '.mat'];
    display(['Saving CMOS image ' num2str(cmos_UID(i))]);
    save(fname,'img');
    
    CMOS_struct.dat{i} = [data_path data_file cmos_file cmos_name num2str(cmos_UID(i)) '.mat'];
    CMOS_struct.format{i} = 'mat';
    CMOS_struct.isfile(i) = 1;
    CMOS_struct.bin_index(i) = 0;
    CMOS_struct.ROI_X(i) = 0;
    CMOS_struct.ROI_Y(i) = 0;
    CMOS_struct.ROI_XNP(i) = 2559;
    CMOS_struct.ROI_YNP(i) = 2159;
    CMOS_struct.RESOLUTION(i) = 19.531;
    CMOS_struct.X_ORIENT{i} = '';
    CMOS_struct.Y_ORIENT{i} = '';
    
end

mydata.raw.images.CMOS = CMOS_struct;
data=E200_save_remote(mydata,true);


