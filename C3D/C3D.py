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

def readFullSpecFeature(file_name):
    content = sio.loadmat(file_name)
#     print content
    return content['fullspecData']

def loadFullSpecFeature(species, rootPath = '../data/specData/', timeNum = 2, seedsNum = 48):
    data = list()
    for time in range(0, timeNum):
        for seed in range(0,seedsNum):
            file_name = rootPath + species + '-0' + str(time +1) + '/' + str(seed + 1)+"_"+"spec.mat"
#             print file_name
            data.append(readFullSpecFeature(file_name))
    return np.asarray(data)

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

def C3D(summary = False):
        """ Return the Keras model of the network
    """
    model = Sequential()
    # 1st layer group
    model.add(Convolution3D(64, 3, 3, 3, activation='relu', 
                            border_mode='same', name='conv1',
                            subsample=(1, 1, 1), 
                            input_shape=(3, 24, 48, 48)))
    model.add(MaxPooling3D(pool_size=(1, 2, 2), strides=(1, 2, 2), 
                           border_mode='valid', name='pool1'))
    # 2nd layer group
    model.add(Convolution3D(128, 3, 3, 3, activation='relu', 
                            border_mode='same', name='conv2',
                            subsample=(1, 1, 1)))
    model.add(MaxPooling3D(pool_size=(2, 2, 2), strides=(2, 2, 2), 
                           border_mode='valid', name='pool2'))
    # 3rd layer group
    model.add(Convolution3D(256, 3, 3, 3, activation='relu', 
                            border_mode='same', name='conv3a',
                            subsample=(1, 1, 1)))
    model.add(Convolution3D(256, 3, 3, 3, activation='relu', 
                            border_mode='same', name='conv3b',
                            subsample=(1, 1, 1)))
    model.add(MaxPooling3D(pool_size=(2, 2, 2), strides=(2, 2, 2), 
                           border_mode='valid', name='pool3'))
    # 4th layer group
    model.add(Convolution3D(512, 3, 3, 3, activation='relu', 
                            border_mode='same', name='conv4a',
                            subsample=(1, 1, 1)))
    model.add(Convolution3D(512, 3, 3, 3, activation='relu', 
                            border_mode='same', name='conv4b',
                            subsample=(1, 1, 1)))
    model.add(MaxPooling3D(pool_size=(2, 2, 2), strides=(2, 2, 2), 
                           border_mode='valid', name='pool4'))
    # 5th layer group
    model.add(Convolution3D(512, 3, 3, 3, activation='relu', 
                            border_mode='same', name='conv5a',
                            subsample=(1, 1, 1)))
    model.add(Convolution3D(512, 3, 3, 3, activation='relu', 
                            border_mode='same', name='conv5b',
                            subsample=(1, 1, 1)))
    model.add(ZeroPadding3D(padding=(0, 1, 1)))
    model.add(MaxPooling3D(pool_size=(2, 2, 2), strides=(2, 2, 2), 
                           border_mode='valid', name='pool5'))
    model.add(Flatten())
    # FC layers group
    model.add(Dense(4096, activation='relu', name='fc6'))
    model.add(Dropout(.5))
    model.add(Dense(4096, activation='relu', name='fc7'))
    model.add(Dropout(.5))
    model.add(Dense(487, activation='softmax', name='fc8'))
    if summary:
        print(model.summary())
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

# names = ["Nearest Neighbors", "Linear SVM", "RBF SVM", "Gaussian Process",
#          "Decision Tree", "Random Forest", "Neural Net", "AdaBoost",
#          "Naive Bayes", "QDA"]



# dictionary = pd.read_csv('../data/dictionary.csv')

# group1 = ['NDC1', 'NV1', 'NepCoTien', 'NepThomBacHai', 'NepThomHungYen', 'NepDacSanLienHoa']
# group2 = ['BC15', 'KimCuong111', 'NBK', 'NBP', 'NPT1', 'TB13']
# group3 = ['CL61' , 'PD211', 'R068', 'SHPT1', 'SVN1']
group4 = ['NT16', 'BQ10', 'KB16', 'VietHuong8', 'PC10', 'NH92']

nSpecFeatures = 256
# nClasses = len(groups)
groups = [group4]
# groups = [group1, group2, group3, group4]
for g in range(0, len(groups)):
    group = groups[g]
    nClasses = len(group)
    for c in range(0, nClasses):
        if c == 0:
            specData = loadSpecData(group[c])
        else:
            dataTemp = loadSpecData(group[c])
            specData = np.concatenate((specData, dataTemp), axis = 0)

    nSamples = specData.shape[0]/nClasses
    trainRatio = 0.84
    negRatio = 0.2
    nTrainingSamples = int(trainRatio * nSamples)
    nTestSamples = nSamples - nTrainingSamples
    nNegTrainingSamples = int(negRatio * nTrainingSamples)


    for count in range(0,5):    
        # separate data
        specPosTraining, specVal, specNegTraining = trainTestSaperate(specData, trainRatio, negRatio, nSpecFeatures)

        #generate binary data
        for i in range(0, nClasses):
            spatialResult = list()
            specResult = list()
            for k in range(0,3):
                allTrainData, allTrainLabels, allTestData, allTestLabels =generateDatasetForBinaryClassification(i, specPosTraining, specNegTraining, specVal)
                nFeatures = nSpecFeatures
                index = range(0, allTrainData.shape[0])
                shuffle(index)
                allTrainData = allTrainData[index, :]
                allTrainLabels = allTrainLabels[index]
                specScores = list()

                model = C3D(summary = True)   
                history = model.fit(allTrainData, allTrainLabels, validation_data = (allTestData,allTestLabels), epochs=225, batch_size=40, verbose = 1)
                specCNNScores = model.evaluate(allTestData, allTestLabels)
                print("\n%s: %.2f%%" % (model.metrics_names[1], specCNNScores[1]*100))
                specScores.append(specCNNScores[1])
            specResult = np.asarray(specScores)
            path = '../Result/Group_4' + str(g)
            if not os.path.exists(path):
                os.makedirs(path)
            fileNames = path + '/time_' + str(count) + 'spec' +'_sp_' + group[i] + '.csv'
            with open(fileNames, 'wb') as dictFile:
                writer = csv.writer(dictFile)
                writer.writerow(FIELD_NAMES)
                writer.writerows(specResult)


