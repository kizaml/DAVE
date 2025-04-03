% clc
% clear
% close all 
%%
% West Energy Resilience
% XE485 24-1 & 24-2
% Contact -> 215-528-7614 (David Sang)


function [Diesel_Stored_Energy,Diesel_Generator_Power,Diesel_Energy_Impact_On_Grid,temp_Dischargeable_Energy_Generation_Deficit_JAN_to_DEC,Dischargeable_Energy_Generation_Deficit_JAN_to_DEC,Diesel_Tank_Size]=Diesel_Generator(Diesel_Strategy,...
    Diesel_Energy_Capacity,Number_of_Diesel_Generators,Diesel_Generator_Size, ...
    Grid_failure_flag_mat,Critical_load,Stochastic_Iterations,Energy_Generation_Deficit_JAN_to_DEC_Post_Battery,Energy_Generation_Deficit_JAN_to_DEC_Post_Battery_Critical,...
    Diesel_initial_Charge_Percent,Diesel_Tank_Refill_Trigger_Percentage, ...
    Diesel_Storage_Delay_Time,Diesel_generator_sizes_mat,Diesel_generator_diesel_use_rate);
%%


%%%%%%%%%%%%%%%% DEBUG INPUTS &&&%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%
% Everything you need to uncomment to have the function run alone
% The original values are still within the code. This is repeated for
% simplicity

% load('WP_energy_model_data.mat')
% load("Model_Assumptions.mat")
% 
% Stochastic_Iterations=100;
% Diesel_Energy_Capacity=1600;     
% Diesel_Power_Output=20;        
% Stochastic_Iterations=100;
% Diesel_Strategy=1;
% Critical_load=10;  % MW
% load('Data_for_Failure_Simulation_Function\Grid_failure_flag_mat.mat')
% Diesel_initial_Charge_Percent=1;
% Diesel_Tank_Refill_Trigger_Percentage=0.97;
% Diesel_Storage_Delay_Time=4*24*4;    % # of 15 min time steps
%     %4 days 
% Number_of_Diesel_Generators=3;
% Diesel_Generator_Size=3;

% Assumption to visualize behavior in the Test plots section
% Grid_failure_flag_mat(1*4*24:2*4*24,1,1)=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% Diesel System Costs/Sizing Background Data
% Generator Size and cost data from Caterpillar 
% • 2000kW: $1,030,000 https://www.cat.com/en_US/products/new/power-systems/electric-power/diesel-generator-sets/1000028912.html
% • 2500kW: $1,260,000 https://www.cat.com/en_US/products/new/power-systems/electric-power/diesel-generator-sets/1000028912.html
% • 2750kW: $1,360,000 https://www.cat.com/en_US/products/new/power-systems/electric-power/diesel-generator-sets/117341.html
% • 3000kW: $1,400,000 https://www.cat.com/en_US/products/new/power-systems/electric-power/diesel-generator-sets/1000033111.html
% (These power measures are standby ratings) 
% This information was given by a CAT contractor in 2024. The pdf can be
% found in references
%Diesel_generator_sizes_mat=[2,2.5,2.75,3];          %MW 
%   (Moved to Assumptions)
%Diesel_generator_costs_mat=[1030,1260,1360,1400];   % $k

% This information was gleaned from the CAT data sheets for each generator
% (located in References) 

% Diesel_generator_diesel_use_rate_max_output=[505.8, 636, 716.3, 773.2]; % L/hr at 100% capacity
% Diesel_generator_diesel_use_rate=[
%     133.6   168     189.2   204.3 
%     104.1   130.7   144.5   164.9
%     75.1    95.2    105.4   123.5
%     43.4    56.1    61.7    65.1 
%     0       0       0       0]; % gal/hr
% Col: Generator Size, (2000, 2500, 2750, 3000)
% Row: Use rate at % loads (Top to bot) ( 100%, 75% , 50%, 25% 0%)


% Find the size of the diesel storage tank needed. Use a conservative
% estimate of efficiency. (Use ther gal/hr *MWH/HR of at 25% output)

Diesel_Tank_Size=Diesel_Energy_Capacity*(1/(Diesel_generator_sizes_mat(Diesel_Generator_Size)))*Diesel_generator_diesel_use_rate(4,Diesel_Generator_Size)*4;

