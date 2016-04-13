function [musicSpectrum, angles, varargout] = computeMUSICSpectrum(X, r, d, SpotFiFlag, separateFreq, sampleFreq, sampleToFs)
% apply the MUSIC algorithm.
% INPUT:
%       X -- the Signal Matrix with rows represent different samples obtained from the same sensor and columns represent the samples cross different sensors at the same time.
%       r -- the number of signal pathes.
%       d -- the distance between two neighbour sensors in terms of lambdas.
%       SpotFiFlag -- indicate whether or not using the SpotFi algorithm.
%       separateFreq -- the distance between neighbouring channels.
%       sampleFreq -- sampling frequency.
%       sampleToFs -- vector of sampling ToFs in terms of how many sampling periods.

% Check the correctness of parameters
if ~SpotFiFlag & (nargout > 2) error('Excessive Output Argument for classic MUSIC!'); end

[NAntenna, NSample] = size(X);
if SpotFiFlag
    nSpotFiAntennaSensors = NAntenna-1;
    nSpotFiChannelSensors = NSample/2;
    X = SpotFiCSISmooth(X, nSpotFiAntennaSensors, nSpotFiChannelSensors);
end
[N, K] = size(X);

R = X * X' / K;
[Q, D] = eig(R);
[D, I] = sort(diag(D), 1, 'descend');
Q = Q(:, I);
Qs = Q(:, 1:r);
Qn = Q(:, r+1:N);

angles = (-90:0.1:90); % in terms of degree
a1 = exp(i*2*pi*d*(0:NAntenna-1)'*sin([angles(:).']*pi/180));
if ~SpotFiFlag
    musicSpectrum = zeros(length(angles), 1);
    for k = 1:length(angles)
        musicSpectrum(k) = (a1(:,k)'*a1(:,k))/(a1(:,k)'*Qn*Qn'*a1(:,k));
    end
else
    ToFs = sampleToFs/sampleFreq;
    musicSpectrum = zeros(length(angles), length(ToFs));
    a2 = SpotFiSteeringMatrixModify(a1, nSpotFiAntennaSensors, nSpotFiChannelSensors);
    a3 = [];
    a3_element = exp(i*2*pi*separateFreq*(0:nSpotFiChannelSensors-1)'*ToFs);
    for k = 1:nSpotFiAntennaSensors
        a3 = [a3;a3_element];
    end
    for tauID = 1:length(ToFs)
        for thetaID = 1:length(angles)
            a4 = a2(:,thetaID).*a3(:,tauID);
            musicSpectrum(thetaID, tauID) = (a4'*a4)/(a4'*Qn*Qn'*a4);
        end
    end
end

if (nargout > 2) varargout{3} = ToFs; end

musicSpectrum = abs(musicSpectrum);
