
function [Wind_Power_Generated_15min_JAN_to_DEC,Wind_Rated_Power_Per_Turbine]=Wind(Data_Selector_Wind,Number_of_Turbines,Hub_height, Rotor_Radius,Cp)
% clc
% clear
% close all 

% West Energy Resilience
% XE485 24-1 & 24-2
% Contact -> 215-528-7614 (David Sang)

load("Data_for_Wind_Function\Wind_Speed_Data_15min.mat")

%% Wind Data Munging

% Wind Data is taken from NASA power CERES MERRA 2 
% File is Data/POWER_Point_Hourly_05OCT.csv
% https://power.larc.nasa.gov/data-access-viewer/
% Data is given by hour 
% COlUMNS
% Year, Month, Day, Hour, Wind Speed 10 meters [m/s], WS 50 meters [m/s]
%
%
% Wind_Speed_Data=[Wind_Speed_Data_Org(6:end,:);Wind_Speed_Data_Org(1:5,:)];
% Wind_Speed_Data_2021=Wind_Speed_Data(Wind_Speed_Data(:,1)==2021,:);
% Wind_Speed_Data_2022=Wind_Speed_Data(Wind_Speed_Data(:,1)~=2021,:);
% 
% Wind_Speed_Data_Combined=cat(3,Wind_Speed_Data_2021,Wind_Speed_Data_2022);
% Wind_Speed_Data_Avg=mean(Wind_Speed_Data_Combined,3);
% 
% 
% Wind_Speed_Data_2021_15min=repelem(Wind_Speed_Data_2021,4,1);
% Wind_Speed_Data_2022_15min=repelem(Wind_Speed_Data_2022,4,1);
% Wind_Speed_Data_Avg_15min=repelem(Wind_Speed_Data_Avg,4,1);
%
% Wind_Speed_Data_15min=cat(3,Wind_Speed_Data_2021_15min(1:end-2,:),Wind_Speed_Data_2022_15min(1:end-2,:),Wind_Speed_Data_Avg_15min(1:end-2,:));
%
%save("Wind_Speed_Data_15min.mat","Wind_Speed_Data_15min")

%%%% FUNCTION INPUT %%%%%
%Data_Selector_Wind=1;
% 1 = 2021
% 2 = 2022
% 3 = Average

%% Parameters

%%%% FUNCTION INPUT %%%%%
%Number_of_Turbines=1

Air_Density=1.225;      %kg/m^3

%Hub_height=95;          %m (IN ASSUMPTIONS FILE)
%Rotor_Radius=127/2;     %m (IN ASSUMPTIONS FILE)
%Cp=0.4;                 % Efficiency ~ 40% (IN ASSUMPTIONS FILE)
Wiebull_Factor=6/pi();  % 

% These numbers have been adjusted to match NREL's Cost of Wind Energy
% Calculations (Can be found in references) 
% https://www.nrel.gov/docs/fy23osti/84774.pdf (PDF 24)

%% Calculations

Alpha=log(Wind_Speed_Data_15min(:,6,Data_Selector_Wind)./Wind_Speed_Data_15min(:,5,Data_Selector_Wind))/log(5);

Wind_Speed_at_Hub_Hieght=(Hub_height/50).^(Alpha).*Wind_Speed_Data_15min(:,6,Data_Selector_Wind);
% m/s

Wind_Power_Generated_15min_JAN_to_DEC=0.5*Air_Density*pi()*Rotor_Radius^2.*Wind_Speed_at_Hub_Hieght.^3*Cp*Wiebull_Factor*Number_of_Turbines/10^6;
% MW

Wind_Rated_Power_Per_Turbine=mean(Wind_Power_Generated_15min_JAN_to_DEC)/Number_of_Turbines/(10^6);
% MW/Turbines
% Specific_Power =mean(Wind_Speed_at_Hub_Hieght)*0.5*Air_Density.^3*Cp*Wiebull_Factor
% Rated Power = Specific Power * Area
% Or just the mean ow find power 

%Wind_Plant_Capacity=Number_of_Turbines*Wind_Rated_Power_Per_Turbine;
% MW

clearvars -except Wind_Rated_Power_Per_Turbine Wind_Power_Generated_15min_JAN_to_DEC

end
