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


-- object: lipas | type: SCHEMA --
-- DROP SCHEMA IF EXISTS lipas CASCADE;
CREATE SCHEMA lipas;
-- ddl-end --
ALTER SCHEMA lipas OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste | type: SCHEMA --
-- DROP SCHEMA IF EXISTS kooste CASCADE;
CREATE SCHEMA kooste;
-- ddl-end --
ALTER SCHEMA kooste OWNER TO tarmo_admin;
-- ddl-end --

SET search_path TO pg_catalog,public,lipas,kooste;
-- ddl-end --

-- object: postgis | type: EXTENSION --
-- DROP EXTENSION IF EXISTS postgis CASCADE;
CREATE EXTENSION postgis
WITH SCHEMA public;
-- ddl-end --

-- object: lipas.abstract | type: TABLE --
-- DROP TABLE IF EXISTS lipas.abstract CASCADE;
CREATE TABLE lipas.abstract (
	email text,
	admin text,
	www text,
	name text NOT NULL,
	"type_typeCode" integer,
	type_name text,
	"phoneNumber" text,
	location_address text,
	location_city_name text,
	"location_postalOffice" text,
	"location_postalCode" integer,
	owner text

);
-- ddl-end --
ALTER TABLE lipas.abstract OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.luistelukentta | type: TABLE --
-- DROP TABLE IF EXISTS lipas.luistelukentta CASCADE;
CREATE TABLE lipas.luistelukentta (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	kiosk boolean,
	"changingRooms" boolean,
	toilet boolean,
	ligthing boolean,
	"infoFi" text,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT luistelukentta_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
COMMENT ON COLUMN lipas.luistelukentta.ligthing IS E'Kirjoitusvirhe Lippaan päässä';
-- ddl-end --
ALTER TABLE lipas.luistelukentta OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.hiihtomaa | type: TABLE --
-- DROP TABLE IF EXISTS lipas.hiihtomaa CASCADE;
CREATE TABLE lipas.hiihtomaa (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	"equipmentRental" boolean,
	kiosk boolean,
	"skiService" boolean,
	toilet boolean,
	"skiTrackTraditional" boolean,
	"skiTrackFreestyle" boolean,
	"restPlacesCount" numeric,
	"accessibilityInfo" text,
	"infoFi" text,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT hiihtomaa_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.hiihtomaa OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.kilpahiihtokeskus | type: TABLE --
-- DROP TABLE IF EXISTS lipas.kilpahiihtokeskus CASCADE;
CREATE TABLE lipas.kilpahiihtokeskus (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	kiosk boolean,
	"skiService" boolean,
	sauna boolean,
	shower boolean,
	"changingRooms" boolean,
	toilet boolean,
	"skiTrackTraditional" boolean,
	"skiTrackFreestyle" boolean,
	"restPlacesCount" numeric,
	"accessibilityInfo" text,
	"infoFi" text,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT kilpahiihtokeskus_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.kilpahiihtokeskus OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.kaukalo | type: TABLE --
-- DROP TABLE IF EXISTS lipas.kaukalo CASCADE;
CREATE TABLE lipas.kaukalo (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	"changingRooms" boolean,
	toilet boolean,
	ligthing boolean,
	"infoFi" text,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT kaukalo_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
COMMENT ON COLUMN lipas.kaukalo.ligthing IS E'Kirjoitusvirhe Lippaan päässä';
-- ddl-end --
ALTER TABLE lipas.kaukalo OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.luistelureitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.luistelureitti CASCADE;
CREATE TABLE lipas.luistelureitti (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	kiosk boolean,
	"equipmentRental" boolean,
	toilet boolean,
	ligthing boolean,
	"infoFi" text,
	"trackLengthM" numeric,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT luistelureitti_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
COMMENT ON COLUMN lipas.luistelureitti.ligthing IS E'Kirjoitusvirhe Lippaan päässä';
-- ddl-end --
ALTER TABLE lipas.luistelureitti OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.tekojaakentta | type: TABLE --
-- DROP TABLE IF EXISTS lipas.tekojaakentta CASCADE;
CREATE TABLE lipas.tekojaakentta (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	kiosk boolean,
	"changingRooms" boolean,
	toilet boolean,
	ligthing boolean,
	"infoFi" text,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT tekojaakentta_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
COMMENT ON COLUMN lipas.tekojaakentta.ligthing IS E'Kirjoitusvirhe Lippaan päässä';
-- ddl-end --
ALTER TABLE lipas.tekojaakentta OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.ruoanlaittopaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.ruoanlaittopaikka CASCADE;
CREATE TABLE lipas.ruoanlaittopaikka (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	toilet boolean,
	"infoFi" text,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT ruoanlaittopaikka_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.ruoanlaittopaikka OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.laavu_kota_kammi | type: TABLE --
-- DROP TABLE IF EXISTS lipas.laavu_kota_kammi CASCADE;
CREATE TABLE lipas.laavu_kota_kammi (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	toilet boolean,
	"infoFi" text,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT laavu_kota_kammi_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.laavu_kota_kammi OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.ulkoilumaja_hiihtomaja | type: TABLE --
-- DROP TABLE IF EXISTS lipas.ulkoilumaja_hiihtomaja CASCADE;
CREATE TABLE lipas.ulkoilumaja_hiihtomaja (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	toilet boolean,
	"infoFi" text,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT ulkoilumaja_hiihtomaja_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.ulkoilumaja_hiihtomaja OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.tupa | type: TABLE --
-- DROP TABLE IF EXISTS lipas.tupa CASCADE;
CREATE TABLE lipas.tupa (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	toilet boolean,
	"infoFi" text,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT tupa_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.tupa OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.telttailu_leiriytyminen | type: TABLE --
-- DROP TABLE IF EXISTS lipas.telttailu_leiriytyminen CASCADE;
CREATE TABLE lipas.telttailu_leiriytyminen (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	toilet boolean,
	"infoFi" text,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT telttailu_leiriytyminen_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.telttailu_leiriytyminen OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.lahiliikuntapaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.lahiliikuntapaikka CASCADE;
CREATE TABLE lipas.lahiliikuntapaikka (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	ligthing boolean,
	"accessibilityInfo" text,
	"infoFi" text,
	"exerciseMachinesCount" numeric,
	playground boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT lahiliikuntapaikka_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
COMMENT ON COLUMN lipas.lahiliikuntapaikka.ligthing IS E'Kirjoitusvirhe Lippaan päässä';
-- ddl-end --
ALTER TABLE lipas.lahiliikuntapaikka OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.ulkokuntoilupaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.ulkokuntoilupaikka CASCADE;
CREATE TABLE lipas.ulkokuntoilupaikka (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	ligthing boolean,
	"infoFi" text,
	"exerciseMachinesCount" numeric,
	playground boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT ulkokuntoilupaikka_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
COMMENT ON COLUMN lipas.ulkokuntoilupaikka.ligthing IS E'Kirjoitusvirhe Lippaan päässä';
-- ddl-end --
ALTER TABLE lipas.ulkokuntoilupaikka OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.koiraurheilualue | type: TABLE --
-- DROP TABLE IF EXISTS lipas.koiraurheilualue CASCADE;
CREATE TABLE lipas.koiraurheilualue (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	toilet boolean,
	ligthing boolean,
	"infoFi" text,
	"trackLengthM" numeric,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT koiraurheilualue_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
COMMENT ON COLUMN lipas.koiraurheilualue.ligthing IS E'Kirjoitusvirhe Lippaan päässä';
-- ddl-end --
ALTER TABLE lipas.koiraurheilualue OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.frisbeegolf_rata | type: TABLE --
-- DROP TABLE IF EXISTS lipas.frisbeegolf_rata CASCADE;
CREATE TABLE lipas.frisbeegolf_rata (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	ligthing boolean,
	"accessibilityInfo" text,
	"infoFi" text,
	"trackLengthM" numeric,
	"altitudeDifference" numeric,
	"holesCount" numeric,
	"trackType" text,
	range boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT frisbeegolf_rata_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
COMMENT ON COLUMN lipas.frisbeegolf_rata.ligthing IS E'Kirjoitusvirhe Lippaan päässä';
-- ddl-end --
ALTER TABLE lipas.frisbeegolf_rata OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.ulkokiipeilyseina | type: TABLE --
-- DROP TABLE IF EXISTS lipas.ulkokiipeilyseina CASCADE;
CREATE TABLE lipas.ulkokiipeilyseina (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	ligthing boolean,
	"infoFi" text,
	"climbingWallWidthM" numeric,
	"climbingWallHeightM" numeric,
	"climbingRoutesCount" numeric,
	"iceClimbing" boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT ulkokiipeilyseina_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
COMMENT ON COLUMN lipas.ulkokiipeilyseina.ligthing IS E'Kirjoitusvirhe Lippaan päässä';
-- ddl-end --
ALTER TABLE lipas.ulkokiipeilyseina OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.kiipeilykallio | type: TABLE --
-- DROP TABLE IF EXISTS lipas.kiipeilykallio CASCADE;
CREATE TABLE lipas.kiipeilykallio (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	ligthing boolean,
	"infoFi" text,
	"climbingWallWidthM" numeric,
	"climbingWallHeightM" numeric,
	"climbingRoutesCount" numeric,
	"iceClimbing" boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT kiipeilykallio_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
COMMENT ON COLUMN lipas.kiipeilykallio.ligthing IS E'Kirjoitusvirhe Lippaan päässä';
-- ddl-end --
ALTER TABLE lipas.kiipeilykallio OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.rantautumispaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.rantautumispaikka CASCADE;
CREATE TABLE lipas.rantautumispaikka (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	toilet boolean,
	"infoFi" text,
	pier boolean,
	"boatLaunchingSpot" boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT rantautumispaikka_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.rantautumispaikka OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.veneilyn_palvelupaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.veneilyn_palvelupaikka CASCADE;
CREATE TABLE lipas.veneilyn_palvelupaikka (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	toilet boolean,
	"infoFi" text,
	pier boolean,
	"boatLaunchingSpot" boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT veneilyn_palvelupaikka_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.veneilyn_palvelupaikka OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.kalastusalue_paikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.kalastusalue_paikka CASCADE;
CREATE TABLE lipas.kalastusalue_paikka (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	toilet boolean,
	"infoFi" text,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT kalastusalue_paikka_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.kalastusalue_paikka OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.koskimelontakeskus | type: TABLE --
-- DROP TABLE IF EXISTS lipas.koskimelontakeskus CASCADE;
CREATE TABLE lipas.koskimelontakeskus (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	"equipmentRental" boolean,
	"infoFi" text,
	"altitudeDifference" numeric,
	pier boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT koskimelontakeskus_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.koskimelontakeskus OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.luontotorni | type: TABLE --
-- DROP TABLE IF EXISTS lipas.luontotorni CASCADE;
CREATE TABLE lipas.luontotorni (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	toilet boolean,
	"infoFi" text,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT luontotorni_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.luontotorni OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.opastuspiste | type: TABLE --
-- DROP TABLE IF EXISTS lipas.opastuspiste CASCADE;
CREATE TABLE lipas.opastuspiste (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	toilet boolean,
	"infoFi" text,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT opastuspiste_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.opastuspiste OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.uimaranta | type: TABLE --
-- DROP TABLE IF EXISTS lipas.uimaranta CASCADE;
CREATE TABLE lipas.uimaranta (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	kiosk boolean,
	sauna boolean,
	shower boolean,
	"changingRooms" boolean,
	toilet boolean,
	"infoFi" text,
	pier boolean,
	"otherPlatforms" boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT uimaranta_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.uimaranta OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.uimapaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.uimapaikka CASCADE;
CREATE TABLE lipas.uimapaikka (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	kiosk boolean,
	sauna boolean,
	shower boolean,
	"changingRooms" boolean,
	toilet boolean,
	"infoFi" text,
	pier boolean,
	"otherPlatforms" boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT uimapaikka_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.uimapaikka OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.talviuintipaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.talviuintipaikka CASCADE;
CREATE TABLE lipas.talviuintipaikka (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	kiosk boolean,
	sauna boolean,
	shower boolean,
	"changingRooms" boolean,
	toilet boolean,
	"infoFi" text,
	pier boolean,
	"iceReduction" boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT talviuintipaikka_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.talviuintipaikka OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.lahipuisto | type: TABLE --
-- DROP TABLE IF EXISTS lipas.lahipuisto CASCADE;
CREATE TABLE lipas.lahipuisto (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	"infoFi" text,
	playground boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT lahipuisto_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.lahipuisto OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.ulkoilupuisto | type: TABLE --
-- DROP TABLE IF EXISTS lipas.ulkoilupuisto CASCADE;
CREATE TABLE lipas.ulkoilupuisto (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	"infoFi" text,
	playground boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT ulkoilupuisto_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.ulkoilupuisto OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.liikuntapuisto | type: TABLE --
-- DROP TABLE IF EXISTS lipas.liikuntapuisto CASCADE;
CREATE TABLE lipas.liikuntapuisto (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326),
	ligthing boolean,
	"accessibilityInfo" text,
	"infoFi" text,
	playground boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT liikuntapuisto_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
COMMENT ON COLUMN lipas.liikuntapuisto.ligthing IS E'Kirjoitusvirhe Lippaan päässä';
-- ddl-end --
ALTER TABLE lipas.liikuntapuisto OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.latu | type: TABLE --
-- DROP TABLE IF EXISTS lipas.latu CASCADE;
CREATE TABLE lipas.latu (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326),
	toilet boolean,
	"skiTrackTraditional" boolean,
	"skiTrackFreestyle" boolean,
	"restPlacesCount" numeric,
	"infoFi" text,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
	"shootingPositionsCount" numeric,
	"outdoorExerciseMachines" boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT latu_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.latu OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.koirahiihtolatu | type: TABLE --
-- DROP TABLE IF EXISTS lipas.koirahiihtolatu CASCADE;
CREATE TABLE lipas.koirahiihtolatu (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326),
	toilet boolean,
	"skiTrackTraditional" boolean,
	"skiTrackFreestyle" boolean,
	"restPlacesCount" numeric,
	"infoFi" text,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT koirahiihtolatu_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.koirahiihtolatu OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.melontareitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.melontareitti CASCADE;
CREATE TABLE lipas.melontareitti (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326),
	"restPlacesCount" numeric,
	"infoFi" text,
	"routeLengthKm" numeric,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT melontareitti_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.melontareitti OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.vesiretkeilyreitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.vesiretkeilyreitti CASCADE;
CREATE TABLE lipas.vesiretkeilyreitti (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326),
	"restPlacesCount" numeric,
	"infoFi" text,
	"routeLengthKm" numeric,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT vesiretkeilyreitti_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.vesiretkeilyreitti OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.pyorailyreitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.pyorailyreitti CASCADE;
CREATE TABLE lipas.pyorailyreitti (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326),
	toilet boolean,
	"restPlacesCount" numeric,
	"infoFi" text,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT pyorailyreitti_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.pyorailyreitti OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.maastopyorailyreitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.maastopyorailyreitti CASCADE;
CREATE TABLE lipas.maastopyorailyreitti (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326),
	toilet boolean,
	"restPlacesCount" numeric,
	"infoFi" text,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT maastopyorailyreitti_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.maastopyorailyreitti OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.kavely_ulkoilureitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.kavely_ulkoilureitti CASCADE;
CREATE TABLE lipas.kavely_ulkoilureitti (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326),
	toilet boolean,
	"restPlacesCount" numeric,
	"accessibilityInfo" text,
	"infoFi" text,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
	"outdoorExerciseMachines" boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT kavely_ulkoilureitti_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.kavely_ulkoilureitti OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.retkeilyreitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.retkeilyreitti CASCADE;
CREATE TABLE lipas.retkeilyreitti (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326),
	toilet boolean,
	"restPlacesCount" numeric,
	"accessibilityInfo" text,
	"infoFi" text,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT retkeilyreitti_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.retkeilyreitti OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.kuntorata | type: TABLE --
-- DROP TABLE IF EXISTS lipas.kuntorata CASCADE;
CREATE TABLE lipas.kuntorata (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326),
	toilet boolean,
	"restPlacesCount" numeric,
	"accessibilityInfo" text,
	"infoFi" text,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
	"shootingPositionsCount" numeric,
	"outdoorExerciseMachines" boolean,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT kuntorata_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.kuntorata OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.luontopolku | type: TABLE --
-- DROP TABLE IF EXISTS lipas.luontopolku CASCADE;
CREATE TABLE lipas.luontopolku (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326),
	"restPlacesCount" numeric,
	"accessibilityInfo" text,
	"infoFi" text,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT luontopolku_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.luontopolku OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.hevosreitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.hevosreitti CASCADE;
CREATE TABLE lipas.hevosreitti (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326),
	"restPlacesCount" numeric,
	"infoFi" text,
	"litRouteLengthKm" numeric,
	"routeLengthKm" numeric,
-- 	email text,
-- 	admin text,
-- 	www text,
-- 	name text NOT NULL,
-- 	"type_typeCode" integer,
-- 	type_name text,
-- 	"phoneNumber" text,
-- 	location_address text,
-- 	location_city_name text,
-- 	"location_postalOffice" text,
-- 	"location_postalCode" integer,
-- 	owner text,
	CONSTRAINT hevosreitti_pk PRIMARY KEY ("sportsPlaceId")
)
 INHERITS(lipas.abstract);
-- ddl-end --
ALTER TABLE lipas.hevosreitti OWNER TO tarmo_admin;
-- ddl-end --

-- object: lipas.metadata | type: TABLE --
-- DROP TABLE IF EXISTS lipas.metadata CASCADE;
CREATE TABLE lipas.metadata (
	"updateId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	last_modified timestamptz,
	"typeCodeList" jsonb,
	CONSTRAINT metadata_pk PRIMARY KEY ("updateId")
);
-- ddl-end --
ALTER TABLE lipas.metadata OWNER TO tarmo_admin;
-- ddl-end --

-- Appended SQL commands --
SET timezone = 'Europe/Helsinki';
-- ddl-end --

INSERT INTO lipas.metadata ("typeCodeList") VALUES ('[4640,4630,1520,1530,1550,1510,206,301,304,302,202,1120,1130,6210,1180,4710,4720,205,203,201,5150,3220,3230,3240,204,207,4402,4440,4451,4452,4412,4411,4403,4405,4401,4404,4430,101,102,1110]');
-- ddl-end --

-- object: kooste.lipas_kohteet_piste | type: TABLE --
-- DROP TABLE IF EXISTS kooste.lipas_kohteet_piste CASCADE;
CREATE TABLE kooste.lipas_kohteet_piste (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	name text NOT NULL,
	"type_typeCode" integer NOT NULL,
	type_name text NOT NULL,
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
	toilet boolean DEFAULT NULL,
	shower boolean DEFAULT NULL,
	"changingRooms" boolean DEFAULT NULL,
	ligthing boolean DEFAULT NULL,
	"restPlacesCount" numeric DEFAULT NULL,
	"skiTrackTraditional" boolean DEFAULT NULL,
	"skiTrackFreestyle" boolean DEFAULT NULL,
	"litRouteLengthKm" numeric DEFAULT NULL,
	"routeLengthKm" numeric DEFAULT NULL,
	pier boolean DEFAULT NULL,
	"otherPlatforms" boolean DEFAULT NULL,
	"accessibilityInfo" text DEFAULT NULL,
	kiosk boolean DEFAULT NULL,
	"skiService" boolean DEFAULT NULL,
	"equipmentRental" boolean DEFAULT NULL,
	sauna boolean DEFAULT NULL,
	playground boolean DEFAULT NULL,
	"exerciseMachines" boolean DEFAULT NULL,
	"infoFi" text DEFAULT NULL,
	"trackLengthM" numeric DEFAULT NULL,
	"altitudeDifference" numeric DEFAULT NULL,
	"climbingWallWidthM" numeric DEFAULT NULL,
	"climbingWallHeightM" numeric DEFAULT NULL,
	"climbingRoutesCount" numeric DEFAULT NULL,
	"holesCount" numeric DEFAULT NULL,
	"boatLaunchingSpot" boolean DEFAULT NULL,
	"iceClimbing" boolean DEFAULT NULL,
	"iceReduction" boolean DEFAULT NULL,
	range boolean DEFAULT NULL,
	"trackType" text DEFAULT NULL,
	status text DEFAULT NULL,
	"additionalInfo" text DEFAULT NULL,
	images text DEFAULT NULL,
	CONSTRAINT lipas_kohteet_piste_pk PRIMARY KEY ("sportsPlaceId")
);
-- ddl-end --
COMMENT ON COLUMN kooste.lipas_kohteet_piste.ligthing IS E'Lippaan päässä kirjoitusvirhe';
-- ddl-end --
ALTER TABLE kooste.lipas_kohteet_piste OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.lipas_kohteet_viiva | type: TABLE --
-- DROP TABLE IF EXISTS kooste.lipas_kohteet_viiva CASCADE;
CREATE TABLE kooste.lipas_kohteet_viiva (
	"sportsPlaceId" bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326) NOT NULL,
	name text NOT NULL,
	"type_typeCode" integer NOT NULL,
	type_name text NOT NULL,
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
	toilet boolean DEFAULT NULL,
	"restPlacesCount" numeric DEFAULT NULL,
	"skiTrackTraditional" boolean DEFAULT NULL,
	"skiTrackFreestyle" boolean DEFAULT NULL,
	"litRouteLengthKm" numeric DEFAULT NULL,
	"routeLengthKm" numeric DEFAULT NULL,
	"accessibilityInfo" text DEFAULT NULL,
	"exerciseMachines" boolean DEFAULT NULL,
	"infoFi" text DEFAULT NULL,
	"shootingPositionsCount" numeric DEFAULT NULL,
	status text DEFAULT NULL,
	"additionalInfo" text DEFAULT NULL,
	images text DEFAULT NULL,
	CONSTRAINT lipas_kohteet_viiva_pk PRIMARY KEY ("sportsPlaceId")
);
-- ddl-end --
ALTER TABLE kooste.lipas_kohteet_viiva OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.luonnonmuistomerkit | type: TABLE --
-- DROP TABLE IF EXISTS kooste.luonnonmuistomerkit CASCADE;
CREATE TABLE kooste.luonnonmuistomerkit (
	sw_member bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	nakyvyys boolean NOT NULL DEFAULT True,
	nimi text,
	kohteenkuvaus1 text,
	paatosnumero integer,
	paatospaiva date,
	CONSTRAINT luonnonmuistomerkit_pk PRIMARY KEY (sw_member)

);
-- ddl-end --
ALTER TABLE kooste.luonnonmuistomerkit OWNER TO tarmo_admin;
-- ddl-end --

-- object: grant_rawd_ea7249322e | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.abstract
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_d5a0ebb7a4 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.laavu_kota_kammi
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_385751eb2c | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.ulkoilumaja_hiihtomaja
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_f6792138ae | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.kilpahiihtokeskus
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_aa4340f30c | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.hiihtomaa
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_9de0cefd6e | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.luistelukentta
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_70feb249c3 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.kaukalo
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_929c8cb8d0 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.luistelureitti
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_be18d7e84d | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.tekojaakentta
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_58fbc9a661 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.tupa
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_142da93e6c | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.telttailu_leiriytyminen
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_b171fc4bbb | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.ruoanlaittopaikka
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_7776647e1e | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.lahiliikuntapaikka
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_7885e19c19 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.ulkokuntoilupaikka
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_551ca1ba30 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.frisbeegolf_rata
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_65c4b6cf41 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.ulkokiipeilyseina
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_e1bbfdfdc1 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.kiipeilykallio
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_7f1b37f8ff | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.koiraurheilualue
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_9f1ea33431 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.uimaranta
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_ee4936b969 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.uimapaikka
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_c74bdffcca | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.talviuintipaikka
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_5f7558ca89 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.veneilyn_palvelupaikka
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_885358e6f1 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.rantautumispaikka
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_402c5b383b | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.kalastusalue_paikka
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_b81fff6f25 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.koskimelontakeskus
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_653df07382 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.opastuspiste
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_633733e892 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.luontotorni
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_fb738edd35 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.lahipuisto
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_70c1b2bb48 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.ulkoilupuisto
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_0b22490a01 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.liikuntapuisto
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_7ceba2b2f1 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.latu
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_9fbe5d3851 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.koirahiihtolatu
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_41698507ad | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.melontareitti
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_e1a802c1b3 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.vesiretkeilyreitti
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_6c614eb2a4 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.pyorailyreitti
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_081d1422a8 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.maastopyorailyreitti
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_5ff0776190 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.kavely_ulkoilureitti
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_426d5bdeaf | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.retkeilyreitti
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_7ad9cecd48 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.kuntorata
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_94532b96a1 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.luontopolku
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_fb01de299a | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.hevosreitti
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_rawd_6bd09fd3fa | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.metadata
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_a4eb7cf4b1 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.lipas_kohteet_piste
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_eb6ff88ef6 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.lipas_kohteet_piste
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_5edde85695 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.lipas_kohteet_viiva
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_9553cb2e9b | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.lipas_kohteet_viiva
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_b0576134c9 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.luonnonmuistomerkit
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_b182858222 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.luonnonmuistomerkit
   TO tarmo_read_write;
-- ddl-end --

-- object: "grant_U_e822f7d865" | type: PERMISSION --
GRANT USAGE
   ON SCHEMA lipas
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
