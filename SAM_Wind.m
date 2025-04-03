
function [Wind_Power_Generated_15min_JAN_to_DEC,Wind_LCOE]=SAM_Wind(Number_of_Turbines)
% clc
% clear
% close all 
%%
% West Energy Resilience
% XE485 24-1 & 24-2
% Contact -> 215-528-7614 (David Sang)

load("Data_for_Wind_Function\SAM_Wind_Speed_Data_15min.mat")

% Data was taken from the SAM Model
% The file can be found in the Data_for_Wind_Function

Wind_Power_Generated_15min_JAN_to_DEC=Number_of_Turbines*(SAMWindSimulationOneTurbine(1:35038))/1000;
% MW

Wind_LCOE=SAMWindSimulationOneTurbineS1(1,1);
% $/kWh

end
