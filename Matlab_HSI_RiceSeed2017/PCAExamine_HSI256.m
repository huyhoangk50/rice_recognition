function PCAExamine_HSI256(filename)
    close all
    %'AllFourRice_refl'
    %datafolder = 'C:\Vu Hai Project\riceseed\16Dec\';
    Envisetup;
    global datafolder;
    global resultfolder;
    [I,info]            =   GenericHSILoad(strcat(datafolder,filename));
    
    %%% darkfile %%% depend on the time we take the data
    %darkfilename = 'darkref28_frame_0';
    darkfilename = 'darkref_feb5_0';
    Idark            =   GenericHSILoad(strcat(datafolder,darkfilename));
    
    nband = info.bands;
    
    %%% get mean val of Idark
    for i=1:nband
        darkVal(i,:) = double(mean(Idark(:,:,i),1));
    end
    
    %%% normalization data
     wavelengthbands = info.Wavelength;
     validband = 55:220;
     wlen = wavelengthbands(validband);
     
    [I, Inorm]         =   normalization(I,info,darkVal);
    
    Ivalid = Inorm(:,:,validband);
    
     %%% preprocessing data now
    [Igauss Ismooth] = preprocessingHypeCube(Inorm);
     %%% it should be Ismooth or Igauss because data already preprocessed
    [Riceidx RicemaskImg]  =   extractRice_HSI256(Ismooth);
    
    
    [m n nband] = size(Ivalid);
    
    IData = reshape(Ivalid,[m*n nband]);
    
    prinCompMat = princomp(IData(Riceidx,:));
    projectedData = zeros(m*n,5);
    projectedData(Riceidx,:) = IData(Riceidx,:)*prinCompMat(:,1:5);
    projectedData = reshape(projectedData,[m n 5]);
    figure
    for i=1:3
        subplot(1,3,i)
        imagesc(projectedData(:,:,i));
        axis image
        colormap bone
        pause
    end