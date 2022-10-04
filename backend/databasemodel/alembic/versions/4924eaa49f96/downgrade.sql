DROP MATERIALIZED VIEW kooste.all_points;
DROP TABLE kooste.tamperewfs_luontopolkurastit;
DROP TABLE kooste.tamperewfs_luonnonmuistomerkit;

-- object: kooste.tamperewfs_luonnonmuistomerkit | type: TABLE --
-- DROP TABLE IF EXISTS kooste.tamperewfs_luonnonmuistomerkit CASCADE;
CREATE TABLE kooste.tamperewfs_luonnonmuistomerkit (
	sw_member bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	visibility boolean DEFAULT True,
	name text NOT NULL,
	tarmo_category text DEFAULT 'Nähtävyydet',
	type_name text DEFAULT 'Luonnonmuistomerkki',
	"infoFi" text,
	paatosnumero text,
	paatospaiva date,
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT tamperewfs_luonnonmuistomerkit_pk PRIMARY KEY (sw_member)
);
CREATE INDEX ON kooste.tamperewfs_luonnonmuistomerkit (deleted);
CREATE INDEX ON kooste.tamperewfs_luonnonmuistomerkit (tarmo_category);
CREATE INDEX ON kooste.tamperewfs_luonnonmuistomerkit (visibility);
-- ddl-end --
ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.tamperewfs_luontopolkurastit | type: TABLE --
-- DROP TABLE IF EXISTS kooste.tamperewfs_luontopolkurastit CASCADE;
CREATE TABLE kooste.tamperewfs_luontopolkurastit (
	mi_prinx bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	visibility boolean DEFAULT True,
	name text NOT NULL,
	tarmo_category text DEFAULT 'Ulkoilureitit',
	type_name text DEFAULT 'Luontopolkurasti',
	tunnus integer,
	rasti integer,
	"infoFi" text,
	lisatietoja text,
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT tamperewfs_luontopolkurastit_pk PRIMARY KEY (mi_prinx)
);
CREATE INDEX ON kooste.tamperewfs_luontopolkurastit (deleted);
CREATE INDEX ON kooste.tamperewfs_luontopolkurastit (tarmo_category);
CREATE INDEX ON kooste.tamperewfs_luontopolkurastit (visibility);
-- ddl-end --
ALTER TABLE kooste.tamperewfs_luontopolkurastit OWNER TO tarmo_admin;
-- ddl-end --

DELETE FROM kooste.tamperewfs_metadata;
INSERT INTO kooste.tamperewfs_metadata (
    layers_to_include
) VALUES (
    '["luonto:YV_LUONNONMUISTOMERKKI", "luonto:YV_LUONTORASTI"]'
);

-- object: grant_r_b0576134c9 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.tamperewfs_luonnonmuistomerkit
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_b182858222 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.tamperewfs_luonnonmuistomerkit
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_6fccdd230c | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.tamperewfs_luontopolkurastit
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_69ac05820f | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.tamperewfs_luontopolkurastit
   TO tarmo_read_write;
-- ddl-end --

create materialized view kooste.all_points as
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('lipas_pisteet-', "sportsPlaceId") as id, "name", "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb as props from kooste.lipas_pisteet as points where deleted=false union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_rkykohteet-', "OBJECTID") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb as props from kooste.museovirastoarcrest_rkykohteet as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_muinaisjaannokset-', "mjtunnus") as id, "name", "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb as props from kooste.museovirastoarcrest_muinaisjaannokset as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('tamperewfs_luonnonmuistomerkit-', "sw_member") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb as props from kooste.tamperewfs_luonnonmuistomerkit as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('tamperewfs_luontopolkurastit-', "mi_prinx") as id ,"name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb as props from kooste.tamperewfs_luontopolkurastit as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('osm_pisteet-', "id") as id , tags ->> 'name' as "name", 'Tampere' as "cityName", "tarmo_category", "type_name", tags || jsonb_build_object('type_name', type_name) as props from kooste.osm_pisteet as points where deleted=false union all
select ST_Centroid(geom)::geometry(point,4326) as geom, CONCAT('osm_alueet-', "id") as id , tags ->> 'name' as "name", 'Tampere' as "cityName", "tarmo_category", "type_name", tags || jsonb_build_object('type_name', type_name) as props from kooste.osm_alueet as areas where deleted=false union all
select ST_Centroid(geom)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_rkyalueet-', "OBJECTID") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(areas)::jsonb as props from kooste.museovirastoarcrest_rkyalueet as areas where deleted=false and visibility=true;

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
