function showSpaSpecData

close all
Envisetup
global datafolder
global resultfolder
 


speices = {'bc15', 'BT286', 'CH12' , 'khangdan18', 'nepcotien'}
nspeices = length(speices);
ncapture = {'01' , '02'};

for i=1:nspeices
    for j=1:length(ncapture)
         spatialFilename = strcat(resultfolder,speices{i},'-',ncapture{j},'_spatialFeat');
         load(spatialFilename,'spatialMat');
         spatialMat = normalizationData(spatialMat);
         
         specFilename = strcat(resultfolder,speices{i},'-',ncapture{j},'_fullricespec');
         load(specFilename,'fullspecData');
         
         if j==1
             specieData = [fullspecData spatialMat] ;
         else
             specieData = vertcat(specieData,[fullspecData spatialMat]);
         end
         
    end
    nrice = size(specieData,1);
    
    currlabel = i*ones(nrice,1);
    if i==1
        allData = specieData;
        alllabel = currlabel;
        meanspecData = mean(specieData,1);
    else
        allData = vertcat(allData,specieData);
        alllabel = vertcat(alllabel,currlabel);
        meanspecData = vertcat(meanspecData,mean(specieData,1));
    end
end
size(allData)
size(alllabel)

pause
%% show data by tSNE tool

% Set parameters
no_dims = 3;
initial_dims = 50;
perplexity = 50;

% Run t?SNE
mappedX = tsne(allData, alllabel, no_dims, initial_dims, perplexity);
% Plot results
gscatter(mappedX(:,1), mappedX(:,2), alllabel);

%scatter3D(mappedX,nspeices,alllabel)


function normData = normalizationData(spatialMat)

maxVal = max(spatialMat,[],1);
minVal = min(spatialMat,[],1);
nsample = size(spatialMat,1);

maxMat = repmat(maxVal,[nsample 1]);
minMat = repmat(minVal,[nsample 1]);

size(maxMat)
size(spatialMat)
normData = (spatialMat-minMat)./(maxMat - minMat);


function scatter3D(mdata,nspeices,label)

colors = 'rgbmk';
markers = 'osdos';

figure
for i = 1 : nspeices
    idx = find(label==i);
    plot3(mdata(idx,1), mdata(idx,2), mdata(idx,3), [colors(i) markers(i)]);
    hold on;
end
grid; %// Show a grid