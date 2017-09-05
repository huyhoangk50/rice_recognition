%%% generate RGB from Hypercube data
function generateRGB_HSI256(filename)
    close all
    %'AllFourRice_refl'
    %datafolder = 'C:\Vu Hai Project\riceseed\16Dec\';
    Envisetup;
    global datafolder;
    global resultfolder;
    global CAMERA;
    global NORMALIZATION;
    global darkfilename;
    [I,info]            =   GenericHSILoad(strcat(datafolder,filename));
    
    %%% darkfile %%% depend on the time we take the data
%     darkfilename = 'darkref28_frame_0';
%     %darkfilename = 'darkref_feb5_0';
%     Idark            =   GenericHSILoad(strcat(datafolder,darkfilename));
    
    
    nband = info.bands;
    
    
%     %%% get mean val of Idark
%     for i=1:nband
%         darkVal(i,:) = double(mean(Idark(:,:,i),1));
%     end
    
    %%% normalization data
     wavelengthbands = info.Wavelength;
    
     
   
   
   if strcmp(CAMERA, 'HSI256')
     validband = 55:220;
     if max(wavelengthbands) < 512
        load(('WL256'),'WL');
        wavelengthbands = WL;
     end
     
     wlen = wavelengthbands(validband);
     
   end
   
   if strcmp(CAMERA, 'NIR')
     validband = 1:256;
     wlen = wavelengthbands(validband);
   end
   
   
     
    %[I, Inorm]         =   normalization(I,info,darkVal);
    
    
    if NORMALIZATION ==1
        %darkfilename = 'darkref28_frame_0';
        %darkfilename = getdarkfile(filename);
        Idark            =   GenericHSILoad(strcat(datafolder,darkfilename));
        %%% get mean val of Idark
        for i=1:nband
            darkVal(i,:) = double(mean(Idark(:,:,i),1));
        end
        [I, Inorm]         =   normalization(I,info,darkVal);
    else
        Inorm = double(I);
    end
    
    Ivalid = Inorm(:,:,validband);
    %%% preprocessing data now
    [Igauss, Ismooth] = preprocessingHypeCube(Inorm);
    
    %%% it should be Ismooth or Igauss because data already preprocessed
    [Riceidx RicemaskImg]  =   extractRice_HSI256(Ismooth);
    
   
    
    imgGray     = generateGrayScale(Ivalid,wlen);
    imgOIF      = genChavezImg(Ivalid,wlen,Riceidx);
    
    %%% display in RGB color scape
    %%% it could be either Inorm, Igauss or Ismooth
    RGBImg      = generateRGB(Ivalid,wlen);
    DensityImg  = generateDensity(Ivalid,wlen);
    
    figure
    imagesc(DensityImg);
    axis image;

    
    imgNIRGB    = generateNIRGB(Ivalid,wlen);
    imgKmean    = genKmeansImg(Ivalid,wlen,Riceidx);
    imgPCA      = genPCAImg(Ivalid,wlen,Riceidx);    %%% previous Igauss
   
    
%     temp1 = im2bw(rgb2gray(imgKmean),0.2);
%     figure
%     imshow(temp1,[]);
%     pause
%     RicemaskImg = RicemaskImg.*temp1;
 
    
    figure
    set(gcf,'Position',[100 100 1800 800]);
    subplot(161)
    imagesc(RGBImg)
    title('RGB Image');
    axis image
    
    subplot(162)
    imagesc(imgGray)
    title('GrayScale');
    axis image
    
    subplot(163)
    imagesc(imgNIRGB)
    title('Near IR');
    axis image
    
    
    subplot(164)
    imagesc(imgKmean)
    title('Kmean image');
    axis image
    
    subplot(165)
    imagesc(imgPCA)
    title('PCA Image');
    axis image
    
    subplot(166)
    imagesc(imgOIF)
    title('Weight Factor');
    axis image
    
    
    %%% save into result folder
    %%% filename_type.png
    imwrite(RGBImg,strcat(resultfolder,filename,'_rgb.png'),'png');
    imwrite(imgGray,strcat(resultfolder,filename,'_gray.png'),'png');
    imwrite(imgNIRGB,strcat(resultfolder,filename,'_nirgb.png'),'png');
    imwrite(imgKmean,strcat(resultfolder,filename,'_kmean.png'),'png');
    imwrite(imgPCA,strcat(resultfolder,filename,'_pca.png'),'png');
    imwrite(imgOIF,strcat(resultfolder,filename,'_oif.png'),'png');
    imwrite(RicemaskImg,strcat(resultfolder,filename,'_mask.png'),'png');
    
    %%% save spec data
    save(strcat(resultfolder,filename,'_spec.mat'),'Ivalid');
