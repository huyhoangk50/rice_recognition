%%% show data 
function showSpatialData

close all
Envisetup
global datafolder
global resultfolder
 


speices = {'bc15', 'BT286', 'CH12' , 'khangdan18', 'nepcotien'}
nspeices = length(speices);
ncapture = {'01' , '02'};

for i=1:nspeices
    for j=1:length(ncapture)
         fullfilename = strcat(resultfolder,speices{i},'-',ncapture{j},'_spatialFeat');
         load(fullfilename,'spatialMat');
         if j==1
             specieData = spatialMat;
         else
             specieData = vertcat(specieData,spatialMat);
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

allData = normalizationData(allData)
pause
%% show data by tSNE tool

% Set parameters
no_dims = 3;
initial_dims = 5;
perplexity = 20;

% Run t?SNE
mappedX = tsne(allData, alllabel, no_dims, initial_dims, perplexity);
% Plot results
%subplot(121)
%gscatter(mappedX(:,1), mappedX(:,2), alllabel);
%subplot(122)
%gscatter(mappedX(:,2), mappedX(:,3), alllabel);

scatter3D(mappedX,nspeices,alllabel)
% figure
% load('WL256','WL');
% wavelength=WL;
% c={'m' 'k' 'r' 'b' 'y' 'g' 't'};
% for i=1:nspeices
%     plot(wavelength,meanspecData(i,:),'-','color',c{i});
%     hold on
% end
% grid on
% hold off
% legend(speices,'location','SouthEast');


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
