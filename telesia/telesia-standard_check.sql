create or replace view telesia_totali_vs_somma_v as 
with telesia_luogo_parti as (
    SELECT 
              id_period
            , period_analysis_id
            --, t.asset
            , c.asset_keep
            --, t.luogo
            , c.luogo_aggregato
            , holiday_id
            --, t.trip_type_id
            , c.trip_type_id_keep
            , gender_id
            , group_age_id
            , visitor_class_id
            , customer_class_id
            , netti_calib netti_somma
            , lordi_calib lordi_somma
    FROM bzame.vfa_telesia_metro_aeroporti_presenze t
        join piatte.telesia_check_luogo c on 
            t.asset = c.asset
            and t.luogo = c.luogo_singolo
            and t.trip_type_id = c.trip_type_id_join
), telesia_luogo_totali as (
    SELECT 
              id_period
            , period_analysis_id
            , c.asset_keep
            , c.luogo_aggregato
            , holiday_id
            , c.trip_type_id_keep
            , gender_id
            , group_age_id
            , visitor_class_id
            , customer_class_id
            , netti_calib netti_tot
            , lordi_calib lordi_tot
    FROM bzame.vfa_telesia_metro_aeroporti_presenze t
        join (select distinct asset_keep, luogo_aggregato, trip_type_id_keep from piatte.telesia_check_luogo ) c on 
            t.asset = c.asset_keep
            and t.luogo = c.luogo_aggregato
            and t.trip_type_id = c.trip_type_id_keep
) 
select id_period, period_analysis_id, asset_keep, luogo_aggregato, holiday_id, trip_type_id_keep, gender_id, group_age_id, visitor_class_id, customer_class_id
		, max(coalesce(netti_tot, 0)) netti_tot
		, sum(coalesce(netti_somma, 0)) netti_somma
from telesia_luogo_totali
    full join telesia_luogo_parti
        using (
            id_period, period_analysis_id, asset_keep, luogo_aggregato, holiday_id, trip_type_id_keep, gender_id, group_age_id, visitor_class_id, customer_class_id
        )
group by id_period, period_analysis_id, asset_keep, luogo_aggregato, holiday_id, trip_type_id_keep, gender_id, group_age_id, visitor_class_id, customer_class_id


