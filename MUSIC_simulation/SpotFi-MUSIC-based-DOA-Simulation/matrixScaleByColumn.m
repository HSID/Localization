function scaledMatrix = matrixScaleByColumn(originalMatrix)
[row, col] = size(originalMatrix);
scaledMatrix = originalMatrix;
for k = 1:col
    maxVal = max(originalMatrix(:,k));
    minVal = min(originalMatrix(:,k));
    scaledMatrix(:,k) = (scaledMatrix(:,k) - minVal)./(maxVal - minVal);
end
