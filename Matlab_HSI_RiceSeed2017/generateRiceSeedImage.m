%%% generate seeds from Mask and RGB file
%%%

function generateRiceSeedImage(filename)

close all
defaultFolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\VIS\RGBMask\';
imgMask = imread(strcat(defaultFolder,filename,'_rgb_mask.png'));

imgRGB = imread(strcat(defaultFolder,filename,'.JPG'));
size(imgMask)
figure
subplot(121)
imshow(imgMask,[]);

size(imgRGB);
leftborder = 1800;
RiceReg = imgRGB(:,leftborder:(leftborder+1600),:);

 se = strel('disk',3);
        
% imgEdge = edge(imgMask,'canny');
% imgEdge = imdilate(imgEdge,se);
% 
% 
% idx = find(imgEdge > 0);
% 
% [m n nchannel] = size(RiceReg);
% 
% imgtemp = reshape(RiceReg,[m*n 3]);
% 
% imgtemp(idx,1:3) = repmat([0 0 255],[length(idx) 1]);
% 
% RiceReg = reshape(imgtemp,[m n 3]);

subplot(122)
imshow(RiceReg,[]);


%%% reorder rice index and extract each rice seeds into a RGB file


L = bwlabel(imgMask); 
nRiceperRow = 8;
L = rearrangericeidx(L,nRiceperRow);

nRice = max(max(L));
[m n] = size(L);
t=1;

for i=1:nRice
    
    bw = zeros(m,n);
    idx = find(L == i);
    bw(idx) = 1;
    s  = regionprops(bw, 'all');
    
    %%% get center of rice
    box = s.BoundingBox;
    
    riceData = zeros(400,200,3);
    x = floor(box(1));
    y = floor(box(2));
    w = floor(box(3)/2);
    h = floor(box(4)/2);
    
    riceData(200-h:200+h,100-w:100+w,1) = double(RiceReg(y:y+2*h,x:x+2*w,1)).*imgMask(y:y+2*h,x:x+2*w);
    riceData(200-h:200+h,100-w:100+w,2) = double(RiceReg(y:y+2*h,x:x+2*w,2)).*imgMask(y:y+2*h,x:x+2*w);
    riceData(200-h:200+h,100-w:100+w,3) = double(RiceReg(y:y+2*h,x:x+2*w,3)).*imgMask(y:y+2*h,x:x+2*w);

    %%% save riceData into file
    imwrite(uint8(riceData),strcat(defaultFolder,filename,'_S',num2str(i),'.png'));
end

function L = rearrangericeidx(Lorig,nRiceperRow)

    %%% rotate Lorig first
   
    nRice = max(max(Lorig));
    [m n] = size(Lorig);
    
    L = zeros(m,n);
    startseed = 1;
    newriceidx=1;
    
    for i=1:nRiceperRow:nRice
        endseed = startseed+nRiceperRow-1;
        
        for j=startseed:endseed
            riceImg = zeros(m,n);
            idx = find(Lorig==j);
            riceImg(idx) = 1;
            s  = regionprops(riceImg, 'centroid');
            centerpoint(j,:) = floor(cat(1, s.Centroid));
            seedIDX(j-startseed+1) = j;
        end
        
        %%% sort centerpoint 
        [c ridx] = sort(centerpoint(startseed:endseed,2));
        for t=1:length(ridx)
            idx = find(Lorig==seedIDX(ridx(t)));
            L(idx) = newriceidx;
            newriceidx =newriceidx+1;
        end
        startseed =endseed+1;
    end
    
