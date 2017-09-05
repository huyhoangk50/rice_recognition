close all
clear

setup


classifiers = {'RF + spatial', 'checkPerform_spatialFeat(''%s'')', 'result-VIS-RF-spat'
            'RF + spectral', 'checkPerform_spectralFeat(''%s'')', 'result-VIS-RF-spect'
            'RF + PCA', 'checkPerform_pca(''%s'')', 'result-VIS-RF-pca'
            'RF + Spat+Spec', 'checkPerform_spatSpecFeat(''%s'')', 'result-VIS-RF-both'
            };
classifiers = cell2struct(classifiers, {'name', 'codefile', 'resultfile'}, 2);
[sel,ok] = listdlg('PromptString', 'Select classifier:',...
        'SelectionMode','single',...
        'ListString', extractfield(classifiers,'name'));
if ~ok
    return
end



DatasetIdx = (1:numDatasets)';
Accuracy = {};
Recall = {};

for i = DatasetIdx'
    cmd = sprintf(['[accu,recall] = ', classifiers(sel).codefile], sprintf('dataset-%02d.mat', i));
    eval(cmd);
    
    Accuracy{i} = accu;
    Recall{i} = recall;
end

results = struct;
results.datasetIdx = DatasetIdx;
results.accuracy = Accuracy;
results.recall = Recall;
save([masterfolder '\Result\' classifiers(sel).resultfile], 'results');