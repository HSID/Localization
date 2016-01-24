figure;
configFile;
while true
  csiData = getCSIMatrix;
  csiMatrix = csiData.csi_matrix;
  csiChannel = reshape(csiMatrix(1, 1, :), [1, 56]);
  pdp = csi2pdp(csiChannel);

  [pseudoSpectrum, freq] = pmusic(pdp, 1);

  dataAoA.data = pseudoSpectrum;
  dataAoA.range = [0 360];
  dataAoA.length = length(pseudoSpectrum);

  [plotData err] = plotAoA(dataAoA, PLOT_AOA_RADIUS, PLOT_AOA_RADIUS_SCALE);
  drawnow;
  %pause(0.2);
  if err ~= 0
    return;
  end
end
