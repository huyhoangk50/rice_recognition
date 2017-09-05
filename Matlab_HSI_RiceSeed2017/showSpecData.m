%%% show data 
function showSpecData

close all
Envisetup
global datafolder
global resultfolder
 


speices = {'A128' 'CTX30' 'HongQuang15' 'KB6' 'N54' 'KimCuong111'}

nspeices = length(speices);
ncapture = {'01' '02'};

validband = 10:240;
for i=1:nspeices
    for j=1:length(ncapture)
         fullfilename = strcat(resultfolder,speices{i},'-',ncapture{j},'_fullricespec');
         load(fullfilename,'fullspecData');
         if j==1
             specieData = fullspecData(:,validband);
         else
             specieData = vertcat(specieData,fullspecData(:,validband));
         end
         
    end
    nrice = size(specieData,1);
    
    size(specieData)
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
perplexity = 3;

% Run t?SNE
mappedX = tsne(allData, alllabel, no_dims, initial_dims, perplexity);

%numDims = 2; pcaDims = 50; perplexity = 50; theta = .5; alg = 'svd';
%[mappedX, landmarks, costs] = read_data; 
%mappedX = fast_tsne(allData, numDims, pcaDims, perplexity, theta, alg);
% Plot results


gscatter(mappedX(:,1), mappedX(:,2), alllabel);


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


% Reads the result file from the fast t-SNE implementation
function [X, landmarks, costs] = read_data
    h = fopen('result.dat', 'rb');
	n = fread(h, 1, 'integer*4');
	d = fread(h, 1, 'integer*4');
	X = fread(h, n * d, 'double');
    landmarks = fread(h, n, 'integer*4');
    costs = fread(h, n, 'double');      % this vector contains only zeros
    X = reshape(X, [d n])';
	fclose(h);
