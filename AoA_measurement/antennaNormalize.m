function [normalizedMatrix] = antennaNormalize(originalMatrix)
normalizedMatrix = originalMatrix;
for k = 1:size(originalMatrix, 1)
    normalizedMatrix(k,:) = originalMatrix(k,:)/norm(originalMatrix(k,:));
end
