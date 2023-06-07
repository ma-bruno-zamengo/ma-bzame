select AddGeometryColumn ('bzame','census_2011','geom_centroid',4326,'POINT',2, false);

update bzame.census_2011 set geom_centroid = st_makevalid(st_centroid(geom));

CREATE INDEX census_2011_geom_idx
  ON census_2011
  USING GIST (geom_centroid); 
 

CREATE INDEX municipality_2022_geom_idx
  ON bzame.municipality_2022
  USING GIST (geom); 

create table bzame.census_2022 as 
select c.fid as fid_sez2011, c.ogc_fid ogc_fid_sez2011, c.sez2011, c.sez, c.ace
		, m.cod_rip, m.cod_reg, m.cod_prov, m.pro_com
		, m.geom geom_pro_com, c.geom geom_sez2011
		from bzame.census_2011 c 
	join bzame.municipality_2022 m on ST_Contains(m.geom, c.geom_centroid)
;



---- CHK: no duplicates ?
select fid_sez2011, count(*)
from bzame.census_2022
group by 1
having count(*)>1
order by 2 desc


create table bzame.ace_2022 as 
select 
		  to_char(
		  	(cod_reg::int * 1e9 + pro_com::int * 1e3 + ace::int)
		  	, 'FM00000000000'
	  	) as cod_istat
		, cod_rip, cod_reg, cod_prov as cod_pro, pro_com, ace
		, to_char(
			pro_com::int * 1e3 + ace::int 
			, 'FM000000000'
		) procom_ace 
		, ST_MakeValid(ST_Union(geom_sez2011)) geom
from bzame.census_2011_municip_2022
group by 1, 2, 3, 4, 5, 6, 7
;



select AddGeometryColumn ('bzame','ace_2022','geom_tmp',4326,'MULTIPOLYGON',2, false);
select AddGeometryColumn ('bzame','census_2011','geom_centroid',4326,'POINT',2, false);