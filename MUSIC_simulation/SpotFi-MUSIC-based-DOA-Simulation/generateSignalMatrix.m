function X = generateSignalMatrix(sampleFreq, freqDist, doas, tofs, powers, antennas, channels, separateDist, freqComponentWeighted, whiteNoisedBw)
% Generate a CSI matrix for MUSIC simulation
% INPUT:
%   sampleFreq   -- sampling frequency
%   freqDist     -- the difference in frequency between neighboring frequecy components
%   doas         -- vector of angles in degree
%   tofs         -- vector of ToFs in sample periods
%   powers       -- vector of powers
%   antennas     -- number of antennas
%   separateDist -- distance between antennas in terms of lambda
%   freqComponentWeighted -- boolean value to indicate whether or not to randomly weight different frequency components
% OUTPUT:
%   X            -- CSI matrix

sample_freq = sampleFreq;
freq_dist = freqDist;
sample_period = 1/sample_freq;
t = (0:sample_period:2 - sample_period); 
freqs = (freq_dist:freq_dist:channels*freq_dist);
sample_n = length(t)/2;
path_n = length(doas);
assert((sample_n/sample_freq*freq_dist>1) & (mod(sample_n, sample_freq)==0), 'the relation between the number of samples and the sampling frequency does not meet the requirement!');
assert(length(doas)==length(tofs), 'the dimensions of doas and tofs do not agree with each other!');

if freqComponentWeighted
    componentWeight = rand([1, length(freqs)]) * 0.5 + 0.5;
else
    componentWeight = ones(1, length(freqs));
end
signal = sum(diag(componentWeight)*exp(i*2*pi*freqs'*t), 1);
signalMatrixWithToFs = zeros(path_n, sample_n);
for k = 1:path_n
    noiseSignal = wgn(1, sample_n, whiteNoisedBw);
    signalMatrixWithToFs(k, :) = signal((tofs(k)+1):(tofs(k)+sample_n)) + noiseSignal;
end
A=exp(i*2*pi*separateDist*(0:antennas-1)'*sin([doas(:).']*pi/180));
signalMatrix = A*diag(sqrt(powers))*signalMatrixWithToFs;

X = zeros(antennas, length(freqs));
for k = 1:antennas
    ffty = fft(signalMatrix(k,:));
    channelPositions = sample_n/sample_freq * freqs + 1;
    X(k,:) = ffty(channelPositions);
end
