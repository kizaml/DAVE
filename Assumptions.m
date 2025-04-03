
close all
clear 
clc

% West Energy Resilience
% XE485 24-1 & 24-2
% My contact -> 215-528-7614 (David Sang)

% This document is used to control the model. It includes all valuable
% inputs and assumptions that can be changed. 

%% Sensitivity Analysis Assumptions

% Use this to decide wether or not to run sensitivity analysis.
% Sensitivity analysis tests the same set of infastrcuters against
% different assumptions. The model will optimize the potential solution
% against all sensitivity scenarios weights equally 

Sensitivity_analysis_multiplyer=[1];
%Sensitivity_analysis_multiplyer=[.9,  1,  1.1];
%Sensitivity_analysis_multiplyer=[.8, .9,  1,  1.1,  1.2];

Sensitivity_iter=length(Sensitivity_analysis_multiplyer);

% Change this as the number of objectives change
Parameters_vars_num=14;
Model_Objectives_num=10;

Sensitivity_Variable="Grid_hazard_rate";

Grid_example_on=0;
% when 1, creates failuers at day 5-7, and 10 - 30 in JAN, 
% I used this to create example failures in the images

%% Model Assumptions 

% Genetic Algorithm 
Pop_size= 200; % # of potential solutions to test 
Max_generations= 25; % # of iterations to optimize for

Stochastic_Iterations= 10;    % # of failure trials for each potential solution
Critical_load=10;               % MW
% Assumed as roughly half WP's average power demand

Discount_Rate=0.08/12;           %/month (*12 to get to years)
% Used for Capex calculations 

%% TOD Selection/Allowance
% Grid Cost Selector
Grid_Cost_Selector=1;
    % 1 = Time of day pricing
    % 2 = Constant pricing 
    % For input in "Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC"
        % in Li_ion_Battery.m

% Select the year to grab TOD grid emissions data from
Grid_Carbon_Selector=1;
    % 1 = 2023
    % 2 = 2022

% Grid Transmission Limit
Grid_Transmission_Limit=36;
% MW
% This if from DPW data 

temp_Days_to_consider=10;
% How many previous days to consider in the precentile

% Charging/ Discharging Assumptions 
    % Only charge/discharge criteria for carbon
    Carbon_Limiter=[30, 70];
    % Charge when below the 30th percentile for carbon costs during the
    % "Days to consider" timeline. Discharge at above the 70th percentile

% Potentially consider having the model decide the limiters. It would be
% cool for the model to optimize these parameters

    % Charge/discharge criteria for cost 
    Cost_Limiter=[30, 70];
    % Charge when below the 30th percentile for electricity costs during the
    % "Days to consider" timeline. Discharge at above the 70th percentile
    

% Run the TOD Charging here. It stays the same for all trials
load("Data_for_Cost_Function_One_Year\Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC.mat")
load("Data_for_emissions\Grid_Carbon_TOD.mat")
[Percentile_Delimeter_Cost,Percentile_Delimeter_Carbon]=TOD_Charging(temp_Days_to_consider,Grid_Carbon_TOD,Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC,Grid_Carbon_Selector,Cost_Limiter,Carbon_Limiter);


%% Solar Assumptions
    
% % Previous Model
% Data_Selector_Solar=26; 
%     % Solar Function Inputs Explanation
%     % [MW,W], (Data_Selecter_Solar, Panel Size)
%     % Data Selecter
%     % 1=1998
%     % 2=1999 and so forth to 25
%     % 25=2022
%     % 26=Average
%     % Panul Size m^2
% 
%     %Solar_LCOE= 0.06; % $/kWh
%     % NREL US Solar Photovoltaic System and Energy Storage Cost Benchmark
%     % https://www.nrel.gov/docs/fy22osti/83586.pdf pdf page 70 
%     %       8.7 to 4.1 cents/kWh
%     %Solar_Energy_Generated_15min_JAN_to_DEC=Solar_Power_Generated_15min_JAN_to_DEC/4; % MWhr
% 
%     % Solar Function Assumptions ---------------
% Panel_Efficiency = 0.22;

% SAM Model Provides LCOE for various Sysem Types
    % SAM Model also provides effieceny and data

% Solar Life Cycle Assumptions
Solar_Life_Cycle=20; % years

