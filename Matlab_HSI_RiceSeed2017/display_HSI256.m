function display_HSI256(filename)

 close all
 Envisetup
 global datafolder
 
 fullfilename = strcat(datafolder,filename);
 
 [I,info]=GenericHSILoad(fullfilename);

%% get white title reference
%%

Iwhite = I(70:170,:,:);
nband = info.bands;
wavelengthbands = info.Wavelength;

for i=1:nband
    whiteval(i,:) = double(mean(Iwhite(:,:,i),1));
    
end

I = I(200:end,:,:);
%%% now we will normalized data
[nline ncol nband] = size(I);

%%% replicate whiteval to be easy doing normalize data

for i=1:nband
    whitemat(:,:,i) = repmat(whiteval(i,:),[nline 1]);
end

%%% normalize data now
Inorm = double(I)./whitemat;


%%% smooth data in term of wavelength
nNeighbour = 7;
halfwindow = floor(nNeighbour/2);

Ismooth = Inorm;
for i=halfwindow+1:nband-halfwindow
    Ismooth(:,:,i) = mean(Inorm(:,:,i-halfwindow:i+halfwindow),3);
end

%%% then finally, smooth in term of spatial
%H = fspecial('gaussian',HSIZE,SIGMA)
gw = fspecial('gaussian',[5 5],2.5);
for i=1:nband
    Igauss(:,:,i) = imfilter(Ismooth(:,:,i),gw);
end

% hh = figure(222)
% set(hh,'Position',[100 100 1200 800]);
% ax1 = subplot(141);
% ax2 = subplot(142);
% ax3 = subplot(143);
% ax4 = subplot(144);

% for i=1:nband
%     axes(ax1);
%     imagesc(I(:,:,i));
%     axis image;
%     title('Original');
%     
%     axes(ax2)
%     imagesc(Inorm(:,:,i));
%     axis image;
%     title('Normalized Data');
%     
%     axes(ax3)
%     imagesc(Ismooth(:,:,i));
%     axis image;
%     title(strcat('Smoothed wavelength=', num2str(i)));
%     
%     axes(ax4)
%     imagesc(Igauss(:,:,i));
%     axis image;
%     title('Smoothed spatial');
%     
%    % pause(0.02);
%     
% end



%%% now we will extract mask
img1 = Igauss(:,:,150);
img2 = Igauss(:,:,100);



img3 = 1-log(img2).*log(img1);
maxVal = max(max(img3));
minVal = min(min(img3));
imgNorm = (img3-minVal)/(maxVal-minVal);
    
    
figure
subplot(131)
imagesc(img1);axis image

subplot(132)
imagesc(img2);axis image

subplot(133)
imagesc(imgNorm);axis image

imgMask =postprocessing(imgNorm);
imgFine = preprocessing(imgMask);

edgeImg = edge(imgFine,'canny');
   
idx = find(edgeImg==1);
imgNorm(idx) = max(max(imgNorm));
    
    
h = figure;
set(h,'Position',[100 100 1000 800]);
ax1 = subplot(121);
ax2 = subplot(122);
    
axes(ax1);
imagesc(imgNorm)
axis image
colormap summer
axes(ax2);
imagesc(imgFine)
axis image


function bw = postprocessing(I)

    background = imopen(I,strel('disk',25));
    I2 = I - background;
    level = graythresh(I);
    bw = im2bw(I,level);
    bw = bwareaopen(bw, 50);



function imgFine = preprocessing(imgMask)

    imgFine = medfilt2(imgMask); 
    imgFine = imclearborder(imgFine);