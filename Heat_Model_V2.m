

function [Heat_Pump_Daily_Constant_MW_Required,Heat_Pump_Daily_MWH_Required,HP_Heat_Output_Total,Heat_Pump_Daily_Space_Heating_MW_Required,Heat_Pump_Daily_Water_Heating_MW_Required]=Heat_Model_V2()

% close all
% clear all
% clc
%%

% West Energy Resilience
% XE485 24-1 & 24-2
% Contact -> 215-528-7614 (David Sang)


load("Data_for_Heat_Model\Heat_Model_V2_Data_Natural_Gas_Input.mat")
load("Data_for_Solar_Function\NSRDB_1998_2022_30min_data_New.mat")

%%
% This data contains the kcf of natural gas purchased by westpoint from
% OCT to SEP. This is from the utility bill data originally. It was
% imported from Harding's heat model which can be found in the data for
% heat model folder

% Reorder the data so it goes from JAN to DEC
Natural_Gas_Input_JAN_DEC_kcf=[Natural_Gas_Input_Data(4:12);Natural_Gas_Input_Data(1:3)];
% kcf
Residential_Natural_Gas_Data_JAN_DEC=[Residential_Natural_Gas_Data(4:12);Residential_Natural_Gas_Data(1:3)];
% MWh


kcf_to_MWh=0.2931;  % ASSUMPTIONS LATER
%https://www.nrg.com/resources/energy-tools/energy-conversion-calculator.html

Natural_Gas_Input_JAN_DEC_MWh=Natural_Gas_Input_JAN_DEC_kcf*kcf_to_MWh;
% MWh

Days_in_month_JAN_to_DEC=[31,28,31,30,31,30,31,31,30,31,30,31]';
Hours_in_Month=24*Days_in_month_JAN_to_DEC;


%% Representative Heat Pump
% We are using the 5 Unitrop 50FY as a representative heat pump

HP_Heat_Output=18;  % MW
HP_Cooling_Output=12;   % MW
HP_Capacity_Factor=0.8;
Array_Size=2;

HP_Heat_Output_Total=HP_Heat_Output*Array_Size; % MW


%% Estimate the amount of Energy Currently Dedicated to Water heating 

% Select a baseline month to reference
Water_Heating_Baseline_Month=9;
% Select a percentage of energy dedicated to water heating
Water_Heating_Baseline_Percentage=1;

% Assume all months use the same amount of energy to heat water per hour. 
% Then find each months water heating energy use
Water_Heating_MWh=min(Natural_Gas_Input_JAN_DEC_MWh, Hours_in_Month/Hours_in_Month(Water_Heating_Baseline_Month)*Natural_Gas_Input_JAN_DEC_MWh(Water_Heating_Baseline_Month));
% MWh

% Find how much energy is used in space heating by subtracting the assumed
% Energy used on water. All negative values are moved to zero. 
Space_Heating_MWh=max(Natural_Gas_Input_JAN_DEC_MWh-Water_Heating_MWh,0);
% MWh

Percentage_of_Energy_Used_for_Water_Heating=min(Water_Heating_MWh./Natural_Gas_Input_JAN_DEC_MWh,1);

%% Determine the Amount of energy needed to replace Existing Systems

% Use assumed inefficiencys to determine how much energy is actually
% delivered.

% Water Heating
Water_Heater_EF=3.75; % Rheem performance Platinum
Assumed_Water_Heating_Boiler_Efficiency=0.9;
Assumed_Water_Heating_Distrubution_Efficiency=0.6;
Updated_Distro_Efficiency=0.75;

Water_Heating_MWh_Delivered=Water_Heating_MWh.*Assumed_Water_Heating_Boiler_Efficiency*Assumed_Water_Heating_Distrubution_Efficiency/(Updated_Distro_Efficiency*Water_Heater_EF);
% MWh

% Residential Space Heating 
ASHP_HSPF=10/3.412; % https://www.mitsubishicomfort.com/commercial/products/m-series-outdoor?
% BTU/whr * 1 whr 3.412 btu
% Divide by the conversion from BTU to watts (3.412 BTU = 1 watt) to 
% make the conversion watts/watts 

Assumed_Residential_Space_Heating_Boiler_Efficiency=0.9;
Assumed_Residential_Space_Heating_Distrubution_Efficiency=0.75;
Updated_Distro_Efficiency=0.75;

% Assume the same percentage of energy that goes towards space heating for 
% cadets goes towards space heating for residents. 
Residential_Space_Heating_MWh_Delivered=Residential_Natural_Gas_Data_JAN_DEC.*(1-Percentage_of_Energy_Used_for_Water_Heating).*Assumed_Residential_Space_Heating_Boiler_Efficiency*Assumed_Residential_Space_Heating_Distrubution_Efficiency/(Updated_Distro_Efficiency*ASHP_HSPF);
% MWh

