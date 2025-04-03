

clc
clear all
close all

load("Model_Assumptions.mat")
load("Data_for_Image_Generation\WP_energy_model_data_Trial_2.mat")
% The value model takes in the model assumptions and one trials set of data



% Sensitivity_Trial is the strut that contains all the trial data
    % Solution Parameters 
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
        % var 9: Number of Diesel Generators ------------------ [#]  
        % var 10: Diesel Generator Size (2,2.5,2.75,3)          [# (MW)]
        %
        % var 11: Pumped Hydro Strategy ----------------------- (#)
        % var 12: Pumped Hydro Selector                         (#)
        %
        % var 13: Electrical Vehicle Adoption ----------------- (Binary 1 yes)
        % 
        % var 14: Heat Pump Transistion ----------------------- (Binary 1 yes)
%
    % Objectives 
        % Output 1: Annual Cost (Mean)                              [$ mil]
        % Output 2: Annual Cost (STD)                               [$ mil]
        % Output 3: Energy Critical Load Shed (Mean)                [MWh]
        % Output 4: Energy Critical Load Shed (STD)                 [MWh]
        % Output 5: Critical Load Failure Time Steps (Mean)         [Steps]
        % Output 6: Critical Load Failure Time Steps (STD)          [Steps]
        % Output 7: Annual Externality Cost (Mean)                  [$ mil]
        % Output 8: Annual Externality Cost (STD)                   [$ mil]



% Use the swing weight to set the weighted value. 
% Raw data -> Value -> Value * Swing weight -> Sum of value * Swing weight = total value
Swing_Weights=[0.3, 0.3, 0.4];
% row 1: Environment
% row 2: Resilience Day 2 Day
% row 3: Resilience Extreme

% Define how resilience is valued
D2D_Resilience_Value_BOT=   150;
D2D_Resilience_Value_Scoreing=[
    0                               100
    D2D_Resilience_Value_BOT        0
    1000000                         0
];

THREAT_Resilience_Value_BOT=   400;
THREAT_Resilience_Value_Scoreing=[
    0                                   100
    THREAT_Resilience_Value_BOT          0 
    1000000                             0
];
% col 1 hrs/yr less than critical load
% col 2 score


Enviroment_Value_Scoring=[   
    0           100
    1000        100
    100000      0
    100000000   0
];
    % tonnes of carbon a year
    % col 1 (Tonnes Carbon Equivalent)
    % col 2 (Value Score)

 
% Calculate the value associated with each potential solution
for i=1:length(Sensitivity_Trial)
    Sensitivity_Trial(i).Resilience_Value_D2D=interp1(D2D_Resilience_Value_Scoreing(:,1),D2D_Resilience_Value_Scoreing(:,2),Sensitivity_Trial(i).Model_Objectives_Day2Day(:,5));
    Sensitivity_Trial(i).Resilience_Value_EXTREME=interp1(THREAT_Resilience_Value_Scoreing(:,1),THREAT_Resilience_Value_Scoreing(:,2),Sensitivity_Trial(i).Model_Objectives_Extreme(:,5));

    Sensitivity_Trial(i).Enviroment_Value=interp1(Enviroment_Value_Scoring(:,1),Enviroment_Value_Scoring(:,2),Sensitivity_Trial(i).Model_Objectives_Day2Day(:,7)*10^6/Carbon_Cost);


    Sensitivity_Trial(i).Alternative_Value=Swing_Weights(1).*Sensitivity_Trial(i).Enviroment_Value+Swing_Weights(2).*Sensitivity_Trial(i).Resilience_Value_D2D+Swing_Weights(3).*Sensitivity_Trial(i).Resilience_Value_EXTREME;
    Sensitivity_Trial(i).Alternative_Average_Cost=(Sensitivity_Trial(i).Model_Objectives_Day2Day(:,1)+Sensitivity_Trial(i).Model_Objectives_Extreme(:,1))/2;
end


%% Nuetral Scenario, Value vs Cost

% This plots the value and cost for the nuetral situation.

Nuetral_idx=ceil(length(Sensitivity_Trial)/2);

figure
p=plot(Sensitivity_Trial(Nuetral_idx).Alternative_Average_Cost,Sensitivity_Trial(Nuetral_idx).Alternative_Value,'o')

xlabel('Cost of System [$Mil]')
ylabel('Value')
title("Value vs Cost")

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

set(gca, 'XDir','reverse')

%% Value Histograms 

[x,y]=ginput()

for i=1:length(Sensitivity_Trial)
    
    Strut_Value=Sensitivity_Trial(i).Alternative_Value;
    Strut_Cost=Sensitivity_Trial(i).Alternative_Average_Cost;
    Strut_Environment_Value=Sensitivity_Trial(i).Enviroment_Value*Swing_Weights(1);
    Strut_Resilience_D2D=Sensitivity_Trial(i).Resilience_Value_D2D*Swing_Weights(2);
    Strut_Resilience_Extreme=Sensitivity_Trial(i).Resilience_Value_EXTREME*Swing_Weights(3);
    
    Strut_Environment_Value_Raw=Sensitivity_Trial(i).Enviroment_Value;
    Strut_Resilience_D2D_Raw=Sensitivity_Trial(i).Resilience_Value_D2D;
    Strut_Resilience_Extreme_Raw=Sensitivity_Trial(i).Resilience_Value_EXTREME;
    
    Strut_Environment_Value_Raw_Data=Sensitivity_Trial(i).Model_Objectives_Day2Day(:,7)*10^6/Carbon_Cost; % Tonnes Carbon Equivalent
    Strut_Resilience_D2D_Raw_Data=Sensitivity_Trial(i).Model_Objectives_Day2Day(:,5);       % Hours
    Strut_Resilience_Extreme_Raw_Data=Sensitivity_Trial(i).Model_Objectives_Extreme(:,5);   % Hours
    
    
    
    eval("New_Strut_Parameters"+i+"=Sensitivity_Trial(i).Solution_Parameters")
    eval("New_Strut_Value_and_Cost"+i+"=cat(3,Strut_Cost,Strut_Value,Strut_Environment_Value,Strut_Resilience_D2D,Strut_Resilience_Extreme,Strut_Environment_Value_Raw,Strut_Resilience_D2D_Raw,Strut_Resilience_Extreme_Raw,Strut_Environment_Value_Raw_Data,Strut_Resilience_D2D_Raw_Data,Strut_Resilience_Extreme_Raw_Data)");
    
    

end

% Find internal Values and Costs
Plot_Strut_Value_and_Costs=New_Strut_Value_and_Cost1( and(  and(New_Strut_Value_and_Cost1(:,1,1)>min(x),New_Strut_Value_and_Cost1(:,1,1)<max(x)) , and(New_Strut_Value_and_Cost1(:,1,2)>min(y),New_Strut_Value_and_Cost1(:,1,2)<max(y)) ) ,1,:)
Plot_Strut_Value_and_Costs_mat=sortrows(squeeze(Plot_Strut_Value_and_Costs));

% col 1: Cost
% col 2: Total Value
% col 3: Environment Value (with SW)
% col 4: Resilience D2D Value (With SW) 
% col 5: Resilience Threat Value (With SW) 
% col 6: Environment Value 
% col 7: Resilience D2D Value 
% col 8: Resilience Threat Value  
% col 9: Environment Value Data
% col 10: Resilience D2D Value Data
% col 11: Resilience Threat Value Data

Plot_Parameters=New_Strut_Parameters1(and(  and(New_Strut_Value_and_Cost1(:,1,1)>min(x),New_Strut_Value_and_Cost1(:,1,1)<max(x)) , and(New_Strut_Value_and_Cost1(:,1,2)>min(y),New_Strut_Value_and_Cost1(:,1,2)<max(y)) ) ,:);

%%%%
%% Full plot of selected



% Create a matrix that counts which row the dot is in
row_idx_mat=[1:size(Plot_Strut_Value_and_Costs_mat,1)];

figure 

subplot(1,7,[1:4])
hold on
b=bar([Plot_Strut_Value_and_Costs_mat(:,3),Plot_Strut_Value_and_Costs_mat(:,4),Plot_Strut_Value_and_Costs_mat(:,5)],'stacked')
ylabel("Value")
xtips1 = b(1).XEndPoints;
ytips1 = b(3).YEndPoints;

labels1 = string(round(Plot_Strut_Value_and_Costs_mat(:,2)));
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

yyaxis right
plot([1:length(Plot_Strut_Value_and_Costs_mat(:,1))],round(Plot_Strut_Value_and_Costs_mat(:,1)), LineStyle="none",Marker='x',LineWidth=3,MarkerSize=10)
ylabel("Cost [$M]")
ylim([10,max(round(Plot_Strut_Value_and_Costs_mat(:,1)))+20])
legend("Environment Value","D2D Resilience Value", "Threat Resilience Value","Cost",Location="southeast")



subplot(1,7,[6:7])
p=plot(Plot_Strut_Value_and_Costs_mat(:,1),Plot_Strut_Value_and_Costs_mat(:,2),'o')

xlabel('Cost of System [$Mil]')
%ylabel('Value')
title("Value vs Cost")
xlim([min(Plot_Strut_Value_and_Costs_mat(:,1))-1,max(Plot_Strut_Value_and_Costs_mat(:,1))+1])
ylim([0,100])

dtt=p.DataTipTemplate;
dtt.DataTipRows(1)=dataTipTextRow("Cost [$M]",Plot_Strut_Value_and_Costs_mat(:,1));
dtt.DataTipRows(2)=dataTipTextRow("Critical Load Failure [Hr]",Plot_Strut_Value_and_Costs_mat(:,10)/4);

dtt.DataTipRows(3)=dataTipTextRow("Solar Tracking Designator",Plot_Parameters(:,1));
dtt.DataTipRows(4)=dataTipTextRow("Solar Panels",Plot_Parameters(:,2));
dtt.DataTipRows(5)=dataTipTextRow("Wind Turbines",Plot_Parameters(:,3));
dtt.DataTipRows(6)=dataTipTextRow("Battery Strategy",Plot_Parameters(:,4));
dtt.DataTipRows(7)=dataTipTextRow("Li Battery Size [MWh]",Plot_Parameters(:,5));
dtt.DataTipRows(8)=dataTipTextRow("Li Battery Power Out [MW]",Plot_Parameters(:,6));
dtt.DataTipRows(9)=dataTipTextRow("Diesel Strategy",Plot_Parameters(:,7));
dtt.DataTipRows(10)=dataTipTextRow("Diesel Storage [MWh]",Plot_Parameters(:,8));
dtt.DataTipRows(11)=dataTipTextRow("Diesel Generators [#]",Plot_Parameters(:,9));
dtt.DataTipRows(12)=dataTipTextRow("Diesel Generator Size [MW]",Plot_Parameters(:,10));
dtt.DataTipRows(13)=dataTipTextRow("Hydro Strategy",Plot_Parameters(:,11));
dtt.DataTipRows(14)=dataTipTextRow("Hydro Option [#]",Plot_Parameters(:,12));
dtt.DataTipRows(15)=dataTipTextRow("EV Adoption [Bin]",Plot_Parameters(:,13));
dtt.DataTipRows(16)=dataTipTextRow("Heat Pump Adoption [Bin]",Plot_Parameters(:,14));
dtt.DataTipRows(17)=dataTipTextRow("Row IDX",row_idx_mat(:));

%% Full Plot Selected Bar Chart


% Create a matrix that counts which row the dot is in
row_idx_mat=[1:size(Plot_Strut_Value_and_Costs_mat,1)];

f=figure("Position",[0,0,1000,500])
hold on
b=bar([Plot_Strut_Value_and_Costs_mat(:,3),Plot_Strut_Value_and_Costs_mat(:,4),Plot_Strut_Value_and_Costs_mat(:,5)],'stacked')
ylabel("Value")
xtips1 = b(1).XEndPoints;
ytips1 = b(3).YEndPoints;

labels1 = string(round(Plot_Strut_Value_and_Costs_mat(:,2)));
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

yyaxis right
plot([1:length(Plot_Strut_Value_and_Costs_mat(:,1))],round(Plot_Strut_Value_and_Costs_mat(:,1)), LineStyle="none",Marker='x',LineWidth=3,MarkerSize=10)
ylabel("Cost [$M]")
ylim([10,max(round(Plot_Strut_Value_and_Costs_mat(:,1)))+20])
legend("Environment Value","D2D Resilience Value", "Threat Resilience Value","Cost",Location="southeast")




%% Partial plot of selected (Low, med, high to explain value)
[min_val,min_value_row_idx]=min(Plot_Strut_Value_and_Costs_mat(:,2));
[max_val,max_value_row_idx]=max(Plot_Strut_Value_and_Costs_mat(:,2));
median_cost_row_idx=round(size(Plot_Strut_Value_and_Costs_mat,1)/2);
Partial_row_idx=[min_value_row_idx,median_cost_row_idx,max_value_row_idx];


f=figure("Position",[0,0,1000,500])

subplot(1,7,[1:4])
hold on
b=bar([Plot_Strut_Value_and_Costs_mat(Partial_row_idx,3),Plot_Strut_Value_and_Costs_mat(Partial_row_idx,4),Plot_Strut_Value_and_Costs_mat(Partial_row_idx,5)],'stacked')
ylabel("Value")
xtips1 = b(1).XEndPoints;
ytips1 = b(3).YEndPoints;

labels1 = string(round(Plot_Strut_Value_and_Costs_mat(Partial_row_idx,2)));
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

yyaxis right
plot([1:length(Plot_Strut_Value_and_Costs_mat(Partial_row_idx,1))],round(Plot_Strut_Value_and_Costs_mat(Partial_row_idx,1)), LineStyle="none",Marker='x',LineWidth=3,MarkerSize=10)
ylabel("Cost [$M]")
ylim([10,max(round(Plot_Strut_Value_and_Costs_mat(:,1)))+20])
legend("Environment Value","D2D Resilience Value", "Threat Resilience Value","Cost",Location="northwest")



subplot(1,7,[6:7])
p=plot(Plot_Strut_Value_and_Costs_mat(Partial_row_idx,1),Plot_Strut_Value_and_Costs_mat(Partial_row_idx,2),'o')

xlabel('Cost of System [$Mil]')
%ylabel('Value')
title("Value vs Cost")
xlim([min(Plot_Strut_Value_and_Costs_mat(Partial_row_idx,1))-5,max(Plot_Strut_Value_and_Costs_mat(Partial_row_idx,1))+5])
ylim([0,100])

dtt=p.DataTipTemplate;
dtt.DataTipRows(1)=dataTipTextRow("Cost [$M]",Plot_Strut_Value_and_Costs_mat(Partial_row_idx,1));
dtt.DataTipRows(2)=dataTipTextRow("Critical Load Failure [Hr]",Plot_Strut_Value_and_Costs_mat(Partial_row_idx,10)/4);

dtt.DataTipRows(3)=dataTipTextRow("Solar Tracking Designator",Plot_Parameters(Partial_row_idx,1));
dtt.DataTipRows(4)=dataTipTextRow("Solar Panels",Plot_Parameters(Partial_row_idx,2));
dtt.DataTipRows(5)=dataTipTextRow("Wind Turbines",Plot_Parameters(Partial_row_idx,3));
dtt.DataTipRows(6)=dataTipTextRow("Battery Strategy",Plot_Parameters(Partial_row_idx,4));
dtt.DataTipRows(7)=dataTipTextRow("Li Battery Size [MWh]",Plot_Parameters(Partial_row_idx,5));
dtt.DataTipRows(8)=dataTipTextRow("Li Battery Power Out [MW]",Plot_Parameters(Partial_row_idx,6));
dtt.DataTipRows(9)=dataTipTextRow("Diesel Strategy",Plot_Parameters(Partial_row_idx,7));
dtt.DataTipRows(10)=dataTipTextRow("Diesel Storage [MWh]",Plot_Parameters(Partial_row_idx,8));
dtt.DataTipRows(11)=dataTipTextRow("Diesel Generators [#]",Plot_Parameters(Partial_row_idx,9));
dtt.DataTipRows(12)=dataTipTextRow("Diesel Generator Size [MW]",Plot_Parameters(Partial_row_idx,10));
dtt.DataTipRows(13)=dataTipTextRow("Hydro Strategy",Plot_Parameters(Partial_row_idx,11));
dtt.DataTipRows(14)=dataTipTextRow("Hydro Option [#]",Plot_Parameters(Partial_row_idx,12));
dtt.DataTipRows(15)=dataTipTextRow("EV Adoption [Bin]",Plot_Parameters(Partial_row_idx,13));
dtt.DataTipRows(16)=dataTipTextRow("Heat Pump Adoption [Bin]",Plot_Parameters(Partial_row_idx,14));


%% Partial plot of selected (Low, med, high to explain value) Bar Only
[min_val,min_value_row_idx]=min(Plot_Strut_Value_and_Costs_mat(:,2));
[max_val,max_value_row_idx]=max(Plot_Strut_Value_and_Costs_mat(:,2));
median_cost_row_idx=round(size(Plot_Strut_Value_and_Costs_mat,1)/2);
Partial_row_idx=[min_value_row_idx,median_cost_row_idx,max_value_row_idx];

figure

hold on
b=bar([Plot_Strut_Value_and_Costs_mat(Partial_row_idx,3),Plot_Strut_Value_and_Costs_mat(Partial_row_idx,4),Plot_Strut_Value_and_Costs_mat(Partial_row_idx,5)],'stacked')
ylabel("Value")
xtips1 = b(1).XEndPoints;
ytips1 = b(3).YEndPoints;

labels1 = string(round(Plot_Strut_Value_and_Costs_mat(Partial_row_idx,2)));
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

yyaxis right
plot([1:length(Plot_Strut_Value_and_Costs_mat(Partial_row_idx,1))],round(Plot_Strut_Value_and_Costs_mat(Partial_row_idx,1)), LineStyle="none",Marker='x',LineWidth=3,MarkerSize=10)
ylabel("Cost [$M]")
ylim([10,max(round(Plot_Strut_Value_and_Costs_mat(:,1)))+20])
legend("Environment Value","D2D Resilience Value", "Threat Resilience Value","Cost",Location="northwest")



%% Partial value plot with table of parameters (Used to explain)

partial_plot_table=array2table([Plot_Strut_Value_and_Costs_mat(Partial_row_idx,1:2)';Plot_Parameters(Partial_row_idx,:)'],...
    "Variablenames",{'Low Value','Mid Value', 'High Value'},...
    "Rownames",{ 'Cost [$Mil/yr]', ...
                 ' Value',...
                'Solar Designator', ...
                'Solar Panels [m^2]', ...
                'Wind Turbines [#]', ...
                'Battery Strategy', ...
                'Battery Size [MWh]',...
                'Battery Power [MW]', ...
                'Diesel Strategy',...
                'Diesel Storage [MWh]', ...
                'Diesel Generators [#]', ...
                'Diesel Generator Sixe [MW]',...
                'Hydro Strategy', ...
                'Hydro Option', ...
                'EV Adoption [BIN]', ...
                'Heat Pump Adoption [BIN]'})
writetable(partial_plot_table,"IMGs\Example_Value_Plot_Table.csv",'Delimiter',',','WriteRowNames',true,'WriteVariableNames',true)
type 'IMGs\Example_Value_Plot_Table.csv'


%% Partial plot of Suggeseted infastructrue selected 

Suggested_row_idx=[10,32,46];


f=figure('Position',[0,0,1000,500])

subplot(1,7,[1:4])
hold on
b=bar([Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,3),Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,4),Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,5)],'stacked')
ylabel("Value")
xtips1 = b(1).XEndPoints;
ytips1 = b(3).YEndPoints;

labels1 = string(round(Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,2)));
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

