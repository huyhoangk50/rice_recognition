import numpy as np
import scipy.io as sio
import os
import glob
from scipy import sparse
import random as rd
import os
os.environ["THEANO_FLAGS"] = "mode=FAST_RUN,device=gpu,floatX=float32"
import theano
from keras.models import Sequential 
from keras.layers import Dense
from keras.layers import Dropout
from keras.layers import Flatten
import keras
import pandas as pd
import csv
from random import shuffle
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
from sklearn import preprocessing
min_max_scaler = preprocessing.MinMaxScaler()
seed = 7
np.random.seed(seed)
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.datasets import make_moons, make_circles, make_classification
from sklearn.neural_network import MLPClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.gaussian_process import GaussianProcessClassifier
from sklearn.gaussian_process.kernels import RBF
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis

def readSpecFeature(file_name):
    content = sio.loadmat(file_name)
    return content['fullspecData']

def readSpatiaFeature(file_name):
    content = sio.loadmat(file_name)
    return content['spatialMat']

def loadSpatialData(species, dictPath = '../data/dictionary.csv', dictionary = None):
    if dictionary is None:
        dictionary = pd.read_csv(dictPath)
    listSpecies = dictionary['species']
    index = listSpecies[listSpecies == species].index[0]
    firstPath = dictionary['1st_spatial_path'][index]
    secondPath = dictionary['2st_spatial_path'][index]
    firstFeatures = readSpatiaFeature(firstPath)
    secondFeatures = readSpatiaFeature(secondPath)
    return np.concatenate((firstFeatures, secondFeatures), axis = 0)

def loadSpecData(species, dictPath = '../data/dictionary.csv', dictionary = None):
    if dictionary is None:
        dictionary = pd.read_csv(dictPath)
    listSpecies = dictionary['species']
    index = listSpecies[listSpecies == species].index[0]
    firstPath = dictionary['1st_spec_path'][index]
    secondPath = dictionary['2st_spec_path'][index]
    firstFeatures = readSpecFeature(firstPath)
    secondFeatures = readSpecFeature(secondPath)
    return np.concatenate((firstFeatures, secondFeatures), axis = 0)

def separate(data, trainRatio = 0.84):
    np.random.shuffle(data)
    trainingData = data[0:int(trainRatio*data.shape[0])]
    testingData = data[int(trainRatio*data.shape[0]): data.shape[0]]
    return trainingData, testingData

def generateDatasetForBinaryClassification(speciesPosition, posTraining, negTraining, val):
    nFeatures = posTraining.shape[2]
    posSamples = posTraining[speciesPosition, :, :]
    posLabels = np.asarray([0] * (posSamples.shape[0])).T
    negPositions = np.asarray(range(0, speciesPosition) + range(speciesPosition + 1, posTraining.shape[0]))
    # print negPositions
    negSamples = negTraining[negPositions, :, :]
    negSamples = negSamples.reshape((nClasses - 1) * nNegTrainingSamples, nFeatures)
    # print negSamples.shape
    negLabels = np.asarray([1] * (posSamples.shape[0])).T
    allTrainData = np.concatenate((posSamples, negSamples), axis = 0)
    allTrainLabels = np.concatenate((posLabels, negLabels), axis = 0)

    posTestSamples = val[speciesPosition, :, :]
    posTestLabels = np.asarray([0] * (posTestSamples.shape[0])).T
    negTestSamples = val[negPositions, :, :]
    negTestSamples = negTestSamples.reshape((nClasses - 1) * nTestSamples, nFeatures)
    negTestLabels = np.asarray([1] * (negTestSamples.shape[0])).T
    allTestData = np.concatenate((posTestSamples, negTestSamples), axis = 0)
    allTestLabels = np.concatenate((posTestLabels, negTestLabels), axis = 0)
    return allTrainData, allTrainLabels, allTestData, allTestLabels

def simpleNetModel(nFeatures):
    model = Sequential()
    model.add(Dense(100, input_dim=nFeatures, init='uniform', activation='relu'))
    model.add(Dense(200, init='uniform', activation='relu'))
    model.add(Dropout(0.25))
    model.add(Dense(200, init='uniform', activation='relu'))
    model.add(Dropout(0.25))
    model.add(Dense(1, init='uniform', activation='sigmoid'))

    # Compile model
    model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
    return model

