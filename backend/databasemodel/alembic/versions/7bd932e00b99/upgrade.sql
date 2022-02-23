ALTER TABLE kooste.lipas_kohteet_piste
RENAME TO lipas_pisteet;

--sp_rename @objname = N'[kooste.lipas_pisteet].[kooste.lipas_kohteet_piste_pk]', @newname = N'lipas_pisteet_pk'

ALTER TABLE kooste.lipas_kohteet_viiva
RENAME TO lipas_viivat;

ALTER TABLE lipas.metadata
RENAME COLUMN "updateId" TO update_id;

ALTER TABLE lipas.metadata
RENAME COLUMN "typeCodeList" TO type_code_list;

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
	update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	datasource text NOT NULL,
	last_modified timestamptz,
	CONSTRAINT metadata_pk PRIMARY KEY (update_id)

);
-- ddl-end --
COMMENT ON COLUMN kooste.metadata.datasource IS E'You can get this information from table names by selecting the part before underscore character';
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
