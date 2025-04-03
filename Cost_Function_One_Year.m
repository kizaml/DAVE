

function Model_Objective = Cost_Function_One_Year(Parameters)

% This is the function that gets run to model the behavior of each
% potential solution. This function can be commented out and manipulated to
% run any predetermined set of parameters. You do this by commenting out
% the function designation and uncommenting out the parameters line


%%
% 
% clc 
% clear all

%tic

load("Data_for_Cost_Function_One_Year\Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC.mat")
load("Data_for_Cost_Function_One_Year\Peak_MWatts_15min_Jan_to_DEC.mat")
load("Data_for_emissions\New_England_Emissions_data.mat")
load("Data_for_emissions\Grid_Carbon_TOD.mat")
load("Data_for_Cost_Function_One_Year\Most_Recent_Cost_of_Natural_Gas_JAN_to_DEC_Monthly.mat")
load("Data_for_Cost_Function_One_Year\Most_Recent_Natural_Gas_Usage_JAN_to_DEC_Monthly.mat")
load("Data_for_Cost_Function_One_Year\Vehicle_Fuel_Delivery_2023.mat")

%load("Model_Assumptions_Sensitivity_analysis.mat")
load('Model_Assumptions.mat')
%tic
%%
% Use this line to set Parameters at a value and find the output
               
