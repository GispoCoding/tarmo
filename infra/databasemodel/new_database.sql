-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler version: 0.9.4-beta
-- PostgreSQL version: 13.0
-- Project Site: pgmodeler.io
-- Model Author: ---
-- object: trerkp_admin | type: ROLE --
-- DROP ROLE IF EXISTS trerkp_admin;
CREATE ROLE trerkp_admin WITH
	SUPERUSER
	CREATEDB
	CREATEROLE
	LOGIN;
-- ddl-end --


-- Database creation must be performed outside a multi lined SQL file.
-- These commands were put in this file only as a convenience.
--
-- object: new_database | type: DATABASE --
-- DROP DATABASE IF EXISTS new_database;
-- CREATE DATABASE new_database;
-- ddl-end --


-- object: lipas | type: SCHEMA --
-- DROP SCHEMA IF EXISTS lipas CASCADE;
CREATE SCHEMA lipas;
-- ddl-end --
ALTER SCHEMA lipas OWNER TO trerkp_admin;
-- ddl-end --

-- object: kooste | type: SCHEMA --
-- DROP SCHEMA IF EXISTS kooste CASCADE;
CREATE SCHEMA kooste;
-- ddl-end --
ALTER SCHEMA kooste OWNER TO trerkp_admin;
-- ddl-end --

SET search_path TO pg_catalog,public,lipas,kooste;
-- ddl-end --

