%%% show all result


function showAllResult

close all
EvaluateResults ={'result-VIS-RF-spat' 'result-VIS-RF-spect' 'result-VIS-RF-both' 'result-VIS-RF-pca'}
legendCap = {'SPATIAL' 'SPECTRAL' 'BOTH' 'PCA'}
for i=1:length(EvaluateResults)
    [ACC RECALL CI_ACC CI_RECALL]= statisticalCal(EvaluateResults{i});
    if i==1
        ACC_ALL = ACC';
        CI_ACC_ALL = CI_ACC;
        
        RECALL_ALL = RECALL';
        CI_RECALL_ALL = CI_RECALL;
    else
        ACC_ALL = horzcat(ACC_ALL,ACC');
        CI_ACC_ALL = horzcat(CI_ACC_ALL,CI_ACC);
        
        RECALL_ALL = horzcat(RECALL_ALL,RECALL');
        CI_RECALL_ALL = horzcat(CI_RECALL_ALL,CI_RECALL);
    end
end


figure
ax1=subplot(211);
ax2=subplot(212);

hold(ax1,'on');
hold(ax2,'on');

nDataset = size(ACC_ALL,1);
axes(ax1)
hb1 = bar(1:nDataset,ACC_ALL,'grouped');

axes(ax2)
hb2 = bar(1:nDataset,RECALL_ALL,'grouped');

for ib = 1:numel(hb1)
      % Find the centers of the bars
      axes(ax1)
      xData = get(get(hb1(ib),'Children'),'XData')
      barCenters = mean(unique(xData,'rows'));
      errorbar(barCenters,ACC_ALL(:,ib),CI_ACC_ALL(:,ib),'b.')
      
      
      axes(ax2)
      xData = get(get(hb2(ib),'Children'),'XData')
      barCenters = mean(unique(xData,'rows'));
      errorbar(barCenters,RECALL_ALL(:,ib),CI_RECALL_ALL(:,ib),'b.')
      
end

axes(ax1)
set(gca,'ylim',[0 1.1]);

legend(legendCap,'interpreter','none','Location','NorthWestOutside');
legend(gca,'boxoff');
grid on

axes(ax2)
set(gca,'ylim',[0 1.1]);
legend(legendCap,'interpreter','none','Location','NorthWestOutside');
legend(gca,'boxoff');
grid on

grid on

%%% show average data on each evaluation
meanACC = mean(ACC_ALL,1);
meanCI_ACC = mean(CI_ACC_ALL);

maxACC = max(ACC_ALL,[],1);
minACC = min(ACC_ALL,[],1);

meanRECALL = mean(RECALL_ALL,1);
meanCI_RECALL = mean(CI_RECALL_ALL);

maxRECALL = max(RECALL_ALL,[],1);
minRECALL = min(RECALL_ALL,[],1);



fprintf(1,'-------> ACCURACY AVERAGE\n');
masterfolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\';
fid = fopen(strcat(masterfolder,'\Result\','summaryResult.txt'),'wt');


for i=1:length(EvaluateResults)
    fprintf(fid,'--> %s\t%5.3f\t%5.3f\t%5.3f\t%5.3f\t%5.3f\t%5.3f\t%5.3f\t%5.3f\n', ...
                EvaluateResults{i},meanACC(i),meanCI_ACC(i),...
                meanRECALL(i), meanCI_RECALL(i),...
                maxACC(i), minACC(i), maxRECALL(i), minRECALL(i));
end

fclose(fid)

