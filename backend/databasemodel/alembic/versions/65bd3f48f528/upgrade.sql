-- object: kooste.syke_natura2000 | type: TABLE --
-- DROP TABLE IF EXISTS kooste.syke_natura2000 CASCADE;
CREATE TABLE kooste.syke_natura2000 (
	"naturaTunnus" text NOT NULL,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	name text NOT NULL,
	tarmo_category text DEFAULT 'Tausta-aineistot',
	type_name text DEFAULT 'Natura-alue',
	"paatosPvm" date,
	"luontiPvm" date,
	"muutosPvm" date,
	"paattymisPvm" date,
	CONSTRAINT syke_natura2000_pk PRIMARY KEY ("naturaTunnus")
);
-- ddl-end --
ALTER TABLE kooste.syke_natura2000 OWNER TO tarmo_admin;
-- ddl-end --

-- object: kooste.syke_valtionluonnonsuojelualueet | type: TABLE --
-- DROP TABLE IF EXISTS kooste.syke_valtionluonnonsuojelualueet CASCADE;
CREATE TABLE kooste.syke_valtionluonnonsuojelualueet (
	"LsAlueTunnus" text NOT NULL,
	geom geometry(MULTIPOINT, 4326) NOT NULL,
	name text NOT NULL,
	tarmo_category text DEFAULT 'Tausta-aineistot',
	type_name text DEFAULT 'Valtion luonnonsuojelualue',
	"infoFi" text,
	"PaatPvm" date,
	"PaatNimi" text,
	"VoimaantuloPvm" date,
	"MuutosPvm" date,
	"LakkautusPvm" date,
	CONSTRAINT syke_valtionluonnonsuojelualueet_pk PRIMARY KEY ("LsAlueTunnus")
);
-- ddl-end --
ALTER TABLE kooste.syke_valtionluonnonsuojelualueet OWNER TO tarmo_admin;
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
