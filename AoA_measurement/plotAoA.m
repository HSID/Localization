function [plotData err] = plotAoA(data, plotRadius, radiusScale)
%function plotData = plotAoA(data, plotRadius, radiusScale)
%
%INPUTS:
%	data          - the data that need to be plotted
%                   data.data   : the sample data
%                   data.range  : [0  180] or [0  360]
%                   data.length : the number of samples in the data.data
% plotRadius    - the radius of the AoA plot
% radiusScale   - the scale of radius for plotting AoA
%
%OUTPUTS:
%	err           - the signal indicating the successness of the plot
plotData = convertCoordinates(data, plotRadius, radiusScale);
formattedPlot(plotData.x, plotData.y, plotRadius);
localMaximas.x = plotData.x(plotData.localMaximasLocations);
localMaximas.y = plotData.y(plotData.localMaximasLocations);
plotPolarLine(localMaximas.x, localMaximas.y);
axis equal;
axis([-plotRadius, plotRadius, -plotRadius, plotRadius]);
err = 0;
hold off;

function err = plotPolarLine(xData, yData)
for i = 1:length(xData)
  plot([0, xData(i)], [0, yData(i)]);
  hold on;
end
err = 0;

function err = formattedPlot(xData, yData, plotRadius)
t = linspace(0, 2 * pi, 100);
for i = 1:plotRadius
  plot(i * cos(t), i * sin(t), '--g');
  hold on;
end
plot(xData, yData, 'r');

function plotData = convertCoordinates(originalData, plotRadius, radiusScale)
%function plotData = convertCoordinates(originalData)
%
%INPUTS:
%	originalData - the data that need to be plotted
%                originalData.data   : the sample data
%					       originalData.range  : [0, 180] or [0, 360]
%                originalData.length : the number of samples in the data.data
%
%OUTPUTS:
%	plotData     - the converted version of the data that can be directly used to plot
%                plotData.x      : x-axis values
%                plotData.y      : y-axis values
%                plotData.range  : the angle range of the data
%                plotData.length : the length of the data
length = originalData.length;
range = originalData.range;
data = originalData.data;
radius = plotRadius;

[localMaximas, maximaLocs] = findpeaks(data);

% deal with the non-localmaxima condition
if isempty(maximaLocs)
  maximaLocs = 1;
end

angles = linspace(range(1), range(2), length)' / 180 * pi;
dataRadii = data / max(data) * plotRadius * radiusScale;

plotData.x = dataRadii .* cos(angles);
plotData.y = dataRadii .* sin(angles);
plotData.localMaximasLocations = maximaLocs;
plotData.range = range;
plotData.length = length;
