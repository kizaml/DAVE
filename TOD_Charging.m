



function [Percentile_Delimeter_Cost,Percentile_Delimeter_Carbon]=TOD_Charging(temp_Days_to_consider,Grid_Carbon_TOD,Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC,Grid_Carbon_Selector,Cost_Limiter,Carbon_Limiter)


% Determine when the battery can charge on the grid 
    % Look at the last 10 days and determine if the current Carbon and Cost are below the average
    % moving average to determine when you can charge 

    %temp_Days_to_consider=10; ASSUMPTIONS
    % Determine how large the window should be

    Percentile_Delimeter_Carbon=zeros(length(Grid_Carbon_TOD(:,:,1)),1);
    % Presize the matrix

    for i=temp_Days_to_consider*24*4+1:length(Grid_Carbon_TOD)
        Percentile_Delimeter_Carbon(i)=prctile(Grid_Carbon_TOD(i-temp_Days_to_consider*24*4:i,2,Grid_Carbon_Selector),Carbon_Limiter(1));
    end
    % use a for loop to calculate the threshold value according to a
    % percentile. If the cost is below this threshold value you can charge

    % Repeat for cost
    Percentile_Delimeter_Cost=zeros(length(Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC),1);
    for i=temp_Days_to_consider*24*4+1:length(Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC)
        Percentile_Delimeter_Cost(i)=prctile(Compiled_Most_Recent_Cost_Of_Grid_Electritcy_JAN_DEC(i-temp_Days_to_consider*24*4:i),Cost_Limiter(1));
    end


end




