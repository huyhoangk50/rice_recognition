%%% check PCA
%%%
function PCACompute()

close all
clear

setup

global masterfolder
% Load information
masterfolder= 'G:\WorkinginUoS\DataSet_RiceSeed2017\';

featureFolder ='G:\WorkinginUoS\DataSet_RiceSeed2017\features-VIS\';

fid = fopen(strcat(masterfolder,'vis-info.txt'),'rt');
c = textscan(fid,'%s\t%s\t%d\t%s\t%d\t%d\n');
directory = c{1};
speices = c{2};
fname = c{4};
leftborder = c{6};
idxS=c{3};
t=1;
for i=1:length(speices)
   currDirectory = directory{i};
   idxofSpeice= idxS(i);
   currSpeice = speices{i};
   currfname = fname{i};
   currLefBorder = leftborder(i);
   str = sprintf('%03d',i);
   currfData = strcat(featureFolder,str,'_',currfname,'_fullricespec.mat');    

   %% check if currfData is existing
   
   if (exist(currfData,'file')==2)
       load(currfData,'fullspecData');
       size(fullspecData);
       if t==1
           totalSpecData = fullspecData;
       else
           totalSpecData = vertcat(totalSpecData,fullspecData);
       end
       t=t+1;
   else
       fprintf(1,'%s --> file does not exist\n',currfData);
   end
    
end

%%% do PCA on alldataset
prinCompMat = princomp(totalSpecData(:,1:256));

%%% dump prinCompMat
modelFolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\Model\';
save(strcat(modelFolder,'PCAAll.mat'),'prinCompMat');

fprintf(1,'%s --> SAVED MODEL\n',strcat(modelFolder,'PCAAll.mat'));