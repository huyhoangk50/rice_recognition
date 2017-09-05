%%% check performance of RICE seed classifcation by LDA
%%% utilizing both spatial and spectral features
%%% Pos sample: 80 seeds
%%% neg sample: 2 seeds x 40 speices = 80 seeds
%%% totally : 81 speices


function checkPerform_lda(datafile)

%%% data folder
datafolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\VIS\';

load(strcat(datafolder,datafile),'dataset');

trainSet = dataset.train;
validSet = dataset.valid;
   
speices = dataset.species
nTrial = 10;
ncomp = 60;
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

    
    %% do LDA now
    [SB Sw] = CalcCovMat(traindata(:,1:256),trainlabel);
    
    [coeff,lambda] = eig(SB,Sw,'chol');
    [lambda,sorted] = sort(diag(lambda),'descend'); % sort by eigenvalues
    coeff = coeff(sorted,:); 
    
    %%% project origData into LDA space
    Input = traindata(:,1:256);
    
    projectedtrainData = Input*coeff(:,1:ncomp);
    
    %%% add spatial features
    projectedtrainData = horzcat(projectedtrainData,traindata(:,257:end));
    
    
    %%% prepare valid dataset
    valid_Pos = validSet{1};
    validlabelPos = ones(size(valid_Pos,1),1);

    valid_Neg = generateNegValid(dataset.valid);
    validlabelNeg = 2*ones(size(valid_Neg,1),1);

    validlabel = vertcat(validlabelPos,validlabelNeg);
    validdata = vertcat(valid_Pos,valid_Neg);

    validInput = validdata(:,1:256);
    
    projectedValidData = validInput*coeff(:,1:ncomp);
    projectedValidData = horzcat(projectedValidData,validdata(:,257:end));
    %%% generate model based on train dataset
    %%% using Random Forest Classfiier
    ntree  = 500;
    
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
end

accuracy_average = mean(accuracy);
recall_average = mean(recall);

fprintf(1,'-------------------------------------------------\n');
disp('Average classification Results with RF   ..... ');
disp(['Accuracy with RF is ' num2str(accuracy_average)]);
disp(['Recall with RF is ' num2str(recall_average)]);





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




function [SB Sw] = CalcCovMat(Input,Target)
Group1     = (Target == 1);
X1= Input(Group1,:);

Group2      = (Target == 2);
X2= Input(Group2,:);

Mu1=mean(X1)'; Mu2=mean(X2)';
S1=cov(X1); S2=cov(X2); 
Sw=S1+S2;
SB=(Mu1-Mu2)*(Mu1-Mu2)';

