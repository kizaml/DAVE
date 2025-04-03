
function [Hydro_Stored_Energy,Pumped_Hydro_Power,Hydro_Energy_Stored_Net_Charge_Discharge,Hydro_Renewable_Charged_Power,Hydro_Grid_Charged_Power,Hydro_CAPEX,temp_Battery_Stored_Energy_mat]=Hydro_power(Strategy,...
    Hydro_Selector,Grid_failure_flag_mat,...
    Critical_load,Stochastic_Iterations,Energy_Generation_Surplus_JAN_to_DEC,Energy_Generation_Deficit_JAN_to_DEC,Energy_Generation_Deficit_JAN_to_DEC_Critical,...
    Hydro_initial_Charge_Percent,Hydro_Charge_Efficiency,Hydro_Discharge_Efficiency,Hydro_Self_Discharge_rate,Hydro_floor_percentage,Grid_Transmission_Limit,...
    Grid_Carbon_TOD,Carbon_Limiter,Cost_Limiter,Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC,Grid_Carbon_Selector,Grid_Cost_Selector,...
    Peak_MWatts_15min_JAN_to_DEC_final,Percentile_Delimeter_Carbon,Percentile_Delimeter_Cost);

% clc
% clear
% close all 

% West Energy Resilience
% XE485 24-1 & 24-2
% Contact -> 215-528-7614 (David Sang)


% Towers will have a capacity of 1.4 or 1.6 MWh. Both would havea 1890 m^3
% capacity. 

% Hydro options (Data from Dr. Johnson)
%       Upper       Lower       Cost        Capacity    Power
% 1     None        None        None        None        None
% 2     Tower 1     Hudson      $2.27 Mil   1.4 MWh     0.09 MW
% 3     Tower 2     Hudson      $2.33 Mil   1.6 MWh     .11 MW
% 4     Wilkins     Long Pond   $7.08 Mil   33 MWh     2.36 MW


Hydro_Options=[
    0       0       0
    2.27    1.4     0.09
    2.33    1.6     .11
    7.08    33     2.36];

Hydro_Energy_Capacity=Hydro_Options(Hydro_Selector,2);          % MWh
Hydro_Power_Output=Hydro_Options(Hydro_Selector,3);     % MW

Hydro_CAPEX=Hydro_Options(Hydro_Selector,1)*10^6;       % $





%%

%%%%%%%%%%%%%%%% DEBUG INPUTS &&&%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%
%
% Everything you need to uncomment to have the function run alone
% The original values are still within the code. This is repeated for
% simplicity
%

% load("System_Methodology_Images.mat")
% Strategy=3;
% Battery_Energy_Capacity=1600;     % MWh  19.3
% Battery_Power_Output=25;        % MW
% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Create a Baseline Battery using numbers from Tesla Megapack
% https://www.tesla.com/megapack/design
%Battery_Energy_Capacity=1600;     % MWh  19.3
%Battery_Power_Input=9.6;         % MW 9.6
%Battery_Power_Output=25;        % MW

% Make some assumptions on how the battery works 
% These reference MIT's future of energy storage text
%Battery_initial_Charge_Percent=0.5; % %charge
%Battery_Charge_Efficiency=0.92; 
%Battery_Discharge_Efficiency=0.92;
%Battery_Self_Discharge_rate=0.015/30/24/4; % Percent per 15 min time
% (IN ASSUMPTIONS MAT)

Battery_Storage_Delay_Time=1;    % # of 15 min time steps

% Pre Size a matrix to speed up the for loop
%Stochastic_Iterations=100;
Hydro_Stored_Energy=zeros(35038+1,1,Stochastic_Iterations);
Hydro_Stored_Energy(1,1,:)=Hydro_initial_Charge_Percent*Hydro_Energy_Capacity;

Hydro_Energy_Stored_Net_Charge_Discharge=zeros(35038,1,Stochastic_Iterations);
Batttery_Energy_Impact_On_Grid=zeros(35038,1,Stochastic_Iterations);

