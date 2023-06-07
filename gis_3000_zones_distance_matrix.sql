-- +----------------------------------------------------------------+
-- | > Create 800 zones distance matrix                             |
-- | >>  Distance is expressed in Km                                |
-- | >>  Distance is computed between O centroid and D centroid     |
-- +----------------------------------------------------------------+
/*
 * Try to add PK
 */ 
alter table gis.c24p11_ferservizi_3000_zones_geography
	add constraint c24p11_ferservizi_3000_zones_geography_pk primary key(cod_3000_zones);
/*
SQL Error [23505]: ERROR: could not create unique index "c24p11_ferservizi_3000_zones_geography_pk"
  Detail: Key (cod_3000_zones)=(10195511000) is duplicated.
 */
select cod_3000_zones 
from gis.c24p11_ferservizi_3000_zones_geography
group by 1
having count(*) > 1
;
/*
cod_3000_zones|
--------------+
   10195511000|
   10193261002|
    1001061000|
 */

select cod_3000_zones, centr_zone, origin, st_makevalid(geom_3000_zones) geom_3000_zones
from gis.c24p11_ferservizi_3000_zones_geography
where cod_3000_zones in (
   10195511000,
   10193261002,
    1001061000
)
;


/*
 * Create new table to store merged geometries with no duplicate IDs
 */
drop table if exists gis.italy_3000_zones;
create table gis.italy_3000_zones (
	  zone_id       numeric(12)
	, centr_zone	numeric(9) -- is it really needed? let's check with Marco 
	, datasource    varchar(12)    

	, CONSTRAINT italy_3000_zones_pk primary key(zone_id)
);

-- add geometry column with function: the geometry column is thus added to the PostGIS "geometries" registry
-- it also checks new geometries type (MULTIPOLYGON only will be accepeted) and SRID (WGS84 4326 only will be accepted)
/* AddGeometryColumn(varchar catalog_name, varchar schema_name, varchar table_name, varchar column_name, integer srid, varchar type, integer dimension, boolean use_typmod=true);*/
SELECT AddGeometryColumn ('gis', 'italy_3000_zones', 'geom_3000_zones', 4326, 'MULTIPOLYGON', 2, false);

comment on table gis.italy_3000_zones is 'Italy "standard" 3000 zones from Ferservizi projects'

/*
 * Fill table:
 * 1. With non-duplicated records
 * 2. With geometry-merged and deduplicated records
 */ 
insert into gis.italy_3000_zones(zone_id, centr_zone, datasource, geom_3000_zones)
select cod_3000_zones, centr_zone, origin, st_makevalid(geom_3000_zones) geom_3000_zones
from gis.c24p11_ferservizi_3000_zones_geography
where cod_3000_zones not in (
   10195511000,
   10193261002,
    1001061000
)
	union all 
select cod_3000_zones, 10193261 centr_zone, 'CESPI' origin
		, st_makevalid(
			St_SetSrid(
				ST_Multi(st_union(geom_3000_zones))
				, 4326
			)
		) geom_3000_zones 
from gis.c24p11_ferservizi_3000_zones_geography
where cod_3000_zones = 10193261002
group by cod_3000_zones

	union all
select cod_3000_zones, 1001061 centr_zone, 'CESPI' origin
	, st_makevalid(
		St_SetSrid(
			ST_Multi(st_union(geom_3000_zones))
			, 4326
		)
	) geom_3000_zones 
from gis.c24p11_ferservizi_3000_zones_geography
where cod_3000_zones = 1001061000
group by cod_3000_zones
	union all 
select cod_3000_zones, 10195511 centr_zone, 'CESPI' origin
		, st_makevalid(
			St_SetSrid(
				ST_MakePolygon( -- rebuild polygon without holes
					St_ExteriorRing(st_union(geom_3000_zones)) -- keep external border only
				)
				, 4326 -- SRID
			)
		) geom_3000_zones 
from gis.c24p11_ferservizi_3000_zones_geography
where cod_3000_zones = 10195511000 
group by cod_3000_zones
--order by 1



/*
 * Create distance matrix data table 
 */
drop table if exists gis.italy_3000_zones_distance_matrix;
create table gis.italy_3000_zones_distance_matrix (
	  origin        numeric(12)
	, destination   numeric(12)
	, distance_km   numeric(8,3)
	
	, CONSTRAINT italy_3000_zones_distance_matrix_pk primary key(origin, destination)
	, CONSTRAINT italy_3000_zones_distance_matrix_fk_origin FOREIGN KEY (origin) REFERENCES gis.italy_3000_zones(zone_id)
	, CONSTRAINT italy_3000_zones_distance_matrix_fk_destination FOREIGN KEY (destination) REFERENCES gis.italy_3000_zones(zone_id)
);

comment on table gis.italy_3000_zones_distance_matrix is 'Italy 3000 zones distance matrix in Km';



/*
 * Fill table with computed O/D distances
 *
 * >> convert geometries to geograpies: distance will be thus returned in meters on spheric distance rather than euclidean one
 */ 
insert into gis.italy_3000_zones_distance_matrix(origin, destination, distance_km)
select origin, destination
		, st_distance(o_geo, d_geo) / 1e3 distance_km
from (
	select zone_id as origin 
			, st_centroid(geom_3000_zones)::geography as o_geo
	from gis.italy_3000_zones
) o
	join (
		select zone_id as destination 
				, st_centroid(geom_3000_zones)::geography as d_geo
		from gis.italy_3000_zones
	) d on origin != destination
;