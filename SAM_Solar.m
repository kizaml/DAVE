


function [Solar_Power_Generated_15min_JAN_to_DEC,Solar_LCOE,Solar_Land_Use,Solar_Rated_Power]=SAM_Solar(Solar_Panel_Tracking_Designator,Panel_size)

% clc
% clear
% close all 

% West Energy Resilience
% XE485 24-1 & 24-2
% Contact -> 215-528-7614 (David Sang)
%%
load("Data_for_Solar_Function\SAM_Solar_Data.mat")

% The SAM file used to generate this data can be found in the
% Data_for_Solar_Functions_Folder. I transported it to a excell file. 

% %Data Munging to Create final file
% SAM_Solar_Single_Variables=[SAMPVSimulationFixedTiltS1,SAMPVSimulation1AxisTrackingS1,SAMPVSimulation2AxisTrackingS1];
% %           Col 1        Col 2                  Col 3
% %           Fixed        1 Axis Tracking        2 Axis Tracking
% % row 1     LCOE ($/kWh)
% % row 2     Lattitude
% % row 3     Longitude
% % row 4     Panel Size (m^2)
% % row 5     Land Area  (acres)
% % row 6     Rated Power (kW dc)
% 
% SAM_Solar_Power_Production=[SAMPVSimulationFixedTilt,SAMPVSimulation1AxisTracking,SAMPVSimulation2AxisTracking];
% SAM_Solar_Power_Production_15min=repelem(SAM_Solar_Power_Production,4,1);
% SAM_Solar_Power_Production_15min=SAM_Solar_Power_Production_15min(1:35038,:);
% save("Data_for_Solar_Function\SAM_Solar_Data.mat")


Solar_LCOE=SAM_Solar_Single_Variables(1,Solar_Panel_Tracking_Designator);
% $/kWh

Solar_Power_Generated_15min_JAN_to_DEC=SAM_Solar_Power_Production_15min(:,Solar_Panel_Tracking_Designator).*(Panel_size/SAM_Solar_Single_Variables(4,Solar_Panel_Tracking_Designator))./1000;
% MW

Solar_Land_Use=Panel_size/SAM_Solar_Single_Variables(4,Solar_Panel_Tracking_Designator).*SAM_Solar_Single_Variables(5,Solar_Panel_Tracking_Designator)*4046.86;
% m^2

Solar_Rated_Power=Panel_size/SAM_Solar_Single_Variables(4,Solar_Panel_Tracking_Designator)*(SAM_Solar_Single_Variables(6,Solar_Panel_Tracking_Designator))./1000;
% MW


end