Renewable_Charged_Energy=zeros(35038,1,Stochastic_Iterations);
Grid_Charged_Energy=zeros(35038,1,Stochastic_Iterations);


%%%%%%%% Battery Strategy %%%%%%%%%%%%%%%%%%%%%%
% Determine What Strategy is being used 
%Strategy=3;

% Fail Criterian
Battery_Failure_or_Cyclic_Loading_mat=[1,1,0,0,0,0];

% Floor Criterion

Battery_Energy_Floor=Hydro_floor_percentage*Hydro_Energy_Capacity; % MWh
Battery_Energy_Floor_Mat=[0, 0, Battery_Energy_Floor, Battery_Energy_Floor, 0, 0];

% Create  Critical Load 
% Critical_load=8;  % MW
Critical_load_mat=[Hydro_Power_Output, Critical_load, Hydro_Power_Output, Critical_load, Hydro_Power_Output, Critical_load];

% MWer

% Method 1a (1), When Fail +
%                   complete discharge 

% Method 1b (2), When Fail + 
%                   discharge only to Critical Load 

% Method 2a (3), Daily Cyclic Loading+
%                   with floor + 
%                   complete discharge on failure

% Method 2b (4), Daily Cyclic Loading + 
%                   with floor + 
%                   discharge only to Critical Load on failure

% Method 2a (5), Daily Cyclic Loading + 
%                   no floor + 
%                   complete discharge on failure

% Method 2b (6), Daily Cyclic Loading +
%                   no floor +
%                   discharge only to Critical Load on failure + 


% Create  Matrix Describing how much Energy can be charged
Chargeable_Energy_Generation_Surplus_JAN_to_DEC=Energy_Generation_Surplus_JAN_to_DEC;

% % Determine when the battery can charge on the grid 
%     % Look at the last 10 days and determine if the current Carbon and Cost are below the average
%     % moving average to determine when you can charge 
% 
%     temp_Days_to_consider=10;
%     % Determine how large the window should be
% 
%     Percentile_Delimeter_Carbon=zeros(length(Grid_Carbon_TOD(:,:,1)),1);
%     % Presize the matrix
% 
%     for i=temp_Days_to_consider*24*4+1:length(Grid_Carbon_TOD)
%         Percentile_Delimeter_Carbon(i)=prctile(Grid_Carbon_TOD(i-temp_Days_to_consider*24*4:i,2,Grid_Carbon_Selector),Carbon_Limiter(1));
%     end
%     % use a for loop to calculate the threshold value according to a
%     % percentile. If the cost is below this threshold value you can charge
% 
%     % Repeat for cost
%     Percentile_Delimeter_Cost=zeros(length(Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC),1);
%     for i=temp_Days_to_consider*24*4+1:length(Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC)
%         Percentile_Delimeter_Cost(i)=prctile(Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC(i-temp_Days_to_consider*24*4:i),Cost_Limiter(1));
%     end




% Create Matrix Describing how much energy the battery can discharge
if or(or(Strategy==2,Strategy==4),Strategy==6)
    Dischargeable_Energy_Generation_Deficit_JAN_to_DEC=Energy_Generation_Deficit_JAN_to_DEC_Critical;
else
    Dischargeable_Energy_Generation_Deficit_JAN_to_DEC=Energy_Generation_Deficit_JAN_to_DEC;
end
% Limit how much the battery can discharge by the output of the battery
Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(Dischargeable_Energy_Generation_Deficit_JAN_to_DEC>Hydro_Power_Output/4)=Hydro_Power_Output/4;
temp_Dischargeable_Energy_Generation_Deficit_JAN_to_DEC=Dischargeable_Energy_Generation_Deficit_JAN_to_DEC;


% Determine when the grid can discharge depending on the Failure vs daily
% cycle criteria. This sets a base value of always yes or always no. The
% always no scenario will be combined with the simulated grid failure to
% determine when it can discharge
Battery_can_discharge_base(1:35038,1)=1-Battery_Failure_or_Cyclic_Loading_mat(Strategy);

Temp_Charged_Energy=zeros(1,1);
Temp_Grid_Charged_Energy=zeros(1,1);


