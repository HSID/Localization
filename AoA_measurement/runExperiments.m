% This script is used to run experiments in a batch manner
clear;
clc;
tStart = cputime;

% Parameters initialization
KalmanFlag = false;
ExponentialMovingAverageFlag = false;
inputFlag = false;
computeMUSICUsingPDP = false;
computeMUSICUsingCSI = false;
computeMUSICUsingOneChannelCSI = false;
computeMUSICUsingSpotFi = false;
periodicalSoundSignal = false;
showFigure = true;
plotLocalMaximaSpotFiFlag = false;

% read the config file for basic configuring
configFile;

INPUT_FILE_NAME = 'scenario-d-10m-1m-200-ground.mat';
COMPUTE_MUSIC_USING = 'SpotFi';
SAMPLES_OF_TOFS = (0:1:100);
measureAoA;
save('scenario-d-10m-1m-200-ground-SpotFi.mat', 'LOG_DATA');

INPUT_FILE_NAME = 'scenario-d-10m-1m-200-ground-shangxiazuoyou.mat';
measureAoA;
save('scenario-d-10m-1m-200-ground-shangxiazuoyou-SpotFi.mat', 'LOG_DATA');

tEnd = cputime;
tElapse = tEnd - tStart;
