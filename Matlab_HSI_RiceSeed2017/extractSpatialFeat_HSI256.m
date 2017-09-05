%%% extract feature based on HSI2
%%%
%%%
%%% applying for HSI visible system 8 bit (256 values in gray scale)
function extractSpatialFeat_HSI256(filename)

 close all
 Envisetup
 global datafolder
 global resultfolder
 global CAMERA
 global NORMALIZATION
 global darkfilename;
 
 fullfilename = strcat(datafolder,filename);

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

    Ivalid = Inorm(:,:,validband);
    %%% preprocessing data now
    [Igauss, Ismooth] = preprocessingHypeCube(Inorm);

[Riceidx imgMask]  =   extractRice_HSI256(Ismooth);

Riceidx  = find(imgMask > 0);

L = bwlabel(imgMask); 
nRice = max(max(L));
    
[m n] = size(L);
t=1;

figure(333)

[rows cols bands] = size(I);
Itemp = reshape(Ismooth,[rows*cols bands]);

for i=1:nRice
    bw = zeros(m,n);
    idx = find(L == i);
    bw(idx) = 1;
    s  = regionprops(bw, 'all');
    shape_fea = [   s.Area s.MajorAxisLength s.MinorAxisLength ...
                        s.MinorAxisLength/s.MajorAxisLength s.Perimeter/s.Area s.Eccentricity];
    spatialMat(i,:) = shape_fea;
end

save(strcat(resultfolder,filename,'_spatialFeat.mat'),'spatialMat');
length(spatialMat)
length(Riceidx)
