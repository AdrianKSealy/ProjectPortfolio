-- My stakeholder's first question is to determine the change in the number of terrorist activities over time
-- and identify any regions where this trend deviates from the global average
Select *
From GTD_Data

-- Finding the change across different regions and over time
Select iyear, region_txt, Count(eventid) as Number_of_attacks
From GTD_Data
Group by iyear, region_txt
order by iyear

Select iyear,region_txt, Number_of_attacks, AVG(Number_of_attacks) as Overall_AVG
From
(Select iyear, region_txt,Count(eventid) as Number_of_attacks 
From GTD_Data
Group by iyear, region_txt
) as Attacks_total
order by iyear

-- My stakeholder's second question is whether there is a correlation between the number of incidents and the number of casualties
-- and whether there are any irregularities or outliers in the data

Select iyear, Count(eventid) as Number_of_attacks , Sum(nkill) as casualties
From GTD_Data
Group by iyear
order by iyear

Select iyear, region_txt,Count(eventid) as Number_of_attacks , Sum(nkill) as Casualties
From GTD_Data
Group by iyear, region_txt
order by iyear

-- My stakeholder's third question is showing the most common methods of terrorist attacks
-- and whether there are regional differences

-- General common methods of attacks
Select attacktype1_txt, Count(attacktype1_txt) as Count_of_attacktype, Sum(nkill) as Sum_of_Casualties
From GTD_Data
Group by attacktype1_txt
Order by Count_of_attacktype desc
-- By region
Select region_txt, attacktype1_txt, Count(attacktype1_txt) as Count_of_attacktype, Sum(nkill) as Sum_of_Casualties
From GTD_Data
Group by region_txt,attacktype1_txt
Order by region_txt desc
-- By time
Select iyear, attacktype1_txt, Count(attacktype1_txt) as Count_of_attacktype, Sum(nkill) as Sum_of_Casualties
From GTD_Data
Group by iyear,attacktype1_txt
Order by iyear 

 -- Lastly, my stakeholder has requested a visualization of the geographic distribution of terrorist attacks
 --  ploting them on a map 
 
 Select eventid, iyear,imonth,iday,region_txt,country,country_txt,provstate,city,location,latitude,longitude,attacktype1_txt,gname,success,nkill
 From GTD_Data

