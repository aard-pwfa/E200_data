function [PROC_imgs,PROC_struct] = median_mean_filter(IM_struct,IM_UID,data,BG,do_median,med_val,do_mean,meanX,meanY)

r = 3;

display('Loading CEGAIN images. . .');
unproc_imgs = E200_load_images(IM_struct,IM_UID,data);
num_imgs    = numel(unproc_imgs);
PROC_imgs   = cell(1,num_imgs);

PROC_struct = IM_struct;
PROC_struct.MED_FILT   = false(1,num_imgs);
PROC_struct.MED_VAL    = zeros(1,num_imgs);
PROC_struct.MEAN_FILT  = false(1,num_imgs);
PROC_struct.MEAN_FILTX = zeros(1,num_imgs);
PROC_struct.MEAN_FILTY = zeros(1,num_imgs);

for i = 1:num_imgs
    
    display(['Processing image ' num2str(i) ' of ' num2str(num_imgs)]);
    img = double(unproc_imgs{i})-BG;
    
    if do_median
        A = zeros([size(img), r^2]);
        for j=1:r^2
            w = zeros(r);
            w(j) = 1;
            A(:,:,j) = filter2(w, img);
        end
        
        B = sort(A,3);
        img = squeeze(B(:,:,med_val));
    end
    
    
    if do_mean; img = filter2(ones(meanX,meanY)/meanX*meanY, img); end
    
    PROC_imgs{i} = img;
    PROC_struct.MED_FILT(i)   = do_median;
    PROC_struct.MED_VAL(i)    = med_val;
    PROC_struct.MEAN_FILT(i)  = do_mean;
    PROC_struct.MEAN_FILTX(i) = meanX;
    PROC_struct.MEAN_FILTY(i) = meanY;
end