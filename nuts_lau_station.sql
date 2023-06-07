create table bzame.eurostat_lau_tmp (
  GISCO_ID    text
, CNTR_CODE    text
, LAU_ID    text
, LAU_NAME    text
, POP_2020    text
, POP_DENS_2    text
, AREA_KM2    text
, YEAR    text
, FID    text
)


create table bzame.eurostat_lau (
      reference_year    numeric(4, 0)
    , fid                varchar(20)
    , gisco_id            varchar(20)
    , alpha_2_code        char(2)
    , lau_id            varchar(20)
    , lau_name            varchar(100)
    , pop_2020            numeric(10, 3)
    , pop_dens_2        numeric(10, 5)
    , area_km2            numeric(10, 5)
);

SELECT AddGeometryColumn ('bzame', 'eurostat_lau', 'geom_lau', 4326, 'MULTIPOLYGON', 2, false);


reference_year, fid, gisco_id, alpha_2_code, lau_id, lau_name, pop_2020, pop_dens_2, area_km2


select
      YEAR::int
    , FID
    , GISCO_ID
    , CNTR_CODE
    , LAU_ID
    , LAU_NAME
    , POP_2020::numeric
    , POP_DENS_2::numeric
    , AREA_KM2::numeric
from bzame.eurostat_lau_tmp



drop table if exists bzame.station;

create table bzame.station (
      station_id            int
    , alpha_2_code          char(2)
    , nuts_id               varchar(10)
    , lau_id                varchar(20)
    , longitude             numeric(8, 6)
    , latitude              numeric(8, 6)
    , insert_date           numeric(8, 0)
    , uic                   varchar(10)
    , parent_station_id     varchar(10)
    , sncf_id               varchar(10)
    , sncf_tvs_id           varchar(10)
    , entur_id              varchar(25)
    , db_id                 varchar(10)
    , busbud_id             varchar(10)
    , distribusion_id       varchar(10)
    , flixbus_id            varchar(10)
    , cff_id                varchar(10)
    , leoexpress_id         varchar(10)
    , obb_id                varchar(10)
    , ouigo_id              varchar(10)
    , trenitalia_id         varchar(10)
    , trenitalia_rtvt_id    varchar(10)
    , ntv_rtiv_id           varchar(10)
    , ntv_id                varchar(10)
    , hkx_id                varchar(10)
    , renfe_id              varchar(10)
    , atoc_id               varchar(10)
    , benerail_id           varchar(10)
    , westbahn_id           varchar(10)
    , iata_airport_code     char(3)
);

SELECT AddGeometryColumn ('bzame', 'station', 'geom', 4326, 'POINT', 2, false);

\copy bzame.station (station_id, uic, longitude, latitude, parent_station_id, alpha_2_code, sncf_id, sncf_tvs_id, entur_id, db_id, busbud_id, distribusion_id, flixbus_id, cff_id, leoexpress_id, obb_id, ouigo_id, trenitalia_id, trenitalia_rtvt_id, ntv_rtiv_id, ntv_id, hkx_id, renfe_id, atoc_id, benerail_id, westbahn_id, iata_airport_code) FROM 'C:/Users/BrunoZamengo/Downloads/stations-eu.csv' CSV HEADER

update bzame.station set 
      insert_date = to_char(current_date, 'yyyymmdd')::numeric 
    , geom = ST_SetSRID(ST_Point(latitude::float, longitude::float), 4326::int)
;



update bzame.station set 
    lau_id = eurostat_lau.lau_id
from bzame.eurostat_lau
where eurostat_lau.alpha_2_code = station.alpha_2_code
    and st_contains(eurostat_lau.geom_lau, station.geom)
    









drop table if exists bzame.eurostat_nuts;

create table bzame.eurostat_nuts (
      reference_year    numeric(4, 0)
    , nuts_level        numeric(2, 0)
    , alpha_2_code      char(2)
    , nuts_id           varchar(20)
    , nuts_name         varchar(100) /* name_latn */
    , fid               varchar(20)
    
    , mount_type        numeric(2, 0)
    , urbn_type         numeric(2, 0)
    , coast_type        numeric(2, 0)
);

SELECT AddGeometryColumn ('bzame', 'eurostat_nuts', 'geom_nuts', 4326, 'MULTIPOLYGON', 2, false);


insert into bzame.eurostat_nuts(reference_year, nuts_level, alpha_2_code, nuts_id, nuts_name, fid, mount_type, urbn_type, coast_type, geom_nuts)
select 
        2021 as reference_year
        , levl_code
        , cntr_code
        , nuts_id
        , name_latn
        , fid
        , mount_type
        , urbn_type
        , coast_type
        , geom
from bzame.nuts_rg_01m_2021_4326
;




update bzame.station set 
    nuts_id  = eurostat_nuts.nuts_id
from bzame.eurostat_nuts
where nuts_level = 3
    and st_contains(eurostat_nuts.geom_nuts, station.geom)