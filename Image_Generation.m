

clc
close all 
clear 
%%
% West Energy Resilience
% XE485 24-1 & 24-2
% Contact -> 215-528-7614 (David Sang)

% This file is used to generate images from the trials run for the model
% NOT ALL OF THE CODE WILL RUN ORGANICALLY
% This file was used to generate pareto curves 

% Yeah this one isn't that pretty. It's more an archive/graveyard for all
% the images that were created. Value Modeling script contains the images
% that describe value modeling.


% Load the data saved from the last trial 
load("WP_energy_model_data_Trial_APR2_1.mat")
load("Model_Assumptions.mat")

% Save the trial data with the date, pop, gen, stochastic trials 
% save("Data_for_Image_Generation\WP_energy_model_data_Trial_2.mat")
%%

load("System_Methodology_Images.mat")
%%
load('Data_for_Cost_Function_One_Year\TOD_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC.mat','TOD_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC')
load('Data_for_Cost_Function_One_Year\Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC.mat','Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC')
% %% Solar SAM vs Calc Comparison
% figure
% hold on 
% %plot(Solar_Power_Generated_15min_JAN_to_DEC_Calc(1:1000))
% plot(Solar_Power_Generated_15min_JAN_to_DEC(1:1000)/10^3)
% title("Solar SAM vs Calc (75000 m^2)")
%     % Parameters matrix has the parameters for this data
% ylabel("Power [MW]")
% xlabel("Time Steps")
% legend("Calculated", "SAM")
% 
% 
% %% Wind SAM vs Calc Comparison
% time_start=1;
% time_end=1000;
% figure
% hold on 
% plot(Wind_Power_Generated_15min_JAN_to_DEC_Calc(time_start:time_end))
% plot(Wind_Power_Generated_15min_JAN_to_DEC(time_start:time_end))
% title("Wind SAM vs Calc (3 Turbines)")
%     % Parameters matrix has the parameters for this data
% ylabel("Power [MW]")
% xlabel("Time Steps")
% legend("Calculated", "SAM")

%% Costs

figure
hold on
plot(Grid_Cost(1:1000))
plot(Solar_Cost(1:1000))
plot(Wind_Cost(1:1000))

%% TOD Calculation Plots


%------------------- [PARAMETER]--------------------------------
%Pick a day/week/whatever to look at
Month=1;
Day=1;
Year=2022; % Our demand data is from FY 2022 (OCT21-OCT22) so year is ~2022
Plot_length=10; % number of days
%------------------- [PARAMETER END]-----------------------------

%NSRDB Data Indexes
Number_of_days_Between=daysact(datetime(2021,12,31),datetime(2022,Month,Day));
start_index=Number_of_days_Between*24*4;
stop_index=(Number_of_days_Between+Plot_length)*24*4+1;

%Date matrix adjusts data to any time perioid in given data
date_matrix=[datetime(Year,1,1):minutes(15): datetime(Year+1,1,1)-minutes(15)]';


figure
hold on
yyaxis left
plot(date_matrix(start_index:stop_index,1),Grid_Carbon_TOD(start_index:stop_index,2,2))
plot(date_matrix(start_index:stop_index,1),Grid_Carbon_TOD(start_index:stop_index,2,1))
yyaxis right
plot(date_matrix(start_index:stop_index,1),Peak_MWatts_15min_JAN_to_DEC(start_index:stop_index,1))
xlim([date_matrix(start_index,1),date_matrix(stop_index,1)])



figure
hold on
yyaxis left
plot(date_matrix(start_index:stop_index,1),TOD_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC(start_index:stop_index))
%plot(date_matrix(start_index:stop_index,1),Grid_Carbon_TOD(start_index:stop_index,2,1))
yyaxis right
plot(date_matrix(start_index:stop_index,1),Peak_MWatts_15min_JAN_to_DEC(start_index:stop_index,1))
%plot(date_matrix(start_index:stop_index,1),Peak_MWatts_15min_JAN_to_DEC(start_index:stop_index,1)+Lheat(start_index:stop_index,1)/1000)
xlim([date_matrix(start_index,1),date_matrix(stop_index,1)])



%% Generation Complete 
close all

% Load the data saved from the last trial 
load("WP_energy_model_data_Trial_100S_5G_100T.mat")
load("Model_Assumptions.mat")
load("System_Methodology_Images_100S_5G_100T.mat")

%------------------- [PARAMETER]--------------------------------
%Pick a day/week/whatever to look at
Month=1;
Day=1;
Year=2022; % Our demand data is from FY 2022 (OCT21-OCT22) so year is ~2022
Plot_length=363; % number of days
%------------------- [PARAMETER END]-----------------------------

