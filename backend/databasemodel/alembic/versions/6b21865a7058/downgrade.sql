DROP INDEX kooste.lipas_viivat_name_idx;
DROP INDEX kooste.lipas_viivat_tarmo_category_idx;
DROP INDEX kooste.lipas_viivat_type_name_idx;
DROP INDEX kooste.all_points_tarmo_category_idx;
DROP INDEX kooste.all_points_type_name_idx;

drop materialized view kooste.all_points;
create materialized view kooste.all_points as
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('lipas_pisteet-', "sportsPlaceId") as id, "name", "cityName", "tarmo_category", 'lipas_pisteet' as table_name, row_to_json(points)::jsonb as props from kooste.lipas_pisteet as points where deleted=false union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_rkykohteet-', "OBJECTID") as id, "name", 'Tampere' as "cityName", "tarmo_category", 'museovirastoarcrest_rkykohteet' as table_name, row_to_json(points)::jsonb as props from kooste.museovirastoarcrest_rkykohteet as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_muinaisjaannokset-', "mjtunnus") as id, "name", "cityName", "tarmo_category", 'museovirastoarcrest_muinaisjaannokset' as table_name, row_to_json(points)::jsonb as props from kooste.museovirastoarcrest_muinaisjaannokset as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('tamperewfs_luonnonmuistomerkit-', "sw_member") as id, "name", 'Tampere' as "cityName", "tarmo_category", 'tamperewfs_luonnonmuistomerkit' as table_name, row_to_json(points)::jsonb as props from kooste.tamperewfs_luonnonmuistomerkit as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('tamperewfs_luontopolkurastit-', "mi_prinx") as id ,"name", 'Tampere' as "cityName", "tarmo_category", 'tamperewfs_luontopolkurastit' as table_name, row_to_json(points)::jsonb as props from kooste.tamperewfs_luontopolkurastit as points where deleted=false and visibility=true;

CREATE INDEX ON kooste.lipas_viivat (tarmo_category);
