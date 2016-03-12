function LOG_DATA = measureAoAWithKalmanFilter(configFileName, varargin)

% read varargin
KalmanFlag = false;
inputFlag = false;
for i = 1:length(varargin)
    if ischar(varargin{i}) 
        if varargin{i} == 'Kalman'
            KalmanFlag = true;
        end
    else 
        inputIndex = 2;
        inputFlag = true;
        input = varargin{i};
    end
end

eval(configFileName);
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
