#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Enter only one argument"
    exit -1
fi

if [ ! -e population.db ];
then 
	"Database file does not exist"
	exit -1
fi

if [ $1 == 1 ]; then
	echo "State_Code|Area_Name|Percentage"
	sqlite3 population.db "select S.State_code, S.Area_Name, 100.0*(A.Trilingual*1.0/E.Total) as Percentage
	from state as S, age as A,age_education_total as E
	where S.State_code=A.State_code and A.State_code=E.State_code and A.State_code!='00' and A.Rural_Urban='Total' and A.Age='Total' and E.Rural_Urban='Total' and E.Age='All ages'
	order by Percentage
	;" 

elif [ $1 == 2 ]; then
	echo "Age_group|Percent_multi_lingual"
	sqlite3 population.db "select Age,max(100.0*(Multi*1.0/Population)) from(
	select A.Age as Age,A.Bilingual as Multi,sum(E.Total) as Population
	from age as A, age_education_total as E, age_group as G
	where A.State_code=E.State_code and A.State_code='00' and A.Rural_Urban='Total' and E.Rural_Urban='Total' and A.Age!='Total' and E.Age=G.Original and A.Age=G.Duplicate
	group by A.Age,A.Bilingual,A.Trilingual)
	;"

elif [ $1 == 3 ]; then
	echo "Age_group|Gender_ratio"
	sqlite3 population.db "select Age, Max(Max(Total_Male*1.0/Total_Female, Total_Female*1.0/Total_Male))
	from age_education_total
	where State_code='00' and Rural_Urban='Total' and Age != 'All ages'
	;"

elif [ $1 == 4 ]; then
	echo "People_Speaking_Only_One_Language"
	sqlite3 population.db "select E.Total-A.Bilingual
	from state as S, age as A,age_education_total as E
	where S.State_code=A.State_code and A.State_code=E.State_code and A.State_code='00' and A.Rural_Urban='Total' and A.Age='Total' and E.Rural_Urban='Total' and E.Age='All ages'
	;"

elif [ $1 == 5 ]; then
	echo "State|Average_age"
	sqlite3 population.db "select State, Max(Average) from( 
	select S.Area_Name as State,  sum(A.Average*E.Total)*1.0/sum(E.Total) as Average 
	from state as S, age_education_total as E, age_group as A
	where S.State_code=E.State_code and E.Age=A.Original and S.State_code!='00' and E.Rural_Urban='Total' and E.Age!='All ages' and E.Age!='Age not stated'
	group by S.Area_Name)
	;" 

else
	echo "Enter query number in the range 1-5"
	exit -1
fi