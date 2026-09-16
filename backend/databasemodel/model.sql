-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler version: 0.9.4
-- PostgreSQL version: 13.0
-- Project Site: pgmodeler.io
-- Model Author: ---
-- object: tarmo_admin | type: ROLE --
-- DROP ROLE IF EXISTS tarmo_admin;
CREATE ROLE tarmo_admin WITH
	CREATEROLE
	LOGIN
	ENCRYPTED PASSWORD 'vaihdaMinut1';
-- ddl-end --

-- object: tarmo_read | type: ROLE --
-- DROP ROLE IF EXISTS tarmo_read;
CREATE ROLE tarmo_read WITH
	LOGIN
	ENCRYPTED PASSWORD 'vaihdaMinut2';
-- ddl-end --

-- object: tarmo_read_write | type: ROLE --
-- DROP ROLE IF EXISTS tarmo_read_write;
CREATE ROLE tarmo_read_write WITH
	LOGIN
	ENCRYPTED PASSWORD 'vaihdaMinut3';
-- ddl-end --


-- Database creation must be performed outside a multi lined SQL file.
-- These commands were put in this file only as a convenience.
--
-- object: model | type: DATABASE --
-- DROP DATABASE IF EXISTS model;
-- CREATE DATABASE model;
-- ddl-end --


-- object: kooste | type: SCHEMA --
-- DROP SCHEMA IF EXISTS kooste CASCADE;
CREATE SCHEMA kooste;
-- ddl-end --
ALTER SCHEMA kooste OWNER TO tarmo_admin;
-- ddl-end --

SET search_path TO pg_catalog,public,kooste;
-- ddl-end --

-- object: postgis | type: EXTENSION --
-- DROP EXTENSION IF EXISTS postgis CASCADE;
CREATE EXTENSION postgis
WITH SCHEMA public;
-- ddl-end --

-- Use the trigram extension to speed up text search
CREATE EXTENSION pg_trgm
WITH SCHEMA public;

-- object: lipas.metadata | type: TABLE --
-- DROP TABLE IF EXISTS lipas.metadata CASCADE;
CREATE TABLE kooste.lipas_metadata (
	update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	last_modified timestamptz,
	type_codes_summer jsonb,
	type_codes_winter jsonb,
	type_codes_all_year jsonb,
	tarmo_category_by_code jsonb,
	CONSTRAINT lipas_metadata_pk PRIMARY KEY (update_id)
);
-- ddl-end --
ALTER TABLE kooste.lipas_metadata OWNER TO tarmo_admin;
-- ddl-end --

-- Appended SQL commands --
SET timezone = 'Europe/Helsinki';
-- ddl-end --

INSERT INTO kooste.lipas_metadata (
	type_codes_summer,
	type_codes_winter,
	type_codes_all_year,
	tarmo_category_by_code
) VALUES (
	'[203,201,5150,3220,3230,4451,4452]', -- checked, alright (only name changes)
	'[4640,4630,1520,1530,1550,1510,3240,4402,4440]', -- checked, alright (only name changes)
	'[206,301,304,302,202,1120,1130,6210,1180,4710,4720,204,207,4412,4411,4403,4405,4401,4404,4430,101,1110]', -- checked, alright (only name changes)
	'{"Hiihto": [4402,4440,4630,4640], "Luistelu": [1510,1520,1530,1550], "Uinti": [3220,3230], "Talviuinti": [3240], "Vesillä ulkoilu": [201,203,5150,4451,4452], "Laavut, majat, ruokailu": [202,206,301,302,304], "Ulkoilupaikat": [101,1110,1120], "Ulkoiluaktiviteetit": [1130,1180,4710,4720,6210], "Ulkoilureitit": [207,4401,4403,4404,4405,4430], "Pyöräily": [4411,4412], "Nähtävyydet": [204]}'
);
-- ddl-end --

