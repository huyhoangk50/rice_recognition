
%%% generate Seed from a list RGB file

function generateSeedListfile

% Load information
masterfolder= 'G:\WorkinginUoS\DataSet_RiceSeed2017\';

fid = fopen(strcat(masterfolder,'vis-info.txt'),'rt');
c = textscan(fid,'%s\t%s\t%d\t%s\t%d\t%d\n');
directory = c{1};
speices = c{2};
fname = c{4};
leftborder = c{6};
idxS=c{3};
%for i=15:length(speices)
for i=120:120
    %% current speice
   currDirectory = directory{i};
   idxofSpeice= idxS(i);
   currSpeice = speices{i};
   currfname = fname{i};
   currLefBorder = leftborder(i);
   str = sprintf('%03d',i);
   currfMask = strcat(str,'_',currfname,'_','rgb_mask.png');
   fprintf(1,'%s\t%s\t%d\n',currSpeice,currfname,currLefBorder);
   currfname = strcat(currDirectory,'\',currfname);
   generateRiceSeedImage2(currSpeice,currfname,currfMask,currLefBorder,idxofSpeice);
   %pause
end
fclose(fid);
