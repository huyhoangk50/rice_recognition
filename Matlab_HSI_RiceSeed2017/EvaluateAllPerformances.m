close all
clear

setup


classifiers = {'RF + spatial', 'checkPerform_spatialFeat(''%s'')', 'result-VIS-RF-spat'
            'RF + spectral', 'checkPerform_spectralFeat(''%s'')', 'result-VIS-RF-spect'
            'RF + both', 'checkPerform_pca(''%s'')', 'result-VIS-RF-both'
            'PCA 5 + spectral', 'checkPerform_pca_n(''%s'',5)', 'result-VIS-PCA05-spect'
            'PCA 10 + spectral', 'checkPerform_pca_n(''%s'',10)', 'result-VIS-PCA10-spect'
            'PCA 15 + spectral', 'checkPerform_pca_n(''%s'',15)', 'result-VIS-PCA15-spect'
            'PCA 20 + spectral', 'checkPerform_pca_n(''%s'',20)', 'result-VIS-PCA20-spect'
            'PCA 25 + spectral', 'checkPerform_pca_n(''%s'',25)', 'result-VIS-PCA25-spect'
            'PCA 30 + spectral', 'checkPerform_pca_n(''%s'',30)', 'result-VIS-PCA30-spect'
            'PCA 35 + spectral', 'checkPerform_pca_n(''%s'',35)', 'result-VIS-PCA35-spect'
            'PCA 40 + spectral', 'checkPerform_pca_n(''%s'',40)', 'result-VIS-PCA40-spect'
            'PCA 41 + spectral', 'checkPerform_pca(''%s'')', 'result-VIS-PCA41-spect'
            'LDA + spectral', 'checkPerform_lda(''%s'')', 'result-VIS-LDA-spect'};
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