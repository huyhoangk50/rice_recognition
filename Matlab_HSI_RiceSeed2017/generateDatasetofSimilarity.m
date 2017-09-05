function generateDatasetofSimilarity
close all
setup
masterfolder ='G:\WorkinginUoS\DataSet_RiceSeed2017\';
global resultfolder
global masterfolder

%listofSpeice = {'NDC1' 'NV1' 'NepCT' 'NepBH' 'NTHY' 'NDSLH'}; %%<<--- G1
%listofSpeice = {'BC15' 'KC111' 'NBK' 'NBP' 'NPT1' 'TB13'};%% <<--- G2
%listofSpeice = {'CL61' 'PD211' 'R068' 'SHPT1' 'SVN1' 'NBP'}; %%%<<-- G3

listofSpeice = {'NT16' 'BQ10' 'BC15' 'VH8' 'PC10' 'NH92'};
datasetIdx  = 'G4';

dataset = struct;
dataset.species = listofSpeice;
dataset.train = {};
dataset.valid = {};
numSpecies = length(listofSpeice);

labelspeice=generateLabel


nposSample =80;


for i=1:numSpecies
    shortnameofSpeice = listofSpeice{i};
    fullnameofSpeice = getFullLengthofSpeice(labelspeice,shortnameofSpeice);
    [FileName1 FileName2] = getfilename(fullnameofSpeice)
    
    hsi1 = load([resultfolder '\' FileName1 '_fullricespec.mat']);
    rgb1 = load([resultfolder '\' FileName1 '_spatialFeat.mat']);
    hsi2 = load([resultfolder '\' FileName2 '_fullricespec.mat']);
    rgb2 = load([resultfolder '\' FileName2 '_spatialFeat.mat']);
    
    feat = [hsi1.fullspecData rgb1.spatialMat; hsi2.fullspecData rgb2.spatialMat];
    
        % randomly choose 80 for training, 16 for validation
    randSeedIdx = randperm(96);
    dataset.trainIdx = randSeedIdx(1 : nposSample);
    dataset.validIdx = randSeedIdx(nposSample+1 : end);
    dataset.train{i} = feat(dataset.trainIdx, :);
    dataset.valid{i} = feat(dataset.validIdx, :);
    
    
end 

save(sprintf('%s\\VIS\\dataset-%s.mat', masterfolder, datasetIdx), 'dataset');


function labelspecie=generateLabel


fid =fopen('specielabel.txt','rt');

labelspecie = textscan(fid,'%d\t%s\t%s\n')

fclose(fid);



function fullnameofSpeice = getFullLengthofSpeice(labelspeice, shortnameofSpeice)

nspecie = length(labelspeice{1})
fullnameofSpeice='';
for i=1:nspecie
    if strcmp(labelspeice{3}{i},shortnameofSpeice)==1
        fullnameofSpeice = labelspeice{2}{i};
        break;
    end
end
    

function [Filename1 Filename2] = getfilename(fullnameofSpeice)

fid =fopen('info-VIS-features.txt','rt');

data = textscan(fid,'%d\t%s\t%s\t%s\n');
nline = length(data{1})
Filename1 = '';
Filename2 = '';

for i=1:nline
     if strcmp(data{2}{i},fullnameofSpeice)==1
        Filename1 = data{3}{i};
        Filename2 = data{4}{i};
        break;
    end
end

