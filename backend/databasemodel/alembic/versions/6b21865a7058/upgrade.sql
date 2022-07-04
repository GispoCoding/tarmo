drop materialized view kooste.all_points;
create materialized view kooste.all_points as
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('lipas_pisteet-', "sportsPlaceId") as id, "name", "cityName", "tarmo_category", "type_name", 'lipas_pisteet' as table_name, row_to_json(points)::jsonb as props from kooste.lipas_pisteet as points where deleted=false union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_rkykohteet-', "OBJECTID") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", 'museovirastoarcrest_rkykohteet' as table_name, row_to_json(points)::jsonb as props from kooste.museovirastoarcrest_rkykohteet as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_muinaisjaannokset-', "mjtunnus") as id, "name", "cityName", "tarmo_category", "type_name", 'museovirastoarcrest_muinaisjaannokset' as table_name, row_to_json(points)::jsonb as props from kooste.museovirastoarcrest_muinaisjaannokset as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('tamperewfs_luonnonmuistomerkit-', "sw_member") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", 'tamperewfs_luonnonmuistomerkit' as table_name, row_to_json(points)::jsonb as props from kooste.tamperewfs_luonnonmuistomerkit as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('tamperewfs_luontopolkurastit-', "mi_prinx") as id ,"name", 'Tampere' as "cityName", "tarmo_category", "type_name", 'tamperewfs_luontopolkurastit' as table_name, row_to_json(points)::jsonb as props from kooste.tamperewfs_luontopolkurastit as points where deleted=false and visibility=true;

DROP INDEX kooste.lipas_viivat_tarmo_category_idx;
CREATE INDEX ON kooste.lipas_viivat USING gin (name gin_trgm_ops);
CREATE INDEX ON kooste.lipas_viivat USING gin ("tarmo_category" gin_trgm_ops);
CREATE INDEX ON kooste.lipas_viivat USING gin ("type_name" gin_trgm_ops);
CREATE INDEX ON kooste.all_points USING gin ("tarmo_category" gin_trgm_ops);
CREATE INDEX ON kooste.all_points USING gin ("type_name" gin_trgm_ops);
