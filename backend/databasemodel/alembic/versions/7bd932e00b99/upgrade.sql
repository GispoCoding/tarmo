-- object: kooste.lipas_kohteet_piste | type: TABLE --
DROP TABLE IF EXISTS kooste.lipas_kohteet_piste CASCADE;

-- object: kooste.lipas_pisteet | type: TABLE --
-- DROP TABLE IF EXISTS kooste.lipas_pisteet CASCADE;
CREATE TABLE kooste.lipas_pisteet (
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
	CONSTRAINT lipas_pisteet_pk PRIMARY KEY ("sportsPlaceId")
);
-- ddl-end --
COMMENT ON COLUMN kooste.lipas_pisteet.ligthing IS E'Lippaan päässä kirjoitusvirhe';
-- ddl-end --
ALTER TABLE kooste.lipas_pisteet OWNER TO tarmo_admin;
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

-- object: kooste.lipas_kohteet_viiva | type: TABLE --
DROP TABLE IF EXISTS kooste.lipas_kohteet_viiva CASCADE;

-- object: kooste.lipas_viivat | type: TABLE --
-- DROP TABLE IF EXISTS kooste.lipas_viivat CASCADE;
CREATE TABLE kooste.lipas_viivat (
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
	CONSTRAINT lipas_viivat_pk PRIMARY KEY ("sportsPlaceId")
);
-- ddl-end --
ALTER TABLE kooste.lipas_viivat OWNER TO tarmo_admin;
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

-- object: kooste.tamperewfs_luontorastit | type: TABLE --
-- DROP TABLE IF EXISTS kooste.tamperewfs_luontorastit CASCADE;
CREATE TABLE kooste.tamperewfs_luontorastit (
	kooste_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	nakyvyys boolean NOT NULL DEFAULT True,
	nimi text,
	tunnus integer,
	rasti integer,
	kohteenkuvaus text,
	lisatietoja text,
	CONSTRAINT tamperewfs_luontorastit_pk PRIMARY KEY (kooste_id)

);
-- ddl-end --
ALTER TABLE kooste.tamperewfs_luontorastit OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.tamperewfs_luontopolut | type: TABLE --
-- DROP TABLE IF EXISTS kooste.tamperewfs_luontopolut CASCADE;
CREATE TABLE kooste.tamperewfs_luontopolut (
	tunnus bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326) NOT NULL,
	nakyvyys boolean NOT NULL DEFAULT True,
	nimi text,
	CONSTRAINT tamperewfs_luontopolut_pk PRIMARY KEY (tunnus)

);
-- ddl-end --
ALTER TABLE kooste.tamperewfs_luontopolut OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.museovirastoarcrest_rkykohteet | type: TABLE --
-- DROP TABLE IF EXISTS kooste.museovirastoarcrest_rkykohteet CASCADE;
CREATE TABLE kooste.museovirastoarcrest_rkykohteet (
	"objectId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 3067) NOT NULL,
	nakyvyys boolean NOT NULL DEFAULT True,
	kohdenimi text,
	url text,
	CONSTRAINT museovirastoarcrest_rkykohteet_pk PRIMARY KEY ("objectId")

);
-- ddl-end --
ALTER TABLE kooste.museovirastoarcrest_rkykohteet OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.museovirastoarcrest_muinaisjaannokset | type: TABLE --
-- DROP TABLE IF EXISTS kooste.museovirastoarcrest_muinaisjaannokset CASCADE;
CREATE TABLE kooste.museovirastoarcrest_muinaisjaannokset (
	mjtunnus bigint NOT NULL,
	geom geometry(MULTIPOINT, 3067) NOT NULL,
	nakyvyys boolean NOT NULL DEFAULT True,
	kohdenimi text,
	laji text,
	kunta text,
	tyyppi text,
	alatyyppi text,
	ajoitus text,
	vedenalainen boolean,
	luontipvm date,
	muutospvm date,
	url text,
	CONSTRAINT museovirastoarcrest_muinaisjaannokset_pk PRIMARY KEY (mjtunnus)

);
-- ddl-end --
ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.metadata | type: TABLE --
-- DROP TABLE IF EXISTS kooste.metadata CASCADE;
CREATE TABLE kooste.metadata (
	"updateId" bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	"dataSource" text NOT NULL,
	"lastModified" timestamptz,
	CONSTRAINT metadata_pk PRIMARY KEY ("updateId")

);
-- ddl-end --
COMMENT ON COLUMN kooste.metadata.dataSource IS E'You can get this information from table names by selecting the part before underscore character';
-- ddl-end --
ALTER TABLE kooste.metadata OWNER TO tarmo_admin;
-- ddl-end --

-- object: grant_r_6fccdd230c | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.tamperewfs_luontorastit
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_69ac05820f | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.tamperewfs_luontorastit
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_fdbd4d94a9 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.tamperewfs_luontopolut
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_a905fd4ec3 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.tamperewfs_luontopolut
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

-- object: grant_r_91bcc10e15 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.metadata
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_5082180c53 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.metadata
   TO tarmo_read_write;
-- ddl-end --
