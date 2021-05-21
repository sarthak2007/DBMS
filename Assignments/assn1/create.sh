#!/bin/bash

# Creating csv files to create sql tables from the given csv files
tail -n +6 multilingual-age.csv | awk -F "," '{OFS=",";print $1,$4,$5,$6,$7,$8,$9,$10,$11}'> age.csv
tail -n +6 multilingual-education.csv | awk -F "," '{OFS=",";print $1,$4,$5,$6,$7,$8,$9,$10,$11}'> education.csv
tail -n +8 age-education.csv | awk -F "," '{OFS=",";print $2,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' > total.csv
tail -n +8 age-education.csv | awk -F "," '{OFS=",";print $2,$5,$6,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44,$45}' > literate.csv
tail -n +6 multilingual-age.csv | awk -F "," '{OFS=",";print $1,$2,$3}' | awk 'NR%30==0'> state.csv

#  Create a table for mapping of different age groups in different csv files
touch age_group.csv
echo "All ages,NULL,NULL
0-6,3,5-9
7,7,5-9
8,8,5-9
9,9,5-9
10,10,10-14
11,11,10-14
12,12,10-14
13,13,10-14
14,14,10-14
15,15,15-19
16,16,15-19
17,17,15-19
18,18,15-19
19,19,15-19
20-24,22,20-24
25-29,27,25-29
30-34,32,30-49
35-39,37,30-49
40-44,42,30-49
45-49,47,30-49
50-54,52,50-69
55-59,57,50-69
60-64,62,50-69
65-69,67,50-69
70-74,72,70+
75-79,77,70+
80+,85,70+
Age not stated,NULL,Age not stated" > age_group.csv

# remove database if already exists
if [ -e population.db ];
then 
	rm population.db
fi

# queries to create the database
sqlite3 population.db <<EOF   
create table age (State_code TEXT,Rural_Urban TEXT,Age TEXT,Bilingual INTEGER, Bilingual_Male INTEGER, Bilingual_Female INTEGER,Trilingual INTEGER, Trilingual_Male INTEGER, Trilingual_Female INTEGER);
create table education (State_code TEXT,Rural_Urban TEXT,Education TEXT,Bilingual INTEGER, Bilingual_Male INTEGER, Bilingual_Female INTEGER,Trilingual INTEGER, Trilingual_Male INTEGER, Trilingual_Female INTEGER);
create table age_education_total (State_code TEXT,Rural_Urban TEXT,Age TEXT,Total INTEGER,Total_Male INTEGER,Total_Female INTEGER,Illiterate INTEGER,Illiterate_Male INTEGER,Illiterate_Female INTEGER,Literate INTEGER,Literate_Male INTEGER,Literate_Female INTEGER);
create table age_education_literate (State_code TEXT, Rural_Urban TEXT,Age TEXT,Literate_WO INTEGER,Literate_WO_Male INTEGER,Literate_WO_Female INTEGER,Below_Primary INTEGER,Below_Primary_Male INTEGER,Below_Primary_Female INTEGER,Primary_Total INTEGER,Primary_Male INTEGER,Primary_Female INTEGER,Middle INTEGER,Middle_Male INTEGER,Middle_Female INTEGER,Matric INTEGER,Matric_Male INTEGER,Matric_Female INTEGER,Higher_Secondary INTEGER,Higher_Secondary_Male INTEGER,Higher_Secondary_Female INTEGER,Non_technical INTEGER,Non_technical_Male INTEGER,Non_technical_Female INTEGER,Technical INTEGER,Technical_Male INTEGER,Technical_Female INTEGER,Graduate INTEGER,Graduate_Male INTEGER,Graduate_Female INTEGER,Unclassified INTEGER,Unclassified_Male INTEGER,Unclassified_Female INTEGER);
create table state(State_code TEXT PRIMARY KEY,District_code TEXT,Area_Name TEXT);
create table age_group(Original TEXT, Average INTEGER, Duplicate TEXT);
.mode csv
.import age.csv age
.import education.csv education
.import total.csv age_education_total
.import literate.csv age_education_literate
.import state.csv state
.import age_group.csv age_group

EOF

# remove the created csv files
rm age.csv education.csv total.csv literate.csv state.csv age_group.csv