-- object: kooste.lipas_pisteet | type: TABLE --
-- DROP TABLE IF EXISTS kooste.lipas_pisteet CASCADE;
CREATE TABLE kooste.lipas_pisteet (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	name text NOT NULL,
	"type_typeCode" integer NOT NULL,
	type_name text NOT NULL,
	tarmo_category text,
	owner text,
	admin text,
	address text,
	"postalCode" integer,
	"postalOffice" text,
	"cityName" text,
	email text,
	"phoneNumber" text,
	www text,
	season text NOT NULL,
	toilet boolean,
	shower boolean,
	"changingRooms" boolean,
	ligthing boolean,
	"restPlacesCount" numeric,
	"skiTrackTraditional" boolean,
	"skiTrackFreestyle" boolean,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
	pier boolean,
	"otherPlatforms" boolean,
	"accessibilityInfo" text,
	kiosk boolean,
	"skiService" boolean,
	"equipmentRental" boolean,
	sauna boolean,
	playground boolean,
	"exerciseMachines" boolean,
	"infoFi" text,
	"trackLengthM" numeric,
	"altitudeDifference" numeric,
	"climbingWallWidthM" numeric,
	"climbingWallHeightM" numeric,
	"climbingRoutesCount" numeric,
	"holesCount" numeric,
	"boatLaunchingSpot" boolean,
	"iceClimbing" boolean,
	"iceReduction" boolean,
	range boolean,
	"trackType" text,
	"additionalInfo" text,
	images text,
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT lipas_pisteet_pk PRIMARY KEY ("sportsPlaceId")
);
CREATE INDEX ON kooste.lipas_pisteet (deleted);
CREATE INDEX ON kooste.lipas_pisteet (tarmo_category);
CREATE INDEX lipas_pisteet_cityname_idx ON kooste.lipas_pisteet ("cityName");
-- ddl-end --
COMMENT ON COLUMN kooste.lipas_pisteet.ligthing IS E'Lippaan päässä kirjoitusvirhe';
-- ddl-end --
ALTER TABLE kooste.lipas_pisteet OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.lipas_viivat | type: TABLE --
-- DROP TABLE IF EXISTS kooste.lipas_viivat CASCADE;
CREATE TABLE kooste.lipas_viivat (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326) NOT NULL,
	name text NOT NULL,
	"type_typeCode" integer NOT NULL,
	type_name text NOT NULL,
	tarmo_category text,
	owner text,
	admin text,
	address text,
	"postalCode" integer,
	"postalOffice" text,
	"cityName" text,
	email text,
	"phoneNumber" text,
	www text,
	season text NOT NULL,
	toilet boolean,
	"restPlacesCount" numeric,
	"skiTrackTraditional" boolean,
	"skiTrackFreestyle" boolean,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
	"accessibilityInfo" text,
	"exerciseMachines" boolean,
	"infoFi" text,
	"shootingPositionsCount" numeric,
	"additionalInfo" text,
	images text,
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT lipas_viivat_pk PRIMARY KEY ("sportsPlaceId")
);
CREATE INDEX ON kooste.lipas_viivat (deleted);
-- Use the trigram extension to speed up text search
CREATE INDEX ON kooste.lipas_viivat USING gin (name gin_trgm_ops);
CREATE INDEX ON kooste.lipas_viivat USING gin ("tarmo_category" gin_trgm_ops);
CREATE INDEX ON kooste.lipas_viivat USING gin ("type_name" gin_trgm_ops);
CREATE INDEX lipas_viivat_cityname_idx ON kooste.lipas_viivat ("cityName");
-- ddl-end --
ALTER TABLE kooste.lipas_viivat OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.osm_pisteet | type: TABLE --
-- DROP TABLE IF EXISTS kooste.osm_pisteet CASCADE;
CREATE TABLE kooste.osm_pisteet (
	id text NOT NULL,
	osm_id bigint NOT NULL,
	osm_type text NOT NULL,
	geom geometry(POINT, 4326) NOT NULL,
	tarmo_category text DEFAULT 'Pysäköinti',
	type_name text DEFAULT 'Pysäköintipaikka',
	tags jsonb,
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT osm_pisteet_pk PRIMARY KEY (id),
	UNIQUE (osm_id, osm_type)
);
CREATE INDEX ON kooste.osm_pisteet (deleted);
CREATE INDEX ON kooste.osm_pisteet (tarmo_category);
ALTER TABLE kooste.osm_pisteet OWNER TO tarmo_admin;

