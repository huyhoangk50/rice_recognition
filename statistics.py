import csv
import pandas as pd
import glob
import numpy as np
import sys

if __name__ == '__main__':
    print sys.argv
    if len(sys.argv) !=3:
        print 'lack of parameters including data_path and output_file'
        print 'python statistics.py data_path output_file'
    else:
        DATA_PATH = '/home/hoangnh/PythonProject/RiceReconization/data/features-VIS/'        
        DATA_PATH = sys.argv[1]

        FIELD_NAMES = ['species', '1st_spatial_path', '2st_spatial_path', '1st_spec_path', '2st_spec_path']
        fileNames = sys.argv[2]
        list_spec_feature_file_path = glob.glob(DATA_PATH + '*fullricespec.mat')
        list_spatial_feature_file_path = glob.glob(DATA_PATH + '*Feat.mat')
        list_spatial_feature_file_path.sort()
        list_spec_feature_file_path.sort()
        aboveLettersNum = len(DATA_PATH) + 4
        bellowLettersNum = 20

        species = list()
        firstSpecFilePath = list()
        secondSpecFilePath = list()

        firstSpatialFilePath = list()
        secondSpatialFilePath = list()
        for i in xrange (len(list_spec_feature_file_path)):
            key = list_spec_feature_file_path[i][aboveLettersNum:-bellowLettersNum]
            if i%2 ==0:
                species.append(key)
                firstSpatialFilePath.append(list_spatial_feature_file_path[i])
                firstSpecFilePath.append(list_spec_feature_file_path[i])
            else:
                secondSpatialFilePath.append(list_spatial_feature_file_path[i])
                secondSpecFilePath.append(list_spec_feature_file_path[i])

        records = np.asarray([species, firstSpatialFilePath, secondSpatialFilePath, firstSpecFilePath, secondSpecFilePath]).T
        # print records.shape
        with open(fileNames, 'wb') as dictFile:
            writer = csv.writer(dictFile)
            writer.writerow(FIELD_NAMES)
            writer.writerows(records)
        print species
        print 'end'