def trainTestSaperate(data, trainRatio, negRatio, nFeatures):
    for i in range (0, data.shape[0]):
        if i == 0:
            posTraining, val = separate(data[i, :, :], trainRatio)
            negTraining, _ = separate(posTraining, negRatio)
        else:
            posTrainingTemp, valTemp = separate(data[i, :, :], trainRatio)
            posTraining = np.concatenate((posTraining, posTrainingTemp),axis = 0)
            val = np.concatenate((val, valTemp), axis = 0)
            negTrainingTemp, _ = separate(posTrainingTemp, negRatio)
            negTraining = np.concatenate((negTraining, negTrainingTemp), axis = 0)
    posTraining = posTraining.reshape(nClasses, nTrainingSamples, nFeatures)
    val = val.reshape(nClasses, nTestSamples, nFeatures)
    negTraining = negTraining.reshape(nClasses, nNegTrainingSamples, nFeatures)
    return posTraining, val, negTraining

names = ["Nearest Neighbors", "Gaussian Process",
         "Decision Tree", "Random Forest", "Neural Net", "AdaBoost",
         "Naive Bayes", "QDA"]
FIELD_NAMES = ["Cnn", "Nearest Neighbors", "Gaussian Process",
         "Decision Tree", "Random Forest", "Neural Net", "AdaBoost",
         "Naive Bayes", "QDA"]         

# names = ["Nearest Neighbors", "Linear SVM", "RBF SVM", "Gaussian Process",
#          "Decision Tree", "Random Forest", "Neural Net", "AdaBoost",
#          "Naive Bayes", "QDA"]


classifiers1 = [
    KNeighborsClassifier(15),
    # SVC(kernel="linear", C=0.025, probability=True),
    # SVC(gamma=2, C=1, probability=True),
    GaussianProcessClassifier(1.0 * RBF(1.0), warm_start=True),
    DecisionTreeClassifier(max_depth=10),
    RandomForestClassifier(max_depth=10, n_estimators=10, max_features=6),
    MLPClassifier(alpha=1),
    AdaBoostClassifier(),
    GaussianNB(),
    QuadraticDiscriminantAnalysis()]

classifiers2 = [
    KNeighborsClassifier(15),
    # SVC(kernel="linear", C=0.025, probability=True),
    # SVC(gamma=2, C=1, probability=True),
    GaussianProcessClassifier(1.0 * RBF(1.0), warm_start=True),
    DecisionTreeClassifier(max_depth=10),
    RandomForestClassifier(max_depth=10, n_estimators=10, max_features=240),
    MLPClassifier(alpha=1),
    AdaBoostClassifier(),
    GaussianNB(),
    QuadraticDiscriminantAnalysis()]

dictionary = pd.read_csv('../data/dictionary.csv')

# group1 = ['NDC1', 'NV1', 'NepCoTien', 'NepThomBacHai', 'NepThomHungYen', 'NepDacSanLienHoa']
group2 = ['BC15', 'KimCuong111', 'NBK', 'NBP', 'NPT1', 'TB13']
# group3 = ['CL61' , 'PD211', 'R068', 'SHPT1', 'SVN1']
# group4 = ['NT16', 'BQ10', 'KB16', 'VH8', 'PC10', 'NH92']