-- object: kooste.osm_alueet | type: TABLE --
-- DROP TABLE IF EXISTS kooste.osm_alueet CASCADE;
CREATE TABLE kooste.osm_alueet (
	id text NOT NULL,
	osm_id bigint NOT NULL,
	osm_type text NOT NULL,
	geom geometry(POLYGON, 4326) NOT NULL,
	tarmo_category text DEFAULT 'Pysäköinti',
	type_name text DEFAULT 'Pysäköintialue',
	tags jsonb,
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT osm_alueet_pk PRIMARY KEY (id),
	UNIQUE (osm_id, osm_type)
);
CREATE INDEX ON kooste.osm_alueet (deleted);
CREATE INDEX ON kooste.osm_alueet (tarmo_category);
ALTER TABLE kooste.osm_alueet OWNER TO tarmo_admin;

-- object: kooste.osm_metadata | type: TABLE --
-- DROP TABLE IF EXISTS kooste.osm_metadata CASCADE;
CREATE TABLE kooste.osm_metadata (
	update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
	last_modified timestamptz,
	tags_to_include jsonb,
	tags_to_exclude jsonb,
	CONSTRAINT osm_metadata_pk PRIMARY KEY (update_id)
);
-- ddl-end --
ALTER TABLE kooste.osm_metadata OWNER TO tarmo_admin;
-- ddl-end --

INSERT INTO kooste.osm_metadata (
    tags_to_include,
    tags_to_exclude
) VALUES (
    '{"amenity": ["parking", "toilets"],
	"tourism": ["camp_site", "caravan_site", "chalet", "guest_house", "hostel", "hotel", "motel", "museum", "viewpoint", "wilderness_hut"],
	"leisure": ["bird_hide", "sauna"],
	"building": ["church"]}',
    '{"access": ["private", "permit"], "shelter_type": ["public_transport"]}'
);

-- object: kooste.tamperewfs_luonnonmuistomerkit | type: TABLE --
-- DROP TABLE IF EXISTS kooste.tamperewfs_luonnonmuistomerkit CASCADE;
CREATE TABLE kooste.tamperewfs_luonnonmuistomerkit (
	id bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	visibility boolean DEFAULT True,
	name text NOT NULL,
	tarmo_category text DEFAULT 'Nähtävyydet',
	type_name text DEFAULT 'Luonnonmuistomerkki',
	"infoFi" text,
	paatosnumero text,
	paatospaiva date,
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT tamperewfs_luonnonmuistomerkit_pk PRIMARY KEY (id)
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
	id bigint NOT NULL,
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
	CONSTRAINT tamperewfs_luontopolkurastit_pk PRIMARY KEY (id)
);
CREATE INDEX ON kooste.tamperewfs_luontopolkurastit (deleted);
CREATE INDEX ON kooste.tamperewfs_luontopolkurastit (tarmo_category);
CREATE INDEX ON kooste.tamperewfs_luontopolkurastit (visibility);
-- ddl-end --
ALTER TABLE kooste.tamperewfs_luontopolkurastit OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.tamperewfs_luontopolkureitit | type: TABLE --
-- DROP TABLE IF EXISTS kooste.tamperewfs_luontopolkureitit CASCADE;
CREATE TABLE kooste.tamperewfs_luontopolkureitit (
	tunnus bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326) NOT NULL,
	visibility boolean DEFAULT True,
	name text NOT NULL DEFAULT 'Nimitieto puuttuu',
	tarmo_category text DEFAULT 'Ulkoilureitit',
	type_name text DEFAULT 'Luontopolku',
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT tamperewfs_luontopolkureitit_pk PRIMARY KEY (tunnus)
);
CREATE INDEX ON kooste.tamperewfs_luontopolkureitit (deleted);
CREATE INDEX ON kooste.tamperewfs_luontopolkureitit (tarmo_category);
CREATE INDEX ON kooste.tamperewfs_luontopolkureitit (visibility);
-- ddl-end --
ALTER TABLE kooste.tamperewfs_luontopolkureitit OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.tamperewfs_metadata | type: TABLE --
-- DROP TABLE IF EXISTS kooste.tamperewfs_metadata CASCADE;
CREATE TABLE kooste.tamperewfs_metadata (
	update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	last_modified timestamptz,
	layers_to_include jsonb,
	CONSTRAINT tamperewfs_metadata_pk PRIMARY KEY (update_id)
);
-- ddl-end --
ALTER TABLE kooste.tamperewfs_metadata OWNER TO tarmo_admin;
-- ddl-end --

