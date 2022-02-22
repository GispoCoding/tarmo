-- object: kooste.luontorastit | type: TABLE --
-- DROP TABLE IF EXISTS kooste.luontorastit CASCADE;
CREATE TABLE kooste.luontorastit (
	kooste_id bigint NOT NULL,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	nakyvyys boolean NOT NULL DEFAULT True,
	nimi text,
	tunnus integer,
	rasti integer,
	kohteenkuvaus text,
	lisatietoja text,
	CONSTRAINT luontorastit_pk PRIMARY KEY (kooste_id)

);
-- ddl-end --
ALTER TABLE kooste.luontorastit OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.luontopolut | type: TABLE --
-- DROP TABLE IF EXISTS kooste.luontopolut CASCADE;
CREATE TABLE kooste.luontopolut (
	tunnus bigint NOT NULL,
	geom geometry(MULTILINESTRING, 4326) NOT NULL,
	nakyvyys boolean NOT NULL DEFAULT True,
	nimi text,
	CONSTRAINT luontopolut_pk PRIMARY KEY (tunnus)

);
-- ddl-end --
ALTER TABLE kooste.luontopolut OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.rkykohteet | type: TABLE --
-- DROP TABLE IF EXISTS kooste.rkykohteet CASCADE;
CREATE TABLE kooste.rkykohteet (
	"objectId" bigint NOT NULL,
	geom geometry(MULTIPOINT, 3067) NOT NULL,
	nakyvyys boolean NOT NULL DEFAULT True,
	kohdenimi text,
	url text,
	CONSTRAINT rkykohteet_pk PRIMARY KEY ("objectId")

);
-- ddl-end --
ALTER TABLE kooste.rkykohteet OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.muinaisjaannokset | type: TABLE --
-- DROP TABLE IF EXISTS kooste.muinaisjaannokset CASCADE;
CREATE TABLE kooste.muinaisjaannokset (
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
	CONSTRAINT muinaisjaannokset_pk PRIMARY KEY (mjtunnus)

);
-- ddl-end --
ALTER TABLE kooste.muinaisjaannokset OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.metadata | type: TABLE --
-- DROP TABLE IF EXISTS kooste.metadata CASCADE;
CREATE TABLE kooste.metadata (
	"updateId" bigint NOT NULL,
	"dataSource" text NOT NULL,
	"lastModified" timestamptz,
	CONSTRAINT metadata_pk PRIMARY KEY ("updateId")

);
-- ddl-end --
ALTER TABLE kooste.metadata OWNER TO tarmo_admin;
-- ddl-end --

-- object: grant_r_6fccdd230c | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.luontorastit
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_69ac05820f | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.luontorastit
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_fdbd4d94a9 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.luontopolut
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_a905fd4ec3 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.luontopolut
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_d0fe98abc4 | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.rkykohteet
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_c9b052d3eb | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.rkykohteet
   TO tarmo_read_write;
-- ddl-end --

-- object: grant_r_7ed8f2c81c | type: PERMISSION --
GRANT SELECT
   ON TABLE kooste.muinaisjaannokset
   TO tarmo_read;
-- ddl-end --

-- object: grant_rawd_a4e8798254 | type: PERMISSION --
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.muinaisjaannokset
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
