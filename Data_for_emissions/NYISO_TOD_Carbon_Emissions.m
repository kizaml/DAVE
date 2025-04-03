


% clc
% clear
% close all 

% Import the US-NY-NYIS Data
% This data was pulled from 
    % https://www.electricitymaps.com/data-portal/united-states-of-america
%   col     1               2                   3               4
%           COe g/kWh       COe g/kWh           % Low Carbon    % Renewables
%           Direct          Life Cycle Avg

%load("Grid_Carbon_TOD.mat")

Grid_Carbon_TOD_2022=repelem(USNYNYIS2022hourly,4,1);
Grid_Carbon_TOD_2023=repelem(USNYNYIS2023hourly,4,1);

Grid_Carbon_TOD=cat(3,Grid_Carbon_TOD_2023,Grid_Carbon_TOD_2022);

Grid_Carbon_TOD=Grid_Carbon_TOD(1:35038,:,:);

save("Grid_Carbon_TOD.mat")


