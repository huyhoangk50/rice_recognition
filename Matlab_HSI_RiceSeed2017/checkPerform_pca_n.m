%%% check performance of RICE seed classifcation
%%% utilizing both spatial and spectral features
%%% Pos sample: 80 seeds
%%% neg sample: 2 seeds x 40 speices = 80 seeds
%%% totally : 81 speices


function checkPerform_pca_n(datafile,nspeices)

%%% data folder
datafolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\VIS\';

load(strcat(datafolder,datafile),'dataset');
trainSet = dataset.train;
validSet = dataset.valid;

%global nspeices
%nspeices = 5; %% total speices = nspeices + 1 (pos)

for i=1:41
    
    train_set = trainSet{i};
    valid_set = validSet{i};
    
    if i==1
        alldataset = vertcat(train_set,valid_set);
    else
        alldataset = vertcat(train_set,valid_set,alldataset);
    end
    
    
   
end

%%% do PCA on alldataset

prinCompMat = princomp(alldataset(:,1:256));
%projectedData = zeros(m*n,5);
    
nTrial = 10;
ncomp = 50;
currF = 0;
for i=1:nTrial
    fprintf(1,'\n');
    fprintf(1,'---> Testing trail %d', i);
    
    %%% prepare training data
    train_Pos = trainSet{1};
    trainlabelPos = ones(size(train_Pos,1),1);

    train_Neg = generateNegTrain(dataset.train,nspeices);
    trainlabelNeg = 2*ones(size(train_Neg,1),1);

    trainlabel = vertcat(trainlabelPos,trainlabelNeg);
    traindata = vertcat(train_Pos,train_Neg);

    %%% prepare valid dataset
    valid_Pos = validSet{1};
    validlabelPos = ones(size(valid_Pos,1),1);

    valid_Neg = generateNegValid(dataset.valid,nspeices);
    validlabelNeg = 2*ones(size(valid_Neg,1),1);

    validlabel = vertcat(validlabelPos,validlabelNeg);
    validdata = vertcat(valid_Pos,valid_Neg);


    %%% generate model based on train dataset
    %%% using Random Forest Classfiier
    ntree  = 500;
    projectedtrainData = traindata(:,1:256)*prinCompMat(:,1:ncomp);
    projectedtrainData = horzcat(projectedtrainData,traindata(:,257:end));
    
     
   
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
    
    lastF = (accuracy(i,1)  + recall(i,1))/2;
    if currF < lastF
        currF = lastF; %% update F value
        bestModel = modelRF;
        bestPCA = prinCompMat(:,1:ncomp);
    end
    
    disp(['Accuracy with RF is ' num2str( accuracy(i,1))]);
    disp(['recall with RF is ' num2str(recall(i,1))]);
    confusionmat;
    
    
end

accuracy_average = mean(accuracy);
recall_average = mean(recall);

fprintf(1,'-------------------------------------------------\n');
disp('Average classification Results with RF   ..... ');
disp(['Accuracy with RF is ' num2str(accuracy_average)]);
disp(['Recall with RF is ' num2str(recall_average)]);


%%% store the bestModel
modelRF=bestModel;
prinCompMat =bestPCA;
currSpeices =dataset.species{1}; %%% current Speices
modelFolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\Model\';
modelName = strcat(modelFolder,currSpeices,'_modelRF.mat');
save(modelName,'modelRF','prinCompMat','ncomp');


function train_Neg = generateNegTrain(origData,nspeices)

t=1;

nsamples = floor(80/nspeices);
for i=2:nspeices+1
    tempData = origData{i};
    npoint = size(tempData,1);
    idxRice = randi(npoint,1,nsamples);
    if t==1
        train_Neg = tempData(idxRice,:);
    else
        train_Neg = vertcat(train_Neg,tempData(idxRice,:));
    end
    t=t+1;
end


    

function valid_Neg = generateNegValid(origData,nspeices)
t=1;
for i=2:nspeices+1
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



