function smoothedCSIMatrix = SpotFiCSISmooth(originalCSIMatrix)
[nR, nC] = size(originalCSIMatrix);
subMatrix1 = zeros(nC/2, nC/2 + 1);
subMatrix2 = zeros(nC/2, nC/2 + 1);
subMatrix3 = zeros(nC/2, nC/2 + 1);
for i = 1:(nC/2)
    for j = 1:(nC/2 + 1)
        subMatrix1(i,j) = originalCSIMatrix(1, i + j - 1);
        subMatrix2(i,j) = originalCSIMatrix(2, i + j - 1);
        subMatrix3(i,j) = originalCSIMatrix(3, i + j - 1);
    end
end
smoothedCSIMatrix = [subMatrix1, subMatrix2; subMatrix2, subMatrix3];
