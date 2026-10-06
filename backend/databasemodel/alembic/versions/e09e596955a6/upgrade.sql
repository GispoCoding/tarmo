ALTER TABLE kooste.lipas_metadata ADD COLUMN loi_types jsonb;
UPDATE kooste.lipas_metadata SET
    loi_types = '["cooking-shelter","canopy","fire-pit"]',
    tarmo_category_by_code = jsonb_set(
        tarmo_category_by_code,
        '{"Laavut, majat, ruokailu"}',
        (tarmo_category_by_code -> 'Laavut, majat, ruokailu') || '["cooking-shelter","canopy","fire-pit"]'
    );

CREATE TABLE kooste.lipas_lois (
	id uuid NOT NULL,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	"loi-category" text NOT NULL,
	"loi-type" text NOT NULL,
	name text,
	description text,
	status text,
	deleted boolean NOT NULL DEFAULT false,
	tarmo_category text,
	CONSTRAINT lipas_lois_pk PRIMARY KEY (id)
);
CREATE INDEX ON kooste.lipas_lois (deleted);
CREATE INDEX ON kooste.lipas_lois (tarmo_category);
ALTER TABLE kooste.lipas_lois OWNER TO tarmo_admin;

GRANT SELECT
   ON TABLE kooste.lipas_lois
   TO tarmo_read;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.lipas_lois
   TO tarmo_read_write;

DROP MATERIALIZED VIEW kooste.all_points;

create materialized view kooste.all_points as
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('lipas_pisteet-', "sportsPlaceId") as id, "name", "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'name' as props from kooste.lipas_pisteet as points where deleted=false union all
-- Sadly, the Lipas LOI API has no city or bounding box filter, and LOIs have no city field.
-- Therefore, 'Tampere' must be hard-coded as the city of all LOIs, no matter where they are.
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('lipas_lois-', "id") as id, "name", 'Tampere' as "cityName", "tarmo_category", "loi-type" as "type_name", row_to_json(points)::jsonb - 'id' - 'name' as props from kooste.lipas_lois as points where deleted=false union all
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