INSERT INTO kooste.tamperewfs_metadata (
    layers_to_include
) VALUES (
    '["ymparisto_ja_terveys:yv_luonnonmuistomerkki", "ymparisto_ja_terveys:yv_luontorasti"]'
);

-- object: kooste.museovirastoarcrest_rkykohteet | type: TABLE --
-- DROP TABLE IF EXISTS kooste.museovirastoarcrest_rkykohteet CASCADE;
CREATE TABLE kooste.museovirastoarcrest_rkykohteet (
	"OBJECTID" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	visibility boolean DEFAULT True,
	name text NOT NULL,
	tarmo_category text DEFAULT 'Nähtävyydet',
	type_name text DEFAULT 'Rakennettu kulttuurikohde',
	www text,
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT museovirastoarcrest_rkykohteet_pk PRIMARY KEY ("OBJECTID")
);
CREATE INDEX ON kooste.museovirastoarcrest_rkykohteet (deleted);
CREATE INDEX ON kooste.museovirastoarcrest_rkykohteet (tarmo_category);
CREATE INDEX ON kooste.museovirastoarcrest_rkykohteet (visibility);
-- ddl-end --
ALTER TABLE kooste.museovirastoarcrest_rkykohteet OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.museovirastoarcrest_rkyalueet | type: TABLE --
-- DROP TABLE IF EXISTS kooste.museovirastoarcrest_rkyalueet CASCADE;
CREATE TABLE kooste.museovirastoarcrest_rkyalueet (
	"OBJECTID" bigint NOT NULL,
	geom geometry(MULTIPOLYGON, 4326) NOT NULL,
	visibility boolean DEFAULT True,
	name text NOT NULL,
	tarmo_category text DEFAULT 'Nähtävyydet',
	type_name text DEFAULT 'Rakennettu kulttuurikohde',
	www text,
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT museovirastoarcrest_rkyalueet_pk PRIMARY KEY ("OBJECTID")
);
CREATE INDEX ON kooste.museovirastoarcrest_rkyalueet (deleted);
CREATE INDEX ON kooste.museovirastoarcrest_rkyalueet (tarmo_category);
CREATE INDEX ON kooste.museovirastoarcrest_rkyalueet (visibility);
-- ddl-end --
ALTER TABLE kooste.museovirastoarcrest_rkyalueet OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.museovirastoarcrest_muinaisjaannokset | type: TABLE --
-- DROP TABLE IF EXISTS kooste.museovirastoarcrest_muinaisjaannokset CASCADE;
CREATE TABLE kooste.museovirastoarcrest_muinaisjaannokset (
	mjtunnus bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	visibility boolean DEFAULT True,
	name text NOT NULL,
	tarmo_category text DEFAULT 'Muinaisjäännökset',
	"cityName" text,
	type_name text DEFAULT 'Muinaisjäännös',
	alatyyppi text,
	ajoitus text,
	vedenalainen boolean,
	luontipvm date,
	muutospvm date,
	www text,
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT museovirastoarcrest_muinaisjaannokset_pk PRIMARY KEY (mjtunnus)

);
CREATE INDEX ON kooste.museovirastoarcrest_muinaisjaannokset (deleted);
CREATE INDEX ON kooste.museovirastoarcrest_muinaisjaannokset (tarmo_category);
CREATE INDEX ON kooste.museovirastoarcrest_muinaisjaannokset (visibility);
CREATE INDEX museovirastoarcrest_muinaisjaannokset_cityname_idx ON kooste.museovirastoarcrest_muinaisjaannokset ("cityName");
-- ddl-end --
ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.museovirastoarcrest_metadata | type: TABLE --
-- DROP TABLE IF EXISTS kooste.museovirastoarcrest_metadata CASCADE;
CREATE TABLE kooste.museovirastoarcrest_metadata (
	update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
	last_modified timestamptz,
	layers_to_include jsonb,
	url text DEFAULT 'https://kartta.nba.fi/arcgis/rest/services/',
	CONSTRAINT museovirastoarcrest_metadata_pk PRIMARY KEY (update_id)

);

