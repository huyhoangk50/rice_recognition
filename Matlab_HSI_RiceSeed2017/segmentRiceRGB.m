%%% segment rice seed from RGB image
function segmentRiceRGB(filename)
close all
 close all
 Envisetup
 global datafolder
 global resultfolder

datafolder ='G:\WorkinginUoS\CCDData\';
resultfolder = datafolder;

imgData = double(imread(strcat(datafolder,filename,'.jpg')));

%%% get red channel



RiceReg = imgData(:,1800:3500,:);
RImg = RiceReg(:,:,1);
RImg = imclearborder(RImg);
[m n] = size(RImg);
TempImg(:,:,1)=RImg;
TempImg(:,:,2) = zeros(m,n);
TempImg(:,:,3) = zeros(m,n);
figure
subplot(141)
imshow(uint8(TempImg));
%axis image;
%colormap hot
title('R channel');
pause
%% background image

background = imopen(RImg,strel('disk',65));
min(min(background))
max(max(background))
I2 = (RImg - background)/255;
subplot(142)
imagesc(I2)
axis image;
title('Background Subtration Result');


thresh= graythresh(I2);
bw = im2bw(I2,thresh);



%%% tunining result
%bw = imfill(bw,'holes');
bw = medfilt2(bw, [9 9]);
bw = bwareaopen(bw, 200);


subplot(143)
imshow(bw)
ss = sprintf('Threshold = %5.2f',thresh);
title(ss,'fontsize',14)

edgeImg = edge(bw,'canny',[0.4 0.7]);
se = strel('disk',3);
edgeImg = imdilate(edgeImg,se);
origRice = reshape(RiceReg,[m*n 3]);
idx = find(edgeImg ==1);
origRice(idx,1) = 255;
origRice(idx,2) = 255;
origRice(idx,3) = 255;

origRice = reshape(origRice,[m n 3]);
subplot(144)
imshow(uint8(origRice),[])

pause
%% write bw to file
imwrite(bw,strcat(resultfolder,filename,'_mask.png'),'png');

%% extract spatial feature from mask file

imgMask=bw;
Riceidx  = find(imgMask > 0);

L = bwlabel(imgMask); 
nRice = max(max(L));
    
[m n] = size(L);
t=1;

%figure(333)

if nRice == 48
else
    fprintf(1,'PLEASE CHECK MASK IMAGE; TOTAL SEED NOT EQUAL 48\n');
end

for i=1:nRice
    bw = zeros(m,n);
    idx = find(L == i);
    bw(idx) = 1;
    s  = regionprops(bw, 'all');
    shape_fea = [   s.Area s.MajorAxisLength s.MinorAxisLength ...
                        s.MinorAxisLength/s.MajorAxisLength s.Perimeter/s.Area s.Eccentricity];
    spatialMat(i,:) = shape_fea;
    fprintf(1,'extracting riceIDX =%d\n',i);
    figure(222)
    imshow(bw,[])
    pause
    
end

save(strcat(resultfolder,filename,'_spatialFeat.mat'),'spatialMat');
length(spatialMat)
format short g
mean(spatialMat,1)