yyaxis right
plot([1:length(Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,1))],round(Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,1)), LineStyle="none",Marker='x',LineWidth=3,MarkerSize=10)
ylabel("Cost [$M]")
ylim([10,max(round(Plot_Strut_Value_and_Costs_mat(:,1)))+20])
legend("Environment Value","D2D Resilience Value", "Threat Resilience Value","Cost",Location="southeast")



subplot(1,7,[6:7])
p=plot(Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,1),Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,2),'o')

xlabel('Cost of System [$Mil]')
%ylabel('Value')
title("Value vs Cost")
xlim([min(Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,1))-5,max(Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,1))+5])

dtt=p.DataTipTemplate;
dtt.DataTipRows(1)=dataTipTextRow("Cost [$M]",Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,1));
dtt.DataTipRows(2)=dataTipTextRow("Critical Load Failure [Hr]",Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,10)/4);

dtt.DataTipRows(3)=dataTipTextRow("Solar Tracking Designator",Plot_Parameters(Suggested_row_idx,1));
dtt.DataTipRows(4)=dataTipTextRow("Solar Panels",Plot_Parameters(Suggested_row_idx,2));
dtt.DataTipRows(5)=dataTipTextRow("Wind Turbines",Plot_Parameters(Suggested_row_idx,3));
dtt.DataTipRows(6)=dataTipTextRow("Battery Strategy",Plot_Parameters(Suggested_row_idx,4));
dtt.DataTipRows(7)=dataTipTextRow("Li Battery Size [MWh]",Plot_Parameters(Suggested_row_idx,5));
dtt.DataTipRows(8)=dataTipTextRow("Li Battery Power Out [MW]",Plot_Parameters(Suggested_row_idx,6));
dtt.DataTipRows(9)=dataTipTextRow("Diesel Strategy",Plot_Parameters(Suggested_row_idx,7));
dtt.DataTipRows(10)=dataTipTextRow("Diesel Storage [MWh]",Plot_Parameters(Suggested_row_idx,8));
dtt.DataTipRows(11)=dataTipTextRow("Diesel Generators [#]",Plot_Parameters(Suggested_row_idx,9));
dtt.DataTipRows(12)=dataTipTextRow("Diesel Generator Size [MW]",Plot_Parameters(Suggested_row_idx,10));
dtt.DataTipRows(13)=dataTipTextRow("Hydro Strategy",Plot_Parameters(Suggested_row_idx,11));
dtt.DataTipRows(14)=dataTipTextRow("Hydro Option [#]",Plot_Parameters(Suggested_row_idx,12));
dtt.DataTipRows(15)=dataTipTextRow("EV Adoption [Bin]",Plot_Parameters(Suggested_row_idx,13));
dtt.DataTipRows(16)=dataTipTextRow("Heat Pump Adoption [Bin]",Plot_Parameters(Suggested_row_idx,14));


