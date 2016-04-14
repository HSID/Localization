function nSignificantEigenValues = computeNumberOfSignificantEigenValues(eigenVector)
maxVal = eigenVector(1);
minVal = eigenVector(length(eigenVector));
ascendEigenVector = flip(eigenVector);
diffVector = diff(ascendEigenVector, 1);
nSignificantEigenValues = length(find(diffVector>(maxVal - minVal)/100));