%%% Generate gray scale image from hypercube data
function imgGray = generateGrayScale(I,wlen)
        % equal weights to all wavelengths
    wavelengthbands = wlen;
    nband = size(I,3);
    RGBWeights = ones(nband, 3);
    % normalize weights
    RGBWeights = RGBWeights*...
                             diag(1./sum(RGBWeights));
    imgSPD = double(RGB2XWFormat(I));
    imgGray = imgSPD*RGBWeights;
    
    
    % scale scene between 0 and 1
    imgGray = ieClip(imgGray,  [], 255);
    currMaxPixVal = max(imgGray(:));
    if currMaxPixVal ~= 0
        imgGray = imgGray/currMaxPixVal;
    end
    
    nrow = size(I,1);
    ncol = size(I,2);
    imgGray = reshape(imgGray,[nrow ncol 3]);


%%% generate OIF image

function imgOIF = genChavezImg(I,wlen,Riceidx)

[rows cols bands] = size(I);
imgSPD = single(RGB2XWFormat(I));

groupWaves = 4;
nSamples = length(Riceidx);
randSamples = imgSPD(Riceidx,:);
wLen = bands;

tmp = zeros(nSamples, floor(wLen/groupWaves));
for k = groupWaves:groupWaves:wLen
    tmp(:, k/groupWaves) =...
        sum(randSamples(:, k-groupWaves+1:k), 2);
end
randSamples = tmp;

% Pearson's correlation coefficient
corrCoeffMat = abs(corrcoef(randSamples)); 
% stdMat = std(randSamples./repmat(mean(randSamples), [nSamples 1]));
stdMat = std(randSamples);
maxVal = 0;
for r = 1:floor(wLen/groupWaves)
    for g = 1:floor(wLen/groupWaves)
        for b = 1:floor(wLen/groupWaves)
            % make sure no same-wavelength channels are chosen
            if (r == g || g == b || r == b)
                continue;
            end
            % original method
%             optIndexFactor = (stdMat(r)+stdMat(g)+stdMat(b))/...
%                              (corrCoeffMat(r, g)* ...
%                               corrCoeffMat(r, b)* ...
%                               corrCoeffMat(g, b));
            optIndexFactor = (stdMat(r)+stdMat(g)+stdMat(b))/...
                             (max([corrCoeffMat(r, g) ...
                              corrCoeffMat(r, b) ...
                              corrCoeffMat(g, b)]));
            if (optIndexFactor > maxVal)
                optR = r;
                optG = g;
                optB = b;
                maxVal = optIndexFactor;
            end
        end
    end
end

idx = sort([optB optG optR], 'descend');
RGBWeights = zeros(wLen, 3);
RGBWeights(idx(1)*groupWaves-groupWaves+1:idx(1)*groupWaves, 1) = 1;
RGBWeights(idx(2)*groupWaves-groupWaves+1:idx(2)*groupWaves, 2) = 1;
RGBWeights(idx(3)*groupWaves-groupWaves+1:idx(3)*groupWaves, 3) = 1;
RGBWeights = RGBWeights*...
                          diag(1./sum(RGBWeights));

imgDisp = zeros(rows*cols,3);
imgDisp(Riceidx,:) = imgSPD(Riceidx,:)*RGBWeights;
% scale scene between 0 and 1
imgDisp = ieClip(imgDisp, 0, []);
currMaxPixVal = max(imgDisp(:));
if currMaxPixVal ~= 0
    imgDisp = imgDisp/currMaxPixVal;
end

imgOIF = reshape(imgDisp,[rows cols 3]);



    
%%% generate PCA Image

function imgPCA = genPCAImg(I,wlen,Riceidx)

wavelengthbands = wlen;

[rows cols bands] = size(I);
imgSPD = single(RGB2XWFormat(I));


prinCompMat = princomp(imgSPD(Riceidx,:));

% extract three highest-variance components and map to R, G, B
RGBWeights = ([prinCompMat(:, 1) prinCompMat(:, 2) prinCompMat(:, 3)]);
maxPCAWeights = max(RGBWeights);
minPCAWeights = abs(min(RGBWeights));
RGBWeights = RGBWeights*diag(-2*(minPCAWeights > maxPCAWeights)+1);
RGBWeights = RGBWeights*diag(1./sum(RGBWeights));

imgDisp = zeros(rows*cols,3);
imgDisp(Riceidx,:) = imgSPD(Riceidx,:)*RGBWeights;

% scale scene between 0 and 1
imgDisp = ieClip(imgDisp, 0, []);
currMaxPixVal = max(imgDisp(:));
if currMaxPixVal ~= 0
    imgDisp = imgDisp/currMaxPixVal;
end

