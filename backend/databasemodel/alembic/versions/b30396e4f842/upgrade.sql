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
