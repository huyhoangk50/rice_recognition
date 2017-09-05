%%% extract feature based on HSI2
%%%
%%%
%%% applying for HSI visible system 8 bit (256 values in gray scale)
function extractSpecFeat_HSI256(filename)

 close all
 Envisetup
 global datafolder
 global resultfolder
 global CAMERA
 global NORMALIZATION
 global darkfilename;
 
 fullfilename = strcat(datafolder,filename)

[I,info]=GenericHSILoad(fullfilename);
 
nband = info.bands;
wavelengthbands = info.Wavelength;
 if strcmp(CAMERA, 'HSI256')
     validband = 55:220;
     if max(wavelengthbands) < 512
        load(('WL256'),'WL');
        wavelengthbands = WL;
     end
     
     wlen = wavelengthbands(validband);
     
 end
   

%[Igauss I] = normalization(Iorig);

%imgMask = extractMask(Igauss);

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

 %%% for show band image
%  for i=1:validband
%      
%      figure(555)
%      imagesc(Inorm(:,:,i))
%      axis image;
%      pause
%      
%  end
    Ivalid = Inorm(:,:,validband);
    %%% preprocessing data now
    [Igauss, Ismooth] = preprocessingHypeCube(Inorm);

    [Riceidx, imgMask]  =   extractRice_HSI256(Inorm);

    Riceidx  = find(imgMask > 0);

L = bwlabel(imgMask); 
nRiceperRow = 8;
L = rearrangericeidx(L,nRiceperRow)

nRice = max(max(L));
[m n] = size(L);
t=1;

figure(333)

[rows, cols, bands] = size(I);
Itemp = reshape(Ismooth,[rows*cols bands]);
fullspecData = Itemp(Riceidx,:);

for i=1:nRice
    bw = zeros(m,n);
    idx = find(L == i);
    bw(idx) = 1;
    %specData = zeros(length(idx),nband);
   % if (length(idx) > 100)  && (length(idx) < 600)     %% skip too small region
        figure(222)
        subplot(221)
        imshow(bw,[]);
            
%         for j=1:nband
%             currRiceSeed = double(Ismooth(:,:,j)).*bw;
%             specData(:,j)= currRiceSeed(idx);
%         end
        
        
        
        %imagesc(specData);
        %axis image;
        %colormap hot;
        specData = Itemp(idx,:);
        meanVal = mean(specData,1);
        
        
        
%         for j=1:length(idx)
%             subplot(2,2,2)
%             plot(wavelengthbands,specData(j,:),'-r',...
%                     'linewidth',2);
%             %hold on
%             grid on
%             set(gca,'ylim',[0 0.8]);
%             [row col] = ind2sub([m n], idx(j));
%             subplot(2,2,3)
%             plot(col,row,'ro');
%             hold on
%             
%             pause(0.01)
%         end
        %meanVal = specData(1:4:end,:);
        %meanVal = pcaExtract(specData);
        %stdVal = std(specData,1);

        if t==1
           %A = meanVal;
           fullspecData = meanVal;
        else
           %A = vertcat(A,meanVal);
           fullspecData = vertcat(fullspecData,meanVal);
        end
       
%        
%         subplot(2,2,3)
%          for j=1:t
%             hold on
%             plot(wavelengthbands,fullspecData(j,:),'-r','linewidth',1);
%             grid on
%          end
%         hold off
  
        subplot(2,2,4)
        plot(wavelengthbands,meanVal,'-r','linewidth',1);
        grid on
            
        t=t+1;
        clear specData
        pause(0.01)
   % end
end

save(strcat(resultfolder,filename,'_fullricespec.mat'),'fullspecData');
length(fullspecData)
length(Riceidx)
%fprintf(1,'number of rice %d\n',t-1);


function specFeat = pcaExtract(origData)

    prinCompMat = pca(origData);
    specFeat = origData(1:2:end,:)*prinCompMat(:,1:5);
    
    
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
        [c ridx] = sort(centerpoint(startseed:endseed,2))
        for t=1:length(ridx)
            idx = find(Lorig==seedIDX(ridx(t)));
            L(idx) = newriceidx;
            newriceidx =newriceidx+1;
        end
        startseed =endseed+1;
    end
    
