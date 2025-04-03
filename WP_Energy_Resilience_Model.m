

clc  
clear
close all

%%
tic

% Before you run this code, update and run the assumptions in the 
% assumption script

load('Model_Assumptions.mat')

% This code runs the gentic algorithm.

% Genetic Optimization Algorithm %%%%%%%%%%%%%%%%%%%%%%%%%%

% The bounds of the algorithm are the upper and lower limits that can be
% chosen for the parameters

%             1     2        3    4   5       6       7   8     9   10  
lower_bounds=[1     0        1    1   0       0       1   0     1   1   1   1   0  0];
upper_bounds=[1     0        1    1   0       0       2   2000  10  4   1   1   0  0];
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


% References for Genetic Algorithms
% https://www.mathworks.com/help/gads/ga.html#d126e50026
% https://www.mathworks.com/help/gads/solving-a-mixed-integer-engineering-design-problem-using-the-genetic-algorithm.html

opts=optimoptions('gamultiobj', ...
    'PopulationSize',Pop_size, ...
    'MaxGenerations', Max_generations, ...
    'FunctionTolerance', 10000);

format long
[Solution_Parameters,Model_Objectives,Termination_Code]=gamultiobj(@Cost_Function_One_Year,Parameters_vars_num,...
    [],[],[],[],lower_bounds,upper_bounds,[],[1,3,4,7,9,10,11,12,13,14],opts);

% When adding new parameters/variables (Things for the model to choose) you
% can select values to be in intergers by plugging in the respective column
% in theo the "[]" after the empty "[]". Currently, variables (1,3,4,7...)
% are set as interger only. Some of these then go on to define an element
% in a data matrix. This is how you 


% Presize Matrix
%Solution_Parameters_Array=zeros(Pop_size,Parameters_vars_num,Sensitivity_iter);
%temp_Model_Objective_Array=zeros(Pop_size,Model_Objectives_num,Sensitivity_iter);
%Termination_Code_Array=zeros(Sensitivity_iter);
Sensitivity_Trial=struct('Solution_Parameters', cell(Sensitivity_iter,1),...
    'Model_Objectives',cell(Sensitivity_iter,1),'Termination_Code',cell(Sensitivity_iter,1),'Diesel_Generator_Power', cell(Sensitivity_iter,1));

%%
% This breaks down the Paramaters and Objectives matrix into more
% legible/workable forms. 
for i=1:Sensitivity_iter
    Sensitivity_Trial(i).Solution_Parameters=Solution_Parameters;
    Sensitivity_Trial(i).Model_Objectives_Day2Day=Model_Objectives(:,((i-1)*2*Model_Objectives_num)+(1:Model_Objectives_num));
    Sensitivity_Trial(i).Model_Objectives_Extreme=Model_Objectives(:,((i-1)*2*Model_Objectives_num)+(Model_Objectives_num+1:2*Model_Objectives_num));
    Sensitivity_Trial(i).Termination_Code=Termination_Code;

end

%% 
% This code allows the model objectives that include cost to be rounded to
% the millions level

for x=1:Sensitivity_iter
    Sensitivity_Trial(x).Model_Objectives_Extreme_new(:,[1,2,7,8,9])=Sensitivity_Trial(x).Model_Objectives_Extreme(:,[1,2,7,8,9])/10^6;
    Sensitivity_Trial(x).Model_Objectives_Day2Day_new(:,[1,2,7,8,9])=Sensitivity_Trial(x).Model_Objectives_Day2Day(:,[1,2,7,8,9])/10^6;
end
%%
save("WP_energy_model_data_Trial_100S_5G_100T.mat", "Sensitivity_Trial","Solution_Parameters", "Model_Objectives")

toc

% Sensitivity_Trial(i).Model_Objectives Description
% 
% Model_Objectives (The functions/things you're optimizing for [minimizing])
% Output 1: Annual Cost (Mean)                              [$ mil]
% Output 2: Annual Cost (STD)                               [$ mil]
% Output 3: Energy Critical Load Shed (Mean)                [MWh]
% Output 4: Energy Critical Load Shed (STD)                 [MWh]
% Output 5: Critical Load Failure Time Steps (Mean)         [Steps]
% Output 6: Critical Load Failure Time Steps (STD)          [Steps]
% Output 7: Annual Externality Cost (Mean)                  [$ mil]
% Output 8: Annual Externality Cost (STD)                   [$ mil]










