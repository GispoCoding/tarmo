-- object: kooste.lipas_kohteet_piste | type: TABLE --
DROP TABLE IF EXISTS lipas.metadata CASCADE;

-- object: lipas.metadata | type: TABLE --
-- DROP TABLE IF EXISTS lipas.metadata CASCADE;
CREATE TABLE lipas.metadata (
	"updateId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	"lastModified" timestamptz,
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

-- object: grant_rawd_6bd09fd3fa | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE lipas.metadata
   TO tarmo_read_write;
-- ddl-end --

-- object: kooste.lipas_pisteet | type: TABLE --
DROP TABLE IF EXISTS kooste.lipas_pisteet CASCADE;

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

-- object: kooste.lipas_viivat | type: TABLE --
DROP TABLE IF EXISTS kooste.lipas_viivat CASCADE;

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

-- object: kooste.tamperewfs_luontorastit | type: TABLE --
DROP TABLE IF EXISTS kooste.tamperewfs_luontorastit CASCADE;

-- object: kooste.tamperewfs_luontopolut | type: TABLE --
DROP TABLE IF EXISTS kooste.tamperewfs_luontopolut CASCADE;

-- object: kooste.museovirastoarcrest_rkykohteet | type: TABLE --
DROP TABLE IF EXISTS kooste.museovirastoarcrest_rkykohteet CASCADE;

-- object: kooste.museovirastoarcrest_muinaisjaannokset | type: TABLE --
DROP TABLE IF EXISTS kooste.museovirastoarcrest_muinaisjaannokset CASCADE;

-- object: kooste.metadata | type: TABLE --
DROP TABLE IF EXISTS kooste.metadata CASCADE;
