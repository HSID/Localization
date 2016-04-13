function locationMatrix = findLocalMaximaIn2DMatrix(originalMatrix)
locationMatrix = [];
[nR, nC] = size(originalMatrix);
for j = 1:nR
    for k = 1:nC
        element = originalMatrix(j, k);
        flag = ones(3);
        if j > 1 flag(1, 2) = originalMatrix(j - 1, k) < element; end
        if j < nR flag(3, 2) = originalMatrix(j + 1, k) < element; end
        if k > 1 flag(2, 1) = originalMatrix(j, k - 1) < element; end
        if k < nC flag(2, 3) = originalMatrix(j, k + 1) < element; end
        if all(all(flag)) locationMatrix = [locationMatrix, [j; k]]; end
        end
    end
