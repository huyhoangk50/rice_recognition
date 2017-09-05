function extractAllSpecImage_HSI256
global datafolder
Envisetup
% global resultfolder
filename = strcat(datafolder, 'info.txt');
[folders, ~, fileNames] = loadData(filename);
for i = 1:size(folders,1)
    specFile = char(fileNames(i));
    folder = char(folders(i));
    extractSpecImage_HSI256(folder, specFile)
end

% loadData()
end

function [folders, species, fileNames] = loadData(filename)
    file = fopen(filename);
    filename
    results = textscan(file, '%s %s %d %s %d %d');
    fclose(file);
    folders = results{1};
    fileNames = results{4};
    species = results{2};
end