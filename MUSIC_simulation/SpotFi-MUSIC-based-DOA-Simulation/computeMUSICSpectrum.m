function [musicSpectrum, angles, varargout] = computeMUSICSpectrum(X, r, d, SpotFiFlag, separateFreq, sampleFreq, sampleAngles, sampleToFs)
% apply the MUSIC algorithm.
% INPUT:
%       X -- the Signal Matrix with rows represent different samples obtained from the same sensor and columns represent the samples cross different sensors at the same time.
%       r -- the number of signal pathes.
%       d -- the distance between two neighbour sensors in terms of lambdas.
%       SpotFiFlag -- indicate whether or not using the SpotFi algorithm.
%       separateFreq -- the distance between neighbouring channels.
%       sampleFreq -- sampling frequency.
%       sampleAngles -- vector of sampling angles in degrees.
%       sampleToFs -- vector of sampling ToFs in terms of how many sampling periods.
% OUTPUT:
%       musicSpectrum -- the music spectrum with size depend on the SpotFiFlag.
%       angles        -- the angles according to the musicSpectrum.
%       eigenValues   -- the vector of eigenValues from MUSIC.
%       numberOfPathes -- the number of signal pathes computed by computeNumberOfSignificantEigenValues function.
%       ToFs          -- the ToFs according to the musicSpectrum when SpotFi is enabled.

% Check the correctness of parameters
if ~SpotFiFlag & (nargout > 4) error('Excessive Output Argument for classic MUSIC!'); end

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
r = computeNumberOfSignificantEigenValues(D);
Q = Q(:, I);
Qs = Q(:, 1:r);
Qn = Q(:, r+1:N);

angles = sampleAngles; % in terms of degree
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

if (nargout == 3) varargout{1} = D; end
if (nargout == 4) varargout{1} = D; varargout{2} = r; end
if (nargout == 5) varargout{1} = D; varargout{2} = r; varargout{3} = ToFs; end

musicSpectrum = abs(musicSpectrum);
