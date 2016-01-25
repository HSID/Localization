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
