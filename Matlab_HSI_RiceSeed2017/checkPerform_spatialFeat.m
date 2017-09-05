%%% check performance of RICE seed classifcation
%%% utilizing both spatial and spectral features
%%% Pos sample: 80 seeds
%%% neg sample: 2 seeds x 40 speices = 80 seeds
%%% totally : 81 speices


function [accuracy, recall] = checkPerform_spatialFeat(datafile)

%%% data folder
global masterfolder
masterfolder='G:\WorkinginUoS\DataSet_RiceSeed2017\';

datafolder = [masterfolder '\VIS\'];
%path(path, [masterfolder '\MatlabTool\RF_MexStandalone-v0.02-precompiled\randomforest-matlab\RF_Class_C']);


load(strcat(datafolder,datafile),'dataset');
trainSet = dataset.train;
validSet = dataset.valid;
nTrial = 10;

for i=1:nTrial
    fprintf(1,'\n');
    fprintf(1,'---> Testing trail %d', i);
    
    %%% prepare training data
    train_Pos = trainSet{1};
    trainlabelPos = ones(size(train_Pos,1),1);

    train_Neg = generateNegTrain(dataset.train);
    trainlabelNeg = 2*ones(size(train_Neg,1),1);

    trainlabel = vertcat(trainlabelPos,trainlabelNeg);
    traindata = vertcat(train_Pos,train_Neg);

    %%% prepare valid dataset
    valid_Pos = validSet{1};
    validlabelPos = ones(size(valid_Pos,1),1);

    valid_Neg = generateNegValid(dataset.valid);
    validlabelNeg = 2*ones(size(valid_Neg,1),1);

    validlabel = vertcat(validlabelPos,validlabelNeg);
    validdata = vertcat(valid_Pos,valid_Neg);


    %%% generate model based on train dataset
    %%% using Random Forest Classfiier
    ntree  = 500;
    modelRF = classRF_train(traindata(:,257:end),trainlabel,ntree);

    %%% test model using valid dataset
    predictlabel = classRF_predict(validdata(:,257:end),modelRF);

    %%% report results
    nlabel = 2;
    confusionmat = zeros(nlabel,nlabel);

    for j=1:length(predictlabel)
        confusionmat(validlabel(j,1),predictlabel(j,1)) = confusionmat(validlabel(j,1),predictlabel(j,1))+1;
    end

    accuracy(i,1) = confusionmat(2,2)/(confusionmat(2,2)+confusionmat(2,1));
    recall(i,1) = confusionmat(1,1)/(confusionmat(1,1)+confusionmat(1,2));
    
    disp(['Accuracy with RF is ' num2str( accuracy(i,1))]);
    disp(['recall with RF is ' num2str(recall(i,1))]);

end


fprintf(1,'-------------------------------------------------\n');
disp('Average classification Results with RF   ..... ');
disp(['Accuracy with RF is ' num2str(mean(accuracy))]);
disp(['Recall with RF is ' num2str(mean(recall))]);





function train_Neg = generateNegTrain(origData)

t=1;
for i=2:41
    tempData = origData{i};
    npoint = size(tempData,1);
    idxRice = randi(npoint,1,2);
    if t==1
        train_Neg = tempData(idxRice,:);
    else
        train_Neg = vertcat(train_Neg,tempData(idxRice,:));
    end
    t=t+1;
end

    

function valid_Neg = generateNegValid(origData)
t=1;
for i=2:41
    tempData = origData{i};
    npoint = size(tempData,1);
    idxRice = randi(npoint,1,16);
    if t==1
        valid_Neg = tempData(idxRice,:);
    else
        valid_Neg = vertcat(valid_Neg,tempData(idxRice,:));
    end
    t=t+1;
end
