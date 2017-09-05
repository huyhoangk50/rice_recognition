function showSpatialFeatures(datafile)
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
nspeices = 6;
for i=1:nspeices
    
    currData = vertcat(dataset.train{i},dataset.valid{i});
    spatData = currData(:,257:end);
    nseed = size(currData,1);
    
    currLabel = cell(nseed,1);
    
    currLabel(:) = dataset.species(i);
    currC = repmat([i/6 i/(12) 0],nseed,1);
    
    if i==1
        allData = spatData;
        allLabel = currLabel;
        colD = currC;
    else
        allData = vertcat(allData,spatData);
        allLabel = vertcat(allLabel,currLabel);
        colD = vertcat(colD,currC);
    end
    
end

size(colD)
pause
%%% SOM from here

clc
riceData=allData;
% shape_fea = [   s.Area s.MajorAxisLength s.MinorAxisLength ...
%                        s.MinorAxisLength/s.MajorAxisLength s.Perimeter/s.Area s.Eccentricity];
                        
sData = som_data_struct(riceData,'name','Rice Data','comp_names',{'Area','MajorLength','MinorLength', 'RatioMM'...
                                                                   'PPA','Eccentricity'});

npoint = size(riceData,1);

sData = som_label(sData,'add',[1:npoint],allLabel);
sData = som_normalize(sData,'var');

sMap = som_make(sData);

sMap = som_autolabel(sMap,sData,'vote');

%%% show the first result
som_show(sMap,'comp',1:6,'norm','d');
figure
som_show(sMap,'empty','Labels','norm','d');
som_show_add('label',sMap,'subplot',1);

%%% show the grid result


[Pd V me] = pcaproj(sData,3);
Pm = pcaproj(sMap,V,me);

figure
C = som_colorcode(sMap,'rgb4');;

som_grid(sMap,'Coord',Pm,'marker','o',...
                'MarkerColor',C,'MarkerSize',4,'Label',sMap.labels,'labelcolor','k','LabelSize',8);
            
grid on
hold on

%% plot original data on grid

som_grid('rect',[npoint 1],'Line','none','Coord',Pd,'MarkerColor',colD);

