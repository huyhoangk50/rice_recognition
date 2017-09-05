%% check CCD data

function extractRicefromRGB(filename)

close all
defaultfolder = 'C:\Vu Hai Project\RiceSeed_2017\109_FUJI\';

imgData = imread(strcat(defaultfolder,filename));

figure


ROI = imgData(400:end,1800:3600,:);
imshow(ROI,[]);


Bchannel = double(ROI(:,:,1));

minVal = min(min(Bchannel));
maxVal = max(max(Bchannel));
Bchannel = (Bchannel-minVal)/(maxVal - minVal);

figure
subplot(121)
imagesc(Bchannel)
axis image
[m n] = size(Bchannel);

idx = find(Bchannel > 0.5);
I = zeros(m,n);
I(idx) = 1;
I = medfilt2(I,[5 5]);
subplot(122)
imshow(I,[]);

Imgedge = edge(I,'canny',[0.3 0.7], 2.5);
figure
imshow(Imgedge,[])