% District Space Heating 
GSHP_HSPF=18.1/3.412; % https://www.sciencedirect.com/science/article/pii/S0378778820310069
% BTU/whr * 1 whr 3.412 btu
% Divide by the conversion from BTU to watts (3.412 BTU = 1 watt) to 
% make the conversion watts/watts 
Assumed_District_Space_Heating_Boiler_Efficiency=0.95;
Assumed_District_Space_Heating_Distrubution_Efficiency=0.6;
Updated_Distro_Efficiency=0.75;

% Assume the same percentage of energy that goes towards space heating for 
% cadets goes towards space heating for residents. 
District_Space_Heating_MWh_Delivered=(Space_Heating_MWh-Residential_Natural_Gas_Data_JAN_DEC.*(1-Percentage_of_Energy_Used_for_Water_Heating)).*Assumed_District_Space_Heating_Boiler_Efficiency*Assumed_District_Space_Heating_Distrubution_Efficiency/(Updated_Distro_Efficiency*GSHP_HSPF);
% MWh

%% Within each month, Spread the heating demand over the whole day equally according to the difference in temperature

Desired_Temperature= 68; %Degrees F

% The temperature data for every 30 minutes (Degrees C) can be found in column 14
% Of the NSRDB Data. (All rows, 14 for temperature, 25 for year 2022)
%   1 = year 1998, 26 average of all

Outside_Temperature=NSRDB_1998_2022_30min_data_New(:,14,25)*1.8+32;

Difference_in_temp=Desired_Temperature-Outside_Temperature;
Difference_in_temp=max(Difference_in_temp,0);

% Find the total temperature difference for each month
Temp_difference_by_Month=zeros([12,1]);

Periods_per_month=[1;Days_in_month_JAN_to_DEC*24*2];


for i=1:12
    Temp_difference_by_Month(i)=sum(Difference_in_temp(sum(Periods_per_month(1:i)):sum(Periods_per_month(1:i+1))-1));
end

% Find the Water heating per day for each month. (Assume equal use per day)
Daily_Water_use=Water_Heating_MWh_Delivered./Days_in_month_JAN_to_DEC;

% Find the Daily whieghting within each month for residential and district
% heating 

Day_wieghts=zeros([365,1]);
Temp_difference_by_day=zeros([365,1]);
Residential_Space_Heating_MWh_Delivered_Daily=zeros([365,1]);
District_Space_Heating_MWh_Delivered_Daily=zeros([365,1]);
Water_Heating_MWh_Delivered_Daily=zeros([365,1]);
idx_mat=zeros([365,1]);

% Create a matrix describing the idx of periods per day
Periods_per_day_idx=zeros(366,1);
Periods_per_day_idx(1)=1;
for i=1:365
Periods_per_day_idx(i+1)=Periods_per_day_idx(i)+2*24-1;
end


for i=1:12
    for j=1:Days_in_month_JAN_to_DEC(i)
        idx=j+sum(Days_in_month_JAN_to_DEC(1:i))-Days_in_month_JAN_to_DEC(i);
        idx_mat(idx)=idx;
    Temp_difference_by_day(idx)=sum(Difference_in_temp(Periods_per_day_idx(idx):Periods_per_day_idx(idx+1)));
    Day_wieghts(idx)=Temp_difference_by_day(idx)/Temp_difference_by_Month(i);
    Residential_Space_Heating_MWh_Delivered_Daily(idx)=Day_wieghts(idx)*Residential_Space_Heating_MWh_Delivered(i);
    District_Space_Heating_MWh_Delivered_Daily(idx)=Day_wieghts(idx)*District_Space_Heating_MWh_Delivered(i);
    Water_Heating_MWh_Delivered_Daily(idx)=Water_Heating_MWh_Delivered(i)/Days_in_month_JAN_to_DEC(i);

    end
end

Heat_Pump_Daily_Space_Heating_MW_Required=(District_Space_Heating_MWh_Delivered_Daily+Residential_Space_Heating_MWh_Delivered_Daily)/24;

Heat_Pump_Daily_Water_Heating_MW_Required=Water_Heating_MWh_Delivered_Daily/24;

Heat_Pump_Daily_MWH_Required=District_Space_Heating_MWh_Delivered_Daily+Residential_Space_Heating_MWh_Delivered_Daily+Water_Heating_MWh_Delivered_Daily;
% MWh

Heat_Pump_Daily_Constant_MW_Required=Heat_Pump_Daily_MWH_Required/24;

end