ALTER TABLE kooste.museovirastoarcrest_metadata OWNER TO tarmo_admin;

INSERT INTO kooste.museovirastoarcrest_metadata(
	layers_to_include
) VALUES (
	'{"WFS/MV_KulttuuriymparistoSuojellut": ["Muinaisjaannokset_piste", "RKY_piste", "RKY_alue"]}'
);

-- object: kooste.syke_natura2000 | type: TABLE --
-- DROP TABLE IF EXISTS kooste.syke_natura2000 CASCADE;
CREATE TABLE kooste.syke_natura2000 (
	"naturaTunnus" text NOT NULL,
	geom geometry(MULTIPOLYGON, 4326) NOT NULL,
	name text NOT NULL,
	tarmo_category text DEFAULT 'Tausta-aineistot',
	type_name text DEFAULT 'Natura-alue',
	"paatosPvm" date,
	"luontiPvm" date,
	"muutosPvm" date,
	"paattymisPvm" date,
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT syke_natura2000_pk PRIMARY KEY ("naturaTunnus")
);
CREATE INDEX ON kooste.syke_natura2000 (deleted);
-- ddl-end --
ALTER TABLE kooste.syke_natura2000 OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.syke_valtionluonnonsuojelualueet | type: TABLE --
-- DROP TABLE IF EXISTS kooste.syke_valtionluonnonsuojelualueet CASCADE;
CREATE TABLE kooste.syke_valtionluonnonsuojelualueet (
	"LsAlueTunnus" text NOT NULL,
	geom geometry(MULTIPOLYGON, 4326) NOT NULL,
	name text NOT NULL,
	tarmo_category text DEFAULT 'Tausta-aineistot',
	type_name text DEFAULT 'Valtion luonnonsuojelualue',
	"infoFi" text,
	"PaatPvm" date,
	"PaatNimi" text,
	"VoimaantuloPvm" date,
	"MuutosPvm" date,
	"LakkautusPvm" date,
	deleted boolean NOT NULL DEFAULT false,
	CONSTRAINT syke_valtionluonnonsuojelualueet_pk PRIMARY KEY ("LsAlueTunnus")
);
CREATE INDEX ON kooste.syke_valtionluonnonsuojelualueet (deleted);
-- ddl-end --
ALTER TABLE kooste.syke_valtionluonnonsuojelualueet OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.syke_metadata | type: TABLE --
-- DROP TABLE IF EXISTS kooste.syke_metadata CASCADE;
CREATE TABLE kooste.syke_metadata (
	update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
	last_modified timestamptz,
	layers_to_include jsonb,
	url text DEFAULT 'https://paikkatieto.ymparisto.fi/arcgis/rest/services/',
	CONSTRAINT syke_metadata_pk PRIMARY KEY (update_id)

);

ALTER TABLE kooste.syke_metadata OWNER TO tarmo_admin;