% Carbon Considerations
Carbon_Grid_Charging_Flag=Grid_Carbon_TOD(:,2,Grid_Carbon_Selector)<=Percentile_Delimeter_Carbon;
% Cost Considerations 
Cost_Grid_Charging_Flag=Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC(:,Grid_Cost_Selector)<=Percentile_Delimeter_Cost;


for Iter=1:Stochastic_Iterations




Chargeable_Grid_Energy=(1-Grid_failure_flag_mat(:,1,Iter)).*Carbon_Grid_Charging_Flag.*Cost_Grid_Charging_Flag.*(Grid_Transmission_Limit/4-Peak_MWatts_15min_JAN_to_DEC_final/4-Energy_Generation_Surplus_JAN_to_DEC);

Chargeable_Energy_Combined=Chargeable_Energy_Generation_Surplus_JAN_to_DEC+Chargeable_Grid_Energy;

% Limit the Amount able to be charged by the input 
Chargeable_Energy_Combined(Chargeable_Energy_Combined>Hydro_Power_Output/4)=Hydro_Power_Output/4;



% Reset Dischargeable Energy Generation 
Dischargeable_Energy_Generation_Deficit_JAN_to_DEC=temp_Dischargeable_Energy_Generation_Deficit_JAN_to_DEC;

% Combine the base value with the grid failure flag to determine when the
% battery can discharge
    Battery_can_discharge=Battery_can_discharge_base+Grid_failure_flag_mat(:,1,Iter)*Battery_Failure_or_Cyclic_Loading_mat(Strategy);
    Dischargeable_Energy_Generation_Deficit_JAN_to_DEC=Dischargeable_Energy_Generation_Deficit_JAN_to_DEC.*Battery_can_discharge;

% Limit how much energy the battery can discharge during grid failure
% by the critical load criterion 
% Dischargeable_Energy_Generation_Deficit_JAN_to_DEC( ...
%     Dischargeable_Energy_Generation_Deficit_JAN_to_DEC.*(Grid_failure_flag_mat(:,1,Iter)==1)> ...
%     Critical_load_mat(Strategy)/(4*Battery_Discharge_Efficiency))   =Critical_load_mat(Strategy)/4;


