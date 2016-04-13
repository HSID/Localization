% This is a script for testing.

clear;
% Load the configuration file.
configFile;

% Basic assertions for checking parameter type errors in configuration file.

% Test the computeMUSICSpectrum function
%%%%% TO DO

% Test the SpotFiSteeringMatrixModify function
%testOriginalCSIMatrix = zeros(3, 56);
%for i = 1:3;
%    testOriginalCSIMatrix(i, :) = i;
%end
%testModifedMatrix = SpotFiSteeringMatrixModify(testOriginalCSIMatrix, 3);
%return;

% Test the SpotFiCSISmooth function
%testOriginalCSIMatrix = zeros(3, 56);
%for i = 1:3
%    for j = 1:56
%        testOriginalCSIMatrix(i,j) = i * 100 + j;
%    end
%end
%testSmoothedMatrix = SpotFiCSISmooth(testOriginalCSIMatrix);
%return;

% Test for the settings in the configuration file.
fprintf('Testing parameters from the configuration file...\n');
measureAoA;

% Test for inverting the bool parameters.
SHOW_FIGURE = ~SHOW_FIGURE;

%READ_DATA_FROM_FILE = ~READ_DATA_FROM_FILE;

PERIODICAL_SOUND_SIGNAL = ~PERIODICAL_SOUND_SIGNAL;

fprintf('Testing with bool parameters inverted...\n');
measureAoA;

% Test for changing the string parameters.
configFile;
SMOOTH_METHOD = 'KalmanFilter';
fprintf('Testing Kalman filtering...\n');
measureAoA;

SMOOTH_METHOD = 'ExponentialMovingAverage';
fprintf('Testing exponential moving average...\n');
measureAoA;

configFile;
COMPUTE_MUSIC_USING = 'CSI';
fprintf('Testing CSI-based MUSIC...\n');
measureAoA;

COMPUTE_MUSIC_USING = 'OneChannelCSI';
fprintf('Testing one-channel-CSI-based MUSIC...\n');
measureAoA;

%COMPUTE_MUSIC_USING = 'SpotFi';
%fprintf('Testing SpotFi-based MUSIC...\n');
%measureAoA;

configFile;
COMPUTE_MUSIC_USING = 'OneChannelCSI';
SMOOTH_METHOD = 'ExponentialMovingAverage';
fprintf('Testing one-channel-CSI-based MUSIC with exponential moving average...\n');
measureAoA;

% Print testing results
fprintf('All tests passed!\n');
