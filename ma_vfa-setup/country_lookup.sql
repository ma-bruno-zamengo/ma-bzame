CREATE TABLE lookup.country (
      reference_year                numeric(4,0)
	, alpha_2_code                  char(2)
	, alpha_3_code                  char(3)
	, country_name_en               varchar(100)
	, country_name_it               varchar(100)
	, iso_3166_1                    char(3)
	, iso_3166_2                    char(13)
    , continent_alpha_2_code        char(2)
    , continent_name_en             varchar(15)
    , continent_name_it             varchar(15)
	, un_region_code                char(3)
	, un_region                     varchar(10)
	, un_sub_region_code            char(5)
	, un_sub_region                 varchar(50)
	, un_intermediate_region_code   char(5)
	, un_intermediate_region        varchar(20)
);



CREATE TABLE tmp.country_united_nation (
	 alpha_2_code                  char(2)
	, alpha_3_code                  char(3)
	, un_region_code                char(3)
	, un_region                     varchar(10)
	, un_sub_region_code            char(5)
	, un_sub_region                 varchar(50)
	, un_intermediate_region_code   char(5)
	, un_intermediate_region        varchar(20)
);



comment on table lookup.country is E'Country official registry from ISO-3166-1 standard
Data has been collected from:
  - https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv
  - https://unstats.un.org/unsd/methodology/m49/overview/';



case region_code	
    when 142	then 'AS'
    when 150	then 'EU'
    when 2	    then 'AF'
    when 19	    then case un_sub_region_code when 21 then 'NA' when 419 then 'SA'end
    when 9	    then 'OC'
end continent_alpha_2_code

case region_code	
    when 142	then 'Asia'
    when 150	then 'Europe'
    when 2	    then 'Africa'
    when 19	    then case un_sub_region_code when 21 then 'North America' when 419 then 'South America'end
    when 9	    then 'Oceania'
end continent_name_en

case region_code	
    when 142	then 'Asia'
    when 150	then 'Europa'
    when 2	    then 'Africa'
    when 19	    then case un_sub_region_codepo when 21 then 'Nord America' when 419 then 'Sud America'end
    when 9	    then 'Oceania'
end continent_name_it