imgPCA = reshape(imgDisp,[rows cols 3]);
%plotWeights(RGBWeights,wlen);
%fprintf(1,'plot PCA\n');
%%% Generate Kmeans Image

function imgKmean =  genKmeansImg(I,wlen,Riceidx)

[rows cols bands] = size(I);

imgSPD = single(RGB2XWFormat(I));
randSamples = imgSPD(Riceidx,:);

% run the kmeans clustering
idx = kmeans(randSamples', 3);

first1 = find(idx == 1, 1, 'first');
first2 = find(idx == 2, 1, 'first');
first3 = find(idx == 3, 1, 'first');
ord = sort([first1 first2 first3], 'ascend');

RGBWeights = [(idx == idx(ord(3))) (idx == idx(ord(2))) (idx == idx(ord(1)))];
RGBWeights = RGBWeights*...
                          diag(1./sum(RGBWeights));

imgDisp = zeros(rows*cols,3);
imgDisp(Riceidx,:) = imgSPD(Riceidx,:)*RGBWeights;

% scale scene between 0 and 1
imgDisp = ieClip(imgDisp, 0, []);
currMaxPixVal = max(imgDisp(:));
if currMaxPixVal ~= 0
    imgDisp = imgDisp/currMaxPixVal;
end
imgKmean = reshape(imgDisp,[rows cols 3]);
%wavelengthbands = wlen;
%plotWeights(RGBWeights,wavelengthbands);
%fprintf(1,'plot Kmeans\n');
%pause

%%% Generate Near IR and RGB image from hypercube data
function imgNIRGB = generateNIRGB(I,wlen)
    wavelengthbands = wlen;
    nband = size(I,3); 
    RGBWeights = zeros(nband, 3);
    wl = 400:10:950;
    tmp(:, 1) = bitand((wl(:) >= 700), (wl(:) < 950));
    tmp(:, 2) = bitand((wl(:) >= 500), (wl(:) < 700));
    tmp(:, 3) = bitand((wl(:) >= 400), (wl(:) < 500));
    for k = 1:3
        RGBWeights(:, k) = interp1(wl, double(tmp(:, k)), ...
                                           wavelengthbands, ...
                                           'linear', 0);
    end

    % normalize the weights 
    RGBWeights = RGBWeights*...
                         diag(1./sum(RGBWeights));

    imgSPD =  single(RGB2XWFormat(I));
    imgDisp = imgSPD*RGBWeights;

    % scale scene between 0 and 1
    imgDisp = ieClip(imgDisp, 0, []);
    currMaxPixVal = max(imgDisp(:));
    if currMaxPixVal ~= 0
        imgDisp = imgDisp/currMaxPixVal;
    end
        
    nrow = size(I,1);
    ncol = size(I,2);
    imgNIRGB = reshape(imgDisp,[nrow ncol 3]);

 %   plotWeights(RGBWeights,wavelengthbands);
 %   fprintf(1,'plot NIRGB\n');
 %   pause

%%% Generate Streckted bands
function imgXYZStretched = genStretchedXYZImg(I,wlen)

    wavelengthbands = wlen;
    nband = size(I,3); 
    imgSPD =  single(RGB2XWFormat(I));
    
    RGBWeights = zeros(nband, 3);
    thr  = 0;
    % By default, the wavelengths from 400-490 add to the blue channel, from
    % 500-570 add to the green channel, and 580-700 add to the red channel
     wl = 400:10:700;
     tmp(:, 1) = bitand((wl(:) >= 580), (wl(:) < 700));
     tmp(:, 2) = bitand((wl(:) >= 500), (wl(:) < 570));
     tmp(:, 3) = bitand((wl(:) >= 400), (wl(:) < 490));
     for k = 1:3
            RGBWeights(:, k) = ...
                interp1(wl, double(tmp(:, k)), ...
                        wavelengthbands, ...
                        'linear', 0);
     end

     
    rMinInd = find(RGBWeights(:, 1) > thr, 1, 'first');
    gMinInd = find(RGBWeights(:, 2) > thr, 1, 'first');
    bMinInd = find(RGBWeights(:, 3) > thr, 1, 'first');

    rMaxInd = find(RGBWeights(:, 1) > thr, 1, 'last');
    gMaxInd = find(RGBWeights(:, 2) > thr, 1, 'last');
    bMaxInd = find(RGBWeights(:, 3) > thr, 1, 'last');
    RGBWeights(:, 1) = interp1(rMinInd:rMaxInd, ...
                                 RGBWeights(rMinInd:rMaxInd, 1), ...
                                 linspace(rMinInd, rMaxInd, nband));
    RGBWeights(:, 2) = interp1(gMinInd:gMaxInd, ...
                                 RGBWeights(gMinInd:gMaxInd, 2), ...
                                 linspace(gMinInd, gMaxInd, nband));
    RGBWeights(:, 3) = interp1(bMinInd:bMaxInd, ...
                                 RGBWeights(bMinInd:bMaxInd, 3), ...
                                 linspace(bMinInd, bMaxInd, nband));
    % normalize the weights 
    RGBWeights = ...
                RGBWeights*...
                    diag(1./sum(RGBWeights));

    imgDisp = imgSPD*RGBWeights;
    % scale scene between 0 and 1
	imgDisp = ieClip(imgDisp, 0, []);
    currMaxPixVal = max(imgDisp(:));
    if currMaxPixVal ~= 0
        imgDisp = imgDisp/currMaxPixVal;
    end

    nrow = size(I,1);
    ncol = size(I,2);
    imgXYZStretched = reshape(imgDisp,[nrow ncol 3]);
    
 %   plotWeights(RGBWeights,wavelengthbands);
 %   fprintf(1,'plot xyz\n');
 %   pause
    
%%% Generate XYZ image from hypercube data
function imgDisp = generateRGB(I,wlen)
    
    wavelengthbands = wlen;
    pause
    wl = 400:10:700;
    tmp(:, 1) = bitand((wl(:) >= 580), (wl(:) < 700));
    tmp(:, 2) = bitand((wl(:) >= 500), (wl(:) < 570));
    tmp(:, 3) = bitand((wl(:) >= 400), (wl(:) < 490));
    
    for k = 1:3
            RGBWeights(:, k) = interp1(wl, double(tmp(:, k)), ...
                                                 wavelengthbands, ...
                                                 'linear', 0);
    end
    
    RGBWeights = RGBWeights*...
                       diag(1./sum(RGBWeights));
    imgSPD = single(RGB2XWFormat(I));
   
    imgDisp = imgSPD*RGBWeights;

    % scale scene between 0 and 1
    imgDisp = ieClip(imgDisp, 0, []);
    currMaxPixVal = max(imgDisp(:));
    if currMaxPixVal ~= 0
        imgDisp = imgDisp/currMaxPixVal;
    end
    
    nrow = size(I,1);
    ncol = size(I,2);
    imgDisp = reshape(imgDisp,[nrow ncol 3]);
  
  
%%% Generate XYZ image from hypercube data
function imgDisp = generateDensity(I,wlen)
    
    wavelengthbands = wlen;
    wl = 400:10:800;
    tmp(:, 1) = bitand((wl(:) >= 780), (wl(:) < 800));
    tmp(:, 2) = bitand((wl(:) >= 500), (wl(:) < 520));
    tmp(:, 3) = bitand((wl(:) >= 400), (wl(:) < 500));
    
    for k = 1:3
            RGBWeights(:, k) = interp1(wl, double(tmp(:, k)), ...
                                                 wavelengthbands, ...
                                                 'linear', 0);
    end
    
    RGBWeights = RGBWeights*...
                       diag(1./sum(RGBWeights));
    imgSPD = single(RGB2XWFormat(I));
   
    imgDisp = imgSPD*RGBWeights;

    % scale scene between 0 and 1
    imgDisp = ieClip(imgDisp, 0, []);
    currMaxPixVal = max(imgDisp(:));
    if currMaxPixVal ~= 0
        imgDisp = imgDisp/currMaxPixVal;
    end
    
    nrow = size(I,1);
    ncol = size(I,2);
    imgDisp = reshape(imgDisp,[nrow ncol 3]);
  

    figure
    imagesc(imgDisp)
    axis image
    pause
    
    
  

function plotWeights(currRGBWeights,wavelength)

figure(111);
wavelengthAxes = subplot('Position',[0.1 0.1 0.7 0.4]);

if ~isempty(currRGBWeights)
    axes(wavelengthAxes);
    plot(wavelength, currRGBWeights(:, 1), 'r', ...
         wavelength, currRGBWeights(:, 2), 'g', ...
         wavelength, currRGBWeights(:, 3), 'b', 'LineWidth', 2);
    xlabel('wavelength [nm]');
    grid on;
else
    axes(wavelengthAxes);
    cla;
    xlabel('wavelength [nm]');
    grid on;
end


%%% generate boundary
function srgb = generateBoundary(I,srgb,Riceidx)

    [rows cols bands] = size(I);
    bwImg = zeros(rows,cols);
    bwImg(Riceidx) = 1;
    edgeImg = edge(bwImg,'canny');
    edgeIdx = find(edgeImg == 1);
    srgb = reshape(srgb,[rows*cols 3]);
    srgb(edgeIdx,:) = repmat([1 1 1],length(edgeIdx),1);
    srgb = reshape(srgb,[rows cols 3]);
    figure
    imshow(srgb,[]);
    pause
    
