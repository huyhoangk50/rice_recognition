%%%som demo1

function som_rice

close all

data = load('riceseed.txt');
clf reset;
figure(gcf)
echo on



clc
riceData = data(:,2:end-1);
sData = som_data_struct(riceData,'name','Rice Data','comp_names',{'Area','Perimeter','Length', 'Width'...
                                                                   'LWR','CS','DS'});
npoint = size(riceData,1);
label  = num2str(data(:,end));
sData = som_label(sData,'add',[1:npoint],label);
sData = som_normalize(sData,'var');

sMap = som_make(sData);

sMap = som_autolabel(sMap,sData,'vote');


%%% show result first

som_show(sMap,'umat','all','comp',1:7,'empty','Labels','norm','d');

som_show_add('label',sMap,'subplot',9);

[Pd V me] = pcaproj(sData,3);
Pm = pcaproj(sMap,V,me);

figure
C = som_colorcode(sMap,'rgb4');;

som_grid(sMap,'Coord',Pm,'marker','o',...
                'MarkerColor',C,'MarkerSize',4,'Label',sMap.labels,'labelcolor','k');
            
grid on
hold on

%% plot original data on grid
for i=1:6
    idx = find(data(:,end) == i);
    currC = repmat([i/6 i/(12) 0],length(idx),1);
    if i==1
        colD = currC;
    else
        colD = vertcat(colD,currC);
    end
end
som_grid('rect',[npoint 1],'Line','none','Coord',Pd,'MarkerColor',colD);

