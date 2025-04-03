% 
% 
% clc 
% clear all
% close all
% 

% West Energy Resilience
% XE485 24-1 & 24-2
% Contact -> 215-528-7614 (David Sang)

load("Data_for_Grid_Cost\Grid_Cost_Data_mat.mat")
load("Data_for_Cost_Function_One_Year\Peak_MWatts_15min_Jan_to_DEC.mat")

%% Grid Electricity Cost

% From utility bill data
% Most recent takes the data from FY23 and FY22 and merges it to create a
% cost data for 1 year starting in JAN going to DEC

Most_Recent_Cost_of_Grid_Electricity_JAN_to_DEC= [WP_Grid_Electricity_Costs_OCT22_to_MAR23(4:6);WP_Grid_Electricity_Costs_OCT21_to_SEP22(7:12);WP_Grid_Electricity_Costs_OCT22_to_MAR23(1:3)]
% $/kWhr

% Average grid cost of energy calculations 
Grid_Electricity_Cost_Matrix_OCT_to_MAR=cat(3,WP_Grid_Electricity_Costs_OCT19_to_SEP20(1:6),...
    WP_Grid_Electricity_Costs_OCT20_to_SEP21(1:6),...
    WP_Grid_Electricity_Costs_OCT21_to_SEP22(1:6),...
    WP_Grid_Electricity_Costs_OCT22_to_MAR23);
Grid_Electricity_Cost_Matrix_APR_to_SEP=cat(3,WP_Grid_Electricity_Costs_OCT19_to_SEP20(7:12),...
    WP_Grid_Electricity_Costs_OCT20_to_SEP21(7:12),...
    WP_Grid_Electricity_Costs_OCT21_to_SEP22(7:12));
Average_Cost_of_Grid_Electricity_OCT_to_SEP=[mean(Grid_Electricity_Cost_Matrix_OCT_to_MAR,3);mean(Grid_Electricity_Cost_Matrix_APR_to_SEP,3)];
Average_Cost_of_Grid_Electricity_JAN_to_DEC=[Average_Cost_of_Grid_Electricity_OCT_to_SEP(4:12);Average_Cost_of_Grid_Electricity_OCT_to_SEP(1:3)];
% $/kWh

% Make 15 minute frequency of cost data
Days_in_month_JAN_to_DEC=[31,28,31,30,31,30,31,31,30,31,30,31]';
Days_in_month_JAN_to_DEC_15min=Days_in_month_JAN_to_DEC*4*24;

Average_Cost_of_Grid_Electricity_JAN_to_DEC_15_min=repelem(Average_Cost_of_Grid_Electricity_JAN_to_DEC,Days_in_month_JAN_to_DEC_15min);
% $/kWh
Most_Recent_Cost_of_Grid_Electricity_JAN_to_DEC_15min=repelem(Most_Recent_Cost_of_Grid_Electricity_JAN_to_DEC,Days_in_month_JAN_to_DEC_15min);
% $/kWh

% remove last 2 values to match data
Average_Cost_of_Grid_Electricity_JAN_to_DEC_15_min=Average_Cost_of_Grid_Electricity_JAN_to_DEC_15_min(1:end-2,:);
% $/kWh
Most_Recent_Cost_of_Grid_Electricity_JAN_to_DEC_15min=Most_Recent_Cost_of_Grid_Electricity_JAN_to_DEC_15min(1:end-2,:);
% % $/kWh

%Grid_Energy_Supplied=Energy_Generation_Deficit_JAN_to_DEC*

%% Time of Day evaluation

% Use the known values of energy to create a whieghted average by month.
% This can be done to isolate the baseline 1 value for each month that
% leads to the same overall cost in the month 

    % First create a flag matrix to determine which days are weekends and
    % which days are weekdays. Jan 1 2022 was a saturday
Weekend_Flag=[1,1,0,0,0,0,0]';
Weekend_Flag=repelem(Weekend_Flag,24*4);
Weekend_Flag=repmat(Weekend_Flag,53,1);
Weekend_Flag=Weekend_Flag(1:365*24*4);

    % Create a matrix that includes the TOD factor for every period over
    % the entire year
