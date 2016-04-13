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
%            pseudoSpectrum: [MUSIC_SPECTRUM_LENGTHx1 double]
%                      angles: [MUSIC_SPECTRUM_LENGTHx1 double]
%                maximaLocs: [2x1 double]


KalmanFlag = false;
ExponentialMovingAverageFlag = false;
inputFlag = false;
computeMUSICUsingPDP = false;
computeMUSICUsingCSI = false;
computeMUSICUsingOneChannelCSI = false;
computeMUSICUsingSpotFi = false;
periodicalSoundSignal = false;
showFigure = true;
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

% load the sound track
load handel.mat

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
    inputStruct = load(INPUT_FILE_NAME);
    input = inputStruct.LOG_DATA;
end
if strcmp(COMPUTE_MUSIC_USING, 'PDP')
    computeMUSICUsingPDP = true;
elseif strcmp(COMPUTE_MUSIC_USING, 'CSI')
    computeMUSICUsingCSI = true;
elseif strcmp(COMPUTE_MUSIC_USING, 'OneChannelCSI')
    computeMUSICUsingOneChannelCSI = true;
elseif strcmp(COMPUTE_MUSIC_USING, 'SpotFi')
    computeMUSICUsingSpotFi = true;
end
periodicalSoundSignal = PERIODICAL_SOUND_SIGNAL;
showFigure = SHOW_FIGURE;

if showFigure
    figure;
end

% sampleData = getCSIData;
% fieldNames = fieldnames(sampleData);

LOG_DATA = {};
matrixForMUSIC = [];
LOG_DATA_BUFF = {};

if KalmanFlag
    %%%%%%%%%%%%%%%%%%% Kalman Filtering %%%%%%%%%%%%%%%
    % initial parameters
    Q = 0.00001; % process variance
    R = 0.1; % estimate of measurement variance
    xInitialGuess = 0.0; % true value initial guess
    pInitialGuess = 0.3; % error initial guess
    
    % initial guess
    spectrumHat = zeros(MUSIC_SPECTRUM_LENGTH, 1); % a posteri estimate of spectrum
    P = zeros(MUSIC_SPECTRUM_LENGTH, 1) + 0.3; % a posteri error estimate
    spectrumHatminus = zeros(MUSIC_SPECTRUM_LENGTH, 1); % a priori estimate of spectrum
    Pminus = zeros(MUSIC_SPECTRUM_LENGTH, 1); % a priori error estimate
    K = 0; % gain or blending factor
    %%%%%%%%%%%%%%%%%%% Kalman Filtering %%%%%%%%%%%%%%%
elseif ExponentialMovingAverageFlag
    %%%%%%%%%%%%% Exponential Moving Average %%%%%%%%%%%%%%
    prePseudoSpectrum = zeros(MUSIC_SPECTRUM_LENGTH, 1);
    %%%%%%%%%%%%% Exponential Moving Average %%%%%%%%%%%%%%
end

