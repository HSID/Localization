function modifiedMatrix = SpotFiSteeringMatrixModify(originalMatrix, nAntennaSensors, nChannelSensors)
[nSensors, nSamples] = size(originalMatrix);
assert(nSensors > nAntennaSensors, 'nAntennaSensors should not exceed or equal to the nSensors!');
nSensorsNew = nAntennaSensors * nChannelSensors;
modifiedMatrix = zeros(nSensorsNew, nSamples);
for k = 1:nAntennaSensors
    for l = 1:nChannelSensors
        modifiedMatrix((k-1)*nChannelSensors+l, :) = originalMatrix(k, :);
    end
end
