%%% check perform with type of speices

%%% check performance of RICE seed classifcation
%%% utilizing both spatial and spectral features
%%% Pos sample: 80 seeds
%%% neg sample: 2 seeds x 40 speices = 80 seeds
%%% totally : 81 speices


function [accuracy, recall] = checkPerform_with_Species(datafile)

%%% data folder
global masterfolder
global resultFolder
resultFolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\Result\';
masterfolder ='G:\WorkinginUoS\DataSet_RiceSeed2017';
datafolder = [masterfolder '\VIS\'];
%path(path, [masterfolder '\MatlabTool\RF_MexStandalone-v0.02-precompiled\randomforest-matlab\RF_Class_C']);


load(strcat(datafolder,datafile),'dataset');
trainSet = dataset.train;
validSet = dataset.valid;


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
%prinCompMat = princomp(alldataset(:,1:256));

modelFolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\Model\';
load(strcat(modelFolder,'PCAAll.mat'),'prinCompMat');

%projectedData = zeros(m*n,5);
    
nTrial = 10;
ncomp = 60;

fid = fopen(strcat(resultFolder,datafile,'_res.txt'),'wt');
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
    speices_Pos = cell(1,size(valid_Pos,1));
    speices_Pos(:) = dataset.species(1);
    
    
    [valid_Neg speices_Neg] = generateNegValid(dataset.valid, dataset.species);
    validlabelNeg = 2*ones(size(valid_Neg,1),1);

    validlabel = vertcat(validlabelPos,validlabelNeg);
    validdata = vertcat(valid_Pos,valid_Neg);
    speices = horzcat(speices_Pos,speices_Neg);
    
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
        %%% update to speices
        currentSpeice = speices{j};
        updateToSpeice(validlabel(j,1),predictlabel(j,1),currentSpeice);
    end

    
    
    
    accuracy(i,1) = confusionmat(2,2)/(confusionmat(2,2)+confusionmat(2,1));
    recall(i,1) = confusionmat(1,1)/(confusionmat(1,1)+confusionmat(1,2));
    
    disp(['Accuracy with RF is ' num2str( accuracy(i,1))]);
    disp(['recall with RF is ' num2str(recall(i,1))]);
    confusionmat
    fprintf(fid,'%d\t%5.3f\t%5.3f\n',i, accuracy(i,1),recall(i,1));
    
end

fclose(fid)



fprintf(1,'-------------------------------------------------\n');
disp('Average classification Results with RF   ..... ');
disp(['Accuracy with RF is ' num2str(mean(accuracy))]);
disp(['Recall with RF is ' num2str(mean(recall))]);



%%% load current result data
 global performFolder
for i=1:41
    currentSpeice = dataset.species{i};
    fname = strcat(performFolder,currentSpeice,'_res','.mat');
    load(fname,'confusmat');
    fprintf(1,'----> current speices =%s\n',currentSpeice);
    confusmat
end



function train_Neg = generateNegTrain(origData)

t=1;
for i=2:41
    tempData = origData{i};
    npoint = size(tempData,1);
    idxRice = randperm(npoint);
    idxRice = idxRice(1:2);
    if t==1
        train_Neg = tempData(idxRice,:);
    else
        train_Neg = vertcat(train_Neg,tempData(idxRice,:));
    end
    t=t+1;
end


    

function [valid_Neg speices_Neg] = generateNegValid(origData, speices)
t=1;
for i=2:41
    tempData = origData{i};
    npoint = size(tempData,1);
    idxRice = randperm(npoint);
    %idxRice = idxRice(1:16);
    if t==1
        valid_Neg = tempData(idxRice,:);
        speices_Neg = cell(1,npoint);
        speices_Neg(:) = speices(i);
    else
        valid_Neg = vertcat(valid_Neg,tempData(idxRice,:));
        currentSpeice = cell(1,npoint);
        currentSpeice(:) = speices(i);
        speices_Neg = horzcat(speices_Neg,currentSpeice);
        
    end
    t=t+1;
end 



function updateToSpeice(validlabel,predictlabel,currentSpeice)

    global performFolder
    performFolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\SpeciePerform\';
    fname = strcat(performFolder,currentSpeice,'_res','.mat');
    
    if (exist(fname,'file')==2)
        
    else
        confusmat = zeros(2,2);
        save(fname,'confusmat');
    end
           
            
    load(fname,'confusmat');
    confusmat(validlabel,predictlabel) = confusmat(validlabel,predictlabel) + 1;
    save(fname,'confusmat');
    