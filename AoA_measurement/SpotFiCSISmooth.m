function smoothedCSIMatrix = SpotFiCSISmooth(originalCSIMatrix, nAntennaSensors, nChannelSensors)
[nR, nC] = size(originalCSIMatrix);
assert(nC >= 2*nChannelSensors, 'nChannelSensors should not exceeds half of the number of actual channels!');
assert(nR > nAntennaSensors, 'nAntennaSensors should not be strictly smaller than the number of actual antennas!');
bufferMatrix = zeros(nChannelSensors, nC-nChannelSensors+1, nR);
for k = 1:nR
    for l = 1:nChannelSensors
        bufferMatrix(l, :, k) = originalCSIMatrix(k, l:l+nC-nChannelSensors);
    end
end
smoothedCSIMatrix = [];
for k = 1:nAntennaSensors
    rowPseudoVector = reshape(bufferMatrix(:,:,k:(k+nR-nAntennaSensors)), nChannelSensors, (nC-nChannelSensors+1)*(nR-nAntennaSensors+1)); 
    smoothedCSIMatrix = [smoothedCSIMatrix; rowPseudoVector];
end