%% Partial plot of Suggeseted infastructrue selected (Bar only)

Suggested_row_idx=[10,32,46];


figure

hold on
b=bar([Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,3),Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,4),Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,5)],'stacked')
ylabel("Value")
xtips1 = b(1).XEndPoints;
ytips1 = b(3).YEndPoints;

labels1 = string(round(Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,2)));
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

yyaxis right
plot([1:length(Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,1))],round(Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,1)), LineStyle="none",Marker='x',LineWidth=3,MarkerSize=10)
ylabel("Cost [$M]")
ylim([10,max(round(Plot_Strut_Value_and_Costs_mat(:,1)))+20])
legend("Environment Value","D2D Resilience Value", "Threat Resilience Value","Cost",Location="southeast")




%% Suggested value plot with table of parameters (Used to explain)


Suggested_plot_table=array2table([Plot_Strut_Value_and_Costs_mat(Suggested_row_idx,1:2)';Plot_Parameters(Suggested_row_idx,:)'],...
    "Variablenames",{'Low Value','Mid Value', 'High Value'},...
    "Rownames",{ 'Cost [$Mil/yr]', ...
                 ' Value',...
                'Solar Designator', ...
                'Solar Panels [m^2]', ...
                'Wind Turbines [#]', ...
                'Battery Strategy', ...
                'Battery Size [MWh]',...
                'Battery Power [MW]', ...
                'Diesel Strategy',...
                'Diesel Storage [MWh]', ...
                'Diesel Generators [#]', ...
                'Diesel Generator Size [MW]',...
                'Hydro Strategy', ...
                'Hydro Option', ...
                'EV Adoption [BIN]', ...
                'Heat Pump Adoption [BIN]'})