%NSRDB Data Indexes
Number_of_days_Between=daysact(datetime(2021,12,31),datetime(2022,Month,Day));
start_index=Number_of_days_Between*24*4;
stop_index=(Number_of_days_Between+Plot_length)*24*4+1;

%Date matrix adjusts data to any time perioid in given data
date_matrix=[datetime(Year,1,1):minutes(15): datetime(Year+1,1,1)-minutes(15)]';


%Plot Power use over time
% figure
% hold on
% plot(date_matrix(start_index:stop_index,1),Peak_MWatts_15min_JAN_to_DEC(start_index:stop_index,1))


% start_index=130*  24*4;
% stop_index=140* 24*4;
Iter=1;

% Fill arguments 
x=date_matrix(start_index:stop_index,1)';
x2=[x, fliplr(x)];




fig=figure('Position',[0,0,1000,500]);
hold on 

plot(date_matrix(start_index:stop_index,1),Peak_MWatts_15min_JAN_to_DEC_final(start_index:stop_index,1,1),"Black",LineWidth=3)
% Grid Power
    inbetween=[zeros(1,stop_index-start_index+1),fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)')];
    fill(x2,inbetween,[0 0.4470 0.7410]+.2)
% Wind Power
    % inbetween=[Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)',fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)')];
    % fill(x2,inbetween,[0.8500 0.3250 0.0980])
% Solar Power
    % inbetween=[Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)',fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)')];
    % fill(x2,inbetween,[0.9290 0.6940 0.1250])
% Battery Charging 
    % inbetween=[Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)',fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Charging(start_index:stop_index,1,Iter)')];
    % fill(x2,inbetween,[0.4940 0.1840 0.5560]+.2)
% Battery Discharging
    % inbetween=[Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Charging(start_index:stop_index,1,Iter)',fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Charging(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Discharging(start_index:stop_index,1,Iter)')];
    % fill(x2,inbetween,[0.4660 0.6740 0.1880]+.2)
% Diesel Discharging
    inbetween=[Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)',fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'-Diesel_Generator_Power(start_index:stop_index,1,Iter)')];
    fill(x2,inbetween,[0.6350 0.0780 0.1840]+.1)
