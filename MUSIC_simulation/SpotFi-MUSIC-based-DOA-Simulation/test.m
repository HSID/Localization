% Test the fft function behavior.
%sample_freq = 100;
%freq_dist = 2;
%sample_period = 1/sample_freq;
%t = (0:sample_period:3-sample_period);
%freqs = (freq_dist:freq_dist:10*freq_dist);
%signal = sum(exp(i*2*pi*freqs'*t), 1);
%ffty = fft(signal);
%length(ffty)
%plot(abs(ffty));
%peakPositions = freqs * length(t)/sample_freq + 1;
%peakPositions
%hold on;
%plot(peakPositions, abs(ffty(peakPositions)), 'ro', 'MarkerSize', 10);

% Test the fft function behavior. 
%sample_freq = 100;
%freqs = (2:2:20);
%t = (0:0.01:4.99);
%signal = sum(exp(-i*2*pi*freqs'*t), 1);
%k = 300;
%tof = 2;
%signalRx = signal(tof+1:tof+k);
%ffty = fft(signalRx);
%plot(abs(ffty));
%channelPositions = k/sample_freq * freqs + 1;
%hold on;
%plot(channelPositions, abs(ffty(channelPositions)), 'ro', 'MarkerSize', 10);
%hold off;
%csiRx = ffty(channelPositions);

% Test the generateSingalMatrix function. (Already checked)
%doas = [0];
%tofs = [2];
%powers = [1];
%antennas = 3;
%separateDist = 0.5;
%X = generateSignalMatrix(doas, tofs, powers, antennas, separateDist);
%assert(all([abs(X(1,:)-X(2,:)) < eps(0.5+0.2j), abs(X(1,:)-X(3,:)) < eps(0.5+0.2j)]), 'the generateSignalMatrix function does not work properly!');
%plot(angle(X(1,:)));

% Test the computeMUSICSpectrum function for classic MUSIC mode. (Already checked)
%doas = [-30, 5, 50];
%tofs = [2, 2, 2];
%powers = [1, 1, 1];
%antennas = 50;
%separateDist = 0.5;
%separateFreq = 2;
%X = generateSignalMatrix(doas, tofs, powers, antennas, separateDist);
%[musicSpectrum, angles] = computeMUSICSpectrum(X, length(doas), separateDist, false, separateFreq);
%plot(angles, musicSpectrum);

% Test the SpotFiCSISmooth function. (Already checked)
%testOriginalCSIMatrix = zeros(5, 30);
%[nAntennas, nChannels] = size(testOriginalCSIMatrix);
%nAntennaSensors = nAntennas-1;
%nChannelSensors = nChannels/2;
%for k = 1:nAntennas
%    for l = 1:nChannels
%        testOriginalCSIMatrix(k,l) = k * 100 + l;
%    end
%end
%testSmoothedMatrix = SpotFiCSISmooth(testOriginalCSIMatrix, nAntennaSensors, nChannelSensors);
%return;

% Test the SpotFiSteeringMatrixModify function. (Already checked)
%testOriginalSteeringMatrix = zeros(5, 30);
%[nAntennas, nSampleAngles] = size(testOriginalSteeringMatrix);
%nAntennaSensors = nAntennas-1;
%nChannelSensors = 28;
%for k = 1:nAntennas;
%    testOriginalSteeringMatrix(k, :) = k;
%end
%testModifedMatrix = SpotFiSteeringMatrixModify(testOriginalSteeringMatrix, nAntennaSensors, nChannelSensors);
%return;

% Test the computeMUSICSpectrum function for SpotFi MUSIC mode. (Already checked)
tStart = cputime;
doas = [-30, 0, 45];
tofs = [21, 11, 33];
powers = [1, 1, 1];
antennas = 15;
channels = 50;
separateDist = 0.5;
separateFreq = 2;
sampleFreq = 200;
sampleToFs = (0:2:50);
freqComponentWeighted = false;
X = generateSignalMatrix(sampleFreq, separateFreq, doas, tofs, powers, antennas, channels, separateDist, freqComponentWeighted);
[musicSpectrum, angles, TOFs] = computeMUSICSpectrum(X, length(doas), separateDist, true, separateFreq, sampleFreq, sampleToFs);
colormap('hot');
imagesc(musicSpectrum);
tEnd = cputime;
tEnd - tStart
