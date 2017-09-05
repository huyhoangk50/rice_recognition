%%% extract feature based on HSI2
%%%
%%%
%%% applying for HSI visible system 8 bit (256 values in gray scale)
function extractSpecImage_HSI256(folder, filename)

 close all
 Envisetup
 global datafolder
 global resultfolder
 global CAMERA
 global NORMALIZATION
 global darkfilename;
imageRow = 48;
imageCol = 48;
% global fullfilename
fullfilename = char(strcat(datafolder,folder, '/', filename));

[I,info]=GenericHSILoad(fullfilename);
 
nband = info.bands;
wavelengthbands = info.Wavelength;
% clearvars info
 if strcmp(CAMERA, 'HSI256')
     validband = 55:220;
     if max(wavelengthbands) < 512
        load(('WL256'),'WL');
        wavelengthbands = WL;
     end
 end
   

 if NORMALIZATION ==1
        Idark            =   GenericHSILoad(char(strcat(datafolder, folder, '/', darkfilename)));
        %%% get mean val of Idark
        for i=1:nband
            darkVal(i,:) = double(mean(Idark(:,:,i),1));
        end
        [~, Inorm]         =   normalization(I,info,darkVal);
 else
        Inorm = double(I);
 end
% clearvars Idark darkVal info;
[~, Ismooth] = preprocessingHypeCube(Inorm);

[~, imgMask]  =   extractRice_HSI256(Inorm);

%     Riceidx  = find(imgMask > 0);

L = bwlabel(imgMask); 
% clearvars imgMask Inorm;
nRiceperRow = 8;
% figure
% imshow(L);
% pause()
L = rearrangericeidx(L,nRiceperRow);

nRice = max(max(L));
[m, n] = size(L);
for i=1:nRice
    
    idx = find(L == i);
    divs = floor(idx/m);
    minCol = min(divs);
    maxCol = max(divs);
    midCol = floor((minCol + maxCol)/2);
    
    mods = mod(idx, m);
    minRow = min(mods);
    maxRow = max(mods);
    midRow = floor((minRow + maxRow)/2);
    if midCol < (imageCol/2 + 1)
        midCol = (imageCol/2 + 1);
    end
    if midRow < (imageRow/2 + 1)
        midRow = (imageRow/2 + 1);
    end
    
    if midCol > (n - imageCol/2)
        midCol = (n - imageCol/2);
    end
    if midRow > (m - imageRow/2)
        midRow = (m - imageRow/2);
    end
    fullspecData = Ismooth(midRow -imageRow/2: midRow + imageRow/2 -1, midCol -imageCol/2:midCol + imageCol/2 -1, :);
    a = [1:24] * 10;
    specData = fullspecData(:,:,a);
%     bar(fullspecData(:,:,100))
    mkdir(strcat(resultfolder,'jpg/', filename))
%    imwrite(fullspecData(:,:,100),strcat(resultfolder,'jpg/', filename,'/', num2str(i),'.jpg'));
%     figure(222)
%     subplot(221)
%     imshow(fullspecData(:,:,100),[]);
%     pause(0.05)
    path = strcat(resultfolder, 'short_specData/',filename,'/');
    mkdir(path)
    save(strcat(path, num2str(i), '_spec.mat'),'specData');

end
% bar(L)
%imwrite(L,strcat(resultfolder,'jpg/', filename,'_fullricespec.jpg'));
% clear
end
% length(fullspecData)
% length(Riceidx)
    
function L = rearrangericeidx(Lorig,nRiceperRow)

    %%% rotate Lorig first
   
    nRice = max(max(Lorig));
    [m, n] = size(Lorig);
    
    L = zeros(m,n);
    startseed = 1;
    newriceidx=1;
    
    for i=1:nRiceperRow:nRice
        endseed = startseed+nRiceperRow-1;
        
        for j=startseed:endseed
            riceImg = zeros(m,n);
            idx = Lorig==j;
            riceImg(idx) = 1;
            s  = regionprops(riceImg, 'centroid');
            centerpoint(j,:) = floor(cat(1, s.Centroid));
            seedIDX(j-startseed+1) = j;
        end
        
        %%% sort centerpoint 
        [~, ridx] = sort(centerpoint(startseed:endseed,2));
        for t=1:length(ridx)
            idx = Lorig==seedIDX(ridx(t));
            L(idx) = newriceidx;
            newriceidx =newriceidx+1;
        end
        startseed =endseed+1;
    end
end    