while true
  % -------- Make decision on offline/online processing
  if ~inputFlag
    csiData = getCSIData;
  elseif inputIndex <= length(input)
    csiData = input{inputIndex};
    inputIndex = inputIndex + 1;
    if showFigure pause(0.0001);end
  else
    break;
  end

  % --------- construct matrix for MUSIC
  csiMatrix = csiData.csi_matrix;
  nr = csiData.nr;
  nc = csiData.nc;
  num_tones = csiData.num_tones;

  % check the correctness of the data and drop data that is not valid
  csiMatrixSize = [nr, nc, num_tones];
  if ~all(csiMatrixSize)
    continue;
  end

  howManyTxToUse = NUM_OF_TX_ANTENNAS_TO_USE; % you can set this variable to limit the number of data from different tx antennas
  vectorForMUSIC = [];
  for i = 1:nr
    for j = 1:howManyTxToUse % Here the logic is currently wrong.
      csiChannel = reshape(csiMatrix(i, j, :), [1, num_tones]);
      if computeMUSICUsingPDP
          elementForMUSIC = csi2pdp(csiChannel);
      elseif computeMUSICUsingCSI | computeMUSICUsingSpotFi
          elementForMUSIC = csiChannel;
      elseif computeMUSICUsingOneChannelCSI
          elementForMUSIC = csiChannel(1);
      end
    end
    vectorForMUSIC = [vectorForMUSIC; elementForMUSIC];
  end
  [nR, nC] = size(matrixForMUSIC);
  if (~computeMUSICUsingOneChannelCSI) | (nC == ONE_CHANNEL_MUSIC_WINDOW_SIZE)
      matrixForMUSIC = [];
  end
  matrixForMUSIC = [matrixForMUSIC, vectorForMUSIC];
  [nR, nC] = size(matrixForMUSIC);

  err = 0;

  % -------- compute MUSIC
  if length(matrixForMUSIC) & ((~computeMUSICUsingOneChannelCSI) | (nC == ONE_CHANNEL_MUSIC_WINDOW_SIZE))
    if computeMUSICUsingSpotFi
        [pseudoSpectrum, angles, eigenVector, ToFs] = computeMUSICSpectrum(matrixForMUSIC, NUMBER_OF_SIGNAL_PATHES, SEPARATION_DISTANCE, computeMUSICUsingSpotFi, SEPARATION_FREQUENCE, ONE_OVER_TIME_RESOLUTION, SAMPLES_OF_TOFS);
    else
        [pseudoSpectrum, angles, eigenVector] = computeMUSICSpectrum(matrixForMUSIC, NUMBER_OF_SIGNAL_PATHES, SEPARATION_DISTANCE, computeMUSICUsingSpotFi, SEPARATION_FREQUENCE, ONE_OVER_TIME_RESOLUTION, SAMPLES_OF_TOFS);
    end

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
    if computeMUSICUsingSpotFi
        dataAoA.ToFRange = [ToFs(1), ToFs(length(ToFs))];
        dataAoA.dataSize = size(dataAoA.data);
    else
        dataAoA.length = length(pseudoSpectrum);
    end

    if showFigure
        [plotData err] = plotAoA(dataAoA, PLOT_AOA_RADIUS, PLOT_AOA_RADIUS_SCALE, computeMUSICUsingSpotFi);
        drawnow;
        localMaximasLocs = plotData.localMaximasLocations;
    else
        if computeMUSICUsingSpotFi
            localMaximasLocs = findLocalMaximaIn2DMatrix(dataAoA.data);
        else
            [localMaximas, localMaximasLocs] = findpeaks(dataAoA.data);
        end
        if isempty(localMaximasLocs)
            localMaximasLocs = 1;
        end
    end
  end
  if err ~= 0
    return;
  end

  if length(LOG_PARA)
    csiData.ntxused = howManyTxToUse;
    csiData.eigenVector = eigenVector;
    if computeMUSICUsingOneChannelCSI
        LOG_DATA_BUFF = [LOG_DATA_BUFF, csiData];
        if nC == ONE_CHANNEL_MUSIC_WINDOW_SIZE
            for i = 1:length(LOG_DATA_BUFF)
                LOG_DATA_BUFF{i}.pseudoSpectrum = pseudoSpectrum;
                LOG_DATA_BUFF{i}.angles = angles;
                LOG_DATA_BUFF{i}.maximaLocs = localMaximasLocs;
            end
            LOG_DATA = [LOG_DATA, LOG_DATA_BUFF];
            LOG_DATA_BUFF = {};
        end
    else
        csiData.pseudoSpectrum = pseudoSpectrum;
        csiData.angles = angles;
        csiData.maximaLocs = localMaximasLocs;
        LOG_DATA = [LOG_DATA, csiData];
    end
  end

  if periodicalSoundSignal
    if ~mod(length(LOG_DATA),200)
        sound(y,Fs);   
    end
  end
end