%Parameters=[1	100000	3    2	 500  12.50	    2	1000	4	2       4   4   0   0];
    % Uncomment the paramters to test run the system with whatever initial
    % paramters you desire
    % var 1: Solar Tracking Designator                      [m^2]
    % var 2: Solar panel size ----------------------------- [m^2]
    % var 3: # of Wind Turbines                             (#) 
    %
    % var 4: Lithium Ion Battery Strategy ----------------- (#)
    % var 5: Lithium Ion Battery Energy Capacity            [MWh]
    % var 6: Lithium Ion Battery Battery Power Output       [MW]
    %
    % var 7: Diesel Generator Strategy -------------------- (#)
    % var 8: Diesel Energy Capacity                         [MWh]  
    % var 9: Number of Diesel Generators ----------------- [#]  
    % var 10: Diesel Generator Size (2,2.5,2.75,3)          [# (MW)]
    %
    % var 11: Pumped Hydro Strategy ----------------------- (#)
    % var 12: Pumped Hydro Selector                         (#)
    % var 13: Electrical Vehicle Adoption ----------------- (Binary 1 yes)
    % 
    % var 14: Heat Pump Transistion ----------------------- (Binary 1 yes)

% This presizes the Model Objectives Array to speed up the funciton
Model_Objective=zeros(1,Sensitivity_iter*Model_Objectives_num*2);


% Sensitivity Analysis ------------------------------------
eval("Sensitivity_variable_initial="+Sensitivity_Variable+";")
    % Store the Initial Value of the variable that will be altered for
    % sensitivity analysis 

for Sens_trial=1:Sensitivity_iter


eval(Sensitivity_Variable+"=Sensitivity_variable_initial*Sensitivity_analysis_multiplyer(Sens_trial);")
    % This allows you to select the sensitivity variable in the assumptions
    % file. This should vary the sensitivity variable within the for loop
    % by scaling the initial value my the multiplyer. 

%% Solar Generation

%B Old solar
% Use the equation with Parametrs(1) when running the optimization function
%[Solar_Power_Generated_15min_JAN_to_DEC_Calc,Solar_Rated_Power]=Solar(Data_Selector_Solar,Parameters(2), Panel_Efficiency);

% Solar Function Inputs Explanation
% [MW,W], (Data_Selecter_Solar, Panel Size)
% Data Selecter
% 1=1998
% 2=1999 and so forth to 25
% 25=2022
% 26=Average
% Panul Size m^2

%------------------------------------------------------------------
% SYSTEM ADVISOR MODEL SOLAR 
% This model uses the output of the SAM Model by NREL for representative
% sizes. The power generated is then sized up and down. 
%[Solar_Power_Generated_15min_JAN_to_DEC,Solar_LCOE,Solar_Land_Use]=SAM_Solar(Solar_Panel_Tracking_Designator,Panel_size)
 [Solar_Power_Generated_15min_JAN_to_DEC,Solar_LCOE,Solar_Land_Use,Solar_Rated_Power]=SAM_Solar(Parameters(1),Parameters(2));
% Outputs
    % Solar Power Generated     [MW]
    % Solar LCOE                [$/kWh]
    % Solar Land Use            [m^2]
    % Solar Rated Power         [MW dc]

% Determine the Step transmission Line costs that are attached to using
% different amounts of solar   
    % All areas are documented in Assumptions

if Solar_Land_Use<=Solar_Roof_Area
    Transmission_Cost=0; % $
elseif and(Solar_Land_Use>Solar_Roof_Area,Solar_Land_Use<=Solar_Parking_Lot_Area)
    Transmission_Cost=Parking_Lot_Transmission_Line_Cost; % $
    %Grid_Transmission_Limit=36+48;
elseif Solar_Land_Use>=Solar_Parking_Lot_Area
    Transmission_Cost=Distance_to_Buckner*Transmission_Line_Cost+Parking_Lot_Transmission_Line_Cost;
    %Grid_Transmission_Limit=36+48;
end

% Discount the transmission cost into a 50 year loan
Transmission_Cost_CAPEX=12*payper(Discount_Rate,Transmission_Line_Life_Cycle*12,Transmission_Cost);


%% Wind Generation 

% Use the wind function with a value for Parameters to test/iterate
%[Wind_Power_Generated_15min_JAN_to_DEC,Wind_Rated_Power_Per_Turbine]=Wind(1,2, Hub_height, Rotor_Radius, Cp);

% Use the equation with Parametrs(2) when running the optimization function
%[Wind_Power_Generated_15min_JAN_to_DEC_Calc,Wind_Rated_Power_Per_Turbine]=Wind(Data_Selector_Wind, Parameters(3), Hub_height, Rotor_Radius, Cp);

% Wind Function Inputs Explanation
% [MW,MW/Turbine], (Data_Selector, Panel Size)
% Data Selecter (In Assumptions File)
% 1 = 2021
% 2 = 2022
% 3 = Average
% # of Turbines

%------------------------------------------------------------------
% SYSTEM ADVISOR MODEL WIND
[Wind_Power_Generated_15min_JAN_to_DEC,Wind_LCOE]=SAM_Wind(Parameters(3));

% Outputs 
% Wind Power [MW]
% Wind LCOE [$/kWh]  *Calculated by SAM*


%% Day 2 Day vs Extreme
% To create a Day2Day output vs an extreme output we nned to run stochastic
% modeling two times. Use a for loop for this. This will vary our
% assumptions about the grid failure rate. 

for D2D=1:2
    % D2D=1 Means Day 2 Day output
    if D2D==1
        temp_Grid_hazard_rate=Grid_hazard_rate(:,1:end-1);
        temp_Grid_Failure_Avg_Length=Grid_Failure_Avg_Length(:,1:end-1);
        temp_Grid_Failure_Length_STD=Grid_Failure_Length_STD(:,1:end-1);
    elseif D2D==2
        temp_Grid_hazard_rate=Grid_hazard_rate;
        temp_Grid_Failure_Avg_Length=Grid_Failure_Avg_Length;
        temp_Grid_Failure_Length_STD=Grid_Failure_Length_STD;
    end 

%% Stochastic Modeling 

% Determine the number of simulated failure years for each set of
% Parameters
%Stochastic_Iterations=50; % (IN ASSUMPTIONS FILE)

% Use the Failure_simulation function to return failure flag matrixes
% Including Parameters can affect simulations where failure changes based
% on size of the system
%[Grid_failure_flag_mat, Solar_failure_flag_mat, Wind_failure_flag_mat]=Failure_simulation(Stochastic_Iterations,Parameters(1),Parameters(2));


[Grid_failure_flag_mat, Solar_failure_flag_mat, Wind_failure_flag_mat]=Failure_simulation(Stochastic_Iterations,...
    Parameters(2),Parameters(3),Solar_hazard_rate,Solar_Failure_Avg_Length,Solar_Failure_Length_STD,...
    Wind_hazard_rate,Wind_Failure_Avg_Length,Wind_Failure_Length_STD,temp_Grid_hazard_rate,temp_Grid_Failure_Avg_Length,...
    temp_Grid_Failure_Length_STD);


% The following two lines can be used to force grid failure in january.
Grid_failure_flag_mat(24*5*4:24*7*4,1,1)=Grid_example_on;
Grid_failure_flag_mat(24*10*4:24*30*4,1,1)=Grid_example_on;

% Create an array with the demand according to Stochastic Iterations
Peak_MWatts_15min_JAN_to_DEC_temp=repelem(Peak_MWatts_15min_JAN_to_DEC,1,1,Stochastic_Iterations);
% MW

% If moving to electric vehicles, increase the MWatts demanded by a flat
% value (According to Erden's EV energy calculations). This assumes the
% charging of EVs is averaged throughout every moment of everyday. The math
% for this can be found in the EV Data folder

EV_Power_Demand_15min_MW=Daily_EV_Energy_Demand/(24)/(1000)*Parameters(13);
% kWh/day *(1 day/ 24 hrs)* (1 MW/ 1000 kw) = MW

% Sum the power demands 
Peak_MWatts_15min_JAN_to_DEC_final=Peak_MWatts_15min_JAN_to_DEC_temp+EV_Power_Demand_15min_MW;

% Create a three dimensional array that describes when solar is active and
% how much it is generating for each moment of each trial
% Dim 1 (rows) Each generation amount for each 15 minute period
% Dim 2 (col) 1 column (allows planes to be for each trial when combined
%       with data later) 
% Dim 3 (plane/z-direction) This is the trial number 
temp_Solar_Power_Generated_15min_JAN_to_DEC_Active=repelem(Solar_Power_Generated_15min_JAN_to_DEC,1,1,Stochastic_Iterations);
Solar_Power_Generated_15min_JAN_to_DEC_Active=temp_Solar_Power_Generated_15min_JAN_to_DEC_Active-temp_Solar_Power_Generated_15min_JAN_to_DEC_Active.*Solar_failure_flag_mat;

% Repeat for Wind
temp_Wind_Power_Generated_15min_JAN_to_DEC_Active=repelem(Wind_Power_Generated_15min_JAN_to_DEC,1,1,Stochastic_Iterations);
Wind_Power_Generated_15min_JAN_to_DEC_Active=temp_Wind_Power_Generated_15min_JAN_to_DEC_Active-temp_Wind_Power_Generated_15min_JAN_to_DEC_Active.*Wind_failure_flag_mat;

%% Heat Model 

% Currently all assumptions are within the Heat Pump model. 
[Heat_Pump_Daily_Constant_MW_Required,Heat_Pump_Daily_MWH_Required,HP_Heat_Output_Total,Heat_Pump_Daily_Space_Heating_MW_Required,Heat_Pump_Daily_Water_Heating_MW_Required]=Heat_Model_V2();

Heat_Pump_15min_Constant_MW_Required=repelem(Heat_Pump_Daily_Constant_MW_Required,24*4);

Peak_MWatts_15min_JAN_to_DEC_final=Peak_MWatts_15min_JAN_to_DEC_final+Heat_Pump_15min_Constant_MW_Required(1:length(Peak_MWatts_15min_JAN_to_DEC_final))*Parameters(14);
% Add the Heat pump power demand to the peak demand depending on the
% selection of a heat system

%% West Point Peak Wattage Data 

% 
% % Take data from HARRL841L851totalMWandLSRTotalSystemLoadFY22PerSeason.
% % This data is downloaded DPW and it shows the peak wattage (in MW)
% %   supplied to West Point in 15 minute increments. 
% 
% % data starts with SEP 21 2022 12AM. When it hits OCT it reverts to 2021
% % We reorganize to make sequential data from OCT2021->SEP2022
% Peak_MWatts_15min_OCT_to_SEP=[WP_Peak_MWatts_15min_initial(2:961,1);WP_Peak_MWatts_15min_initial(961:end,1)];
% Peak_MWatts_15min_JAN_to_DEC=[Peak_MWatts_15min_OCT_to_SEP(8833:end,1);Peak_MWatts_15min_OCT_to_SEP(1:8832,1)];
% Average_MWatts_WestPoint=mean(Peak_MWatts_15min_OCT_to_SEP);
% 
% % Create a date time vector for the data
% Peak_MWatts_15min_Xdates_OCT_to_SEP=[datetime(2021,10,1):minutes(15): datetime(2022,10,1)-minutes(45)]';
% Peak_MWatts_15min_Xdates_JAN_to_DEC=[datetime(2022,1,1):minutes(15): datetime(2023,1,1)-minutes(45)]';
% % ##### OF NOTE ###### The DPW data is missing 2 values measurements. 
% %   I shortened the date time vector by 2 elements to account for this

% Determine the gap between demanded power and generated power
Electrical_Power_Generation_Gap_Pre_Storage=Peak_MWatts_15min_JAN_to_DEC_final-...
    Solar_Power_Generated_15min_JAN_to_DEC_Active-...
    Wind_Power_Generated_15min_JAN_to_DEC_Active; 
% MW

% Convert Power to Energy By dividing by 4 to get in unit of hour
Energy_Generation_Gap_JAN_to_DEC_Pre_Storage=Electrical_Power_Generation_Gap_Pre_Storage/4; % MWhr

% Isolate deficit by making negative values in Energy gap (Surpluses in
% energy) equal to 0 
Energy_Generation_Deficit_JAN_to_DEC=Energy_Generation_Gap_JAN_to_DEC_Pre_Storage; % MWhr
Energy_Generation_Deficit_JAN_to_DEC(Energy_Generation_Deficit_JAN_to_DEC<0)=0; % MWhr
%plot(Energy_Generation_Deficit_JAN_to_DEC(:,1,1))

% Isolate surplus by making positive values in Energy generation gap 
% (Deficits in energy) equal to 0 and fliping the sign. 
% (positive means extra enery generated)
Energy_Generation_Surplus_JAN_to_DEC=Energy_Generation_Gap_JAN_to_DEC_Pre_Storage; % MWhr
Energy_Generation_Surplus_JAN_to_DEC(Energy_Generation_Surplus_JAN_to_DEC>0)=0; % MWhr
Energy_Generation_Surplus_JAN_to_DEC=Energy_Generation_Surplus_JAN_to_DEC*-1; % MWhr
%plot(Energy_Generation_Surplus_JAN_to_DEC(1:5*24*4,1,1))

% Determine the gap between Critical load and generated power
Electrical_Power_Generation_Gap_Pre_Storage_Critical=Critical_load-...
    Solar_Power_Generated_15min_JAN_to_DEC_Active-...
    Wind_Power_Generated_15min_JAN_to_DEC_Active; 
% MW

% Convert Power to Energy By dividing by 4 to get in unit of hour
Energy_Generation_Gap_JAN_to_DEC_Pre_Storage_Critical=Electrical_Power_Generation_Gap_Pre_Storage_Critical/4; % MWhr

% Isolate deficit by making negative values in Energy gap (Surpluses in
% energy) equal to 0 
Energy_Generation_Deficit_JAN_to_DEC_Critical=Energy_Generation_Gap_JAN_to_DEC_Pre_Storage_Critical; % MWhr
Energy_Generation_Deficit_JAN_to_DEC_Critical(Energy_Generation_Gap_JAN_to_DEC_Pre_Storage_Critical<0)=0; % MWhr
%plot(Energy_Generation_Deficit_JAN_to_DEC(:,1,1))

Energy_Generation_Surplus_JAN_to_DEC_Critical=Energy_Generation_Gap_JAN_to_DEC_Pre_Storage; % MWhr
Energy_Generation_Surplus_JAN_to_DEC_Critical(Energy_Generation_Surplus_JAN_to_DEC_Critical>0)=0; % MWhr
Energy_Generation_Surplus_JAN_to_DEC_Critical=Energy_Generation_Surplus_JAN_to_DEC_Critical*-1; % MWhr
%plot(Energy_Generation_Surplus_JAN_to_DEC(1:5*24*4,1,1))

%% Energy Storage 

%%%%%%%%%%%%%%%%%% Lithium Batttery  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Critical_load=10; % MW (IN ASSUMPTIONS) 

[Li_Ion_Battery_Stored_Energy,Li_Ion_Battery_Power,Battery_Energy_Stored_Net_Charge_Discharge,Renewable_Charged_Power,Grid_Charged_Power]=Li_Ion_Battery(Parameters(4),...
    Parameters(5),Parameters(6),Grid_failure_flag_mat,...
    Critical_load,Stochastic_Iterations,Energy_Generation_Surplus_JAN_to_DEC,Energy_Generation_Surplus_JAN_to_DEC_Critical,Energy_Generation_Deficit_JAN_to_DEC,Energy_Generation_Deficit_JAN_to_DEC_Critical,...
    Battery_initial_Charge_Percent,Battery_Charge_Efficiency,Battery_Discharge_Efficiency,Battery_Self_Discharge_rate,Battery_floor_percentage,Grid_Transmission_Limit,...
    Grid_Carbon_TOD,Carbon_Limiter,Cost_Limiter,Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC(:,Grid_Cost_Selector),Grid_Carbon_Selector,Grid_Cost_Selector,...
    Peak_MWatts_15min_JAN_to_DEC_final,Percentile_Delimeter_Carbon,Percentile_Delimeter_Cost);

% Lithium Ion Battery Inputs
% Stategy (Parameters 3)
%   1 Discharge on fail only + Full Discharge
%   2 Discharge on fail only + Discharge to Crtical Load
%   3 Cyclic Discharge + Battery Charge Floor + Full Discharge on Grid Fail
%   4 Cyclic Discharge + Battery Charge Floor + Discharge to Critical Load
%   5 Cyclic Discharge + No Battery Charge Floor + Full Discharge on Grid Fail
%   6 Cyclic Discharge + No Battery Charge Floor + Discharge to Critical Load
% Battery Capacity  (Parameters 4)              [MWh]
% Battery Power Input   (Parameters 5)          [MW]
% Battery Power Output  (Parameters 6)          [MW]
% Grid Failure Flag
% Critical Load                                 [MW]    
% Stochastic Iterations       
% Energy_Generation_Surplus_JAN_to_DEC          [MWh]
% Energy_Generation_Deficit_JAN_to_DEC          [MWh]
% Energy_Generation_Deficit_JAN_to_DEC_Critical [MWh]
% Battery_initial_Charge_Percent
% Battery_Charge_Efficiency
% Battery_Discharge_Efficiency
% Battery_Self_Discharge_rate
% Battery_floor_percentage
% Grid_Transmission_Limit
% Grid_Carbon_TOD
% Carbon_Limiter
% Cost_Limiter
% Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC
% Grid_Carbon_Selector
% Grid_Cost_Selector
% Peak_MWatts_15min_JAN_to_DEC_final

% Lithium Ion Battery Outputs
% Li_Ion_Battery_Stored_Energy:     MWh
% Li_Ion_Battery_Power (Positive is Battery Charging):             MW

%%
Li_Ion_Battery_Power_Charging=Li_Ion_Battery_Power;
Li_Ion_Battery_Power_Charging(Li_Ion_Battery_Power_Charging<0)=0;
Li_Ion_Battery_Power_Discharging=Li_Ion_Battery_Power;
Li_Ion_Battery_Power_Discharging(Li_Ion_Battery_Power_Discharging>0)=0;
% MW
%%

% Recalculate Generation gaps

% Add Battery Discharge/Charge to Power Draw to get Electrical Power Gap
Electrical_Power_Generation_Gap_Post_Battery=Electrical_Power_Generation_Gap_Pre_Storage+Li_Ion_Battery_Power;
% MW

% Convert Power to Energy By dividing by 4 to get in unit of hour
Energy_Generation_Gap_JAN_to_DEC_Post_Battery=Electrical_Power_Generation_Gap_Post_Battery/4; % MWhr

% Isolate deficit by making negative values in Energy gap (Surpluses in
% energy) equal to 0 
Energy_Generation_Deficit_JAN_to_DEC_Post_Battery=Energy_Generation_Gap_JAN_to_DEC_Post_Battery; % MWhr
Energy_Generation_Deficit_JAN_to_DEC_Post_Battery(Energy_Generation_Deficit_JAN_to_DEC_Post_Battery<0)=0; % MWhr
%plot(Energy_Generation_Deficit_JAN_to_DEC(:,1,1))



% Determine the gap between Critical load and generated power
Electrical_Power_Generation_Gap_Post_Battery_Critical=Electrical_Power_Generation_Gap_Pre_Storage_Critical+Li_Ion_Battery_Power;
% MW

% Convert Power to Energy By dividing by 4 to get in unit of hour
Energy_Generation_Gap_JAN_to_DEC_Post_Battery_Critical=Electrical_Power_Generation_Gap_Post_Battery_Critical/4; % MWhr

% Isolate deficit by making negative values in Energy gap (Surpluses in
% energy) equal to 0 
Energy_Generation_Deficit_JAN_to_DEC_Post_Battery_Critical=Energy_Generation_Gap_JAN_to_DEC_Post_Battery_Critical; % MWhr
Energy_Generation_Deficit_JAN_to_DEC_Post_Battery_Critical(Energy_Generation_Gap_JAN_to_DEC_Post_Battery_Critical<0)=0; % MWhr

% Recalculate Generation Surplus
Energy_Generation_Surplus_JAN_to_DEC_Post_Battery=Energy_Generation_Surplus_JAN_to_DEC-Renewable_Charged_Power; % MW

%%%%%%%%%%%%%%%%%%%%%%%% Diesel Generators %%%%%%%%%%%%%%%%%%%%


% [Diesel_Stored_Energy,Diesel_Generator_Power,Diesel_Energy_Impact_On_Grid]=Diesel_Generator(Diesel_Strategy,...
%     Diesel_Energy_Capacity,Number_of_Diesel_Generators,Diesel_Generator_Size, ...
%     Grid_failure_flag_mat,Critical_load,Stochastic_Iterations, ...
%     Energy_Generation_Deficit_JAN_to_DEC,Diesel_initial_Charge_Percent,Diesel_Tank_Refill_Trigger_Percentage, ...
%     Diesel_Storage_Delay_Time);

%
[Diesel_Stored_Energy,Diesel_Generator_Power,Diesel_Energy_Impact_On_Grid,temp_Dischargeable_Energy_Generation_Deficit_JAN_to_DEC,Dischargeable_Energy_Generation_Deficit_JAN_to_DEC,Diesel_Tank_Size]=Diesel_Generator( ...
    Parameters(7),Parameters(8),Parameters(9),Parameters(10), ...
    Grid_failure_flag_mat,Critical_load,Stochastic_Iterations,Energy_Generation_Deficit_JAN_to_DEC_Post_Battery,Energy_Generation_Deficit_JAN_to_DEC_Post_Battery_Critical,...
    Diesel_initial_Charge_Percent,Diesel_Tank_Refill_Trigger_Percentage, ...
    Diesel_Storage_Delay_Time,Diesel_generator_sizes_mat,Diesel_generator_diesel_use_rate);


% Diesel Generator Inputs
% Stategy (Parameters 7)
%   1 Discharge on fail only + Full Discharge
%   2 Discharge on fail only + Discharge to Crtical Load
% Battery Capacity  (Parameters 8)                              [MWh]
% # of Diesel Generators (Parameters 9)                         [#]
% Size of Diesel Generators (2,2.5,2.75.3) (Parameters 10)      [# (MW)]
% Grid Failure Flag
% Critical Load (In assumptions)                                [MW]    
% Stochastic Iterations (In assumptions)      
% Energy_Generation_Deficit_JAN_to_DEC
% Diesel_initial_Charge_Percent (In assumptions)

% Diesel Generator Outputs
% Diesel Stored_Energy:     MWh
% Diesel_Generator_Power (Negative is Discharge do Grid):       [MW]
% Diesel_Energy_Impact_On_Grid (Negative is Discharge do Grid): [MWh]
% Diesel Tank Size [gal]


% Recalculate Generation gaps
% Add Battery Discharge/Charge to Power Draw to get Electrical Power Gap
Electrical_Power_Generation_Gap_Post_Diesel=Energy_Generation_Gap_JAN_to_DEC_Post_Battery+Diesel_Generator_Power;
% MW

% Convert Power to Energy By dividing by 4 to get in unit of hour
Energy_Generation_Gap_JAN_to_DEC_Post_Diesel=Electrical_Power_Generation_Gap_Post_Diesel/4; % MWhr

% Isolate deficit by making negative values in Energy gap (Surpluses in
% energy) equal to 0 
Energy_Generation_Deficit_JAN_to_DEC_Post_Diesel=Energy_Generation_Gap_JAN_to_DEC_Post_Diesel; % MWhr
Energy_Generation_Deficit_JAN_to_DEC_Post_Diesel(Energy_Generation_Deficit_JAN_to_DEC_Post_Diesel<0)=0; % MWhr
%plot(Energy_Generation_Deficit_JAN_to_DEC(:,1,1))



% Determine the gap between Critical load and generated power
Electrical_Power_Generation_Gap_Post_Diesel_Critical=Electrical_Power_Generation_Gap_Post_Battery_Critical+Diesel_Generator_Power;
% MW

% Convert Power to Energy By dividing by 4 to get in unit of hour
Energy_Generation_Gap_JAN_to_DEC_Post_Diesel_Critical=Electrical_Power_Generation_Gap_Post_Diesel_Critical/4; % MWhr

% Isolate deficit by making negative values in Energy gap (Surpluses in
% energy) equal to 0 
Energy_Generation_Deficit_JAN_to_DEC_Post_Diesel_Critical=Energy_Generation_Gap_JAN_to_DEC_Post_Diesel_Critical; % MWhr
Energy_Generation_Deficit_JAN_to_DEC_Post_Diesel_Critical(Energy_Generation_Gap_JAN_to_DEC_Post_Diesel_Critical<0)=0; % MWhr


%%%%%%%%%%%%%%%%%%%%%%%% Hydro Power %%%%%%%%%%%%%%%%%%%%

% [Hydro_Stored_Energy,Hydro_Pump_Power,Hydro_Energy_Stored_Net_Charge_Discharge,Hydro_Renewable_Charged_Power,Hydro_Grid_Charged_Power]=Hydro_Power(Hydro_Strategy,...
%     Hydro_Selector,Grid_failure_flag_mat,...
%     Critical_load,Stochastic_Iterations,Energy_Generation_Surplus_JAN_to_DEC,Energy_Generation_Deficit_JAN_to_DEC,Energy_Generation_Deficit_JAN_to_DEC_Critical,...
%     Hydro_initial_Charge_Percent,Hydro_Charge_Efficiency,Hydro_Discharge_Efficiency,Hydro_Self_Discharge_rate,Hydro_floor_percentage,Grid_Transmission_Limit,...
%     Grid_Carbon_TOD,Carbon_Limiter,Cost_Limiter,Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC,Grid_Carbon_Selector,Grid_Cost_Selector,...
%     Peak_MWatts_15min_JAN_to_DEC_final,Percentile_Delimeter_Carbon,Percentile_Delimeter_Cost);
%
[Hydro_Stored_Energy,Pumped_Hydro_Power,Hydro_Energy_Stored_Net_Charge_Discharge,Hydro_Renewable_Charged_Power,Hydro_Grid_Charged_Power,Hydro_CAPEX,temp_Battery_Stored_Energy_mat]=Hydro_power(Parameters(11),...
    Parameters(12),Grid_failure_flag_mat,...
    Critical_load,Stochastic_Iterations,Energy_Generation_Surplus_JAN_to_DEC_Post_Battery,Energy_Generation_Deficit_JAN_to_DEC_Post_Diesel,Energy_Generation_Deficit_JAN_to_DEC_Post_Diesel_Critical,...
    Hydro_initial_Charge_Percent,Hydro_Charge_Efficiency,Hydro_Discharge_Efficiency,Hydro_Self_Discharge_rate,Hydro_floor_percentage,Grid_Transmission_Limit,...
    Grid_Carbon_TOD,Carbon_Limiter,Cost_Limiter,Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC,Grid_Carbon_Selector,Grid_Cost_Selector,...
    Peak_MWatts_15min_JAN_to_DEC_final,Percentile_Delimeter_Carbon,Percentile_Delimeter_Cost);

 Hydro_Power_Discharging=Pumped_Hydro_Power;
 Hydro_Power_Discharging(Hydro_Power_Discharging>0)=0;

% Hydro_Grid_Charged_Power(Hydro_Grid_Charged_Power<0)=0;
% Hydro_Renewable_Charged_Power(Hydro_Renewable_Charged_Power<0)=0;
% Hydro_Power_Discharging=Pumped_Hydro_Power;
% Hydro_Power_Discharging(Hydro_Power_Discharging>0)=0;


%% Calculate Energy (Including Energy Storage Methods)

% Add Battery Discharge/Charge to Power Draw to get Electrical Power Gap
Electrical_Power_Generation_Gap_Post_Storage=Electrical_Power_Generation_Gap_Pre_Storage+Li_Ion_Battery_Power+Diesel_Generator_Power+Pumped_Hydro_Power;
% MW

% Grid Electricity 
% Determine how much power is supplied by the grid using the Generation
% Power Gap
Grid_Power_Supplied_15min_JAN_to_DEC_Active=Electrical_Power_Generation_Gap_Post_Storage-Electrical_Power_Generation_Gap_Post_Storage.*Grid_failure_flag_mat;
% Remove negative values
Grid_Power_Supplied_15min_JAN_to_DEC_Active(Grid_Power_Supplied_15min_JAN_to_DEC_Active<0)=0;
% MW
%plot(Grid_Power_Supplied_15min_JAN_to_DEC(1:5*24*4,1,1))

% Determine the Overall Electrical Power Gap (Load Shed) 
Electrical_Load_Shed_Power=Peak_MWatts_15min_JAN_to_DEC_final-...
    Solar_Power_Generated_15min_JAN_to_DEC_Active-...
    Wind_Power_Generated_15min_JAN_to_DEC_Active-...
    Grid_Power_Supplied_15min_JAN_to_DEC_Active+...
    Li_Ion_Battery_Power+...
    Diesel_Generator_Power+...
    Pumped_Hydro_Power;
% MW

% Remove negative values. These represent surplus
Electrical_Load_Shed_Power(Electrical_Load_Shed_Power<0)=0;
% plot(Electrical_Load_Shed_Power(1:350*24*4,1,1))
%
% Find the Load Shed value 
Energy_Load_Shed=Electrical_Load_Shed_Power/4; %MWhr
temp_Energy_Load_Shed_cum=sum(Energy_Load_Shed,[1,2]);
Energy_Load_Shed_cum=squeeze(temp_Energy_Load_Shed_cum);



% Find the Critical Load Shed Value
% Set Demand Equal to Critical load
Energy_Critical_Load_Shed=(Critical_load- ...
    Solar_Power_Generated_15min_JAN_to_DEC_Active-...
    Wind_Power_Generated_15min_JAN_to_DEC_Active-...
    Grid_Power_Supplied_15min_JAN_to_DEC_Active+...
    Li_Ion_Battery_Power+...
    Diesel_Generator_Power+...
    Pumped_Hydro_Power)/4; 
% MWh
Energy_Critical_Load_Shed(Energy_Critical_Load_Shed<0)=0;
% Sum within the iterations
temp_Energy_Critical_Load_Shed_cum=sum(Energy_Critical_Load_Shed,[1,2]);
% Squeeze them into a column of values
Energy_Critical_Load_Shed_cum=squeeze(temp_Energy_Critical_Load_Shed_cum);

% Create a Model_Objective Index Value to aid in placing the model
% objectives within the Model_Objective Matrix for each iteration

Model_Objective_Indexer=(Sens_trial-1)*2*Model_Objectives_num+(D2D-1)*Model_Objectives_num;

% These model objectives are for overall load shed
%Model_Objective(Model_Objective_Indexer+1)=mean(Energy_Load_Shed_cum);
%Model_Objective(Model_Objective_Indexer+2)=std(Energy_Load_Shed_cum);


% Find the mean and std
%Model_Objective(Model_Objective_Indexer+3)=mean(Energy_Critical_Load_Shed_cum); 
% MWh
%Model_Objective(Model_Objective_Indexer+4)=std(Energy_Critical_Load_Shed_cum);
% MWh

% Find the days with Critical Load Shed 
temp_Critical_Load_Fail_Time_Steps=sum(Energy_Critical_Load_Shed>0,[1,2]);
Critical_Load_Fail_Time_Steps=squeeze(temp_Critical_Load_Fail_Time_Steps);
Model_Objective(Model_Objective_Indexer+5)=mean(Critical_Load_Fail_Time_Steps);
%Model_Objective(Model_Objective_Indexer+6)=std(Critical_Load_Fail_Time_Steps);
%% Cost Calculations

% %% Grid Electricity Cost
% 
% % From utility bill data
% % Most recent takes the data from FY23 and FY22 and merges it to create a
% % cost data for 1 year starting in JAN going to DEC
% 
% Most_Recent_Cost_of_Grid_Electricity_JAN_to_DEC= [WP_Grid_Electricity_Costs_OCT22_to_MAR23(4:6);WP_Grid_Electricity_Costs_OCT21_to_SEP22(7:12);WP_Grid_Electricity_Costs_OCT22_to_MAR23(1:3)]
% % $/kWhr
% 
% % Average grid cost of energy calculations 
% Grid_Electricity_Cost_Matrix_OCT_to_MAR=cat(3,WP_Grid_Electricity_Costs_OCT19_to_SEP20(1:6),...
%     WP_Grid_Electricity_Costs_OCT20_to_SEP21(1:6),...
%     WP_Grid_Electricity_Costs_OCT21_to_SEP22(1:6),...
%     WP_Grid_Electricity_Costs_OCT22_to_MAR23);
% Grid_Electricity_Cost_Matrix_APR_to_SEP=cat(3,WP_Grid_Electricity_Costs_OCT19_to_SEP20(7:12),...
%     WP_Grid_Electricity_Costs_OCT20_to_SEP21(7:12),...
%     WP_Grid_Electricity_Costs_OCT21_to_SEP22(7:12));
% Average_Cost_of_Grid_Electricity_OCT_to_SEP=[mean(Grid_Electricity_Cost_Matrix_OCT_to_MAR,3);mean(Grid_Electricity_Cost_Matrix_APR_to_SEP,3)]
% Average_Cost_of_Grid_Electricity_JAN_to_DEC=[Average_Cost_of_Grid_Electricity_OCT_to_SEP(4:12);Average_Cost_of_Grid_Electricity_OCT_to_SEP(1:3)]
% % $/kWh
% 
% % Make 15 minute frequency of cost data
% Days_in_month_JAN_to_DEC=[31,28,31,30,31,30,31,31,30,31,30,31]';
% Days_in_month_JAN_to_DEC_15min=Days_in_month_JAN_to_DEC*4*24;
% 
% Average_Cost_of_Grid_Electricity_JAN_to_DEC_15_min=repelem(Average_Cost_of_Grid_Electricity_JAN_to_DEC,Days_in_month_JAN_to_DEC_15min);
% % $/kWh
% Most_Recent_Cost_of_Grid_Electricity_JAN_to_DEC_15min=repelem(Most_Recent_Cost_of_Grid_Electricity_JAN_to_DEC,Days_in_month_JAN_to_DEC_15min);
% % $/kWh
% 
% % remove last 2 values to match data
% Average_Cost_of_Grid_Electricity_JAN_to_DEC_15_min=Average_Cost_of_Grid_Electricity_JAN_to_DEC_15_min(1:end-2,:);
% % $/kWh
% Most_Recent_Cost_of_Grid_Electricity_JAN_to_DEC_15min=Most_Recent_Cost_of_Grid_Electricity_JAN_to_DEC_15min(1:end-2,:);
% % $/kWh

%Grid_Energy_Supplied=Energy_Generation_Deficit_JAN_to_DEC*

% Expand Most Recent Cost of Grid Electricit to Stochastic Array Iterations
Cost_of_Grid_Electricity_JAN_to_DEC_15min_Stoch=repelem(Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC(:,Grid_Cost_Selector),1,1,Stochastic_Iterations);
% $/kWhr

Grid_Cost=Grid_Power_Supplied_15min_JAN_to_DEC_Active/4.*Cost_of_Grid_Electricity_JAN_to_DEC_15min_Stoch*1000;
% $

% Wind_LCOE= 4; % cents/kWh (IN ASSUMPTIONS FILE)
% 3 to 4.5 cents/kWh
% NREL's Cost of Wind Energy Calculations 
% https://www.nrel.gov/docs/fy23osti/84774.pdf (PDF 29)
Wind_Cost=Wind_Power_Generated_15min_JAN_to_DEC_Active/4*1000*Wind_LCOE; %dollars

% Solar_LCOE= 6; %cents/kWh (IN ASSUMPTIONS FILE)
% NREL US Solar Photovoltaic System and Energy Storage Cost Benchmark
% https://www.nrel.gov/docs/fy22osti/83586.pdf pdf page 70 
%       8.7 to 4.1 cents/kWh
%Solar_Energy_Generated_15min_JAN_to_DEC=Solar_Power_Generated_15min_JAN_to_DEC/4; % MWhr

% Isolate the power generated by Solar
Solar_Power_Generated_15min_JAN_to_DEC_Active_Cost=Solar_Power_Generated_15min_JAN_to_DEC_Active;
Solar_Power_Generated_15min_JAN_to_DEC_Active_Cost(Solar_Power_Generated_15min_JAN_to_DEC_Active_Cost<0)=0;

% Convert the power generated to the cost of solar power at each step
Solar_Cost=Solar_Power_Generated_15min_JAN_to_DEC_Active_Cost/4*(1000)*Solar_LCOE; %dollar
% MW-(15 min terms) * (1 hr/4*(15 min terms)) * (1000 kW/Mw) * ($/kWh)

%% Heat Pump Cost Estimation

% Sum all the costs of the heat pump
HR_Heat_Pump_CAPEX_Tot=HP_Heat_Output_Total*HP_Equipment_CAPEX+HP_Drilling_Costs+HP_Surface_facility_Capital_Costs+HP_Stimulation_CAPEX+HP_Interconnection_CAPEX;
HR_Heat_Pump_Annual_Cost_CAPEX=12*payper(Discount_Rate,Heat_Pump_Life_Cycle*12,HR_Heat_Pump_CAPEX_Tot)*Parameters(14);

HP_OPEX=(HP_Labor_OPEX+HP_Maintenance_Cost_Fraction*HR_Heat_Pump_CAPEX_Tot/Heat_Pump_Life_Cycle)*Parameters(14);
% Calculate the total OPEX for the Heat Pump 

%% Cost of Lithium battery system
% This information is from NREL and MIT Future Energy Storage
% https://www.nrel.gov/docs/fy23osti/85332.pdf
% Lithium Ion Battery NREL Cost Projections
% MIT Future of Energy Storage
% https://energy.mit.edu/research/future-of-energy-storage/
Li_Ion_Battery_Capacity=Parameters(5);          % MWh 
%Li_Ion_Battery_Capacity_Cost= 277*1000;        % $/MWh (IN ASSUMPTIONS FILE)
Li_Ion_Battery_Power_Output=Parameters(6);      % MW
%Li_Ion_Battery_Power_Output_Cost=257*1000;     % $/MW (IN ASSUMPTIONS FILE)
% Discount_Rate=0.08/12;                        % %  (IN ASSUMPTIONS FILE)
% Discount_Years=15;                            % years (IN ASSUMPTIONS FILE)
%Li_Ion_Battery_Power_Output_FOM=1.4*1000;      % $/MW-Year (IN ASSUMPTIONS FILE)
%Li_Ion_Battery_Power_Capacity_FOM= 6.8*1000;   % $/MWh-Year (IN ASSUMPTIONS FILE)

% Use the energy capacity and capacity cost aswell as out put and output
% cost to determine the annual cost. Use the discount rate and divide it
% over the project length (15 years) into monthly payments. 
Li_Ion_Battery_Annual_Cost_CAPEX=12*payper(Discount_Rate,Li_Ion_Battery_Life_Cycle*12,Li_Ion_Battery_Capacity*Li_Ion_Battery_Capacity_Cost+Li_Ion_Battery_Power_Output*Li_Ion_Battery_Power_Output_Cost);

% Use the size of the battery to determine the fixed yearly operating &
% maintenance costs. 
Li_Ion_Battery_Annual_Cost_FOM=Li_Ion_Battery_Capacity*Li_Ion_Battery_Power_Capacity_FOM+Li_Ion_Battery_Power_Output*Li_Ion_Battery_Power_Output_FOM;

%% Cost of Hydro Systems

Hydro_Annual_Cost_CAPEX=12*payper(Discount_Rate,Hydro_Life_Cycle*12,Hydro_CAPEX);
% https://www.sciencedirect.com/science/article/pii/S0378778820310069#s0050


%% Cost of Diesel Generators 

% Generator Size and cost data from Caterpillar 
% • 2000kW: $1,030,000 https://www.cat.com/en_US/products/new/power-systems/electric-power/diesel-generator-sets/1000028912.html
% • 2500kW: $1,260,000 https://www.cat.com/en_US/products/new/power-systems/electric-power/diesel-generator-sets/1000028912.html
% • 2750kW: $1,360,000 https://www.cat.com/en_US/products/new/power-systems/electric-power/diesel-generator-sets/117341.html
% • 3000kW: $1,400,000 https://www.cat.com/en_US/products/new/power-systems/electric-power/diesel-generator-sets/1000033111.html
% (These power measures are standby ratings) 
% This information was given by a CAT contractor in 2024. The pdf can be
% found in references

Diesel_generator_sizes_mat=[2,2.5,2.75,3];          %MW
Diesel_generator_costs_mat=[1030,1260,1360,1400];   % $k


% This information was gleaned from the CAT data sheets for each generator
% (located in References) 
Diesel_generator_diesel_use_rate_output=[
    505.8,  636,     716.3,  773.2; % at 100% capacity
    393.9,  494.6,   547,    624.2; % at 75% capacity
    284.2,  360.5,   399,    467.5; % at 50% capacity
    164.3,  212.3,   233.5,  246.4; % at 25% capacity
    0,      0,       0,      0;     % at 0% capacity
    ]; 
% L/hr
Diesel_generator_diesel_use_rates=[1,.75,.5,.25,0];


% Find how much diesel was used in each period 
    % First find the percent capacity at 
Diesel_Usage_Capacity=-Diesel_Generator_Power./(Diesel_generator_sizes_mat(Parameters(10)).*Parameters(9));
% % of max capacity
Diesel_Usage_Capacity(isnan(Diesel_Usage_Capacity))=0;
    % This makes the value of usage zero if the number of generators is
    % zero

% Use Interpolate to determine how much fuel is being used 
Diesel_Fuel_Use=interp1(Diesel_generator_diesel_use_rates,Diesel_generator_diesel_use_rate_output(:,Parameters(10)),Diesel_Usage_Capacity).*Parameters(9)./4;
% L

% Find the Cost of diesel fuel for each time period
Diesel_Generator_Fuel_Cost=Diesel_Fuel_Use.*Price_of_Diesel;
% $ 

% Find the cost of storeing the Diesel
% The data came from Erden's research. A summary doc is included in Diesel
% generator data
% Assume we will be using double wall systems
%   Double wall data (in Assumptions)
% Double_Wall_storage=[15000, 56584]; % gal, $

Number_of_Tanks=ceil(Diesel_Tank_Size/Double_Wall_storage(1));
Cost_of_Diesel_Tanks=Double_Wall_storage(2)*Number_of_Tanks; % $

% Combine costs of generators and storage tanks to find capex cost
Diesel_Capex=Parameters(9)*Diesel_generator_costs_mat(Parameters(10))*1000+Cost_of_Diesel_Tanks;
% $

% Use the Diesal Capex to account for mainenance. Use the discount rate and divide it
% over the project length (20 years) into monthly payments. 
Diesel_Annual_Cost_CAPEX=12*payper(Discount_Rate,Diesel_System_Life_Cycle*12,Diesel_Capex*Diesel_Capex_Multiplicative_Factor);

% Diesels=struct('Diesel_Generator_Power', cell(Sensitivity_iter,1))


%%  Cost of Grid Carbon/Externalities

% New England Electricity Carbon Generation Data can be found in
% Data_for_emissions. It is taken from sheet 3.3.1 which is load wheighted
% marginal emissions (lb/MWh) [SO2, NOx, CO2] <-arranged in this way
% https://www.iso-ne.com/system-planning/system-plans-studies/emissions
%
% Make 15 minute frequency of New England Data uses these mat
%Days_in_month_JAN_to_DEC=[31,28,31,30,31,30,31,31,30,31,30,31]';
%Days_in_month_JAN_to_DEC_15min=Days_in_month_JAN_to_DEC*4*24;
%
%temp_New_England_Emissions_data=repelem(final2022airemissionsreportappendixS7, Days_in_month_JAN_to_DEC_15min,1);
%New_England_Emissions_data=temp_New_England_Emissions_data(1:35038,:);
%lbs/MWh

% Carbon Cost ----------------------------------------------------
% 2023 = 204 $/tonn Carbon (metric) 
% Range Potentially (From EPA) 
% Carbon_Cost=204;                % $/tonnes (IN ASSUMPTIONS FILE)

Grid_Carbon_Cost=Carbon_Cost*(1/2204.62)*New_England_Emissions_data(:,3).*Grid_Power_Supplied_15min_JAN_to_DEC_Active/4;
% $ = [$/tonnes]*[tonnes/lbs]*[lbs/MWh]*[MW]*[hr/15min]

% Carbon Cost TOD -----------------------------------------------
Grid_Carbon_Cost_TOD=Carbon_Cost.*Grid_Carbon_TOD(:,2,Grid_Carbon_Selector).*Grid_Power_Supplied_15min_JAN_to_DEC_Active/4*10^-3;
% $ = [$/tonnes]*[1 tonnes/ 10^6 g]*[g/kWh]*[1000 kWh/MWh]*[MW]*[hr/15 min]

Grid_Carbon_Combined=[Grid_Carbon_Cost_TOD,Grid_Carbon_Cost];


% SOX ---------------------------------------------------------------
% 2022 = 150 $/Metric tonn
%SOX_Cost=150;                   % $/tonnes (IN ASSUMPTIONS FILE)
Grid_SOX_Cost=SOX_Cost*(1/2204.62)*New_England_Emissions_data(:,1).*Grid_Power_Supplied_15min_JAN_to_DEC_Active/4;
% $

% NOX ----------------------------------------------------------------
% Nox_Cost=15000; $/Tonn (Metric)
Grid_NOX_Cost=NOX_Cost*(1/2204.62)*New_England_Emissions_data(:,2).*Grid_Power_Supplied_15min_JAN_to_DEC_Active/4;

%% Embedded Carbon 

% Solar Embedded Carbon -----------------------------------------
% 2560 kg CO2 per KWp (rated power of the system) for Solar Panels 
% Solar_Embedded_Carbon=2560;         % kg CO2/ kWp [In Assumptions]
Solar_System_Embedded_Carbon=Solar_Rated_Power*Solar_Embedded_Carbon*1000;
% kg

Solar_System_Embedded_Carbon_Capex=Solar_System_Embedded_Carbon/1000*Carbon_Cost;
% (kg) * (1 tonne/ 1000kg) * ($/tonne) = $
% $

% Find the discounted value of the Embedded carbon cost
Solar_System_Embedded_Carbon_Annual_Cost=12*payper(Discount_Rate,Solar_Life_Cycle*12,Solar_System_Embedded_Carbon_Capex);



% Wind Embedded Carbon -----------------------------------------
% 465077 kg CO2/ 1.75 MW 
% Each SAM Turbine is rated for 3 MW 
% Wind_Embedded_Carbon=465077/1.75*3;       [In Assumptions]
% % (kg CO2/ 1.75 MW) * (3 MW / Turbine) = kg CO2/ Turbine
Wind_System_Embedded_Carbon=Wind_Embedded_Carbon*Parameters(3);
% kg

Wind_System_Embedded_Carbon_Capex=Wind_System_Embedded_Carbon/1000*Carbon_Cost;
% (kg) * (1 tonne/ 1000kg) * ($/tonne) = $

% Find the discounted value of the Embedded carbon cost
Wind_System_Embedded_Carbon_Annual_Cost=12*payper(Discount_Rate,Wind_Life_Cycle*12,Wind_System_Embedded_Carbon_Capex);



% Lithium Battery Embedded Carbon ----------------------------------
% 28.4 kg CO2/ kWh (CO2 from raw materials & production) (This is considered
% Capex, 

Li_Ion_Battery_System_Embedded_Carbon=Li_Ion_Battery_Embedded_Carbon*Parameters(5)*1000;
% kg CO2/kWh * (1000 kWh/1 MWh) * MW = kg

Li_Ion_Battery_System_Embedded_Carbon_Capex=Li_Ion_Battery_System_Embedded_Carbon/1000*Carbon_Cost;
% (kg) * (1 tonne/ 1000kg) * ($/tonne) = $

% Find the discounted value of the Embedded carbon cost
Li_Ion_Battery_System_Embedded_Carbon_Annual_Cost=12*payper(Discount_Rate,Li_Ion_Battery_Life_Cycle*12,Li_Ion_Battery_System_Embedded_Carbon_Capex);

%% Cost of Diesel Externalities
% Emissions Data for each generator
% % This information was gleaned from the CAT data sheets for each generator
% (located in References) 
% Col generators
% Row
%  1: NOX
%  2: CO
%  3: HC 
%  4: PM
% Diesel_generator_emissions_nominal=[
%     2754.3  2349.1  2319.2  2610.4;
%     143.3   195.4   321.4   305.9;
%     44.7    42.1    30.7    17.4;
%     10.4    14.1    20.0    17.6]; % (g/hp-h)
% Diesel_generator_emissions_nominal=Diesel_generator_emissions_nominal./(0.7456998716*1000); % (Tonnes/MWhr)
%    % 1 gram = 10^-6 Metric Tons
%    % 1 hp-h = 745.6998716 Wh = 745.6998716*10^-6 MWhr

Diesel_generator_emissions_potential=[
    3305.2  2818.9  2783    3132.5;
    258     351.8   536.7   550.6;
    59.5    55.9    40.8    23.1;
    14.6    19.7    28.1    24.6]; % (g/hp-h)
Diesel_generator_emissions_potential=Diesel_generator_emissions_potential./(0.7456998716*1000); % (Tonnes/MWhr)
% (g/hp) (1 hp / 0.000745699 MWh) * (1 Metric Ton / 10000000 g)

% Diesel NOX -----------------------------------------------------
% Use the interpolated value of Diesel Fuel use as a percentage of the max
% fuel use. Then multiply against the emissions generated at maximum output
% to estimate emissions
Diesel_NOX_Cost=Diesel_Fuel_Use./(Diesel_generator_diesel_use_rate_output(1,Parameters(10))).*...
    Diesel_generator_emissions_potential(1,Parameters(10))*NOX_Cost;

% Diesel Carbon Cost ---------------------------------------------------
Diesel_Carbon_Cost=Diesel_Fuel_Use.*Carbon_in_Diesel./10^3.*Carbon_Cost;
% $
Diesel_Carbon=Diesel_Fuel_Use.*Carbon_in_Diesel./10^3;
% tonnes

%% Cost of Vehicle Fuels

% This data was gleaned from the fuel delivery chart used by dpw and an
% average cost of fuel. The Fuel delivery was assumed as gallons

Cost_of_Vehicle_Fuel=(sum(Mogas_Delivered_2023)*Price_of_Mogas+...
    sum(E85_Delivered_2023)*Price_of_E85+...
    sum(Diesel_Delivered_2023)*Price_of_Diesel_gal)*(1-Parameters(13)); % Dollars

% If parameters(13)=1 then that means we are switching to electric
% vehicles. This leads to an increase in electrical power demand and fuel
% costs drop to zero. 

Cost_of_Vehicle_Fuel_Carbon=(sum(Mogas_Delivered_2023)*Mogas_Carbon+...
    sum(E85_Delivered_2023)*E85_Carbon+...
    sum(Diesel_Delivered_2023)*Carbon_in_Diesel_gal)*(1/1000)*(1-Parameters(13))*Carbon_Cost; % Dollars


%% Cost of Natural Gas

Cost_of_Natral_Gas=sum(Most_Recent_Cost_of_Natural_Gas_JAN_to_DEC_Monthly)*(1-Parameters(14)); % $
% If using Natural gas system, this returns the most recent years Natural gas prices 

Natural_Gas_Carbon=sum(Most_Recent_Natural_Gas_Usage_JAN_to_DEC_Monthly)*Natural_Gas_Carbon_Emissions*(1/1000)*(1000/1)*(1-Parameters(14));
% kcf Natural Gas *(kg co2/cf NG) * (1 tonnes/1000 kg) *(1000 cf/1 kcf) =
% tonnes CO2

Natural_Gas_Carbon_Cost=Carbon_Cost*Natural_Gas_Carbon;
% $



%% Cost Aggregation

% Collect the cost data into one matrix
Cost_Matrix=[Grid_Cost,Solar_Cost,Wind_Cost,Diesel_Generator_Fuel_Cost];
Externality_Cost_Matrix=[Grid_Carbon_Combined(:,Grid_Cost_Selector,:),Grid_SOX_Cost,Grid_NOX_Cost,Diesel_Carbon_Cost,Diesel_NOX_Cost];


% Use a function to collect the data
temp=sum(Cost_Matrix,[1,2]);
Cost_One_Year=squeeze(temp);
Model_Objective(Model_Objective_Indexer+1)=mean(Cost_One_Year)+...
    Li_Ion_Battery_Annual_Cost_CAPEX+Li_Ion_Battery_Annual_Cost_FOM+...
    Hydro_Annual_Cost_CAPEX+Diesel_Annual_Cost_CAPEX+Transmission_Cost_CAPEX+...
    Cost_of_Natral_Gas+HR_Heat_Pump_Annual_Cost_CAPEX+HP_OPEX+Cost_of_Vehicle_Fuel;
%Model_Objective(Model_Objective_Indexer+2)=std(Cost_One_Year);

temp2=sum(Externality_Cost_Matrix,[1,2]);
Externality_Cost_One_Year=squeeze(temp2);
Model_Objective(Model_Objective_Indexer+7)=mean(Externality_Cost_One_Year)+...
    Solar_System_Embedded_Carbon_Annual_Cost+Wind_System_Embedded_Carbon_Annual_Cost+...
    Li_Ion_Battery_System_Embedded_Carbon_Annual_Cost+Natural_Gas_Carbon_Cost+Cost_of_Vehicle_Fuel_Carbon;
%Model_Objective(Model_Objective_Indexer+8)=std(Externality_Cost_One_Year);

% Create a model objective for Max on Post Power Generation (FUTURE WORK) 
%Model_Objective(Model_Objective_Indexer+9)=sum(Solar_Rated_Power,Wind_Rated_Power_Per_Turbine*Parameters(3))


end % End for the D2D vs Extreme for loop

end % End for the Sensitivity For loop

save("System_Methodology_Images_100S_5G_100T.mat");

%toc 
end % End for the function 


