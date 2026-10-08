-- loi_types changes from a list of types to a dict of types and their Finnish names
UPDATE kooste.lipas_metadata SET
    loi_types = '{"cooking-shelter": "Keittokatos","canopy": "Laavu","fire-pit": "Nuotiopaikka"}';

-- Fill in type names for existing LOIs before making the column mandatory.
-- Types without a translation get the LOI type, as in the loader.
ALTER TABLE kooste.lipas_lois ADD COLUMN type_name text;
UPDATE kooste.lipas_lois AS lois SET
    type_name = COALESCE(metadata.loi_types ->> lois."loi-type", lois."loi-type")
    FROM (SELECT loi_types FROM kooste.lipas_metadata LIMIT 1) AS metadata;
UPDATE kooste.lipas_lois SET type_name = "loi-type" WHERE type_name IS NULL;
ALTER TABLE kooste.lipas_lois ALTER COLUMN type_name SET NOT NULL;

DROP MATERIALIZED VIEW kooste.all_points;

create materialized view kooste.all_points as
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('lipas_pisteet-', "sportsPlaceId") as id, "name", "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'name' as props from kooste.lipas_pisteet as points where deleted=false union all
-- Sadly, the Lipas LOI API has no city or bounding box filter, and LOIs have no city field.
-- Therefore, 'Tampere' must be hard-coded as the city of all LOIs, no matter where they are.
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('lipas_lois-', "id") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'id' - 'name' as props from kooste.lipas_lois as points where deleted=false union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_rkykohteet-', "OBJECTID") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'name' as props from kooste.museovirastoarcrest_rkykohteet as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_muinaisjaannokset-', "mjtunnus") as id, "name", "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'name' as props from kooste.museovirastoarcrest_muinaisjaannokset as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('tamperewfs_luonnonmuistomerkit-', "id") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'id' - 'name' as props from kooste.tamperewfs_luonnonmuistomerkit as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('tamperewfs_luontopolkurastit-', "id") as id ,"name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'id' - 'name' as props from kooste.tamperewfs_luontopolkurastit as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('osm_pisteet-', "id") as id , tags ->> 'name' as "name", 'Tampere' as "cityName", "tarmo_category", "type_name", tags - 'name' as props from kooste.osm_pisteet as points where deleted=false union all
select ST_Centroid(geom)::geometry(point,4326) as geom, CONCAT('osm_alueet-', "id") as id , tags ->> 'name' as "name", 'Tampere' as "cityName", "tarmo_category", "type_name", tags - 'name' as props from kooste.osm_alueet as areas where deleted=false union all
select ST_Centroid(geom)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_rkyalueet-', "OBJECTID") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(areas)::jsonb - 'name' as props from kooste.museovirastoarcrest_rkyalueet as areas where deleted=false and visibility=true;

create index on kooste.all_points (id);
-- Use the trigram extension to speed up text search
create index on kooste.all_points USING gin (name gin_trgm_ops);
create index on kooste.all_points USING gin ("tarmo_category" gin_trgm_ops);
create index on kooste.all_points USING gin ("type_name" gin_trgm_ops);
create index on kooste.all_points ("cityName");

ALTER TABLE kooste.all_points OWNER TO tarmo_read_write;

GRANT SELECT
   ON TABLE kooste.all_points
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.all_points
   TO tarmo_admin;
