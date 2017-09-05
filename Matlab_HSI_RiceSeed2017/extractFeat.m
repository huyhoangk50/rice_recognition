%%% Extract spatial and spectral feature
%%% 

function featAll = extractFeat(filename)

%%% load spetral data
    close all
    Envisetup;
    global datafolder;
    global resultfolder;
   % [I,info]            =   GenericHSILoad(strcat(datafolder,filename));
   % [Igauss, I]         =   normalization(I,info);
    
%%%% load RiceMask and ImgDisp 

    imgXYZ      = imread(strcat(resultfolder,filename,'_rgb.png'));
    imgGray     = imread(strcat(resultfolder,filename,'_gray.png'));
    imgNIRGB    = imread(strcat(resultfolder,filename,'_nirgb.png'));
    imgKmean    = imread(strcat(resultfolder,filename,'_kmean.png'));
    imgPCA      = imread(strcat(resultfolder,filename,'_pca.png'));
    imgOIF      = imread(strcat(resultfolder,filename,'_oif.png'));
    RiceMaskImg = imread(strcat(resultfolder,filename,'_mask.png'));
    
    %%% load spec data
    load(strcat(resultfolder,filename,'_spec.mat'),'Ivalid');
    
%%% extract spatial feature of each rice seed
    spatialMat = extractSpatial(RiceMaskImg);
    
%%% extract texture feature of each rice seed
    [textureMat histoMat] = extractTexture(imgGray, RiceMaskImg);

%%% extract color feature
    colorMat1 = extractColor(imgNIRGB,RiceMaskImg);
    
    colorMat2 = extractColor(imgXYZ,RiceMaskImg);
    
    colorMat3 = extractColor(imgPCA,RiceMaskImg);
    
%%% spetral extraction
    spectralData = extractSpec(Ivalid,RiceMaskImg);
    
    %dump spatialMat textureMat  histoMat colorMat into a mat file
    size(spectralData)

    pause
    
    featAll = [spatialMat colorMat1 colorMat2 colorMat3 textureMat spectralData];
    
    size(featAll)
    pause
%%% stpore featAll into a mat file
    save(strcat(resultfolder,filename,'_featAll.mat'),'featAll');
    
    
%%% extract spetral data
function spectralData = extractSpec (I,RiceMaskImg)
    [m n nband] = size(I);
    L = bwlabel(RiceMaskImg); 
    nRice = max(max(L));     
    imgSPD = RGB2XWFormat(I);
    dipImg = zeros(m,n);
    for i=1:nRice
        idx = find(L == i);
        riceImg = zeros(m,n);
        
        riceImg(idx) = 1;
        
        s  = regionprops(riceImg, 'centroid');
        c = floor(cat(1, s.Centroid));
        [row col] = meshgrid(c(1)-3:c(1)+3,c(2)-3:c(2)+3);
        idx2 = sub2ind([m n],col,row);
        
        riceImg(idx2) = 2;
        dipImg = dipImg + riceImg;
        RGB = label2rgb(dipImg);
        spectralData(i,:) = mean(imgSPD(idx2,:),1);
    end
    
    figure(55)
    imshow(RGB)
    pause
    
   
    
    
    
function spatialMat = extractSpatial(imgMask)
    L = bwlabel(imgMask); 
    nRice = max(max(L));        %%% total rice seed in a captured image
    
    [m n] = size(imgMask);
    
    for i=1:nRice
        bw = zeros(m,n);
        idx = find(L == i);
        bw(idx) = 1;
        s  = regionprops(bw, 'all');
        shape_fea = [   s.Area s.MajorAxisLength s.MinorAxisLength ...
                        s.MinorAxisLength/s.MajorAxisLength s.Perimeter/s.Area s.Eccentricity];
       % shape_fea = (shape_fea - min(shape_fea))/(max(shape_fea) - min(shape_fea));
        spatialMat(i,:) = shape_fea;
    end
    
    %%% normalize data into [0 .. 1] for each dimension
    %maxVal = max(spatialMat,[],1);
    %minVal = min(spatialMat,[],1);
    
    %maxMat = repmat(maxVal,[nRice 1]);
    %minMat = repmat(minVal,[nRice 1]);
    
    %spatialMat = (spatialMat-minMat)./(maxMat - minMat);
    fprintf(1,'size of spatial Mat = %d \t %d\n',size(spatialMat,1),size(spatialMat,2));
    

function [textureMat histoMat] = extractTexture(IDisp, imgMask)
    
        L = bwlabel(imgMask); 
        nRice = max(max(L));        %%% total rice seed in a captured image
    
        [m n] = size(imgMask);
        

        
        for i=1:nRice
            
            idx = find(L == i);
            [hist_gray, xx] = imhist(IDisp(idx),256);
            intensity = xx';
            
            hist_gray = hist_gray/length(idx);            
            histoMat(i,:) = hist_gray';
            
            mean_hist_gray = linspace(0,1,256)*hist_gray;
            in_z = intensity - mean_hist_gray;
            in_z = in_z.*in_z.*in_z;
            third_moment(i,:) = in_z*hist_gray;
            U_gray(i,:) = mean(mean(hist_gray*hist_gray'));
            sd_gray_val = double(IDisp(idx)) - mean_hist_gray;
            sd_gray(i,:) = mean(mean(sd_gray_val*sd_gray_val'));
        end
        
        textureMat = [sd_gray third_moment];
        
        %%% normalize data into [0 .. 1] for each dimension
        maxVal = max(textureMat,[],1);
        minVal = min(textureMat,[],1);
    
        maxMat = repmat(maxVal,[nRice 1]);
        minMat = repmat(minVal,[nRice 1]);
        
        textureMat = (textureMat-minMat)./(maxMat - minMat);
        
function colorMat = extractColor(IDisp,imgMask)
        L = bwlabel(imgMask); 
        nRice = max(max(L));        %%% total rice seed in a captured image
        [m n] = size(imgMask);
        IDisp = reshape(IDisp,[m*n 3]);
        for i=1:nRice
            idx = find(L == i);
            meanc1 = mean((IDisp(idx,1)));
            meanc2 = mean((IDisp(idx,2)));
            meanc3 = mean((IDisp(idx,3)));
            
            colorMat(i,:) = [meanc1 meanc2 meanc3 ...
                            std(double(IDisp(idx,1))) std(double(IDisp(idx,2))) std(double(IDisp(idx,3)))];
            clear idx;
        end
        colorMat = colorMat;
        
function spectralMat = extractSpectral(I,riceMask)
    
