%%%% generate panorama images for validation
%%% input: a list of species; and number of seeds randomly selected
%%% generate a full image

%%% species = {'001_BC15-01' '005_CH12-01' '003_CT286-01'}
%%% nseeds = [16 2 2];

function imgPano = generatePanoImage(posSpecies,validPosSeedIDX,validNegSeedIDX,negSpecies)


%species = {'001_BC15-01' '005_CH12-01' '003_CT286-01'};
global datafolder;
%defaultFolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\VIS\RGBMask\';
nseeds = [16 2 2];
species = [posSpecies  negSpecies];
seedIDX = vertcat(validPosSeedIDX,validNegSeedIDX);
%%% get random between 1 .. 48

%% totalseeds
totalseeds = size(seedIDX,1);
nseedperrow = 5;
nseedpercol = totalseeds/nseedperrow;
seedsPOS = randperm(totalseeds);

imgPano = zeros(nseedpercol*400,nseedperrow*200,3);

for i=1:length(seedIDX)
    currentSpe = species{i};
    currentSeed = seedIDX(i);
    imgData = imread(strcat(datafolder,currentSpe,'_S',num2str(currentSeed),'.png'));
    currentPos = seedsPOS(i)-1;
    %%% merge to image
    nRow = floor(currentPos/nseedperrow);
    nCol = mod(currentPos,nseedperrow);
    imgPano = imgMerge(imgPano,imgData,nCol,nRow);
end

function imgPano = imgMerge(imgPano,imgData,nCol,nRow)

startX = nRow*400+1;
endX = startX +400-1;
startY = nCol*200+1;
endY = startY+200-1;
imgPano(startX:endX,startY:endY,:) = imgData;





