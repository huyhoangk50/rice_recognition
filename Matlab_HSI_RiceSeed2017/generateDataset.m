function generateDataset
close all
clear

setup


infoAvail = readtable('info-VIS-features.txt', 'Delimiter', '\t');
infoAvail = table2struct(infoAvail);

% remove unused entries
for i = length(infoAvail) : -1 : 1
    if (~infoAvail(i).Used)
        infoAvail(i) = [];
    end
end



for datasetIdx = 1 : numDatasets
    % randomly keep only numSpecies species
    info = infoAvail( randperm(length(infoAvail), numSpecies) );
`````````````````````````````````````````````````````````````````````````````````````````````````````````````
    dataset = struct;
    dataset.species = extractfield(info, 'SpeciesName');
    dataset.train = {};
    dataset.valid = {};

    for i = 1 : numSpecies
        hsi1 = load([resultfolder '\' info(i).FileName1 '_fullricespec.mat']);
        rgb1 = load([resultfolder '\' info(i).FileName1 '_spatialFeat.mat']);
        hsi2 = load([resultfolder '\' info(i).FileName2 '_fullricespec.mat']);
        rgb2 = load([resultfolder '\' info(i).FileName2 '_spatialFeat.mat']);

        % combine RGB and HSI features
        feat = [hsi1.fullspecData rgb1.spatialMat; hsi2.fullspecData rgb2.spatialMat];
        if size(feat,1) ~= 96 || size(feat, 2) ~= (256+6)
            error('Number of features is not correct: %s\n', info(i).SpeciesName);
        end

        % randomly choose 80 for training, 16 for validation
        randSeedIdx = randperm(96);
        dataset.trainIdx = randSeedIdx(1 : (numSpecies-1)*2);
        dataset.validIdx = randSeedIdx((numSpecies-1)*2+1 : end);
        dataset.train{i} = feat(dataset.trainIdx, :);
        dataset.valid{i} = feat(dataset.validIdx, :);
    end
    
    save(sprintf('%s\\dataset-VIS\\dataset-%02d.mat', masterfolder, datasetIdx), 'dataset');
end