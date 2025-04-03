

% West Energy Resilience
% XE485 24-1 & 24-2
% Contact -> 215-528-7614 (David Sang)



function [Grid_failure_flag_mat, Solar_failure_flag_mat, Wind_failure_flag_mat]=Failure_simulation(Stochastic_Iterations,...
    Panel_size,Turbines,Solar_hazard_rate,Solar_Failure_Avg_Length,Solar_Failure_Length_STD,...
    Wind_hazard_rate,Wind_Failure_Avg_Length,Wind_Failure_Length_STD,Grid_hazard_rate,Grid_Failure_Avg_Length,...
    Grid_Failure_Length_STD);


%%%%%%%%%%%%%%%% DEBUG INPUTS &&&%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Stochastic_Iterations=100;
% Data has 100 stochastic iterations so keep stochastic iterations at 100
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%Solar Failure
% Failure of Solar Panel 
% 5/10000 fail in a year

% Assume the Solar system fails once every 21 years. 
% The chance it fails in 15 minutes can be found using the following
% formula
%Solar_hazard_rate=1/(21*365*24*4); % 1 failure out of 21 years 
% (IN ASSUMPTIONS) 
Solar_15min_Failure_Probability=1-exp(-(Solar_hazard_rate));

% After it fails we need to determine how long it fails for
% Assunming the Average length of failure is 1.5 days with a standard
% deviation of 8 hours 

%Solar_Failure_Avg_Length=1.5*24*4;  % 15 min sessions [=1.5 days]
%Solar_Failure_Length_STD=8*4;      % 15 min sessions [=8 hrs]
% (IN ASSUMPTIONS)
% 1 std means 68% of solar failures are resolved between 
% [1 days 4hrs and 1 day 20hrs]

Solar_failure_flag_mat=zeros(35038,1,Stochastic_Iterations);


for x =1:Stochastic_Iterations
    % With the failure probability we can use rand to simulate when it fails
    Solar_Failure_Initiation=rand([35038,1])<Solar_15min_Failure_Probability;
    
    % Set this up to flag the matrix if failures occur
    Solar_Failure_Initiation_Idx=find(Solar_Failure_Initiation);
    Solar_Failure_Length=round(repmat(Solar_Failure_Avg_Length,length(Solar_Failure_Initiation_Idx),1)+ rand(length(Solar_Failure_Initiation_Idx),1)*Solar_Failure_Length_STD);
    
        for i = 1:length(Solar_Failure_Initiation_Idx)
            Solar_Failure_Initiation(Solar_Failure_Initiation_Idx(i):(Solar_Failure_Initiation_Idx(i)+Solar_Failure_Length(i)))=1;
        end
    
    Solar_failure_flag_mat(:,1,x)=Solar_Failure_Initiation(1:35038);
end
%% Wind System Failure
% Assume a wind Turbine fails once every 1 years. 
% NREL Wind Turbine Reliability Review
% https://www.nrel.gov/docs/fy13osti/59111.pdf (PDF 14)
% The chance it fails in 15 minutes can be found using the following
% formula

%Wind_hazard_rate=1/(1*170*24*4); % 1 failure out of 170 days
% (IN ASSUMPTIONS)
Wind_15min_Failure_Probability=1-exp(-(Wind_hazard_rate));

% After it fails we need to determine how long it fails for
% Assunming the Average length of failure is 4 days with a standard
% deviation of 1 day
%Wind_Failure_Avg_Length=4*24*4;  % 15 min sessions [=4 days]
%Wind_Failure_Length_STD=24*4;      % 15 min sessions [=1 day]
% (IN ASSUMPTIONS)

Wind_failure_flag_mat=zeros(35038,1,Stochastic_Iterations);

for x =1:Stochastic_Iterations
    % With the failure probability we can use rand to simulate when it fails
    Wind_Failure_Initiation=rand([35038,1])<Wind_15min_Failure_Probability;
    
    % Set this up to flag the matrix if failures occur
    Wind_Failure_Initiation_Idx=find(Wind_Failure_Initiation);
    Wind_Failure_Length=round(repmat(Wind_Failure_Avg_Length,length(Wind_Failure_Initiation_Idx),1)+ rand(length(Wind_Failure_Initiation_Idx),1)*Wind_Failure_Length_STD);
    
    for i = 1:length(Wind_Failure_Initiation_Idx)
        Wind_Failure_Initiation(Wind_Failure_Initiation_Idx(i):(Wind_Failure_Initiation_Idx(i)+Wind_Failure_Length(i)))=1;
    end
    
    Wind_failure_flag_mat(:,1,x)=Wind_Failure_Initiation(1:35038);
end
%% Grid Electricity Failure
% Failure of Grid Electricity 
% For Grid we will Create assumptions to fight four types of events
% We will create yearly failures, Decade level events,
% Half century level events, and a Cyber attack event


%Grid_hazard_rate=[1/(1*365*24*4), 1/(10*365*24*4), 1/(50*365*24*4), 1/(3*365*24*4)];
% 1 failure/1 years , 1 fail/10 years, 1 fail/50 years, Cyber attack (1/3yr)
% (IN ASSUMPTIONS)

Grid_15min_Failure_Probability=1-exp(-(Grid_hazard_rate));

% After it fails we need to determine how long it fails for
% Event                 Avg Length      STD
% Annual                1 days          0.5 days
% Decade                4 days          1 days
% Half-Cent             7 days          1.5 days
% Cyber Attack          14 days         1 days

%Grid_Failure_Avg_Length=24*4*[1,4,7,14]; 
% 15 min sessions [= 1, 4, 7, 14 days]
% (IN ASSUMPTIONS)

%Grid_Failure_Length_STD=24*4*[0.5,1,1.5,1];   
% 15 min sessions [= 0.5, 1, 1.5, 1 days]
% (IN ASSUMPTIONS)

Grid_failure_flag_mat=zeros(35038,1,Stochastic_Iterations);

for x =1:Stochastic_Iterations
    % With the failure probability we can use rand to simulate when it fails
    Grid_Failure_Initiation=rand([35038,size(Grid_hazard_rate,2)])<Grid_15min_Failure_Probability;
  
    % Set this up to flag the matrix if failures occur
    [Grid_Failure_Initiation_Idx_row,Grid_Failure_Initiation_Idx_col]=find(Grid_Failure_Initiation);
    
    Grid_Failure_Length=round(repmat(Grid_Failure_Avg_Length,length(Grid_Failure_Initiation_Idx_row),1)+ rand(length(Grid_Failure_Initiation_Idx_row),1)*Grid_Failure_Length_STD);
    
    for i = 1:length(Grid_Failure_Initiation_Idx_row)
        Grid_Failure_Initiation(Grid_Failure_Initiation_Idx_row(i):(Grid_Failure_Initiation_Idx_row(i)+Grid_Failure_Length(i,Grid_Failure_Initiation_Idx_col(i))),Grid_Failure_Initiation_Idx_col(i))=1;
    end
    
    Grid_failure_flag_mat(:,1,x)=sum(Grid_Failure_Initiation(1:35038,:),2)>0;
    %Grid_failure_flag_mat_times(x)=sum(Grid_failure_flag_mat(:,1,x))
end
end