INSERT INTO kooste.syke_metadata(
	layers_to_include
) VALUES (
    '{"SYKE/SYKE_SuojellutAlueet": ["Natura 2000 - SAC Manner-Suomi aluemaiset", "Natura 2000 - SPA Manner-Suomi", "Natura 2000 - SCI Manner-Suomi", "Valtion maiden luonnonsuojelualueet"]}'
);

-- object: kooste.metadata | type: TABLE --
-- DROP TABLE IF EXISTS kooste.metadata CASCADE;
CREATE TABLE kooste.metadata (
	update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
	datasource text NOT NULL,
	last_modified timestamptz,
	CONSTRAINT metadata_pk PRIMARY KEY (update_id)

);
-- ddl-end --
COMMENT ON COLUMN kooste.metadata.datasource IS E'You can get this information from table names by selecting the part before underscore character';
-- ddl-end --
ALTER TABLE kooste.metadata OWNER TO tarmo_admin;
-- ddl-end --

GRANT SELECT
   ON TABLE kooste.osm_pisteet
   TO tarmo_read;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.osm_pisteet
   TO tarmo_read_write;

GRANT SELECT
   ON TABLE kooste.osm_alueet
   TO tarmo_read;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.osm_alueet
   TO tarmo_read_write;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.osm_metadata
   TO tarmo_read_write;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.tamperewfs_metadata
   TO tarmo_read_write;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.museovirastoarcrest_metadata
   TO tarmo_read_write;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.syke_metadata
   TO tarmo_read_write;

-- object: grant_rawd_6bd09fd3fa | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.lipas_metadata
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_a4eb7cf4b1 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.lipas_pisteet
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_eb6ff88ef6 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.lipas_pisteet
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_5edde85695 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.lipas_viivat
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_9553cb2e9b | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.lipas_viivat
   TO tarmo_read_write;
-- ddl-end --

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

-- object: grant_r_fdbd4d94a9 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.tamperewfs_luontopolkureitit
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_a905fd4ec3 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.tamperewfs_luontopolkureitit
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_d0fe98abc4 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.museovirastoarcrest_rkykohteet
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_c9b052d3eb | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.museovirastoarcrest_rkykohteet
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_d0fe98abc4 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.museovirastoarcrest_rkyalueet
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_c9b052d3eb | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.museovirastoarcrest_rkyalueet
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_7ed8f2c81c | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.museovirastoarcrest_muinaisjaannokset
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_a4e8798254 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.museovirastoarcrest_muinaisjaannokset
   TO tarmo_read_write;
-- ddl-end --

GRANT SELECT
   ON TABLE kooste.syke_natura2000
   TO tarmo_read;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.syke_natura2000
   TO tarmo_read_write;

GRANT SELECT
   ON TABLE kooste.syke_valtionluonnonsuojelualueet
   TO tarmo_read;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.syke_valtionluonnonsuojelualueet
   TO tarmo_read_write;

-- object: grant_rawd_5082180c53 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.metadata
   TO tarmo_read_write;
-- ddl-end --

-- object: "grant_U_ec9ae01f22" | type: PERMISSION --
GRANT USAGE
   ON SCHEMA kooste
   TO tarmo_read;
-- ddl-end --

-- object: "grant_U_eafe528eb4" | type: PERMISSION --
GRANT USAGE
   ON SCHEMA kooste
   TO tarmo_read_write;
-- ddl-end --

-- in combined views, we want to generate unique ids for each point, and save needed fields as jsonb for use in cluster+point layers
-- We must take care that the jsonb field must not contain *any* keys that are the same as the column names in the view.
-- Identical keys (e.g. "id" in both columns and inside props json) will mess up pg_tileserv, as it will merge the column keys with
-- the jsonb props keys. Will result in different fields overwriting each other randomly at each tile request.
-- For this reason, we may not store name or type_name *both* as a column and inside props json.
create materialized view kooste.all_points as
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('lipas_pisteet-', "sportsPlaceId") as id, "name", "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'name' as props from kooste.lipas_pisteet as points where deleted=false union all
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