Solar_Roof_Area_Correction_Factor=0.6;  % 60% of the area is useful
Solar_Roof_Area=50847.80*Solar_Roof_Area_Correction_Factor; % m^2
% Found using google earth. There is a document titled West Point Roof
% Areas containing the Areas

Solar_Parking_Lot_Correction_Factor=0.8; % 80% of the area is useful
Solar_Parking_Lot_Area= 20.9 * 4046.86 * Solar_Parking_Lot_Correction_Factor; % m^2
% This can be foud in the Solar Park Excell Sheet



%% Wind Assumptions 

% % Old wind assumptions 
% Data_Selector_Wind=1;
% % 
% % % Wind Function Inputs Explanation
% % % [W,MW/Turbine], (Data_Selector, Panel Size)
% % % Data Selecter
% % % 1 = 2021
% % % 2 = 2022
% % % 3 = Average
% % % # of Turbines
% % 
% % Wind_LCOE= 0.04; % $kWh
% % % 3 to 4.5 cents/kWh
% % % NREL's Cost of Wind Energy Calculations 
% % % https://www.nrel.gov/docs/fy23osti/84774.pdf (PDF 29)
% % 
% % % Wind Function Assumptions -----------------
%  Hub_height=95;          %m
% Rotor_Radius=127/2;     %m
% Cp=0.4;                 % Efficiency ~ 40%
% % % These numbers have been adjusted to match NREL's Cost of Wind Energy
% % % Calculations (Can be found in references) 
% % % https://www.nrel.gov/docs/fy23osti/84774.pdf (PDF 24)

% SAM Wind model usese internal assumptions so these values are not needed

% Wind Life Cycle Assumption, Used for embedded carbon
Wind_Life_Cycle=15;         % Years

%% Battery Assumptions

% This information is from NREL and MIT Future Energy Storage
% https://www.nrel.gov/docs/fy23osti/85332.pdf
% Lithium Ion Battery NREL Cost Projections
% MIT Future of Energy Storage
% https://energy.mit.edu/research/future-of-energy-storage/
Li_Ion_Battery_Life_Cycle=15;                   %years
Li_Ion_Battery_Capacity_Cost= 277*1000;         % $/MWh
Li_Ion_Battery_Power_Output_Cost=257*1000;      % $/MW
%Discount_Rate=0.08/12;                          % %/month (*12 to get to years)
Li_Ion_Battery_Power_Output_FOM=1.4*1000;       % $/MW-Year
Li_Ion_Battery_Power_Capacity_FOM= 6.8*1000;    % $/MWh-Year

% Battery Function Assumptions
% Make some assumptions on how the battery works 
% These reference MIT's future of energy storage text
Battery_initial_Charge_Percent=0.5; % %of max capacity
Battery_floor_percentage=0.45;      % %of max capacity
Battery_Charge_Efficiency=0.92; 
Battery_Discharge_Efficiency=0.92;
Battery_Self_Discharge_rate=0.015/30/24/4; % Percent per 15 min time
% 1.5% discharge a month



%% Diesel Assumptions

% This information is from NREL and MIT Future Energy Storage
% https://www.nrel.gov/docs/fy23osti/85332.pdf
% Lithium Ion Battery NREL Cost Projections
% MIT Future of Energy Storage
% https://energy.mit.edu/research/future-of-energy-storage/
Diesel_System_Life_Cycle=20;                    %years
Diesel_Capex_Multiplicative_Factor=1.5;         %
    % This represents the increase in capex due to maintenance over its
    % Life time. 
%Li_Ion_Battery_Capacity_Cost= 277*1000;         % $/MWh
%Li_Ion_Battery_Power_Output_Cost=257*1000;      % $/MW
%Li_Ion_Battery_Power_Output_FOM=1.4*1000;       % $/MW-Year
%Li_Ion_Battery_Power_Capacity_FOM= 6.8*1000;    % $/MWh-Year

Diesel_initial_Charge_Percent=1; % %of max capacity
Diesel_Tank_Refill_Trigger_Percentage=0.97; 
% What percentage the diesel tank needs to be at to trigger a refill
Diesel_Storage_Delay_Time=7*24*4;    % # of 15 min time steps
% 7 days 
Price_of_Diesel=3*3.78541; % $/L
% Assuming #2 Diesal is used. It is ~ $3/gal (1 gal = 3.78541 L)
% Found from google



