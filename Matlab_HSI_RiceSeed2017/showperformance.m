%%% show performances

function showperformance
close all
global performFolder
performFolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\SpeciePerform\';
    
files = dir(performFolder);

fileIndex = find(~[files.isdir]);
t=1;
for i = 1:length(fileIndex)

    fName = files(fileIndex(i)).name;
    fprintf(1,'--> current file = %s\n', fName);
    
    load(strcat(performFolder,fName),'confusmat');
    %if (confusmat(1,1)+confusmat(1,2) > 0)
        accuracy(t) = confusmat(2,2)/(confusmat(2,2)+confusmat(2,1));
        recall(t) = confusmat(1,1)/(confusmat(1,1)+confusmat(1,2));
        speices{t} = fName(1:end-8);
        if (length(fName(1:end-8)) > 8)
            speices{t} = fName(1:8);
        end
        t=t+1;
    %end
end
%%
performALL = horzcat(accuracy',recall');
meanALL = mean(performALL,2)
[foo idx] = sort(meanALL);

figure

bar(1:t-1,performALL(idx,:),'grouped');
set(gca,'XTickLabel',speices(idx),'fontsize',12) 
legend({'Accuracy','recall'})
grid on
figure

[foo idx] = sort(accuracy);

bar(1:t-1,accuracy(idx),'g','EdgeColor',[1 0.5 0.5]);
set(gca,'XTickLabel',speices(idx),'fontsize',12) 
grid on
title('Accuracy','fontsize',16);


figure
[foo idx] = sort(recall);

bar(1:t-1,recall(idx),'g','EdgeColor',[1 0.5 0.5]);
set(gca,'XTickLabel',speices(idx),'fontsize',12) 
grid on
title('Recall','fontsize',16);

