%%% setup the envi
%%%
function Envisetup

global datafolder
global resultfolder

datafolder = '/media/data/datasets/rice/data-VIS/';
resultfolder = '../Result/';
global ncomp
ncomp = 7; %%% main component for PCA analysis

global nfeat
nfeat = 50:1:200;

%% for training data using random forest
global ntree
ntree = 500;

global validband
validband = 55:220;

global CAMERA;
CAMERA = 'HSI256' ;  %%% other option: NIR; or HSI4096

global NORMALIZATION;
NORMALIZATION = 1;

global RegionExt; %% center or lowband or highband or fullband
RegionExt = 'center';

global darkfilename;
darkfilename = 'black';