Carbon_in_Diesel=2.6391;      %kg/L
% Assume 1 L Diesel produces 2.6391kg of carbon
%https://comcar.co.uk/emissions/co2litre/?fueltype=diesel#:~:text=Diesel%20produces%202.6391%20kgs%20of,by%20the%20addition%20of%20oxygen.


% Generator Size and cost data from Caterpillar 
% • 2000kW: $1,030,000 https://www.cat.com/en_US/products/new/power-systems/electric-power/diesel-generator-sets/1000028912.html
% • 2500kW: $1,260,000 https://www.cat.com/en_US/products/new/power-systems/electric-power/diesel-generator-sets/1000028912.html
% • 2750kW: $1,360,000 https://www.cat.com/en_US/products/new/power-systems/electric-power/diesel-generator-sets/117341.html
% • 3000kW: $1,400,000 https://www.cat.com/en_US/products/new/power-systems/electric-power/diesel-generator-sets/1000033111.html
% (These power measures are standby ratings) 
% This information was given by a CAT contractor in 2024. The pdf can be
% found in references

Diesel_generator_sizes_mat=[2,2.5,2.75,3];          %MW 


Diesel_generator_diesel_use_rate=[
    133.6   168     189.2   204.3 
    104.1   130.7   144.5   164.9
    75.1    95.2    105.4   123.5
    43.4    56.1    61.7    65.1 
    0       0       0       0]; % gal/hr
% Col: Generator Size, (2000, 2500, 2750, 3000)
% Row: Use rate at % loads (Top to bot) ( 100%, 75% , 50%, 25% 0%)

% Diesel Fuel Storage Costs
% The data came from Erden's research. A summary doc is included in Diesel
% generator data
% Assume we will be using double wall systems
%   Double wall data (in Assumptions)
Double_Wall_storage=[15000, 56584]; % gal, $


%% Hydro Assumptions (Copied from battery Assumptions)

Hydro_Life_Cycle=15;                            %years
%Discount_Rate=0.08/12;                          % %/month (*12 to get to years)

% Hydro Function Assumptions
% Make some assumptions on how Hydro Power works 
Hydro_initial_Charge_Percent=0.5; % %of max capacity
Hydro_floor_percentage=0.45;      % %of max capacity
Hydro_Charge_Efficiency=1; 
Hydro_Discharge_Efficiency=1;
Hydro_Self_Discharge_rate=0.01    /30/24/4; % Percent per 15 min time
% 1% discharge a month (Assuming 30 day months)

%% Heat Pump Assumptions
% https://www.sciencedirect.com/science/article/pii/S0378778820310069#s0050

Heat_Pump_Life_Cycle=30;                            %years
%Discount_Rate=0.08/12;                          % %/month (*12 to get to years)

HP_Drilling_Costs=10350222; %$
HP_Surface_facility_Capital_Costs=2600000; % $
HP_Stimulation_CAPEX=1250000;          % $
HP_Equipment_CAPEX=300000;          % $/MW Heat pump  Capacity
HP_Interconnection_CAPEX=1000000;      % $
HP_Labor_OPEX=50000;       % $/year
HP_Maintenance_Cost_Fraction=0.01;    % Percentage of CAPEX_tot/Years


% Natural Gas Emissions 

Natural_Gas_Carbon_Emissions=0.0550;  % kg CO2/ft^3 Natural gas

% https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references#:~:text=The%20average%20carbon%20dioxide%20coefficient,gallon%20barrel%20(EPA%202023b).

%%  Hydro Function Assumptions
% Make some assumptions on how Hydro Power works 
Hydro_initial_Charge_Percent=0.5; % %of max capacity
Hydro_floor_percentage=0.45;      % %of max capacity
Hydro_Charge_Efficiency=1; 
Hydro_Discharge_Efficiency=1;
Hydro_Self_Discharge_rate=0.01    /30/24/4; % Percent per 15 min time
% 1% discharge a month (Assuming 30 day months)
%% Transmission Line Assumptions

% 48.3 MW Line costs $4 million per mile
% $4 mil/mile was an estimate given by LTC Barry 
% Buckner is 10 miles away

Transmission_Line_Cost=4000000; % $/Mile

Parking_Lot_Transmission_Line_Cost=Transmission_Line_Cost; % $

Distance_to_Buckner=10; % miles

Transmission_Line_Life_Cycle=50; % years


%% Vehicle Fuel Assumptions

