%%% check performance of RICE seed classifcation
%%% utilizing both spatial and spectral features
%%% Pos sample: 80 seeds
%%% neg sample: 2 seeds x 40 speices = 80 seeds
%%% totally : 81 speices


function [accuracy, recall] = checkPerform_anyspecie(datafile)

%%% data folder

close all
setup

global resultfolder
global masterfolder

datafolder = [masterfolder '\VIS\'];
resultFolder = [masterfolder '\Result\']
%path(path, [masterfolder '\MatlabTool\RF_MexStandalone-v0.02-precompiled\randomforest-matlab\RF_Class_C']);


strcat(datafolder,datafile)

load(strcat(datafolder,datafile),'dataset');
trainSet = dataset.train;
validSet = dataset.valid;



for i=1:6
    train_set = trainSet{i};
    valid_set = validSet{i};
    if i==1
        alldataset = vertcat(train_set,valid_set);
    else
        alldataset = vertcat(train_set,valid_set,alldataset);
    end
end


%%% do PCA on alldataset
%prinCompMat = princomp(alldataset(:,1:256));

modelFolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\Model\';
load(strcat(modelFolder,'PCAAll.mat'),'prinCompMat');

%projectedData = zeros(m*n,5);
    
nTrial = 10;
ncomp = 60;


listofspeice = 1:6;
fid = fopen(strcat(resultFolder,datafile,'_res.txt'),'wt');

for nSpeice=1:6
 
  accuracy =[];
  recall =[];
  for i=1:nTrial
    fprintf(1,'\n');
    fprintf(1,'---> Testing trail %d', i);
    
    %%% prepare training data
    
    train_Pos = trainSet{nSpeice};
    trainlabelPos = ones(size(train_Pos,1),1);

    negSpecie = listofspeice(listofspeice~=nSpeice);
    
    train_Neg = generateNegTrain(dataset.train,negSpecie);
    trainlabelNeg = 2*ones(size(train_Neg,1),1);

    trainlabel = vertcat(trainlabelPos,trainlabelNeg);
    traindata = vertcat(train_Pos,train_Neg);
    
    
    %%% prepare valid dataset
    valid_Pos = validSet{nSpeice};
    validlabelPos = ones(size(valid_Pos,1),1);

    valid_Neg = generateNegValid(dataset.valid,negSpecie);
    validlabelNeg = 2*ones(size(valid_Neg,1),1);

    validlabel = vertcat(validlabelPos,validlabelNeg);
    validdata = vertcat(valid_Pos,valid_Neg);

    size(validdata)



    %%% generate model based on train dataset
    %%% using Random Forest Classfiier
    ntree  = 500;
    projectedtrainData = traindata(:,1:256)*prinCompMat(:,1:ncomp);
    projectedtrainData = horzcat(projectedtrainData,traindata(:,257:end));
    
     
    size(projectedtrainData)
   
    projectedValidData = validdata(:,1:256)*prinCompMat(:,1:ncomp);
    projectedValidData = horzcat(projectedValidData,validdata(:,257:end));
   
    modelRF = classRF_train(projectedtrainData,trainlabel,ntree);

    %%% test model using valid dataset
    predictlabel = classRF_predict(projectedValidData,modelRF);

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
    confusionmat
%    fprintf(fid,'%d\t%5.3f\t%5.3f\n',i, accuracy(i,1),recall(i,1));
    
  end

  allAcc(:,nSpeice) = accuracy;
  allRecall(:,nSpeice) = recall;
end

fprintf(1,'-------------------------------------------------\n');
disp('Average classification Results with RF   ..... ');
disp(['Accuracy with RF is ' num2str(mean(allAcc))]);
disp(['Recall with RF is ' num2str(mean(allRecall))]);


meanRecall = mean(allRecall);
meanAcc = mean(allAcc);;

for i=1:nSpeice
   fprintf(fid,'%d\t%5.3f\t%5.3f\n',i, meanAcc(i),meanRecall(i));
end
fclose(fid)




function train_Neg = generateNegTrain(origData,negSpecie)

t=1;
nNeg = length(negSpecie);
for i=1:nNeg
    
    tempData = origData{negSpecie(i)};
    npoint = size(tempData,1);
    idxRice = randperm(npoint);
    idxRice = idxRice(1:16);
    if t==1
        train_Neg = tempData(idxRice,:);
    else
        train_Neg = vertcat(train_Neg,tempData(idxRice,:));
    end
    t=t+1;
end


    

function valid_Neg = generateNegValid(origData,negSpecie)
t=1;
nNeg = length(negSpecie);
for i=1:nNeg
    tempData = origData{negSpecie(i)};
    npoint = size(tempData,1);
    idxRice = randperm(npoint);
    idxRice = idxRice(1:16);
    if t==1
        valid_Neg = tempData(idxRice,:);
    else
        valid_Neg = vertcat(valid_Neg,tempData(idxRice,:));
    end
    t=t+1;
end