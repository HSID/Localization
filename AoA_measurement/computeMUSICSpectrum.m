function [musicSpectrum, angles] = computeMUSICSpectrum(X, r, d)
[N, K] = size(X);
R = X * X' / K;
[Q, D] = eig(R);
[D, I] = sort(diag(D), 1, 'descend');
Q = Q(:, I);
Qs = Q(:, 1:r);
Qn = Q(:, r+1:N);

angles = (-90:0.1:90);
a1 = exp(-i*2*pi*d*(0:N-1)'*sin([angles(:).']*pi/180));

for k = 1:length(angles)
    musicSpectrum(k) = (a1(:,k)'*a1(:,k))/(a1(:,k)'*Qn*Qn'*a1(:,k));
end
musicSpectrum = abs(musicSpectrum).';
