function pdp = csi2pdp(singleChannelCSI)
% function pdp = csi2pdp(singleChannelCSI)
% INPUTS
%  singleChannelCSI - a csi sample from a single channel with raw complex values
%
% OUTPUTS
%  pdp - a pdp sample from a single channel
pdp = ifft(singleChannelCSI);