-- Note that it is possible for a cluster with size 1 to be generated:
-- https://postgis.net/docs/ST_ClusterDBSCAN.html
-- "Note that border geometries may be within eps distance of core geometries in more than one cluster; in this case, either assignment would be correct, and the border geometry will be arbitrarily asssigned to one of the available clusters. In these cases, it is possible for a correct cluster to be generated with fewer than minpoints geometries."
create function kooste.get_cluster_ids(radius float)
	returns table(cluster_id int, id text, point_geom geometry, "cityName" text, "tarmo_category" text, name text, type_name text, props jsonb)
	as $$
	begin
		return query select ST_ClusterDBSCAN(points.geom,radius,2) over (
			partition by points."cityName", points."tarmo_category"
		) as cluster_id, points.id, points.geom, points."cityName", points."tarmo_category", points.name, points.type_name, points.props
		from kooste.all_points as points;
	end; $$
language 'plpgsql';

-- -- Treat clusters with size 1 as non-clusters
-- create function kooste.get_cluster_sizes(radius float)
-- 	returns table(cluster_id int, id text, cluster_size int, point_geom geometry, "cityName" text, "tarmo_category" text, table_name text, props jsonb)
-- 	as $$
-- 	begin
-- 		return query select points.cluster_id, points.id, count(*) over (
-- 			partition by points.cluster_id, points."cityName", points."tarmo_cateogory", points.table_name
-- 		) as cluster_size, points.geom, points."cityName", points."tarmo_category", points.table_name, points.props
-- 		from kooste.get_cluster_ids(radius) as points;
-- 	end; $$
-- language 'plpgsql';

-- This function will return all clusters and all single points not belonging to any cluster
create function kooste.get_clusters(radius float)
	returns table(id text, size bigint, cluster_geom geometry(point,4326), "cityName" text, "tarmo_category" text, props jsonb)
	as $$
	begin
		return query with cluster_ids as (
			select * from kooste.get_cluster_ids(radius)
		), clusters as (
			-- clusters do have any extra props atm
			select points.cluster_id::text, count(*) as size, ST_Centroid(ST_Collect(point_geom)) as cluster_geom, points."cityName", points."tarmo_category", row_to_json(null)::jsonb as props
			from cluster_ids as points where points.cluster_id is not null
			group by points.cluster_id, points."cityName", points."tarmo_category"
			order by points."cityName", points."tarmo_category"
		), non_clusters as (
			-- any all_points fields needed in single tarmo points must be added back to props json
			select points.id, 1 as size, point_geom as cluster_geom, points."cityName", points."tarmo_category", points.props || jsonb_build_object('name', points.name,'type_name', points.type_name) as props
			from cluster_ids as points where points.cluster_id is null
		) select * from clusters union all select * from non_clusters;
	end; $$
language 'plpgsql';

create materialized view kooste.point_clusters_8 as
select id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.20);

create materialized view kooste.point_clusters_9 as
select id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.10);

create materialized view kooste.point_clusters_10 as
select id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.05);

create materialized view kooste.point_clusters_11 as
select id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.025);

create materialized view kooste.point_clusters_12 as
select id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.0125);

create materialized view kooste.point_clusters_13 as
select id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.007);

create index on kooste.point_clusters_8 ("cityName");
create index on kooste.point_clusters_9 ("cityName");
create index on kooste.point_clusters_10 ("cityName");
create index on kooste.point_clusters_11 ("cityName");
create index on kooste.point_clusters_12 ("cityName");
create index on kooste.point_clusters_13 ("cityName");

ALTER TABLE kooste.point_clusters_8 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_9 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_10 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_11 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_12 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_13 OWNER TO tarmo_read_write;

GRANT SELECT
   ON TABLE kooste.point_clusters_8
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.point_clusters_8
   TO tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_9
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.point_clusters_9
   TO tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_10
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.point_clusters_10
   TO tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_11
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.point_clusters_11
   TO tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_12
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.point_clusters_12
   TO tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_13
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.point_clusters_13
   TO tarmo_admin;
