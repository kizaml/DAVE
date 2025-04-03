


function [Solar_Power_Generated_15min_JAN_to_DEC,Solar_Rated_Power]=Solar(Data_Selector_Solar,Panel_size,Panel_Efficiency)

% clc
% clear
% close all 

% West Energy Resilience
% XE485 24-1 & 24-2
% Contact -> 215-528-7614 (David Sang)

load("Data_for_Solar_Function\NSRDB_1998_2022_30min_data_New.mat")

%DEBUGGING UNCOMMENT THIS TO RUN FUNCTION ALONE
%load("Model_Assumptions.mat")
%Panel_size=1;

%% Solar Energy 

% -------------- Solar Data munging ------------------
% Solar Data was taken from NSRDB: National Solar Radiation Database
% https://nsrdb.nrel.gov/data-viewer
% USA & Americas (30, 60min / 4km / 1998-2022)
% All data 
% Data was downloaded as a table
% Column 1: Year
% Column 2: Month
% Column 3: Day
% Column 4: Hour
% Column 5: Minute
% Column 6: Surface Albedo
% Column 7: ClearSky GHI w/m^2
% Column 8: ClearSky DHI w/m^2
% Column 9: Clearsky DNI w/m^2
% Column 10: DHI w/m^2
% Column 11: DNI w/m^2 
% Column 12: GHI w/m^2
% Column 13: Solar Zenith Degrees
% Column 14: Tempurature Degrees C
% Column 15: Wind Speed m/s Elevation = 79m

% xxxxxxxxxxxxxxxxxxx Hard Code xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

%Data_Selecter=Data_Selecter;
%Data_Selector=3; (Uncomment to run function alone)
% 1=1998
% 25=2022
% 26=Average
%
% xxxxxxxxxxxxxxxxxxx Hard Code xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% Solar Altitude
Solar_altitude_angle=90-NSRDB_1998_2022_30min_data_New(:,13,Data_Selector_Solar);


% Day Number
Day_number=[datetime(2022,1,1):minutes(30): datetime(2023,1,1)-minutes(30)]';
Day_number=round(daysact(datetime(2021,12,31),Day_number),0);

% Solar Declination 
Solar_declanation=23.45* sind( 360* (284 + Day_number ) /365 );
% -------------- Solar Data munging ------------------

% -------------- Solar Calculations ------------------
% Solar Time

% Standard longitude ------ [PARAMETER]---------
l_st=75;            % degrees W, 75 for EST

% Local Longitude ------ [PARAMETER]---------
l_loc=74.04;      % degrees W, 74.04 for West Point

% Latitude ------ [PARAMETER]---------
Latitude=41.37; % degrees N, 41.37 for West Point 

% Collector Azimuth ------ [PARAMETER]---------
Collector_azimuth=0; % degrees, set for no tracking

% Collector Tilt ------ [PARAMETER]---------
Collector_tilt= 41; % degrees, typically lattitude

% xxxxxxxxxxxxxxxxxxx Hard Code xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%--------- Panels 
% Panel_Efficiency = 0.3; (IN ASSUMPTIONS FILE)
%Panel_size=170000; % m^2 (10 football fields) (Uncomment to run function alone)
% xxxxxxxxxxxxxxxxxxx Hard Code xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


% Equation of time
B=360*(Day_number-81)/364;
ET=9.87*sind(2*B)-7.53*cosd(B)-1.5*sind(B);     % minutes

% Solar Time
local_time=[datetime(2022,1,1):minutes(30): datetime(2023,1,1)-minutes(30)]';
Solar_time=local_time+minutes((ET+(l_st-l_loc)*4));   

% Hour Angle 
Solar_hour_angle=15*(hour(Solar_time)+minute(Solar_time)/60-12);

% Theory Altitude Angle
Solar_altitude_angle_math=asind( sind(Latitude).*sind(Solar_declanation) + cosd(Latitude).*cosd(Solar_declanation).*cosd(Solar_hour_angle));
% It's very similar to the one given by NREL

% Solar Azimuth Angle
Solar_azimuth_angle=asind( (cosd(Solar_declanation).*sind(Solar_hour_angle))./cosd(Solar_altitude_angle));