Critical_load_line=repelem(Critical_load,(stop_index-start_index+1));
plot(date_matrix(start_index:stop_index,1),Critical_load_line,"Red",LineWidth=1,LineStyle="--")
%plot(x,Energy_Generation_Gap_JAN_to_DEC_Pre_Storage(start_index:stop_index,1,Iter)'*4)
%plot(x,Energy_Generation_Gap_JAN_to_DEC_Post_Battery(start_index:stop_index,1,Iter)'*4)
%plot(x,Energy_Generation_Deficit_JAN_to_DEC_Post_Battery_Critical(start_index:stop_index,1,Iter)'*4,LineWidth=3)
%plot(date_matrix(start_index:stop_index,1),Grid_failure_flag_mat(start_index:stop_index)*5,LineWidth=5,Color='r')
%plot(x,-Diesel_Generator_Power(start_index:stop_index),LineStyle='--',LineWidth=3,Color='g')
%plot(x,temp_Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(start_index:stop_index),LineStyle="--",LineWidth=3,Color='r')
%plot(x,Diesel_Stored_Energy(start_index:stop_index),LineWidth=5,color='blue')
%plot(date_matrix(start_index:stop_index,1),Li_Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(start_index:stop_index)*5,LineWidth=3,Color='g')
%plot(date_matrix(start_index:stop_index,1),Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(start_index:stop_index)*5,LineWidth=2,Color='b')

title("Power Demand & Supply")
ylabel("Power [MW]")
xlabel("Time Steps")
% legend("Demand","Grid", "Wind","Solar","Lithium Battery Charging","Lithium Battery Discharging","Diesel Generator","Critical Load",'Grid Failure',Location="eastoutside")
legend("Demand","Grid","Diesel Generator","Critical Load",'Grid Failure',Location="eastoutside")
xlim([date_matrix(start_index,1),date_matrix(stop_index,1)]);
ylim([-3,80]);

%% Generation Complete Plot, Generation on Bottom, Charging different colors
close all
clear all

% Load the data saved from the last trial 
load("WP_energy_model_data_Trial_APR2_1.mat")
load("Model_Assumptions.mat")
load("System_Methodology_Images.mat")

%------------------- [PARAMETER]--------------------------------
%Pick a day/week/whatever to look at
Month=1;
Day=1;
Year=2022; % Our demand data is from FY 2022 (OCT21-OCT22) so year is ~2022
Plot_length=360; % number of days
%------------------- [PARAMETER END]-----------------------------

%NSRDB Data Indexes
Number_of_days_Between=daysact(datetime(2021,12,31),datetime(2022,Month,Day));
start_index=Number_of_days_Between*24*4;
stop_index=(Number_of_days_Between+Plot_length)*24*4+1;

%Date matrix adjusts data to any time perioid in given data
date_matrix=[datetime(Year,1,1):minutes(15): datetime(Year+1,1,1)-minutes(15)]';


%Plot Power use over time
% figure
% hold on
% plot(date_matrix(start_index:stop_index,1),Peak_MWatts_15min_JAN_to_DEC(start_index:stop_index,1))


% start_index=130*  24*4;
% stop_index=140* 24*4;
Iter=1;

% Fill arguments 
x=date_matrix(start_index:stop_index,1)';
x2=[x, fliplr(x)];


All_Charging=-Renewable_Charged_Power(start_index:stop_index,1,Iter)'-Grid_Charged_Power(start_index:stop_index,1,Iter)'-Hydro_Renewable_Charged_Power(start_index:stop_index,1,Iter)'-Hydro_Grid_Charged_Power(start_index:stop_index,1,Iter)';

fig=figure('Position',[0,0,1000,500]);
hold on 

plot(date_matrix(start_index:stop_index,1),Peak_MWatts_15min_JAN_to_DEC_final(start_index:stop_index,1,1),"Black",LineWidth=3)
% Solar Power
    inbetween=[zeros(1,stop_index-start_index+1),fliplr(Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)')];
    fill(x2,inbetween,[0.9290 0.6940 0.1250])
% Wind Power
    inbetween=[Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)',...
        fliplr(Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)')];
    fill(x2,inbetween,[0.3660 0.5740 0.0880])

% Curtailment
inbetween=[Peak_MWatts_15min_JAN_to_DEC_final(start_index:stop_index,1,1)',...
      fliplr(max([Peak_MWatts_15min_JAN_to_DEC_final(start_index:stop_index,1,Iter)';Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)']))];
   fill(x2,inbetween,[0 0 0])

% Grid Power
    inbetween=[Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)',...
        fliplr(Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)')];
    fill(x2,inbetween,[0 0.4470 0.7410]+.2)




% Renewable Battery Charging 
    inbetween=[Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging,...
        fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)')];
    fill(x2,inbetween,[0.4540 0.1440 0.5060]+.2)

% Grid Battery Charging 
    inbetween=[Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)',...
        fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Grid_Charged_Power(start_index:stop_index,1,Iter)')];
    fill(x2,inbetween,[0.2 0.1840 0.5560]+.2)    

% Battery Discharging
    inbetween=[Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Grid_Charged_Power(start_index:stop_index,1,Iter)',...
        fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Grid_Charged_Power(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Discharging(start_index:stop_index,1,Iter)')];
    fill(x2,inbetween,[0.4660 0.6740 0.1880]+.2)


% Renewable Hydro Charging 
    inbetween=[Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Grid_Charged_Power(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Discharging(start_index:stop_index,1,Iter)',...
        fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Grid_Charged_Power(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Discharging(start_index:stop_index,1,Iter)'+Hydro_Renewable_Charged_Power(start_index:stop_index,1,Iter)')];
    fill(x2,inbetween,[0.6540 0.0440 0.4060]+.0)

% Grid Hydro Charging 
    inbetween=[Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Grid_Charged_Power(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Discharging(start_index:stop_index,1,Iter)'+Hydro_Renewable_Charged_Power(start_index:stop_index,1,Iter)',...
        fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Grid_Charged_Power(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Discharging(start_index:stop_index,1,Iter)'+Hydro_Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Hydro_Grid_Charged_Power(start_index:stop_index,1,Iter)')];
    fill(x2,inbetween,[1 .6 0])    

% Hydro Discharging
    inbetween=[Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Grid_Charged_Power(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Discharging(start_index:stop_index,1,Iter)'+Hydro_Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Hydro_Grid_Charged_Power(start_index:stop_index,1,Iter)',...
        fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Grid_Charged_Power(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Discharging(start_index:stop_index,1,Iter)'+Hydro_Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Hydro_Grid_Charged_Power(start_index:stop_index,1,Iter)'-Hydro_Power_Discharging(start_index:stop_index,1,Iter)')];
    fill(x2,inbetween,[0.8660 0.3740 0.880]+.1)

% Diesel Discharging
    inbetween=[Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Grid_Charged_Power(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Discharging(start_index:stop_index,1,Iter)'+Hydro_Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Hydro_Grid_Charged_Power(start_index:stop_index,1,Iter)'-Hydro_Power_Discharging(start_index:stop_index,1,Iter)',...
        fliplr(Grid_Power_Supplied_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Wind_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+Solar_Power_Generated_15min_JAN_to_DEC_Active(start_index:stop_index,1,Iter)'+All_Charging+Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Grid_Charged_Power(start_index:stop_index,1,Iter)'-Li_Ion_Battery_Power_Discharging(start_index:stop_index,1,Iter)'+Hydro_Renewable_Charged_Power(start_index:stop_index,1,Iter)'+Hydro_Grid_Charged_Power(start_index:stop_index,1,Iter)'-Hydro_Power_Discharging(start_index:stop_index,1,Iter)'-Diesel_Generator_Power(start_index:stop_index,1,Iter)')];
    fill(x2,inbetween,[0.6350 0.0780 0.1840]+.1)



       
Critical_load_line=repelem(Critical_load,(stop_index-start_index+1));
plot(date_matrix(start_index:stop_index,1),Critical_load_line,"Red",LineWidth=1,LineStyle="--")


%plot(x,Energy_Generation_Gap_JAN_to_DEC_Pre_Storage(start_index:stop_index,1,Iter)'*4)
%plot(x,Energy_Generation_Gap_JAN_to_DEC_Post_Battery(start_index:stop_index,1,Iter)'*4)
%plot(x,Energy_Generation_Deficit_JAN_to_DEC_Post_Battery_Critical(start_index:stop_index,1,Iter)'*4,LineWidth=3)
%plot(date_matrix(start_index:stop_index,1),Grid_failure_flag_mat(start_index:stop_index)*5,LineWidth=5,Color='r')
%plot(x,-Diesel_Generator_Power(start_index:stop_index),LineStyle='--',LineWidth=3,Color='g')
%plot(x,temp_Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(start_index:stop_index),LineStyle="--",LineWidth=3,Color='r')
%plot(x,Diesel_Stored_Energy(start_index:stop_index),LineWidth=5,color='blue')
%plot(date_matrix(start_index:stop_index,1),Li_Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(start_index:stop_index)*5,LineWidth=3,Color='g')
%plot(date_matrix(start_index:stop_index,1),Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(start_index:stop_index)*5,LineWidth=2,Color='b')
%plot(date_matrix(start_index:stop_index,1),Hydro_Power_Discharging(start_index:stop_index),LineWidth=5,Color='b')

%plot(date_matrix(start_index:stop_index,1),Hydro_Renewable_Charged_Power(start_index:stop_index),LineWidth=5,Color='b')


title("Power Demand & Supply")
ylabel("Power [MW]")
xlabel("Time Steps")
legend("Demand","Solar", "Wind",'Curtailment',"Grid","Renewable Lithium Battery Charging","Grid Lithium Battery Charging","Lithium Battery Discharging","Renewable Hydro Charging","Grid Hydro Charging","Hydro Discharging","Diesel Generator","Critical Load",'Grid Failure',Location="eastoutside")
xlim([date_matrix(start_index,1),date_matrix(stop_index,1)]);
ylim([0,30]);


%%
% figure 
% hold on
% plot(Energy_Generation_Deficit_JAN_to_DEC_Post_Battery(time_start:time_end,1,Iter)*4)
% plot(Energy_Generation_Deficit_JAN_to_DEC_Post_Battery_Critical(time_start:time_end,1,Iter)*4)
% plot(temp_Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(time_start:time_end,1,Iter)*4,LineWidth=3)
% plot(Dischargeable_Energy_Generation_Deficit_JAN_to_DEC(time_start:time_end,1,Iter)*4,LineStyle='--',LineWidth=5)
% plot(-Diesel_Generator_Power(time_start:time_end,1,Iter))
%%
figure
hold on
% plot(Energy_Generation_Gap_JAN_to_DEC_Pre_Storage(1:100,1,1))
% plot(Energy_Generation_Gap_JAN_to_DEC_Post_Battery(1:100,1,1))

plot(Diesel_Generator_Power(1:100))
plot(Li_Ion_Battery_Power_Discharging(1:100))
%% Pareto Curve for Nuetral Situation 

Nuetral_idx=ceil(Sensitivity_iter/2);

fig=figure('Position',[0,0,1000,500])
subplot(1,2,1)
p=plot(Sensitivity_Trial(Nuetral_idx).Model_Objectives_Day2Day(:,1),round(Sensitivity_Trial(Nuetral_idx).Model_Objectives_Day2Day(:,5)/4),'o');
title("[D2D] Cost of System vs Critical Load Shed")
xlabel("Cost of the System [$Mil]")
ylabel("Critical Load Failed Terms [Hrs]")
dtt=p.DataTipTemplate;
dtt.DataTipRows(1)=dataTipTextRow("Cost [$M]",Sensitivity_Trial(Nuetral_idx).Model_Objectives_Day2Day(:,1));
dtt.DataTipRows(2)=dataTipTextRow("Critical Load Failure [Hr]",Sensitivity_Trial(Nuetral_idx).Model_Objectives_Day2Day(:,5)/4);

dtt.DataTipRows(3)=dataTipTextRow("Solar Tracking Designator",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,1));
dtt.DataTipRows(4)=dataTipTextRow("Solar Panels",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,2));
dtt.DataTipRows(5)=dataTipTextRow("Wind Turbines",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,3));
dtt.DataTipRows(6)=dataTipTextRow("Battery Strategy",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,4));
dtt.DataTipRows(7)=dataTipTextRow("Li Battery Size [MWh]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,5));
dtt.DataTipRows(8)=dataTipTextRow("Li Battery Power Out [MW]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,6));
dtt.DataTipRows(9)=dataTipTextRow("Diesel Strategy",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,7));
dtt.DataTipRows(10)=dataTipTextRow("Diesel Storage [MWh]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,8));
dtt.DataTipRows(11)=dataTipTextRow("Diesel Generators [#]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,9));
dtt.DataTipRows(12)=dataTipTextRow("Diesel Generator Size [MW]",Diesel_generator_sizes_mat(Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,10)));
dtt.DataTipRows(13)=dataTipTextRow("Hydro Strategy",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,11));
dtt.DataTipRows(14)=dataTipTextRow("Hydro Option [#]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,12));
dtt.DataTipRows(15)=dataTipTextRow("EV Adoption [Bin]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,13));
dtt.DataTipRows(16)=dataTipTextRow("Heat Pump Adoption [Bin]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,14));

xlim([10,max(Sensitivity_Trial(Nuetral_idx).Model_Objectives_Extreme(:,1))+5])
ylim([0,max(round(Sensitivity_Trial(Nuetral_idx).Model_Objectives_Extreme(:,5)/4))+5])
grid minor

%fig=figure('Position',[0,0,600,500])
subplot(1,2,2)
p=plot(Sensitivity_Trial(Nuetral_idx).Model_Objectives_Extreme(:,1),round(Sensitivity_Trial(Nuetral_idx).Model_Objectives_Extreme(:,5)/4),'o');
title("[Threat] Cost of System vs Critical Load Shed")
xlabel("Cost of the System [$Mil]")
ylabel("Critical Load Failed Terms [Hrs]")
dtt=p.DataTipTemplate;
dtt.DataTipRows(1)=dataTipTextRow("Cost [$M]",Sensitivity_Trial(Nuetral_idx).Model_Objectives_Extreme(:,1));
dtt.DataTipRows(2)=dataTipTextRow("Critical Load Failure [Hr]",Sensitivity_Trial(Nuetral_idx).Model_Objectives_Extreme(:,5)/4);

dtt.DataTipRows(3)=dataTipTextRow("Solar Tracking Designator",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,1));
dtt.DataTipRows(4)=dataTipTextRow("Solar Panels",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,2));
dtt.DataTipRows(5)=dataTipTextRow("Wind Turbines",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,3));
dtt.DataTipRows(6)=dataTipTextRow("Battery Strategy",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,4));
dtt.DataTipRows(7)=dataTipTextRow("Li Battery Size [MWh]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,5));
dtt.DataTipRows(8)=dataTipTextRow("Li Battery Power In [MW]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,6));
dtt.DataTipRows(9)=dataTipTextRow("Diesel Strategy",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,7));
dtt.DataTipRows(10)=dataTipTextRow("Diesel Storage [MWh]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,8));
dtt.DataTipRows(11)=dataTipTextRow("Diesel Generators [#]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,9));
dtt.DataTipRows(12)=dataTipTextRow("Diesel Generator Size [MW]",Diesel_generator_sizes_mat(Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,10)));
dtt.DataTipRows(13)=dataTipTextRow("Hydro Strategy",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,11));
dtt.DataTipRows(14)=dataTipTextRow("Hydro Option [#]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,12));
dtt.DataTipRows(15)=dataTipTextRow("EV Adoption [Bin]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,13));
dtt.DataTipRows(16)=dataTipTextRow("Heat Pump Adoption [Bin]",Sensitivity_Trial(Nuetral_idx).Solution_Parameters(:,14));

xlim([10,max(Sensitivity_Trial(Nuetral_idx).Model_Objectives_Extreme(:,1))+5])
ylim([0,max(round(Sensitivity_Trial(Nuetral_idx).Model_Objectives_Extreme(:,5)/4))+5])
grid minor

%% Pareto Curve for All Situations


fig=figure('Position',[0,0,1000,500]);
subplot(1,2,1)
hold on
for idx=1:length(Sensitivity_analysis_multiplyer)
    eval("p"+idx+"=plot(Sensitivity_Trial(idx).Model_Objectives_Day2Day(:,1),round(Sensitivity_Trial(idx).Model_Objectives_Day2Day(:,5)/4),'o');")

    eval("dtt=p"+idx+".DataTipTemplate;")
    dtt.DataTipRows(1)=dataTipTextRow("Cost [$M]",Sensitivity_Trial(idx).Model_Objectives_Day2Day(:,1));
    dtt.DataTipRows(2)=dataTipTextRow("Critical Load Failure [Hr]",Sensitivity_Trial(idx).Model_Objectives_Day2Day(:,5)/4);
    
    dtt.DataTipRows(3)=dataTipTextRow("Solar Tracking Designator",Sensitivity_Trial(idx).Solution_Parameters(:,1));
    dtt.DataTipRows(4)=dataTipTextRow("Solar Panels",Sensitivity_Trial(idx).Solution_Parameters(:,2));
    dtt.DataTipRows(5)=dataTipTextRow("Wind Turbines",Sensitivity_Trial(idx).Solution_Parameters(:,3));
    dtt.DataTipRows(6)=dataTipTextRow("Battery Strategy",Sensitivity_Trial(idx).Solution_Parameters(:,4));
    dtt.DataTipRows(7)=dataTipTextRow("Li Battery Size [MWh]",Sensitivity_Trial(idx).Solution_Parameters(:,5));
    dtt.DataTipRows(8)=dataTipTextRow("Li Battery Power In [MW]",Sensitivity_Trial(idx).Solution_Parameters(:,6));
    dtt.DataTipRows(9)=dataTipTextRow("Li Battery Power Out [MW]",Sensitivity_Trial(idx).Solution_Parameters(:,7));
    dtt.DataTipRows(10)=dataTipTextRow("Diesel Strategy",Sensitivity_Trial(idx).Solution_Parameters(:,8));
    dtt.DataTipRows(11)=dataTipTextRow("Diesel Storage [MWh]",Sensitivity_Trial(idx).Solution_Parameters(:,9));
    dtt.DataTipRows(12)=dataTipTextRow("Diesel Power [MW]",Sensitivity_Trial(idx).Solution_Parameters(:,10).*Sensitivity_Trial(idx).Solution_Parameters(:,11));
end
title("[D2D] Cost of System vs Critical Load Shed")
xlabel("Cost of the System [$Mil]")
ylabel("Critical Load Failed Terms [Hrs]")
legend("Trial 1","Trial 2","Trial 3")

subplot(1,2,2)
hold on
for idx=1:length(Sensitivity_analysis_multiplyer)
    eval("p"+idx+"=plot(Sensitivity_Trial(idx).Model_Objectives_Extreme(:,1),round(Sensitivity_Trial(idx).Model_Objectives_Extreme(:,5)/4),'o');")

    eval("dtt=p"+idx+".DataTipTemplate;")
    dtt.DataTipRows(1)=dataTipTextRow("Cost [$M]",Sensitivity_Trial(idx).Model_Objectives_Extreme(:,1));
    dtt.DataTipRows(2)=dataTipTextRow("Critical Load Failure [Hr]",Sensitivity_Trial(idx).Model_Objectives_Extreme(:,5)/4);
    
    dtt.DataTipRows(3)=dataTipTextRow("Solar Tracking Designator",Sensitivity_Trial(idx).Solution_Parameters(:,1));
    dtt.DataTipRows(4)=dataTipTextRow("Solar Panels",Sensitivity_Trial(idx).Solution_Parameters(:,2));
    dtt.DataTipRows(5)=dataTipTextRow("Wind Turbines",Sensitivity_Trial(idx).Solution_Parameters(:,3));
    dtt.DataTipRows(6)=dataTipTextRow("Battery Strategy",Sensitivity_Trial(idx).Solution_Parameters(:,4));
    dtt.DataTipRows(7)=dataTipTextRow("Li Battery Size [MWh]",Sensitivity_Trial(idx).Solution_Parameters(:,5));
    dtt.DataTipRows(8)=dataTipTextRow("Li Battery Power In [MW]",Sensitivity_Trial(idx).Solution_Parameters(:,6));
    dtt.DataTipRows(9)=dataTipTextRow("Li Battery Power Out [MW]",Sensitivity_Trial(idx).Solution_Parameters(:,7));
    dtt.DataTipRows(10)=dataTipTextRow("Diesel Strategy",Sensitivity_Trial(idx).Solution_Parameters(:,8));
    dtt.DataTipRows(11)=dataTipTextRow("Diesel Storage [MWh]",Sensitivity_Trial(idx).Solution_Parameters(:,9));
    dtt.DataTipRows(12)=dataTipTextRow("Diesel Power [MW]",Sensitivity_Trial(idx).Solution_Parameters(:,10).*Sensitivity_Trial(idx).Solution_Parameters(:,11));
end
title("[Extreme] Cost of System vs Critical Load Shed")
xlabel("Cost of the System [$Mil]")
ylabel("Critical Load Failed Terms [Hrs]")
legend("Trial 1","Trial 2","Trial 3")



%% Sensitivity Analysis Plot

figure(4)
hold on
plot(Sensitivity_Trial(1).Model_Objectives_Day2Day(:,1),round(Sensitivity_Trial(1).Model_Objectives_Day2Day(:,5)/4),'o')
%plot(Sensitivity_Trial(2).Model_Objectives_Day2Day(:,1),Sensitivity_Trial(2).Model_Objectives_Day2Day(:,5),'o')
%plot(Sensitivity_Trial(3).Model_Objectives_Day2Day(:,1),round(Sensitivity_Trial(3).Model_Objectives_Day2Day(:,5)/4),'o')
%plot(Sensitivity_Trial(4).Model_Objectives_Day2Day(:,1),Sensitivity_Trial(4).Model_Objectives_Day2Day(:,5),'o')
%plot(Sensitivity_Trial(5).Model_Objectives_Day2Day(:,1),round(Sensitivity_Trial(5).Model_Objectives_Day2Day(:,5)/4),'o')
hold off
legend("Optimistic", "Nuetral","Pesimistic")
title("Cost Of System vs Critical Load Shed Sensitivity Analysis")
xlabel("Cost of the System [$Mil]")
ylabel("Critical Load Failed Terms [Hrs]")
%%
figure(5)
hold on
plot(Sensitivity_Trial(1).Model_Objectives_Day2Day(:,1),round(Sensitivity_Trial(1).Model_Objectives_Day2Day(:,5)/4),'o')
plot(Sensitivity_Trial(1).Model_Objectives_Day2Day(:,1)+Sensitivity_Trial(1).Model_Objectives_Day2Day(:,7),round(Sensitivity_Trial(1).Model_Objectives_Day2Day(:,5)/4),'o')

%plot(Sensitivity_Trial(2).Model_Objectives_Day2Day(:,1),Sensitivity_Trial(2).Model_Objectives_Day2Day(:,5)/4,'o')
%plot(Sensitivity_Trial(2).Model_Objectives_Day2Day(:,1)+Sensitivity_Trial(2).Model_Objectives_Day2Day(:,7),round(Sensitivity_Trial(2).Model_Objectives_Day2Day(:,5)/4),'o')
%plot(Sensitivity_Trial(3).Model_Objectives_Day2Day(:,1),round(Sensitivity_Trial(3).Model_Objectives_Day2Day(:,5)/4),'o')
%plot(Sensitivity_Trial(3).Model_Objectives_Day2Day(:,1)+Sensitivity_Trial(3).Model_Objectives_Day2Day(:,7),round(Sensitivity_Trial(3).Model_Objectives_Day2Day(:,5)/4),'o')
%plot(Sensitivity_Trial(4).Model_Objectives_Day2Day(:,1),Sensitivity_Trial(4).Model_Objectives_Day2Day(:,5),'o')
%plot(Sensitivity_Trial(5).Model_Objectives_Day2Day(:,1),Sensitivity_Trial(5).Model_Objectives_Day2Day(:,5),'o')
hold off
legend("Basic Cost", "Including Externalities")
title("Cost Of System vs Critical Load Shed")
xlabel("Cost of the System [$Mil]")
ylabel("Critical Load Failed Terms [Hrs]")
% %%
% Sensitivity_Trial(1).Solution_Parameters
% Sensitivity_Trial(1).Model_Objectives_Day2Day
% 
% %%
% length(Sensitivity_Trial(1).Solution_Parameters(:,6))

%%
Sensitivity_Trial(3).Solution_Parameters(:,7)=[1:length(Sensitivity_Trial(3).Solution_Parameters(:,6))]';
Sensitivity_Trial(3).Solution_Parameters;

Sensitivity_Trial(3).Model_Objectives_Day2Day(:,9)=[1:length(Sensitivity_Trial(3).Model_Objectives_Day2Day(:,8))]';
Sensitivity_Trial(3).Model_Objectives_Day2Day;

Results_Lookup_Objectives=sortrows(Sensitivity_Trial(3).Model_Objectives_Day2Day,1)
Results_Lookup_Parameters=Sensitivity_Trial(3).Solution_Parameters;
Results_Lookup_Parameters(7,:)

%Sensitivity_Trial(3).Model_Objectives_Day2Day
%
% Model_Objectives_Day2Day (The Functions/things you're optimizing for)
% Output 1: Annual Cost (Mean)                              [$]
% Output 2: Annual Cost (STD)                               [$]
% Output 3: Energy Critical Load Shed (Mean)                [MWh]
% Output 4: Energy Critical Load Shed (STD)                 [MWh]
% Output 5: Critical Load Failure Time Steps (Mean)         [Steps]
% Output 6: Critical Load Failure Time Steps (STD)          [Steps]
% Output 7: Annual Externality Cost (Mean)                  [$]
% Output 8: Annual Externality Cost (STD)                   [$]


%%

% 
% 
% 
% figure(2)
% errorbar(Model_Objectives_Day2Day(:,1)/10^6,Model_Objectives_Day2Day(:,5)/4,Model_Objectives_Day2Day(:,6)/8,Model_Objectives_Day2Day(:,6)/8,Model_Objectives_Day2Day(:,2)/10^6*.5,Model_Objectives_Day2Day(:,2)/10^6*.5,"o")
% title("Pareto Analysis Cost vs Load Shed")
% xlabel("Annual Cost of System [$Mil]")
% ylabel("Annal Hrs of Load Shed [Hrs]")
% %%
% figure(3)
% errorbar(Model_Objectives_Day2Day(:,1),Model_Objectives_Day2Day(:,7),Model_Objectives_Day2Day(:,8)/2,Model_Objectives_Day2Day(:,8)/2,Model_Objectives_Day2Day(:,2)/2,Model_Objectives_Day2Day(:,2)/2,'o')
% title("Pareto Analysis Cost vs Externality Cost")
% xlabel("Annual Cost of System [$Mil]")
% ylabel("Annal Cost of CO2 + SOX [$Mil]")
%% Heat Model Power Draw Figure

%------------------- [PARAMETER]--------------------------------
%Pick a day/week/whatever to look at
Month=1;
Day=1;
Year=2022; % Our demand data is from FY 2022 (OCT21-OCT22) so year is ~2022
Plot_length=365; % number of days
%------------------- [PARAMETER END]-----------------------------

%NSRDB Data Indexes
Number_of_days_Between=daysact(datetime(2021,12,31),datetime(2022,Month,Day));
start_index=Number_of_days_Between;
stop_index=(Number_of_days_Between+Plot_length)-1;

%Date matrix adjusts data to any time perioid in given data
date_matrix=[datetime(Year,1,1):days(1): datetime(Year+1,1,1)-days(1)]';

figure 
hold on
plot(date_matrix(start_index:stop_index,1),Heat_Pump_Daily_Constant_MW_Required(start_index:stop_index,1),LineWidth=2,Color='black')
plot(date_matrix(start_index:stop_index,1),Heat_Pump_Daily_Water_Heating_MW_Required(start_index:stop_index,1))
plot(date_matrix(start_index:stop_index,1),Heat_Pump_Daily_Space_Heating_MW_Required(start_index:stop_index,1))
title("Heat Pump Power Draw")
xlabel("Date")
ylabel("Power Draw [MW]")
ylim([0,8])
legend("Combined","Water Heating", "Space Heating")

figure 
plot(date_matrix(start_index:stop_index,1),Heat_Pump_Daily_Space_Heating_MW_Required(start_index:stop_index,1))
title("Space Heating Power Draw")
xlabel("Date")
ylabel("Power Draw [MW]")
ylim([0,8])

figure 
plot(date_matrix(start_index:stop_index,1),Heat_Pump_Daily_Water_Heating_MW_Required(start_index:stop_index,1))
title("Water Heating Power Draw")
xlabel("Date")
ylabel("Power Draw [MW]")
ylim([0,8])