TOD_Factor_JAN_DEC=zeros([length(Peak_MWatts_15min_JAN_to_DEC),1]);
end_idx=0;
for i=1:12
    start_idx=1+end_idx;
    end_idx=start_idx+Days_in_month_JAN_to_DEC(i)*24*4-1;
    


    Month_Weekday=repelem(TOD_Grid_Cost_SAM_Weekday(i,:),1,4)';
    Month_Weekend=repelem(TOD_Grid_Cost_SAM_Weekend(i,:),1,4)';
    
    Total_Month_Weekday=repmat(Month_Weekday,Days_in_month_JAN_to_DEC(i),1);
    Total_Month_Weekend=repmat(Month_Weekend,Days_in_month_JAN_to_DEC(i),1);

    TOD_Factor_JAN_DEC_Weekend(start_idx:end_idx)=Weekend_Flag(start_idx:end_idx).*Total_Month_Weekend;
    TOD_Factor_JAN_DEC_Weekday(start_idx:end_idx)=-1*(Weekend_Flag(start_idx:end_idx)-1).*Total_Month_Weekday;
    TOD_Factor_JAN_DEC(start_idx:end_idx)=TOD_Factor_JAN_DEC_Weekend(start_idx:end_idx)+TOD_Factor_JAN_DEC_Weekday(start_idx:end_idx);
end

%%
ts=360;

figure
hold on
plot(TOD_Factor_JAN_DEC(1:24*4*ts))
% plot(TOD_Factor_JAN_DEC_Weekend(1:24*4*ts))
% plot(TOD_Factor_JAN_DEC_Weekday(1:24*4*ts),'--')
% plot(Weekend_Flag(1:24*4*ts))

    % Second determine the Baseline cost values (What represents 1 on the 
    % SAM TOD charts) For each month. Assume variation in monthly costs is
    % captured in different monthly costs
Monthly_baseline_cost=zeros([12,1]);

end_idx=0;
for i=1:12
    start_idx=1+end_idx;
    end_idx=start_idx+Days_in_month_JAN_to_DEC(i)*24*4-1;
    if end_idx>length(Peak_MWatts_15min_JAN_to_DEC)
        end_idx=length(Peak_MWatts_15min_JAN_to_DEC)
    end
    Baseline_cost_month=sum(Peak_MWatts_15min_JAN_to_DEC(start_idx:end_idx).*Most_Recent_Cost_of_Grid_Electricity_JAN_to_DEC_15min(start_idx:end_idx))./...
        sum(Peak_MWatts_15min_JAN_to_DEC(start_idx:end_idx,1).*TOD_Factor_JAN_DEC(start_idx:end_idx));
    
    Monthly_baseline_cost(i)=Baseline_cost_month
end


    % Third, use the monthly baseline costs multiplied by the TOD factors
    % within the month

end_idx=0;
for i=1:12
    start_idx=1+end_idx;
    end_idx=start_idx+Days_in_month_JAN_to_DEC(i)*24*4-1;
    if end_idx>length(Peak_MWatts_15min_JAN_to_DEC)
        end_idx=length(Peak_MWatts_15min_JAN_to_DEC);
    end
    
    TOD_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC(start_idx:end_idx)=Monthly_baseline_cost(i)*TOD_Factor_JAN_DEC(start_idx:end_idx);

end

TOD_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC=TOD_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC';
Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC=[TOD_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC,Most_Recent_Cost_of_Grid_Electricity_JAN_to_DEC_15min];


save('Data_for_Cost_Function_One_Year\TOD_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC.mat','TOD_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC')
save('Data_for_Cost_Function_One_Year\Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC.mat','Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC')

ts=360;
%%
figure
hold on
%plot(TOD_Factor_JAN_DEC(1:24*4*ts))
plot(TOD_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC(1:24*4*ts))
% plot(TOD_Factor_JAN_DEC_Weekend(1:24*4*ts))
% plot(TOD_Factor_JAN_DEC_Weekday(1:24*4*ts),'--')
% plot(Weekend_Flag(1:24*4*ts))