% Solar Incendence 
Solar_incidence_angle=acosd( sind(Latitude).*sind(Solar_declanation).*cosd(Collector_tilt)-...
    cosd(Latitude).*sind(Solar_declanation).*sind(Collector_tilt).*cosd(Collector_azimuth)+...
    cosd(Latitude).*cosd(Solar_declanation).*cosd(Solar_hour_angle).*cosd(Collector_tilt)+...
    sind(Latitude).*cosd(Solar_declanation).*cosd(Solar_hour_angle).*sind(Collector_tilt).*cosd(Collector_azimuth)+...
    cosd(Solar_declanation).*sind(Solar_hour_angle).*sind(Collector_tilt).*sind(Collector_azimuth));
%https://arka360.com/ros/solar-angles/

% Flag Matrix for when Solar_Altitude > 0 and Incedence Angle <90
Flag1=Solar_altitude_angle>0;
Flag2=Solar_incidence_angle<90;
Flag2_1=Solar_incidence_angle>0;
Flag=Flag1.*Flag2.*Flag2_1;
% 
% % Solar Altitude Plot 
% figure(1)
% hold on
% plot(Solar_altitude_angle_math(1:50))
% plot(Solar_altitude_angle(1:50))
% legend("Math", "NSRDB")
% Solar_altitude_angle_math(Solar_altitude_angle_math<1)=1;
% title("Calculated Solar Altitude vs Measured")

%%
% Tilt Factors
%Tilt_factor_beam=cosd((Solar_incidence_angle))./sind(Solar_altitude_angle_math);
Tilt_factor_beam=cosd((Solar_incidence_angle));
%Tilt_factor_diffuse=cos(Collector_tilt*pi()/180/2)^2;

% Isotropic Model
% https://www.nrel.gov/docs/fy15osti/64102.pdf (PDF 27)
Tilt_factor_diffuse_ISO=(1+cosd(Collector_tilt))/2;

% HDKR Model
Zenith_ang=NSRDB_1998_2022_30min_data_New(:,13,Data_Selector_Solar);
Ibh=NSRDB_1998_2022_30min_data_New(:,11,Data_Selector_Solar).*cosd(Zenith_ang);
Igh=Ibh+NSRDB_1998_2022_30min_data_New(:,10,Data_Selector_Solar);
Rb=cosd((Solar_incidence_angle))./sind(Solar_altitude_angle_math);
G=(1367)*(1+0.033*cos(pi()/180*360*Day_number/365));
H=G.*cosd(Zenith_ang);
%H(Zenith_ang==0)=G;
H(Zenith_ang<0)=0;
H(Zenith_ang>90)=0;
Ai=Ibh./H;
f=sqrt(Ibh./Igh);
s=sind(Collector_tilt/2)^3;
cir=NSRDB_1998_2022_30min_data_New(:,10,Data_Selector_Solar).*Ai.*Rb;
iso=NSRDB_1998_2022_30min_data_New(:,10,Data_Selector_Solar).*(1-Ai).*(1+cosd(Solar_incidence_angle))/2;
isohar=iso.*(1+f.*s);
I_diffuse_HDKR=isohar+cir;

% close all
% figure(3)
% hold on
% plot(Solar_incidence_angle(1*24*4:1.5*24*4).*Flag(1*24*4:1.5*24*4))
% plot(Solar_altitude_angle_math(1*24*4:1.5*24*4).*Flag(1*24*4:1.5*24*4))
% plot(NSRDB_1998_2022_30min_data((7*24*4:7.5*24*4),10,Data_Selector_Solar))
% %plot(cos(Solar_incidence_angle(1*24*4:1.5*24*4)*pi()/180).*Flag(1*24*4:1.5*24*4))
% %plot(sin(Solar_altitude_angle_math(1*24*4:1.5*24*4)*pi()/180).*Flag(1*24*4:1.5*24*4))
% % plot(Tilt_factor_beam(1*24*4:1.5*24*4).*Flag(1*24*4:1.5*24*4),'o')
% %plot(Tilt_factor_beam(1*24*4:1.5*24*4).*Flag(1*24*4:1.5*24*4))
% %plot(Tilt_factor_beam2(1*24*4:1.5*24*4).*Flag(1*24*4:1.5*24*4))
% %legend("sin","cos")
% %plot(Solar_incidence_angle(1*24*4:1.5*24*4))