-- object: postgis | type: EXTENSION --
-- DROP EXTENSION IF EXISTS postgis CASCADE;
CREATE EXTENSION postgis
WITH SCHEMA lipas;
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
ALTER TABLE lipas.abstract OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.luistelukentta | type: TABLE --
-- DROP TABLE IF EXISTS lipas.luistelukentta CASCADE;
CREATE TABLE lipas.luistelukentta (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.luistelukentta OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.hiihtomaa | type: TABLE --
-- DROP TABLE IF EXISTS lipas.hiihtomaa CASCADE;
CREATE TABLE lipas.hiihtomaa (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.hiihtomaa OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.kilpahiihtokeskus | type: TABLE --
-- DROP TABLE IF EXISTS lipas.kilpahiihtokeskus CASCADE;
CREATE TABLE lipas.kilpahiihtokeskus (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.kilpahiihtokeskus OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.kaukalo | type: TABLE --
-- DROP TABLE IF EXISTS lipas.kaukalo CASCADE;
CREATE TABLE lipas.kaukalo (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.kaukalo OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.luistelureitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.luistelureitti CASCADE;
CREATE TABLE lipas.luistelureitti (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.luistelureitti OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.tekojaakentta | type: TABLE --
-- DROP TABLE IF EXISTS lipas.tekojaakentta CASCADE;
CREATE TABLE lipas.tekojaakentta (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.tekojaakentta OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.ruoanlaittopaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.ruoanlaittopaikka CASCADE;
CREATE TABLE lipas.ruoanlaittopaikka (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.ruoanlaittopaikka OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.laavu_kota_kammi | type: TABLE --
-- DROP TABLE IF EXISTS lipas.laavu_kota_kammi CASCADE;
CREATE TABLE lipas.laavu_kota_kammi (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.laavu_kota_kammi OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.ulkoilumaja_hiihtomaja | type: TABLE --
-- DROP TABLE IF EXISTS lipas.ulkoilumaja_hiihtomaja CASCADE;
CREATE TABLE lipas.ulkoilumaja_hiihtomaja (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.ulkoilumaja_hiihtomaja OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.tupa | type: TABLE --
-- DROP TABLE IF EXISTS lipas.tupa CASCADE;
CREATE TABLE lipas.tupa (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.tupa OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.telttailu_leiriytyminen | type: TABLE --
-- DROP TABLE IF EXISTS lipas.telttailu_leiriytyminen CASCADE;
CREATE TABLE lipas.telttailu_leiriytyminen (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.telttailu_leiriytyminen OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.lahiliikuntapaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.lahiliikuntapaikka CASCADE;
CREATE TABLE lipas.lahiliikuntapaikka (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.lahiliikuntapaikka OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.ulkokuntoilupaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.ulkokuntoilupaikka CASCADE;
CREATE TABLE lipas.ulkokuntoilupaikka (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.ulkokuntoilupaikka OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.koiraurheilualue | type: TABLE --
-- DROP TABLE IF EXISTS lipas.koiraurheilualue CASCADE;
CREATE TABLE lipas.koiraurheilualue (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.koiraurheilualue OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.frisbeegolf_rata | type: TABLE --
-- DROP TABLE IF EXISTS lipas.frisbeegolf_rata CASCADE;
CREATE TABLE lipas.frisbeegolf_rata (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.frisbeegolf_rata OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.ulkokiipeilyseina | type: TABLE --
-- DROP TABLE IF EXISTS lipas.ulkokiipeilyseina CASCADE;
CREATE TABLE lipas.ulkokiipeilyseina (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.ulkokiipeilyseina OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.kiipeilykallio | type: TABLE --
-- DROP TABLE IF EXISTS lipas.kiipeilykallio CASCADE;
CREATE TABLE lipas.kiipeilykallio (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.kiipeilykallio OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.rantautumispaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.rantautumispaikka CASCADE;
CREATE TABLE lipas.rantautumispaikka (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.rantautumispaikka OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.veneilyn_palvelupaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.veneilyn_palvelupaikka CASCADE;
CREATE TABLE lipas.veneilyn_palvelupaikka (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.veneilyn_palvelupaikka OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.kalastusalue_paikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.kalastusalue_paikka CASCADE;
CREATE TABLE lipas.kalastusalue_paikka (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.kalastusalue_paikka OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.koskimelontakeskus | type: TABLE --
-- DROP TABLE IF EXISTS lipas.koskimelontakeskus CASCADE;
CREATE TABLE lipas.koskimelontakeskus (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.koskimelontakeskus OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.luontotorni | type: TABLE --
-- DROP TABLE IF EXISTS lipas.luontotorni CASCADE;
CREATE TABLE lipas.luontotorni (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.luontotorni OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.opastuspiste | type: TABLE --
-- DROP TABLE IF EXISTS lipas.opastuspiste CASCADE;
CREATE TABLE lipas.opastuspiste (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.opastuspiste OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.uimaranta | type: TABLE --
-- DROP TABLE IF EXISTS lipas.uimaranta CASCADE;
CREATE TABLE lipas.uimaranta (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.uimaranta OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.uimapaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.uimapaikka CASCADE;
CREATE TABLE lipas.uimapaikka (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.uimapaikka OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.talviuintipaikka | type: TABLE --
-- DROP TABLE IF EXISTS lipas.talviuintipaikka CASCADE;
CREATE TABLE lipas.talviuintipaikka (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.talviuintipaikka OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.lahipuisto | type: TABLE --
-- DROP TABLE IF EXISTS lipas.lahipuisto CASCADE;
CREATE TABLE lipas.lahipuisto (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.lahipuisto OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.ulkoilupuisto | type: TABLE --
-- DROP TABLE IF EXISTS lipas.ulkoilupuisto CASCADE;
CREATE TABLE lipas.ulkoilupuisto (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.ulkoilupuisto OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.liikuntapuisto | type: TABLE --
-- DROP TABLE IF EXISTS lipas.liikuntapuisto CASCADE;
CREATE TABLE lipas.liikuntapuisto (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067),
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
ALTER TABLE lipas.liikuntapuisto OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.koirahiihtolatu | type: TABLE --
-- DROP TABLE IF EXISTS lipas.koirahiihtolatu CASCADE;
CREATE TABLE lipas.koirahiihtolatu (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTILINESTRING, 3067),
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
ALTER TABLE lipas.koirahiihtolatu OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.melontareitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.melontareitti CASCADE;
CREATE TABLE lipas.melontareitti (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTILINESTRING, 3067),
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
ALTER TABLE lipas.melontareitti OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.vesiretkeilyreitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.vesiretkeilyreitti CASCADE;
CREATE TABLE lipas.vesiretkeilyreitti (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTILINESTRING, 3067),
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
ALTER TABLE lipas.vesiretkeilyreitti OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.pyorailyreitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.pyorailyreitti CASCADE;
CREATE TABLE lipas.pyorailyreitti (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTILINESTRING, 3067),
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
ALTER TABLE lipas.pyorailyreitti OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.maastopyorailyreitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.maastopyorailyreitti CASCADE;
CREATE TABLE lipas.maastopyorailyreitti (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTILINESTRING, 3067),
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
ALTER TABLE lipas.maastopyorailyreitti OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.kavely_ulkoilureitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.kavely_ulkoilureitti CASCADE;
CREATE TABLE lipas.kavely_ulkoilureitti (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTILINESTRING, 3067),
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
ALTER TABLE lipas.kavely_ulkoilureitti OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.retkeilyreitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.retkeilyreitti CASCADE;
CREATE TABLE lipas.retkeilyreitti (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTILINESTRING, 3067),
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
ALTER TABLE lipas.retkeilyreitti OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.kuntorata | type: TABLE --
-- DROP TABLE IF EXISTS lipas.kuntorata CASCADE;
CREATE TABLE lipas.kuntorata (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTILINESTRING, 3067),
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
ALTER TABLE lipas.kuntorata OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.luontopolku | type: TABLE --
-- DROP TABLE IF EXISTS lipas.luontopolku CASCADE;
CREATE TABLE lipas.luontopolku (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTILINESTRING, 3067),
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
ALTER TABLE lipas.luontopolku OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.hevosreitti | type: TABLE --
-- DROP TABLE IF EXISTS lipas.hevosreitti CASCADE;
CREATE TABLE lipas.hevosreitti (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTILINESTRING, 3067),
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
ALTER TABLE lipas.hevosreitti OWNER TO trerkp_admin;
-- ddl-end --

-- object: kooste.lipas_kohteet_piste | type: TABLE --
-- DROP TABLE IF EXISTS kooste.lipas_kohteet_piste CASCADE;
CREATE TABLE kooste.lipas_kohteet_piste (
	"koosteId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 3067) NOT NULL,
	name text NOT NULL,
	"typeCode" integer NOT NULL,
	"typeName" text NOT NULL,
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
	lighting boolean DEFAULT NULL,
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
	additionalInfo text DEFAULT NULL,
	images text DEFAULT NULL,
	CONSTRAINT lipas_kohteet_piste_pk PRIMARY KEY ("koosteId")

);
-- ddl-end --
ALTER TABLE kooste.lipas_kohteet_piste OWNER TO trerkp_admin;
-- ddl-end --

-- object: lipas.latu | type: TABLE --
-- DROP TABLE IF EXISTS lipas.latu CASCADE;
CREATE TABLE lipas.latu (
	"sportsPlaceId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTILINESTRING, 3067),
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
ALTER TABLE lipas.latu OWNER TO trerkp_admin;
-- ddl-end --

-- object: kooste.lipas_kohteet_viiva | type: TABLE --
-- DROP TABLE IF EXISTS kooste.lipas_kohteet_viiva CASCADE;
CREATE TABLE kooste.lipas_kohteet_viiva (
	"koosteId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTILINESTRING, 3067) NOT NULL,
	name text NOT NULL,
	"typeCode" integer NOT NULL,
	"typeName" text NOT NULL,
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
	additionalInfo text DEFAULT NULL,
	images text DEFAULT NULL,
	CONSTRAINT lipas_kohteet_viiva_pk PRIMARY KEY ("koosteId")

);
-- ddl-end --
ALTER TABLE kooste.lipas_kohteet_viiva OWNER TO trerkp_admin;
-- ddl-end --
