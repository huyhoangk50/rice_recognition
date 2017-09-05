function varargout = demo(varargin)
% DEMO MATLAB code for demo.fig
%      DEMO, by itself, creates a new DEMO or raises the existing
%      singleton*.
%
%      H = DEMO returns the handle to a new DEMO or the handle to
%      the existing singleton*.
%
%      DEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEMO.M with the given input arguments.
%
%      DEMO('Property','Value',...) creates a new DEMO or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before demo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to demo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help demo

% Last Modified by GUIDE v2.5 16-Feb-2017 14:53:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @demo_OpeningFcn, ...
                   'gui_OutputFcn',  @demo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before demo is made visible.
function demo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to demo (see VARARGIN)

% Choose default command line output for demo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes demo wait for user response (see UIRESUME)
% uiwait(handles.demoGUI);


% --- Outputs from this function are returned to the command line.
function varargout = demo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)


% --- Executes during object creation, after setting all properties.
function checkResult_Callback(hObject, eventdata, handles)
% hObject    handle to predictData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate predictData

%%% STEP 1: load current model of speices
global modelFolder dataset NegData LocData panoImage predictlabel


tstart = tic;
currSpecies = dataset.species{1};
modelFolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\Model\';
modelName = strcat(modelFolder,currSpecies,'_modelRF.mat');
load(modelName,'modelRF','prinCompMat','ncomp');
fprintf(1,'--> LOADING MODEL \n');

%%% prepare validData
validSet = dataset.valid;

%%% Positive data
valid_Pos = validSet{1};

%%% Negative data
valid_Neg = generateNegValid(dataset.valid,NegData);

%%% Merge positive and Negative data to validData
validdata = vertcat(valid_Pos,valid_Neg);

%%% Project data into a PCA space
projectedValidData = validdata(:,1:256)*prinCompMat(:,1:ncomp);
projectedValidData = horzcat(projectedValidData,validdata(:,257:end));

size(projectedValidData)

%%% get predict label with projectedValidData
predictlabel = classRF_predict(projectedValidData,modelRF);

%%% Show predict label on panoImage
resultImg = panoImage;
[m n nchannel] = size(panoImage);
currImg = zeros(m,n,nchannel);

elapsed= toc(tstart);

for i=1:length(predictlabel)
    if (predictlabel(i) == 2) %%% negative seed dection
        nRow = LocData(i,1);
        nCol = LocData(i,2);
        rgbI = drawRec(currImg,[ nRow nCol]);
        currImg(:,:,1) = currImg(:,:,1) +rgbI(1:m,1:n,1);
        currImg(:,:,2) = currImg(:,:,2) +rgbI(1:m,1:n,2);
        currImg(:,:,3) = currImg(:,:,3) +rgbI(1:m,1:n,3);
    end
end
resultImg(:,:,1) = resultImg(:,:,1)+currImg(1:m,1:n,1);
resultImg(:,:,2) = resultImg(:,:,2)+currImg(1:m,1:n,2);
resultImg(:,:,3) = resultImg(:,:,3)+currImg(1:m,1:n,3);

axes(handles.predictData);
imshow(uint8(resultImg),[]);

%%% show computational time

elapsed_str = sprintf('%.2f',elapsed);
set(handles.txtDetectionResult, 'String', ...
    strcat('Impurity Seeds Detected (Computational time:',' ',elapsed_str,'s)'));



function rgbI  = drawRec(currImg,position) 
nRow = position(1);
nCol = position(2);
x = nRow*400+1;
y = nCol*200+1;
w = 400;
h = 200;
[m n nchanel] = size(currImg);
rgbI = zeros(m,n,nchanel);
%rgbI=currImg;

    rgbI(x:x+w,y,1)   = 255;
    rgbI(x:x+w,y+h,1) = 255;
    rgbI(x,y:y+h,1)   = 255;
    rgbI(x+w,y:y+h,1) = 255;
    rgbI(x:x+w,y,2)   = 0;
    rgbI(x:x+w,y+h,2) = 0;
    rgbI(x,y:y+h,2)   = 0;
    rgbI(x+w,y:y+h,2) = 0;
    rgbI(x:x+w,y,3)   = 0;
    rgbI(x:x+w,y+h,3) = 0;
    rgbI(x,y:y+h,3)   = 0;
    rgbI(x+w,y:y+h,3) = 0;
    
    se = strel('disk',5);
    rgbI = imdilate(rgbI,se);
 %   figure(333)
 %   imshow(uint8(rgbI),[]);
    
%   size( rgbI)
%   size(currImg)


function valid_Neg = generateNegValid(origData,NegData)
for i=1:length(NegData)
    idxRice = NegData{i,1};
    currSpeiceIDX = NegData{i,3};
    curSpeicesData = origData{currSpeiceIDX};
    if i==1
        valid_Neg = curSpeicesData(idxRice,:);
    else
        valid_Neg = vertcat(valid_Neg,curSpeicesData(idxRice,:));
    end
end


% --- Executes on button press in loadData.
function loadData_Callback(hObject, eventdata, handles)
% hObject    handle to loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global dataset datafolder panoImage PosData NegData LocData

%%% STEP 1: assign a dataset for demostration
%%%%
dataset = 'dataset-16';
datafolder = 'G:\WorkinginUoS\DataSet_RiceSeed2017\VIS\';
nNegSpe = 4; %%% total neg species in the panoImage;
nNegSeed = [1 1 1 1]; %% number of neg speices per each speices;