% MWH * (1/ MW) * (gal/hr @ 25% power) * (4 x 25% power / 100% power)= gal


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
% 
% Diesel_generator_emissions_potential=[
%     3305.2  2818.9  2783    3132.5;
%     258     351.8   536.7   550.6;
%     59.5    55.9    40.8    23.1;
%     14.6    19.7    28.1    24.6]; % (g/hp-h)

%% Power Output
Diesel_Power_Output=Diesel_generator_sizes_mat(Diesel_Generator_Size)*Number_of_Diesel_Generators; % MW

% Pre Size matrixes to speed up the for loop
Diesel_Stored_Energy=zeros(35038+1,1,Stochastic_Iterations);
Diesel_Stored_Energy(1,1,:)=Diesel_initial_Charge_Percent*Diesel_Energy_Capacity; %DICP from Assumptions 

Diesel_Stored_Net_Charge_Discharge=zeros(35038,1,Stochastic_Iterations);
Diesel_Energy_Impact_On_Grid=zeros(35038,1,Stochastic_Iterations);

Needs_refill_flag=zeros(35038,1,Stochastic_Iterations);
Diesel_Refill_log=zeros(35038,1,Stochastic_Iterations);


%%%%%%%% Diesel Strategy %%%%%%%%%%%%%%%%%%%%%%
% Determine What Strategy is being used 

% Fail Criterian
Diesel_Failure_or_Cyclic_Loading_mat=[1,1];

% Floor Criterion
Diesel_Energy_Floor_Mat=[0, 0];

% Create  Critical Load 
% Critical_load=8;  % MW
Critical_load_mat=[Diesel_Power_Output, Critical_load];

% MWer

% Method 1a (1), When Fail +
%                   complete discharge 

% Method 1b (2), When Fail + 
%                   discharge only to Critical Load 


% Create Matrix Describing how much energy the battery can discharge
% This is different than the Lithium Ion Battery becuse Energy Generation
% Deficit will come in as a [35038,1,Iteration] array instead of a matrix.
% Therefore, the array is used when reseting the Dischargeable Energy


if Diesel_Strategy==2
    Dischargeable_Energy_Generation_Deficit_JAN_to_DEC=Energy_Generation_Deficit_JAN_to_DEC_Post_Battery_Critical;
else
    Dischargeable_Energy_Generation_Deficit_JAN_to_DEC=Energy_Generation_Deficit_JAN_to_DEC_Post_Battery;
end

% Limit how much the battery can discharge by the output of the battery
Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(Dischargeable_Energy_Generation_Deficit_JAN_to_DEC>(Diesel_Power_Output/4))=Diesel_Power_Output/4;
temp_Dischargeable_Energy_Generation_Deficit_JAN_to_DEC=Dischargeable_Energy_Generation_Deficit_JAN_to_DEC;


% Determine when the generators are used depending on the Failure vs daily
% cycle criteria. This sets a base value of always yes or always no. The
% always no scenario will be combined with the simulated grid failure to
% determine when it can discharge
Generator_can_discharge_base(1:35038,1)=1-Diesel_Failure_or_Cyclic_Loading_mat(Diesel_Strategy);

for Iter=1:Stochastic_Iterations

% Reset Dischargeable Energy Generation 
Dischargeable_Energy_Generation_Deficit_JAN_to_DEC=temp_Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(:,1,Iter);

% Combine the base value with the grid failure flag to determine when the
% generator can supply energy
    Generator_can_discharge=Generator_can_discharge_base+Grid_failure_flag_mat(:,1,Iter)*Diesel_Failure_or_Cyclic_Loading_mat(Diesel_Strategy);
    Dischargeable_Energy_Generation_Deficit_JAN_to_DEC=Dischargeable_Energy_Generation_Deficit_JAN_to_DEC.*Generator_can_discharge;
