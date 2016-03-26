% function LOG_DATA = measureAoA(configFileName, varargin)
%   INPUT:  configFileName                  -- type of string
%           ['KalmanFilter']                      -- indicating using the Kalman filtering
%           ['ExponentialMovingAverage']    -- indicating using the exponential moving average
%           [weight]                        -- type of float. The weight for exponential moving average.
%           [mfileName]                     -- indicating using mfile as input. Offline processing.
%   OUTPUT: LOG_DATA                        -- type of cell. The data structure to save the log data.
%               structure of LOG_DATA:
%                   channel: 2437
%                    chanBW: 0
%                      rate: 142
%                        nr: 3
%                        nc: 2
%                 num_tones: 56
%                      rssi: 51
%                    rssi_0: 44
%                    rssi_1: 48
%                    rssi_2: 45
%               payload_len: 124
%                csi_matrix: [3x2x56 double]
%                   ntxused: 1
%            pseudoSpectrum: [256x1 double]
%                      freq: [256x1 double]
%                maximaLocs: [2x1 double]


KalmanFlag = false;
ExponentialMovingAverageFlag = false;
inputFlag = false;
%for i = 1:length(varargin)
%    if ischar(varargin{i}) 
%        if strcmp(varargin{i}, 'KalmanFilter');
%            KalmanFlag = true;
%        else strcmp(varargin{i}, 'ExponentialMovingAverage');
%            ExponentialMovingAverageFlag = true;
%        end
%    elseif isfloat(varargin{i}) 
%        if ExponentialMovingAverageFlag
%            weightForExponentialMovingAverage = varargin{i};
%        end
%    else
%        inputIndex = 1;
%        inputFlag = true;
%        input = varargin{i};
%    end
%end

% read config file
configFile;

% set the flags
if strcmp(SMOOTH_METHOD, 'KalmanFilter')
    KalmanFlag = true;
elseif strcmp(SMOOTH_METHOD, 'ExponentialMovingAverage')
    ExponentialMovingAverageFlag = true;
    weightForExponentialMovingAverage = WEIGHT_FOR_EXPONENTIAL_MOVING_AVERAGE;
end
if READ_DATA_FROM_FILE
    inputIndex = 1;
    inputFlag = true;
    input = load(INPUT_FILE_NAME);
end

figure;

% sampleData = getCSIData;
% fieldNames = fieldnames(sampleData);

LOG_DATA = {};

if KalmanFlag
    %%%%%%%%%%%%%%%%%%% Kalman Filtering %%%%%%%%%%%%%%%
    % initial parameters
    Q = 0.00001; % process variance
    R = 0.1; % estimate of measurement variance
    xInitialGuess = 0.0; % true value initial guess
    pInitialGuess = 0.3; % error initial guess
    
    % initial guess
    spectrumHat = zeros(256, 1); % a posteri estimate of spectrum
    P = zeros(256, 1) + 0.3; % a posteri error estimate
    spectrumHatminus = zeros(256, 1); % a priori estimate of spectrum
    Pminus = zeros(256, 1); % a priori error estimate
    K = 0; % gain or blending factor
    %%%%%%%%%%%%%%%%%%% Kalman Filtering %%%%%%%%%%%%%%%
elseif ExponentialMovingAverageFlag
    %%%%%%%%%%%%% Exponential Moving Average %%%%%%%%%%%%%%
    prePseudoSpectrum = zeros(256, 1);
    %%%%%%%%%%%%% Exponential Moving Average %%%%%%%%%%%%%%
end

while true
  if ~inputFlag
    csiData = getCSIData;
  elseif inputIndex <= length(input)
    csiData = input{inputIndex};
    inputIndex = inputIndex + 1;
    pause(0.2);
  else
    break;
  end

  csiMatrix = csiData.csi_matrix;
  nr = csiData.nr;
  nc = csiData.nc;
  num_tones = csiData.num_tones;

  % check the correctness of the data
  csiMatrixSize = [nr, nc, num_tones];
  if ~all(csiMatrixSize)
    continue;
  end

  howManyTxToUse = NUM_OF_TX_ANTENNAS_TO_USE; % you can set this variable to limit the number of data from different tx antennas
  pdpMatrix = [];
  for i = 1:nr
    for j = 1:howManyTxToUse
      csiChannel = reshape(csiMatrix(i, j, :), [1, num_tones]);
      pdp = csi2pdp(csiChannel);
      pdpMatrix = [pdpMatrix; pdp];
    end
  end

  err = 0;

  if length(pdpMatrix)
    [pseudoSpectrum, freq] = pmusic(pdpMatrix', 1);

    if KalmanFlag
        %%%%%%%%%%%%%%%%%% Kalman Filtering %%%%%%%%%%%%%%%%%%%
        % time update
        spectrumHatminus = spectrumHat;
        Pminus = P + Q;

        % measurement update
        K = Pminus ./ (Pminus + R);
        spectrumHat = spectrumHatminus + K .* (pseudoSpectrum - spectrumHatminus);
        P = (1 - K) .* Pminus;
        pseudoSpectrum = spectrumHat;
        %%%%%%%%%%%%%%%%%% Kalman Filtering %%%%%%%%%%%%%%%%%%%
    elseif ExponentialMovingAverageFlag
        %%%%%%%%%%%%% Exponential Moving Average %%%%%%%%%%%%%%
        pseudoSpectrum = (1 - weightForExponentialMovingAverage) .* prePseudoSpectrum + weightForExponentialMovingAverage .* pseudoSpectrum;
        prePseudoSpectrum = pseudoSpectrum;
        %%%%%%%%%%%%% Exponential Moving Average %%%%%%%%%%%%%%
    end

    dataAoA.data = pseudoSpectrum;
    dataAoA.range = [0 180];
    dataAoA.length = length(pseudoSpectrum);

    [plotData err] = plotAoA(dataAoA, PLOT_AOA_RADIUS, PLOT_AOA_RADIUS_SCALE);
    drawnow;
  end
  if err ~= 0
    return;
  end

  if length(LOG_PARA)
    csiData.ntxused = howManyTxToUse;
    csiData.pseudoSpectrum = pseudoSpectrum;
    csiData.freq = freq;
    csiData.maximaLocs = plotData.localMaximasLocations;
    LOG_DATA = [LOG_DATA, csiData];
  end
end
