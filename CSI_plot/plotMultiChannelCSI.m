function err = plotMultiChannelCSI(CSICell, averageForEachChannel)
% Plot the received CSI CSICell
% INPUT:
%   CSICell               -- the data which is read from files using read_log_file
%   averageForEachChannel -- whether to plot the CSI in an average manner? true or false
% OUTPUT:
%   err -- indicate the successful running of the function.

% Set consts
CSI_CHANNEL_NUM_PER_SAMPLE = 56;
MAX_NR                     = 3;
MAX_NC                     = 3;
HOLD_ON                    = 1;
HOLD_OFF                   = 0;

figure

channelIDArray        = [];
plotDataBuff          = zeros(MAX_NR, MAX_NC, CSI_CHANNEL_NUM_PER_SAMPLE + 1);
samplePerChannelCount = zeros(MAX_NR, MAX_NC);
channelIDBuff         = 0;
csi_channel_id        = [];

for k = 1:length(CSICell)
  CSIData    = CSICell{k};
  channel    = CSIData.channel;
  nr         = CSIData.nr;
  nc         = CSIData.nc;
  num_tones  = CSIData.num_tones;
  bandWidth  = CSIData.bandWidth;
  csi_matrix = CSIData.csi;
  timestamp  = CSIData.timestamp;

  if ~channelIDBuff
    channelIDBuff = channel;
  elseif ~averageForEachChannel || channelIDBuff ~= channel
    [refreshFlag channelIDArray] = refreshOrNot(channelIDArray, channelIDBuff);
    flushAndPlot(csi_channel_id, plotDataBuff, samplePerChannelCount, refreshFlag);
    plotDataBuff = zeros(MAX_NR, MAX_NC, CSI_CHANNEL_NUM_PER_SAMPLE + 1);
    samplePerChannelCount = zeros(MAX_NR, MAX_NC);
    channelIDBuff = channel;
  end

  for i = 1:nr
    for j = 1:nc
      csi_channel = reshape(csi_matrix(i, j, :), [1, CSI_CHANNEL_NUM_PER_SAMPLE]);
      [csi_channel_id csi_channel] = reshapeCSIChannel(csi_channel, channel);
      plotDataBuff(i, j, :) = reshape(plotDataBuff(i, j, :), [1, 57]) + csi_channel;
      samplePerChannelCount(i, j) = samplePerChannelCount(i, j) + 1;
    end
  end
end
err = 0;

function err = flushAndPlot(csi_channel_id, plotDataBuff, samplePerChannelCount, refreshFlag)
MAX_NR = 3;
MAX_NC = 3;
HOLD_ON = 1;
HOLD_OFF = 0;
for i = 1:MAX_NR
  for j = 1:MAX_NC
    subPlotID = (i - 1) * MAX_NR + j;
    subplot(MAX_NR, MAX_NC, double(subPlotID));
    if refreshFlag == HOLD_ON
      hold on;
    else
      hold off;
    end
    if samplePerChannelCount(i, j)
      plotData = db(abs(reshape(plotDataBuff(i, j, :), [1, 57]) / samplePerChannelCount(i, j)));
      plot(csi_channel_id, plotData);
    end
    axis([2400, 2480, 0, 70]);
    drawnow;
  end
end
err = 0;

function [csi_channel_id csi_channel] = reshapeCSIChannel(csi_channel, channelID)
CSI_SUBCHANNEL_INTERVAL    = 0.3125;
CSI_CHANNEL_NUM_PER_SAMPLE = 56;

halfChannelNumber = CSI_CHANNEL_NUM_PER_SAMPLE / 2;
firstSegmentEnd = halfChannelNumber;
secondSegmentBegin = firstSegmentEnd + 1;
csi_channel = [csi_channel(1:firstSegmentEnd), ...
               (csi_channel(firstSegmentEnd) + csi_channel(secondSegmentBegin))/2, ...
               csi_channel(secondSegmentBegin:CSI_CHANNEL_NUM_PER_SAMPLE)];
csi_channel_id = [channelID - halfChannelNumber * CSI_SUBCHANNEL_INTERVAL ...
                  : CSI_SUBCHANNEL_INTERVAL : ...
                   channelID + halfChannelNumber * CSI_SUBCHANNEL_INTERVAL];

function [refreshFlag channelIDArray] = refreshOrNot(channelIDArray, currentChannelID)
% Setting refreshFlag to refresh the plot for every receiving period.
%  INPUT:
%     channelIDArray   -- Already plotted channelIDs in the current period.
%     currentChannelID -- the channel ID of the current plotting sample.
%  OUTPUT:
%     refreshFlag      -- the flag variable to instruct the plot commmand.
%     channelIDArray   -- updated array of plotted channelIDs.
HOLD_ON = 1;
HOLD_OFF = 0;
if length(channelIDArray) && (currentChannelID == channelIDArray(end))
  refreshFlag  = HOLD_ON;
  channelIDArray = channelIDArray;
elseif any(currentChannelID==channelIDArray)
  refreshFlag = HOLD_OFF;
  channelIDArray = currentChannelID;
else
  refreshFlag = HOLD_ON;
  channelIDArray = [channelIDArray, currentChannelID];
end