writetable(Suggested_plot_table,"IMGs\Suggested_Value_Plot_Table.csv",'Delimiter',',','WriteRowNames',true,'WriteVariableNames',true)
type 'IMGs\Suggested_Value_Plot_Table.csv'

%% Carbon Value Plot 

% col 1: Cost
% col 2: Total Value
% col 3: Environment Value (with SW)
% col 4: Resilience D2D Value (With SW) 
% col 5: Resilience Threat Value (With SW) 

% col 6: Environment Value 
% col 7: Resilience D2D Value 
% col 8: Resilience Threat Value  

% col 9: Environment Value Data
% col 10: Resilience D2D Value Data
% col 11: Resilience Threat Value Data

figure 
yyaxis left 
plot(Plot_Strut_Value_and_Costs_mat(:,1),Plot_Strut_Value_and_Costs_mat(:,6),'o')
ylabel("Environment Value")
ylim([0,100])
xlabel('Cost [$Mil]')
title("Equivalent Carbon")

yyaxis right 
plot(Plot_Strut_Value_and_Costs_mat(:,1),-Plot_Strut_Value_and_Costs_mat(:,9),'x')
ylabel('Equivalent Carbon [Tonnes]')
ylim([-100000,-1000])


%% D2D Resilience Value Plot

figure 
yyaxis left 
plot(Plot_Strut_Value_and_Costs_mat(:,1),Plot_Strut_Value_and_Costs_mat(:,7),'o')
ylabel("Resilience Value")
xlabel('Cost [$Mil]')
ylim([0,100])
title("Day to Day Resilience")