nSpecFeatures = 256
nSpatialFeatures = 6
# nClasses = len(groups)
groups = [ group2]
# groups = [group1, group2, group3, group4]
for g in range(0, len(groups)):
    group = groups[g]
    nClasses = len(group)
    for c in range(0, nClasses):
        if c == 0:
            specData = loadSpecData(group[c])
            spatialData = loadSpatialData(group[c])
        else:
            dataTemp = loadSpecData(group[c])
            specData = np.concatenate((specData, dataTemp), axis = 0)

            dataTemp = loadSpatialData(group[c])
            spatialData = np.concatenate((spatialData, dataTemp), axis = 0)

    nSamples = spatialData.shape[0]/nClasses
    trainRatio = 0.84
    negRatio = 0.2
    nTrainingSamples = int(trainRatio * nSamples)
    nTestSamples = nSamples - nTrainingSamples
    nNegTrainingSamples = int(negRatio * nTrainingSamples)

    
    # nomarlization
    for i in range(0, nSpecFeatures):
        specData[:,i] = min_max_scaler.fit_transform(specData[:, i])

    specData = specData.reshape(nClasses, nSamples, nSpecFeatures)

    for i in range(0, nSpatialFeatures):
        spatialData[:,i] = min_max_scaler.fit_transform(spatialData[:, i])

    spatialData = spatialData.reshape(nClasses, nSamples, nSpatialFeatures)

    for count in range(0,5):    
        # separate data
        spatialPosTraining, spatialVal, spatialNegTraining = trainTestSaperate(spatialData, trainRatio, negRatio, nSpatialFeatures)
        specPosTraining, specVal, specNegTraining = trainTestSaperate(specData, trainRatio, negRatio, nSpecFeatures)

        #generate binary data
        for i in range(0, nClasses):
            spatialResult = list()
            specResult = list()
            for k in range(0,1):
                for j in [1, 2]:
                    if j == 1:
                        allTrainData, allTrainLabels, allTestData, allTestLabels =generateDatasetForBinaryClassification(i, spatialPosTraining, spatialNegTraining, spatialVal)
                        nFeatures = nSpatialFeatures
                        index = range(0, allTrainData.shape[0])
                        shuffle(index)
                        allTrainData = allTrainData[index, :]
                        allTrainLabels = allTrainLabels[index]
                        spatialScores = list()

                        model = simpleNetModel(nFeatures)  
                        history = model.fit(allTrainData, allTrainLabels, validation_data = (allTestData,allTestLabels), epochs=150, batch_size=40, verbose = 1)
                        spatialCNNScores = model.evaluate(allTestData, allTestLabels)
                        # plt.plot(history.history['acc'])
                        # plt.plot(history.history['val_acc'])
                        # plt.title('model accuracy')
                        # plt.ylabel('accuracy')
                        # plt.xlabel('epoch')
                        # plt.legend(['train', 'test'], loc='upper left')
                        # plt.show()
                        # # summarize history for loss
                        # plt.plot(history.history['loss'])
                        # plt.plot(history.history['val_loss'])
                        # plt.title('model loss')
                        # plt.ylabel('loss')
                        # plt.xlabel('epoch')
                        # plt.legend(['train', 'test'], loc='upper left')
                        # plt.show()
                        print("\n%s: %.2f%%" % (model.metrics_names[1], spatialCNNScores[1]*100))

                        spatialScores.append(spatialCNNScores[1])
                        for idx,(name, clf) in enumerate(zip(names, classifiers1)):
                            clf.fit(allTrainData, allTrainLabels)
                            score = clf.score(allTestData, allTestLabels)
                            spatialScores.append(score)
                            print name+' score: '+str(score)
                    else :
                        allTrainData, allTrainLabels, allTestData, allTestLabels =generateDatasetForBinaryClassification(i, specPosTraining, specNegTraining, specVal)
                        nFeatures = nSpecFeatures
                        index = range(0, allTrainData.shape[0])
                        shuffle(index)
                        allTrainData = allTrainData[index, :]
                        allTrainLabels = allTrainLabels[index]
                        specScores = list()

                        model = simpleNetModel(nFeatures)   
                        history = model.fit(allTrainData, allTrainLabels, validation_data = (allTestData,allTestLabels), epochs=225, batch_size=40, verbose = 1)
                        specCNNScores = model.evaluate(allTestData, allTestLabels)
                        print("\n%s: %.2f%%" % (model.metrics_names[1], specCNNScores[1]*100))
                        # plt.plot(history.history['acc'])
                        # plt.plot(history.history['val_acc'])
                        # plt.title('model accuracy')
                        # plt.ylabel('accuracy')
                        # plt.xlabel('epoch')
                        # plt.legend(['train', 'test'], loc='upper left')
                        # plt.show()
                        # # summarize history for loss
                        # plt.plot(history.history['loss'])
                        # plt.plot(history.history['val_loss'])
                        # plt.title('model loss')
                        # plt.ylabel('loss')
                        # plt.xlabel('epoch')
                        # plt.legend(['train', 'test'], loc='upper left')
                        # plt.show()
                        specScores.append(specCNNScores[1])
                        for idx,(name, clf) in enumerate(zip(names, classifiers2)):
                            clf.fit(allTrainData, allTrainLabels)
                            score = clf.score(allTestData, allTestLabels)
                            specScores.append(score)
                            print name+' score: '+str(score)
                spatialResult.append(spatialScores)
                specResult.append(specScores)
            spatialResult = np.asarray(spatialResult)
            specResult = np.asarray(specResult)
            fileNames = '../Result/Group_v2' + str(g) + '/time_' + str(count) + 'spatial' +'_sp_' + group[i] + '.csv'
            if not os.path.exists('../Result/Group_v2' + str(g)):
                os.makedirs('../Result/Group_v2' + str(g))
            with open(fileNames, 'wb') as dictFile:
                # print '--------------------------------------------------------------------------'
                writer = csv.writer(dictFile)
                writer.writerow(FIELD_NAMES)
                writer.writerows(spatialResult)
            fileNames = '../Result/Group_v2' + str(g) + '/time_' + str(count) + 'spec' +'_sp_' + group[i] + '.csv'
            with open(fileNames, 'wb') as dictFile:
                writer = csv.writer(dictFile)
                writer.writerow(FIELD_NAMES)
                writer.writerows(specResult)