%%
% Limit how much energy the battery can discharge during grid failure
% by the critical load criterion minus the discharge of the battery. 
% (Discharge is saved as negative values in
% Li_Ion_Battery_Power_Discharging)
% Critical_load_mat_Iter=(Critical_load_mat(Diesel_Strategy)+Li_Ion_Battery_Power_Discharging(:,1,Iter));
% 
% Dischargeable_Energy_Generation_Deficit_JAN_to_DEC( ...
%     Dischargeable_Energy_Generation_Deficit_JAN_to_DEC.*(Grid_failure_flag_mat(:,1,Iter)==1)> ...
%     Critical_load_mat_Iter)=...
%     Critical_load_mat_Iter(Dischargeable_Energy_Generation_Deficit_JAN_to_DEC.*(Grid_failure_flag_mat(:,1,Iter)==1)> ...
%     Critical_load_mat_Iter);



    for time_block=1:35038
        % Find how much energy can be stored in the battery at each time
        % block
        temp_Stored_Energy=Diesel_Stored_Energy(time_block,1,Iter)-...
            Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(time_block,1);
        % MWh
        
        % Create an ability to refill the diesel tank at a set delay when
        % diesel levels fall below 100% full 
            % Flag when the the tank has dropped below fill levels
            Needs_refill_flag(time_block,1,Iter)=temp_Stored_Energy<Diesel_Tank_Refill_Trigger_Percentage*Diesel_Energy_Capacity;
        
            % Only run this funcition if enough time has passed for an
            % order to be made and fulfilled
            if time_block>Diesel_Storage_Delay_Time+2
                % Set the diesel refill to the capacity if there was a call
                % for refill in the time step before the gap
                % [ call, gap , refill] 
                Diesel_Refill=Needs_refill_flag(time_block-(Diesel_Storage_Delay_Time+1),1,Iter)*(Diesel_Energy_Capacity-temp_Stored_Energy);
                    
                % if Diesel has been refilled at this timestep, remove all
                % calls for refills between the first call and now 
                if Diesel_Refill>0
                    Needs_refill_flag(time_block-Diesel_Storage_Delay_Time:Diesel_Storage_Delay_Time)=0;
                end 
                % Log the energy refilled into the tank
                Diesel_Refill_log(time_block,1,Iter)=Diesel_Refill;
                % MW

                % Refill the storage tank 
                temp_Stored_Energy=temp_Stored_Energy+Diesel_Refill; 
                Diesel_Refill=0; % Reset the diesel refill to zero 
            end 

        % Limit the energy able to be discharged to floor or 0 depending on
        % the strategy
        % When the grid fails the floor must be removed
        temp_Stored_Energy(temp_Stored_Energy<(Diesel_Energy_Floor_Mat(Diesel_Strategy)*(1-Grid_failure_flag_mat(time_block,1,Iter))))=Diesel_Energy_Floor_Mat(Diesel_Strategy)*(1-Grid_failure_flag_mat(time_block,1,Iter));
        % Mwh
        
        % Store the result
        Diesel_Stored_Energy(time_block+1,1,Iter)=temp_Stored_Energy; % MWh
    end 


% Find when the Diesel tank was refueled
Diesel_Refill_flag=Diesel_Refill_log>0;

% Find the Energy discharged to the grid 
% Charge is positive, Discharge is negative
    % Subtract the refill flag times the dischargeable energy on days of refueling
    % to account for energy supplied directly from refuel delivery that may be
    % anaccounted for simply looking at the change in stored energy
Diesel_Stored_Net_Charge_Discharge(:,1,Iter)=Diesel_Stored_Energy(2:end,1,Iter)-Diesel_Stored_Energy(1:end-1,1,Iter)-Diesel_Refill_flag(:,1,Iter).*Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(:,1);
Diesel_Stored_Net_Charge_Discharge(Diesel_Stored_Net_Charge_Discharge>0)=0;
Diesel_Energy_Impact_On_Grid(:,1,Iter)=Diesel_Stored_Net_Charge_Discharge(:,1,Iter);
% MWh 


end 


Diesel_Generator_Power=Diesel_Energy_Impact_On_Grid*4;
% MW
% Where (+ is charging) 


%% Test Plots 

% figure
% hold on
% plot(Diesel_Energy_Impact_On_Grid(1:4*24*10,1,1))
% plot(Diesel_Stored_Energy(1:4*24*10,1,1))
% 
% 
% save("Diesel_Data.mat")
end






