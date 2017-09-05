%%% extract rice pixel from hypercube data
function [Riceidx imgFine] = extractRice_HSI256(Inorm)

   % close all
     
    %%% extract rice pixel
    imgFine  = extractMask(Inorm);
    Riceidx  = find(imgFine > 0);
end
    
    
   
%% now we will extract mask
function imgFine= extractMask(Inorm)
    
    img1    = Inorm(:,:,150);
    img2    = Inorm(:,:,100);
    img3    = 1-log(img2).*log(img1); % for data on Jan 25
    
    %img3 = log(img2)./log(img1);        %% for data on JAn 19
    maxVal  = max(max(img3));
    minVal  = min(min(img3));
    imgNorm =(img3-minVal)/(maxVal-minVal);
    
    imgMask = postprocessing(imgNorm);
    imgFine = preprocessing(imgMask);
end
%     figure
%     subplot(121)
%     imshow(imgFine,[])
%     
%     subplot(122)
%     imgEdge = edge(imgFine,'canny');
%     idx = find(imgEdge > 0);
%     Itemp =Inorm(:,:,100);
%     Itemp(idx) = 1;
%     imshow(Itemp,[])
%     title('Wavelength at band 100');
%     
%     pause
  
function bw = postprocessing(I)
   
    
    background = imopen(I,strel('disk',15));
    I2 = I - background;
    level = graythresh(I2)*1.4;  %%% for data captured on 25 jan scale is 1.4
    bw = im2bw(I2,level);
    %bw(:,1:30) = 0;
    bw = bwareaopen(bw, 100);
end
    
    
function imgFine = preprocessing(imgMask)

    imgFine = medfilt2(imgMask); 
    imgFine = imclearborder(imgFine,18);
    
 %   imgFine(:,261:end) = 0; %% apply for rice image only
    
    L = bwlabel(imgFine); 
    nRice = max(max(L)); 
    
    if nRice == 32 || nRice == 48
    else
        imgMask(:,1:30) = 0;
        for i = 0:nRice
            idx = find(L == i);
            if size(idx) < 100
                imgMask(idx) = 0;
            end
        end
%         imgMask = bwareaopen(imgMask, 100);
        imgFine = preprocessing(imgMask);
        fprintf(1,'PAY ATTENTION PLESE nrice = %d\n',nRice);
%         pause
    end
end
    
    
    