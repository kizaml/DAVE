
clear
close
clc

% West Energy Resilience
% XE485 24-1 & 24-2
% Contact -> 215-528-7614 (David Sang)


%%

NSRDB_1998=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_1998.csv")
NSRDB_1999=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_1999.csv")
NSRDB_2000=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2000.csv")
NSRDB_2001=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2001.csv")
NSRDB_2002=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2002.csv")
NSRDB_2003=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2003.csv")
NSRDB_2004=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2004.csv")
NSRDB_2005=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2005.csv")
NSRDB_2006=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2006.csv")
NSRDB_2007=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2007.csv")
NSRDB_2008=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2008.csv")
NSRDB_2009=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2009.csv")
NSRDB_2010=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2010.csv")
NSRDB_2011=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2011.csv")
NSRDB_2012=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2012.csv")
NSRDB_2013=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2013.csv")
NSRDB_2014=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2014.csv")
NSRDB_2015=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2015.csv")
NSRDB_2016=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2016.csv")
NSRDB_2017=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2017.csv")
NSRDB_2018=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2018.csv")
NSRDB_2019=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2019.csv")
NSRDB_2020=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2020.csv")
NSRDB_2021=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2021.csv")
NSRDB_2022=importdata("Data\NREL_NSRDB_30min\1246511_41.41_-73.94_2022.csv")

%Creating an index matrix to help concatenate the matrices 
index=[];
for i=1998:1:2022
    index=[index,"NSRDB_"+(i)+".data"];
end

%Using a for loop to concatenate the frames into 1 array
NSRDB_1998_2022_30min_data=[];
for i=1:25
    NSRDB_1998_2022_30min_data=cat(3,NSRDB_1998_2022_30min_data,eval(index{i}));
end
%%
NSRDB_1998_2022_30min_data_mean=mean(NSRDB_1998_2022_30min_data,3);
NSRDB_1998_2022_30min_data=cat(3,NSRDB_1998_2022_30min_data,NSRDB_1998_2022_30min_data_mean);
save("NSRDB_1998_2022_30min_data","NSRDB_1998_2022_30min_data","NSRDB_1998_2022_30min_data_mean")

