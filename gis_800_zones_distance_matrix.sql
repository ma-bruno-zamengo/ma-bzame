-- +----------------------------------------------------------------+
-- | > Create 800 zones distance matrix                             |
-- | >>  Distance is expressed in Km                                |
-- | >>  Distance is computed between O centroid and D centroid     |
-- +----------------------------------------------------------------+
/*
 * fix source column data type (from floating point to fixed width integer number)
 */
alter table gis.c24p11_ferservizi_800_zones_geography
	ALTER COLUMN cod_800_zones TYPE numeric(12) USING cod_800_zones::numeric(12)

/*
 * add PK to source table (in order to create FK + avoid duplicates)
 */
alter table gis.c24p11_ferservizi_800_zones_geography
	add constraint c24p11_ferservizi_800_zones_geography_pk primary key(cod_800_zones);



/*
 * Create data table 
 */
drop table if exists gis.italy_800_zones_distance_matrix;
create table gis.italy_800_zones_distance_matrix (
	  origin        numeric(12)
	, destination   numeric(12)
	, distance_km   numeric(8,3)
	
	, CONSTRAINT italy_800_zones_distance_matrix_pk primary key(origin, destination)
	, CONSTRAINT italy_800_zones_distance_matrix_fk_origin FOREIGN KEY (origin) REFERENCES gis.c24p11_ferservizi_800_zones_geography(cod_800_zones)
	, CONSTRAINT italy_800_zones_distance_matrix_fk_destination FOREIGN KEY (destination) REFERENCES gis.c24p11_ferservizi_800_zones_geography(cod_800_zones)
);

comment on table gis.italy_800_zones_distance_matrix is 'Italy 800 zones distance matrix in Km';



/*
 * Fill table with computed O/D distances
 *
 * >> convert geometries to geograpies: distance will be thus returned in meters on spheric distance rather than euclidean one
 */ 
insert into gis.italy_800_zones_distance_matrix(origin, destination, distance_km)
select origin, destination
		, st_distance(o_geo, d_geo) / 1e3 distance_km
from (
	select cod_800_zones as origin 
			, st_centroid(geom_800_zones)::geography as o_geo
	from gis.c24p11_ferservizi_800_zones_geography
) o
	join (
		select cod_800_zones as destination 
				, st_centroid(geom_800_zones)::geography as d_geo
		from gis.c24p11_ferservizi_800_zones_geography
	) d on origin != destination
;