function scaledMatrix = matrixScale(originalMatrix)
scaledMatrix = originalMatrix;
[row, col] = size(originalMatrix);
originalMatrix = reshape(originalMatrix, [1, row*col]);
maxVal = max(originalMatrix)
minVal = min(originalMatrix)
scaledMatrix = (scaledMatrix - minVal)./(maxVal - minVal);
