% This is the configure file for the matlab version of the localization project

% LOG_PARA is the flag to tell the program whether or not and how to log the data into files.
LOG_PARA = {'all'};

% PLOT_AOA_RADIUS is the radius value for visualize the AoA.
PLOT_AOA_RADIUS = 10;
% PLOT_AOA_RADIUS_SCALE is the rate between the maxSpectrumPower and the plotRadius.
PLOT_AOA_RADIUS_SCALE = 0.8;

% NUM_OF_TX_ANTENNAS_TO_USE
NUM_OF_TX_ANTENNAS_TO_USE = 1;
% INDICES_OF_RX_ANTENNAS_TO_USE is the index array of receiving antennas to be used.
INDICES_OF_REC_ANTENNAS_TO_USE = [1, 2, 3];
% INDICES_OF_TX_ANTENNAS_TO_USE is the index array of transmitting antennas to be used.
INDICES_OF_TX_ANTENNAS_TO_USE = [1, 2, 3];

% MUSIC_SPECTRUM_LENGTH
MUSIC_SPECTRUM_LENGTH = length(-90:0.1:90);

% SMOOTH_METHOD 'ExponentialMovingAverage' 'KalmanFilter'
SMOOTH_METHOD = 'None';
% WEIGHT_FOR_EXPONENTIAL_MOVING_AVERAGE between 0 and 1
WEIGHT_FOR_EXPONENTIAL_MOVING_AVERAGE = 0.5;
% READ_DATA_FROM_FILE
READ_DATA_FROM_FILE = true;
% INPUT_FILE_NAME
INPUT_FILE_NAME = 'test.mat';

% PERIODICAL_SOUND_SIGNAL
PERIODICAL_SOUND_SIGNAL = false;

% SHOW_FIGURE
SHOW_FIGURE = true;

% COMPUTE_MUSIC_USING 'PDP' 'CSI' 'OneChannelCSI' 'SpotFi'
COMPUTE_MUSIC_USING = 'PDP';

% ONE_CHANNEL_MUSIC_WINDOW
ONE_CHANNEL_MUSIC_WINDOW_SIZE = 20;

% NUMBER_OF_SIGNAL_PATHES
NUMBER_OF_SIGNAL_PATHES = 1;

% SEPARATION_DISTANCE (in terms of lambdas)
SEPARATION_DISTANCE = 0.5;

% SEPARATION_FREQUENCE (in terms of Hertz)
SEPARATION_FREQUENCE = 312500;

% ONE_OVER_TIME_RESOLUTION
ONE_OVER_TIME_RESOLUTION = 10^9;

% SAMPLES_OF_TOFS in terms of how many time units/resolutions e.g. nanoseconds.
SAMPLES_OF_TOFS = (0:1:50);