load(strcat(datafolder,dataset));

%%% STEP 2: GENERATE a pano image ; The panoImage consists of negative and
%%% postive sample
%%%
PosData   = generatePosSeeds(dataset.species{1},dataset.validIdx);
NegData   = generateNegSeeds(dataset.species,nNegSpe,nNegSeed);
[panoImage LocData] = generatePanoImage(PosData,NegData);

%%% STEP 3: SHOW panoImage on the first axis
%axes(validData);
axes(handles.validData);
imshow(uint8(panoImage),[]);

%%% Show current Speices label
set(handles.txtCurrSpeice, 'String', strcat('Speices:',' ',dataset.species{1}));

%%% Reset figures
cla(handles.GTData,'reset');
set(handles.GTData,'color','black');

cla(handles.predictData,'reset');
set(handles.predictData,'color','black');

set(handles.txtDetectionResult, 'String','Detected Result');
set(handles.txtGTCheck, 'String','Ground-truth');


function curData = generatePosSeeds(species,validIDX)
for i=1:length(validIDX)
    if i==1
         curData = {validIDX(i) species};
    else
         curData = vertcat(curData,{validIDX(i) species});
    end
end

function curData = generateNegSeeds(species,nNegSpe,nNegSeed)

t=1;
for j=1:nNegSpe
    arr = randperm(41);
    idxSpeice=arr(1)
    
    if idxSpeice == 1
        idxSpeice=arr(2);
    end
    currSpecies=species{idxSpeice};
    Seedarr = randperm(16);
    for i=1:nNegSeed(j)
        if t==1
            curData = {Seedarr(i) currSpecies idxSpeice};
        else
            curData = vertcat(curData,{Seedarr(i) currSpecies idxSpeice});
        end
        t=t+1;
    end
end

function [imgPano locData] = generatePanoImage(posData,negData)


global datafolder;
datafolder ='G:\WorkinginUoS\DataSet_RiceSeed2017\RiceSeedSeg\';

species = vertcat(posData(:,2),negData(:,2));

validPosSeedIDX = cell2mat(posData(:,1));
validNegSeedIDX = cell2mat(negData(:,1));
seedIDX = vertcat(validPosSeedIDX,validNegSeedIDX);

%%% get random between 1 .. 48

%% totalseeds
totalseeds = size(seedIDX,1);
nseedperrow = 5;
nseedpercol = totalseeds/nseedperrow;
seedsPOS = randperm(totalseeds);

imgPano = zeros(nseedpercol*400,nseedperrow*200,3);

nPos = length(validPosSeedIDX);

for i=1:length(seedIDX)
    currentSpe = species{i};
    currentSeed = seedIDX(i);
    imgData = imread(strcat(datafolder,currentSpe,'_S',num2str(currentSeed),'.png'));
    currentPos = seedsPOS(i)-1;
    %%% merge to image
    nRow = floor(currentPos/nseedperrow);
    nCol = mod(currentPos,nseedperrow);
    imgPano = imgMerge(imgPano,imgData,nCol,nRow);
    if i<= nPos
        GTlabel = 1;
    else
        GTlabel = 2;
    end
    if i==1
        locData = [nRow nCol GTlabel];
    else
        locData = vertcat(locData,[nRow nCol GTlabel]);
    end
end

function imgPano = imgMerge(imgPano,imgData,nCol,nRow)

startX = nRow*400+1;
endX = startX +400-1;
startY = nCol*200+1;
endY = startY+200-1;
imgPano(startX:endX,startY:endY,:) = imgData;

% --- Executes on button press in showGT.
function showGT_Callback(hObject, eventdata, handles)
% hObject    handle to showGT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global modelFolder dataset NegData LocData panoImage predictlabel


resultImg =panoImage;
[m n nchannel] = size(panoImage);
currImg = zeros(m,n,nchannel);

for i=1:length(LocData)
    if (LocData(i,3) == 2) %%% negative seed dection
        nRow = LocData(i,1);
        nCol = LocData(i,2);
        rgbI = drawRec(currImg,[ nRow nCol]);
        currImg(:,:,1) = currImg(:,:,1) +rgbI(1:m,1:n,1);
        currImg(:,:,2) = currImg(:,:,2) +rgbI(1:m,1:n,2);
        currImg(:,:,3) = currImg(:,:,3) +rgbI(1:m,1:n,3);
    end
    
end
resultImg(:,:,1) = resultImg(:,:,1)+currImg(1:m,1:n,1);
resultImg(:,:,2) = resultImg(:,:,2)+currImg(1:m,1:n,2);
resultImg(:,:,3) = resultImg(:,:,3)+currImg(1:m,1:n,3);

axes(handles.GTData);
imshow(uint8(resultImg),[]);

%%% show performance
conffMat=zeros(2,2);
for i=1:length(predictlabel)
    conffMat(predictlabel(i),LocData(i,3))=conffMat(predictlabel(i),LocData(i,3))+1;
end

nMissed_str = sprintf('Total Missed Detection=%d\n',conffMat(1,2));
nWrong_str = sprintf('\nTotal Wrong Detections=%d',conffMat(2,1));

set(handles.txtGTCheck, 'String', ...
    strcat(nMissed_str,nWrong_str));

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.demoGUI); 