Price_of_Mogas=5.71; % (NO UNITS), Assume dollars
%https://airnav.com/fuel/report.html

Price_of_E85=3.42; % Dollars/gal

Price_of_Diesel_gal=Price_of_Diesel*(1/.264172); % Dollars/gal

% Fuel delivery numbers did not come with units. Assume it is gallons. 

% EV demand for government vehicles
    % Calculated value of 12,188 kWh per day
Daily_EV_Energy_Demand=12188;   %kWh


Mogas_Carbon=8.887; %kg/gal
% https://www.epa.gov/greenvehicles/greenhouse-gas-emissions-typical-passenger-vehicle#:~:text=This%20assumes%20the%20average%20gasoline,8%2C887%20grams%20of%20CO2.

E85_Carbon=Mogas_Carbon;

Carbon_in_Diesel_gal=2.6391*(1/.264172);      %kg/gal

%% Externality Assumptions

% Carbon Cost 
% 2023 = 204 $/tonn Carbon (metric) 
% Range Potentially (From EPA) 
Carbon_Cost=204;                % $/tonnes

% SOX 
% 2022 = 150 $/Metric tonn
SOX_Cost=150;                   % $/tonnes

% NOX
% Nox_Cost=15000; $/Tonn (Metric)
NOX_Cost=15000; 
% the externalities were provided by Melissa Rankel, Reference the
% externality document for the sources

% Solar Embedded Carbon 
% 2560 kg CO2 per KWp (rated power of the system) for Solar Panels
Solar_Embedded_Carbon=2560;         % kg CO2/ kWp

% Wind Embedded Carbon
% 465077 kg CO2/ 1.75 MW Rated Turbine
Wind_Embedded_Carbon=465077/1.75*3;
% (kg CO2/ 1.75 MW) * (3 MW / Turbine) = kg CO2/ Turbine


% Li-Ion Battery Embedded Carbon
% 28.4 kg CO2/ kWh (CO2 from raw materials & production) (This is considered
% Capex, 
Li_Ion_Battery_Embedded_Carbon=28.4;
% kg/kWh

%% Stochastic Model Assumptions 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Currently on the Solar, Wind, and Grid can fail. Future work needs to
% expand on the failure behavior of all technologies 


% Assume the Solar system fails once every 21 years. 
% The chance it fails in 15 minutes can be found using the following
% formula
Solar_hazard_rate=1/(21*365*24*4); % 1 failure out of 21 years

% After it fails we need to determine how long it fails for
% Assunming the Average length of failure is 1.5 days with a standard
% deviation of 8 hours 
Solar_Failure_Avg_Length=1.5*24*4;  % 15 min sessions [=1.5 days]
Solar_Failure_Length_STD=8*4;      % 15 min sessions [=8 hrs]
% 1 std means 68% of solar failures are resolved between 
% [1 days 4hrs and 1 day 20hrs]

% Assume Wind Fails Once Every 170 Days
Wind_hazard_rate=1/(1*170*24*4); % 1 failure out of 170 days

% After it fails we need to determine how long it fails for
% Assunming the Average length of failure is 4 days with a standard
% deviation of 1 day
Wind_Failure_Avg_Length=4*24*4;  % 15 min sessions [=4 days]
Wind_Failure_Length_STD=24*4;      % 15 min sessions [=1 day]


% Failure of Grid Electricity 
% For Grid we will Create assumptions to fight four types of events
% We will create yearly failures, Decade level events,
% Half century level events, and a Cyber attack event

Grid_hazard_rate=[1/(1*365*24*4), 1/(10*365*24*4), 1/(50*365*24*4), 1/(3*365*24*4)];
% 1 failure/1 years , 1 fail/10 years, 1 fail/50 years, Cyber attack (1/3yr)

% After it fails we need to determine how long it fails for
% Event                 Avg Length      STD
% Annual                1 days          0.5 days
% Decade                4 days          1 days
% Half-Cent             7 days          1.5 days
% Cyber Attack          14 days         1 days

Grid_Failure_Avg_Length=24*4*[1,4,7,14]; 
% 15 min sessions [= 1, 4, 7, 14 days]

Grid_Failure_Length_STD=24*4*[0.5,1,1.5,1];   
% 15 min sessions [= 0.5, 1, 1.5, 1 days]


save("Model_Assumptions.mat")