temp_Battery_Stored_Energy_mat=zeros([35038,1,Stochastic_Iterations]);

    for time_block=1:35038
        
        % Find how much energy can be stored in the battery at each time
        % block
        temp_Battery_Stored_Energy=Hydro_Stored_Energy(time_block,1,Iter)*(1-Hydro_Self_Discharge_rate)+...
            Chargeable_Energy_Combined(time_block,1,Iter)*Hydro_Charge_Efficiency-...
            Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(time_block,1)/Hydro_Discharge_Efficiency;
        % MWh
        
        % Limit the energy able to be stored to the max battery capacity
        temp_Battery_Stored_Energy(temp_Battery_Stored_Energy>Hydro_Energy_Capacity)=Hydro_Energy_Capacity;
        % MWh
  

        % Limit the energy able to be discharged to floor or 0 depending on
        % the strategy
        % When the grid fails the floor must be removed
        
        if Hydro_Stored_Energy(time_block,1,Iter)>(Battery_Energy_Floor_Mat(Strategy)*(1-Grid_failure_flag_mat(time_block,1,Iter)))
            temp_Battery_Stored_Energy(temp_Battery_Stored_Energy<(Battery_Energy_Floor_Mat(Strategy)*(1-Grid_failure_flag_mat(time_block,1,Iter))))=Battery_Energy_Floor_Mat(Strategy)*(1-Grid_failure_flag_mat(time_block,1,Iter));
        else 
            temp_Battery_Stored_Energy(temp_Battery_Stored_Energy<(Battery_Energy_Floor_Mat(Strategy)*(1-Grid_failure_flag_mat(time_block,1,Iter))))=max([0,temp_Battery_Stored_Energy]);
        end
        
        % Mwh



        % if Hydro_Stored_Energy>=Battery_Energy_Floor_Mat(Strategy)

        %     temp_Battery_Stored_Energy=max([Hydro_Energy_floor,temp_Battery_Stored_Energy]);
        % elseif Hydro_Stored_Energy<Battery_Energy_Floor_Mat(Strategy)
        %     Hydro_Energy_floor=0;
        %     if temp_Battery_Stored_Energy<0;
        %         temp_Battery_Stored_Energy=0;
        %     end
        % end
       
        % if Hydro_Stored_Energy(time_block,1,Iter)>temp_Battery_Stored_Energy
        %     temp_Battery_Stored_Energy(temp_Battery_Stored_Energy<Hydro_Energy_floor)=Hydro_Energy_floor;
        % elseif  temp_Battery_Stored_Energy>=Hydro_Stored_Energy(time_block,1,Iter)
        %     temp_Battery_Stored_Energy=temp_Battery_Stored_Energy;
        %     % Mwh
        % end
        


        % If the battery charged, determine where it charged from and store
        % the value
        Temp_Charged_Energy(temp_Battery_Stored_Energy>Hydro_Stored_Energy(time_block,1,Iter))=temp_Battery_Stored_Energy-Hydro_Stored_Energy(time_block,1,Iter);
        Temp_Charged_Energy(temp_Battery_Stored_Energy<=Hydro_Stored_Energy(time_block,1,Iter))=0;

        Temp_Renewable_Charged_Energy=min([Temp_Charged_Energy,min([abs(Chargeable_Energy_Generation_Surplus_JAN_to_DEC(time_block,1,Iter)),Hydro_Power_Output/4])]);

        Temp_Grid_Charged_Energy(Temp_Renewable_Charged_Energy<Temp_Charged_Energy)=Temp_Charged_Energy-Temp_Renewable_Charged_Energy;
        Temp_Grid_Charged_Energy(Temp_Renewable_Charged_Energy==Temp_Charged_Energy)=0;

        Renewable_Charged_Energy(time_block,1,Iter)=Temp_Renewable_Charged_Energy;
        Grid_Charged_Energy(time_block,1,Iter)=Temp_Grid_Charged_Energy;

        % Store the result
        Hydro_Stored_Energy(time_block+1,1,Iter)=temp_Battery_Stored_Energy; % MWh
        temp_Battery_Stored_Energy_mat(time_block+1,1,Iter)=temp_Battery_Stored_Energy;
    end 
    
% Find the change in Battery stored to determine the true charge/discharge
% rates
% Charge is positive, Discharge is negative
Hydro_Energy_Stored_Net_Charge_Discharge(:,1,Iter)=Hydro_Stored_Energy(2:end,1,Iter)-Hydro_Stored_Energy(1:end-1,1,Iter);
Batttery_Energy_Impact_On_Grid(:,1,Iter)=Hydro_Energy_Stored_Net_Charge_Discharge(:,1,Iter)*(1+Hydro_Self_Discharge_rate);
% MWh 



end 
% Correct the battery numbers to the impact on the grid using the
% Efficiencies
Batttery_Energy_Impact_On_Grid(Batttery_Energy_Impact_On_Grid>0)=Batttery_Energy_Impact_On_Grid(Batttery_Energy_Impact_On_Grid>0)/Hydro_Charge_Efficiency;
Batttery_Energy_Impact_On_Grid(Batttery_Energy_Impact_On_Grid<0)=Batttery_Energy_Impact_On_Grid(Batttery_Energy_Impact_On_Grid<0)*Hydro_Discharge_Efficiency;
% MWh

Renewable_Charged_Energy_Impact_on_Grid=Renewable_Charged_Energy/Hydro_Charge_Efficiency;
Grid_Charged_Energy_Impact_on_Grid=Grid_Charged_Energy/Hydro_Charge_Efficiency;
% MWh

Hydro_Renewable_Charged_Power=Renewable_Charged_Energy_Impact_on_Grid*4;
Hydro_Grid_Charged_Power=Grid_Charged_Energy_Impact_on_Grid*4;
% MW



Pumped_Hydro_Power=Batttery_Energy_Impact_On_Grid*4;
% MW
% Where (+ is charging) 

end