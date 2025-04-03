close all
clear all
clc

%%
% West Energy Resilience
% XE485 24-1 & 24-2
% Contact -> 215-528-7614 (David Sang)

% This data was taken from Utility bill data 
load('Data_for_Cost_Function_One_Year\Natural_Gas_Cost_Data.mat')
load('Data_for_Cost_Function_One_Year\Natural_Gas_Use_Data.mat')

Most_Recent_Cost_of_Natural_Gas_JAN_to_DEC_Monthly=[Natural_Gas_2023(4:6);Natural_Gas_2022(7:12);Natural_Gas_2023(1:3)];
% $
Most_Recent_Natural_Gas_Usage_JAN_to_DEC_Monthly=[Natural_Gas_Use_2023(4:6);Natural_Gas_Use_2022(7:12);Natural_Gas_Use_2023(1:3)];
% kcf

save("Data_for_Cost_Function_One_Year\Most_Recent_Cost_of_Natural_Gas_JAN_to_DEC_Monthly.mat",'Most_Recent_Cost_of_Natural_Gas_JAN_to_DEC_Monthly')
save("Data_for_Cost_Function_One_Year\Most_Recent_Natural_Gas_Usage_JAN_to_DEC_Monthly.mat",'Most_Recent_Natural_Gas_Usage_JAN_to_DEC_Monthly')