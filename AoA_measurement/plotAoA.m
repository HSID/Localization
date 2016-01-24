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
plot(plotData.x, plotData.y);
axis([-plotRadius, plotRadius, -plotRadius, plotRadius]);
axis equal;
err = 0;

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
%                plotData.x : x-axis values
%                plotData.y : y-axis values
length = originalData.length;
range = originalData.range;
data = originalData.data;
radius = plotRadius;

angles = linspace(range(1), range(2), length)' / 180 * pi;
dataRadii = data / max(data) * plotRadius * radiusScale;

plotData.x = dataRadii .* cos(angles);
plotData.y = dataRadii .* sin(angles);
plotData.range = range;
plotData.length = length;
