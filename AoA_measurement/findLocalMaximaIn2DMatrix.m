function locationMatrix = findLocalMaximaIn2DMatrix(originalMatrix)
[row, col] = find(imregionalmax(originalMatrix)==1);
locationMatrix = [row, col];
