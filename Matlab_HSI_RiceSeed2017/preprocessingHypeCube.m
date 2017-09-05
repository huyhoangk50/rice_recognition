%%% preprocessing hypercube data
%%%
function [Igauss, Ismooth] = preprocessingHypeCube(Iorig)

    nband = size(Iorig,3);
    
    %%% spatial smoothing based on gaussian function
    gw = fspecial('gaussian',[3 3],1.5);
    Igauss = Iorig;
    
    for i=1:nband
        Igauss(:,:,i) = imfilter(Iorig(:,:,i),gw);
    end
    
    %%% Then smoothing along wavelength
    nNeighbour = 7;
    halfwindow = floor(nNeighbour/2);
    Ismooth = Igauss;
    
    for i=halfwindow+1:nband-halfwindow
       Ismooth(:,:,i) = mean(Igauss(:,:,i-halfwindow:i+halfwindow),3);
    end
    