yyaxis right 
plot(Plot_Strut_Value_and_Costs_mat(:,1),Plot_Strut_Value_and_Costs_mat(:,10),'x')
ylabel('Critical Load Failed Time [Hrs]')
ylim([0,D2D_Resilience_Value_BOT,])
set(gca, 'XDir','reverse')

%% Threat Resilience Value Plot (NO DOTS)
figure 
yyaxis left 
%plot(Plot_Strut_Value_and_Costs_mat(:,1),Plot_Strut_Value_and_Costs_mat(:,8),'o')
ylabel("Resilience Value")
ylim([0,100])
xlim([min(Plot_Strut_Value_and_Costs_mat(:,1))-1,max(Plot_Strut_Value_and_Costs_mat(:,1))+1])
xlabel('Cost [$Mil]')
title("Threat Resilience")

yyaxis right 
%plot(Plot_Strut_Value_and_Costs_mat(:,1),Plot_Strut_Value_and_Costs_mat(:,11),'x')
ylabel('Critical Load Failed Time [Hrs]')
ylim([0,THREAT_Resilience_Value_BOT])
set(gca, 'YDir','reverse')
set(gca, 'XDir','reverse')


% Threat Resilience Value Plot (One DOT)
figure 
box on
yyaxis left 
plot(Plot_Strut_Value_and_Costs_mat(median_cost_row_idx,1),Plot_Strut_Value_and_Costs_mat(median_cost_row_idx,8),'o')
ylabel("Resilience Value")
ylim([0,100])
xlim([min(Plot_Strut_Value_and_Costs_mat(:,1))-1,max(Plot_Strut_Value_and_Costs_mat(:,1))+1])
xlabel('Cost [$Mil]')
title("Threat Resilience")

yyaxis right 
plot(Plot_Strut_Value_and_Costs_mat(median_cost_row_idx,1),Plot_Strut_Value_and_Costs_mat(median_cost_row_idx,11),'x')
ylabel('Critical Load Failed Time [Hrs]')
ylim([0,THREAT_Resilience_Value_BOT])
set(gca, 'YDir','reverse')
set(gca, 'XDir','reverse')

% Threat Resilience Value Plot (Many DOTs)
figure 
yyaxis left 
plot(Plot_Strut_Value_and_Costs_mat(:,1),Plot_Strut_Value_and_Costs_mat(:,8),'o')
ylabel("Resilience Value")
ylim([0,100])
xlim([min(Plot_Strut_Value_and_Costs_mat(:,1))-1,max(Plot_Strut_Value_and_Costs_mat(:,1))+1])
xlabel('Cost [$Mil]')
title("Threat Resilience")

yyaxis right 
plot(Plot_Strut_Value_and_Costs_mat(:,1),Plot_Strut_Value_and_Costs_mat(:,11),'x')
ylabel('Critical Load Failed Time [Hrs]')
ylim([0,THREAT_Resilience_Value_BOT])
set(gca, 'YDir','reverse')
set(gca, 'XDir','reverse')



