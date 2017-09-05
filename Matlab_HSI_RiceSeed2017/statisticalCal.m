%%% statistcal analysis on the results

function [meanAcc meanRecall CIAcc CIRecall]= statisticalCal(resultfile)
close all

setup
global masterfolder
masterfolder ='G:\WorkinginUoS\DataSet_RiceSeed2017';
load(strcat(masterfolder,'\Result\',resultfile));

%%% calculate average on all trial for each dataset
nDataset = length(results.accuracy)

for i=1:nDataset
    meanAcc(i) = mean(results.accuracy{i});
    meanRecall(i) = mean(results.recall{i});
    CIAcc(i,:) = confidenceIntervalCal(results.accuracy{i})
    CIRecall(i,:) = confidenceIntervalCal(results.accuracy{i})
end

figure
subplot(121)
bar(1:nDataset,meanAcc,'b','EdgeColor',[1 0.5 0.5]);
hold on
%errorbar(1:nDataset,meanAcc,CI(:,1),'r.','markerfacecolor',[1 0 1])
errorbar(1:nDataset,meanAcc,CIAcc,'r.','markerfacecolor',[1 0 1])

subplot(122)
bar(1:nDataset,meanRecall,'b','EdgeColor',[1 0.5 0.5]);
hold on
errorbar(1:nDataset,meanRecall,CIRecall,'r.','markerfacecolor',[1 0 1])
set(gca,'ylim',[0 1.05]);

function CI = confidenceIntervalCal(x)
SEM = std(x)/sqrt(length(x)); 
ts = tinv([0.005  0.995],length(x)-1);
CI = ts*SEM;   
CI(1) =[];