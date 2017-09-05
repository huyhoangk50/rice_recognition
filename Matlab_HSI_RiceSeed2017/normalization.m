%%%    plotWeights(RGBWeights,wavelengthbands);
    
function [I, Inorm] = normalization(Iorig,info,darkVal)

    global datafolder
    
    %%% show white region to check
    Itemp = Iorig(:,:,80);
    [WhiteReg RiceReg] = whiteRegDection(Itemp);
    Iwhite = Iorig(WhiteReg,:,:);
    
%%% extract sample regions
    I = double(Iorig(RiceReg,:,:));
    nband = size(I,3);
    
    for i=1:nband
        whiteval(i,:) = double(mean(Iwhite(:,:,i),1));
    end
    
    %%% now we will normalized data
    [nline ncol nband] = size(I);

    %%% replicate whiteval to be easy doing normalize data
    for i=1:nband
        whitemat(:,:,i) = repmat(whiteval(i,:),[nline 1]);
        darkmat(:,:,i)  = repmat(darkVal(i,:), [nline 1]);
        %% flip lr original image
        %I(:,:,i) = fliplr(I(:,:,i));
    end

    %%% normalize data now
    Inorm = (I-darkmat)./(whitemat-darkmat);
   
    % for i=1:nband
    %    Inorm(:,:,i) = fliplr(Inorm(:,:,i));
    % end
    %%% Illumination normalization
%     Inorm2 = zeros(nline,ncol,nband);
%     
%      for i=1:nband
%          for j=1:nline
%              Inorm2(j,:,i) = Inorm(j,:,i)(mean(Inorm(j,:,i)));
%          end
%      end
%      
%    
%     Inorm = Inorm2;
    %%% it should be carefully check Inorm values is nan or infinite
    %%% reset it to 0
    idx = find(isnan(Inorm) == 1);
    Inorm(idx) = 0;
    
    clear idx;
    idx = find(~isfinite(Inorm) == 1);
    Inorm(idx) = 0;
    
    %%% reset all of value > 1 to be 1 
    idx = find(Inorm > 1);
    Inorm(idx) = 1;
    
    %%% reset all of value < 0 to be 0
    idx = find(Inorm < 0);
    Inorm(idx) = 0;
   
   
    

    
function [WhiteReg RiceReg] = whiteRegDection(Itemp)
    h = fspecial('gaussian',[5 5],2.5)
    Iorig = Itemp;
    Itemp = imfilter(Itemp,h);
    minVal = min(min(Itemp));
    maxVal = max(max(Itemp));
    Itemp = (Itemp - minVal)./(maxVal - minVal);
    se = strel('disk',3);
    Itemp = imdilate(Itemp,se);
    
    CC = bwconncomp(Itemp);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [biggest,idx] = max(numPixels);
    [m n] = size(Itemp);
    bw = zeros(m,n);
    
    bw(CC.PixelIdxList{idx}) = 1;
    s = regionprops(bw,'BoundingBox','Centroid' )
    c = floor(s.Centroid);

    
    WhiteReg = c(2)-30:c(2)+30;
    
    WhitetitleBox = floor(s.BoundingBox);
    pad = 5;
    %%% for data in March 09
    %pad = 50;
    %RiceReg = WhitetitleBox(4)+WhitetitleBox(2)+pad:m;
    RiceReg = 1:WhitetitleBox(2)-pad;
    %[row col] = meshgrid(c(1)-floor(n/2)+10:c(1)+floor(n/2)-100,WhiteReg);
%     [row col] = meshgrid(1:n,WhiteReg);
%     idx = sub2ind([m n],col,row);
%     bw(idx) = 2;
%     
%     
%     [row col] = meshgrid(1:n,RiceReg);
%     idx = sub2ind([m n],col,row);
%     bw(idx) = 3;
%     
%     RGB = label2rgb(bw);
%     figure
%     subplot(121)
%     imagesc(RGB)
%     axis image
%     hold on
%     rectangle('Position', WhitetitleBox);
%     
%     subplot(122)
%     imagesc(Iorig)
%     axis image;
%     pause
    
    
        
    
    