% Insolation Calculations
% DNI for normal insolation
I_beam=NSRDB_1998_2022_30min_data_New(:,11,Data_Selector_Solar);
I_beam_collector=Tilt_factor_beam.*I_beam.*Flag;



% clc
% close all
% figure (3)
% hold on
% %plot(I_beam(50*24*2:51*24*2),'--')
% %plot(I_beam_collector(1*24*2:2*24*2))
% %plot(Solar_power_generated_mean_temp)
% %plot(I_diffuse_collector(1*24*2:2*24*2))
% plot(Solar_Power_Generated_30min(14*24*2:15*24*2)*10^6)
% %plot(Flag(1*24*2:2*24*2)*200)
% %plot(Flag1(1*24*2:2*24*2)*220)
% %plot(Flag2(1*24*2:2*24*2)*230)
% %plot(Flag3(50*24*2:51*24*2)*240)
% legend('I beam Collector', 'I Diffuse', 'Solar Power Generated')

%%
% DHI for normal insolation
I_diffuse=NSRDB_1998_2022_30min_data_New(:,10,Data_Selector_Solar);
I_diffuse_collector_ISO=Tilt_factor_diffuse_ISO.*I_diffuse;

% I Reflected 
Surface_albedo=NSRDB_1998_2022_30min_data_New(:,6,Data_Selector_Solar);
I_reflected= Surface_albedo.*(I_beam.*cos(Zenith_ang)+I_diffuse).*(1+cos(Collector_tilt))/2;

% Determine the Total Insolation on the panel
Total_I_ISO=I_beam_collector+I_diffuse_collector_ISO+I_reflected; % w/m^2
Total_I_HDKR=I_beam_collector+I_diffuse_HDKR+I_reflected;           % w/m^2


% Replace NaN values with zero
Total_I_ISO(isnan(Total_I_ISO))=0;

temp=Total_I_ISO-Total_I_HDKR;
%sum(temp>0)

%sum(Ai<0)

Total_I_ISO=I_beam_collector+I_diffuse_collector_ISO+I_reflected;

% figure (1)
% hold on 
% plot(Total_I_ISO(1:100))
% plot(I_beam_collector(1:100))
% plot(I_diffuse_collector_ISO(1:100))
% plot(I_reflected(1:100))
% plot(Total_I_HDKR(1:100))
%%
%------------ Solar Outputs -------------------------
% Calculate solar power generated over time
Solar_Power_Generated_30min=Total_I_ISO*Panel_size*Panel_Efficiency/(10^6);% MW
%Solar_Power_Generated_30min=smoothdata(Solar_Power_Generated_30min,1,"movmean",5);
Solar_Energy_Generated_30min=Total_I_ISO*Panel_size*Panel_Efficiency/(2*10^6);% Mwhr 

% Create a solar power generated matrix at 15 minute intervals
Solar_Power_Generated_15min_JAN_to_DEC=repelem(Solar_Power_Generated_30min,2,1);
Solar_Power_Generated_15min_JAN_to_DEC=Solar_Power_Generated_15min_JAN_to_DEC(1:35038);
%% Plots 

temp_I_beam_collector=repelem(I_beam_collector,2,1);
temp_I_diffuse_collector=repelem(I_diffuse_collector_ISO,2,1);

% clc
% figure (1)
% hold on
% plot(temp_I_beam_collector((50*24*4:51*24*4)))
% plot(temp_I_diffuse_collector((50*24*4:51*24*4)))
%plot(Solar_Power_Generated_15min_JAN_to_DEC(3*24*4:4*24*4))
%plot(Solar_incidence_angle((1*24*4:1.5*24*4)).*Flag(1*24*4:1.5*24*4))
%plot(I_beam((1*24*4:2*24*4)))
%plot(Tilt_factor_beam((1*24*4:1.5*24*4)).*Flag(1*24*4:1.5*24*4))
% 
% legend("I Beam","I Diffuse","Solar Power")

%Solar_Power_Generated_15min_JAN_to_DEC=smooth(1:35038,Solar_Power_Generated_15min_JAN_to_DEC(1:35038,1),2/35038,'rloess');

%%
% Total Rated power of the System 
Solar_Rated_Power=Panel_Efficiency*Panel_size/1000; % MW


end



