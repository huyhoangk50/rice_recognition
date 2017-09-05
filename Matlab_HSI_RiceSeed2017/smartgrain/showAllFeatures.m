function showAllFeatures(datafile)
close all
%%% data folder
global masterfolder
global resultFolder
resultFolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\Result\';
masterfolder ='G:\WorkinginUoS\DataSet_RiceSeed2017';
datafolder = [masterfolder '\VIS\'];
%path(path, [masterfolder '\MatlabTool\RF_MexStandalone-v0.02-precompiled\randomforest-matlab\RF_Class_C']);


load(strcat(datafolder,datafile),'dataset');

%%% get only spatial data
nspeices = size(dataset.species);
nspeices = 16;
for i=1:nspeices
    
    currData = vertcat(dataset.train{i},dataset.valid{i});
    specData = currData(:,1:256);
    spaData = currData(:,257:end);
    nseed = size(currData,1);
    
    currLabel = cell(nseed,1);
    
    currLabel(:) = dataset.species(i);
    if (mod(i,2) == 0)
        currC = repmat([i/6 i*i/256 0],nseed,1);
    else
        currC = repmat([i/6 0 i*i/256],nseed,1);
    end
    if i==1
        allspaData = spaData;
        allData = specData;
        allLabel = currLabel;
        colD = currC;
    else
        allspaData = vertcat(allspaData,spaData);
        allData = vertcat(allData,specData);
        allLabel = vertcat(allLabel,currLabel);
        colD = vertcat(colD,currC);
    end
    
end



modelFolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\Model\';
load(strcat(modelFolder,'PCAAll.mat'),'prinCompMat');
ncomp = 10;
[Pd V me] = pcaproj(allData,ncomp);

%projectedData = allData*prinCompMat(:,1:ncomp);

size(colD)
pause
%%% SOM from here
allspaData = som_normalize(allspaData,'var');
clc
riceData=horzcat(Pd,allspaData);

% shape_fea = [   s.Area s.MajorAxisLength s.MinorAxisLength ...
%                        s.MinorAxisLength/s.MajorAxisLength s.Perimeter/s.Area s.Eccentricity];
                        
sData = som_data_struct(riceData,'name','Rice Data') ;%'comp_names',{'pc1','pc2','pc3', 'pc4', 'pc5'...
                                                                   %%'pc6','pc7','pc8', 'pc9', 'pc10'});

npoint = size(riceData,1);

sData = som_label(sData,'add',[1:npoint],allLabel);
%sData = som_normalize(sData,'var');

sMap = som_make(sData);

sMap = som_autolabel(sMap,sData,'vote');

%%% show the first result
figure
som_show(sMap,'umat','all');
figure
som_show(sMap,'comp',1:6,'norm','d');
figure
som_show(sMap,'empty','Labels','norm','d');
som_show_add('label',sMap,'subplot',1);

%%% show the grid result


%[Pd V me] = pcaproj(sData,3);
%Pm = pcaproj(sMap,V,me);
Pm = sMap.codebook(:,1:3);

figure
C = som_colorcode(sMap,'rgb4');;


som_grid(sMap,'Coord',Pm,'marker','d',...
                'MarkerColor',C,'MarkerSize',8,'Label',sMap.labels,'labelcolor','k','LabelSize',8);
            
grid on
hold on

pause
%% plot original data on grid

som_grid('rect',[npoint 1],'Line','none','Coord',Pd(:,1:3),'MarkerColor',colD,'MarkerSize',2);

