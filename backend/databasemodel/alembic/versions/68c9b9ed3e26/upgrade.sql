ALTER TABLE kooste.museovirastoarcrest_rkykohteet DROP CONSTRAINT museovirastoarcrest_rkykohteet_pk;
ALTER TABLE kooste.museovirastoarcrest_rkykohteet DROP COLUMN "objectId";
ALTER TABLE kooste.museovirastoarcrest_rkykohteet ADD COLUMN id bigint NOT NULL;
ALTER TABLE kooste.museovirastoarcrest_rkykohteet ADD CONSTRAINT museovirastoarcrest_rkykohteet_pk PRIMARY KEY (id);
ALTER TABLE kooste.museovirastoarcrest_rkykohteet DROP COLUMN geom;
ALTER TABLE kooste.museovirastoarcrest_rkykohteet ADD COLUMN geom geometry(MULTIPOINT, 4326) NOT NULL;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset DROP COLUMN geom;
ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset ADD COLUMN geom geometry(MULTIPOINT, 4326) NOT NULL;

CREATE TABLE kooste.museovirastoarcrest_metadata (
	update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
	last_modified timestamptz,
	layers_to_include jsonb,
	url text DEFAULT 'http://kartta.nba.fi/arcgis/rest/services/',
	CONSTRAINT museovirastoarcrest_metadata_pk PRIMARY KEY (update_id)

);
ALTER TABLE kooste.museovirastoarcrest_metadata OWNER TO tarmo_admin;
INSERT INTO kooste.museovirastoarcrest_metadata(
	layers_to_include
) VALUES (
	'{"WFS/MV_KulttuuriymparistoSuojellut": ["Muinaisjaannokset_piste", "RKY_piste"]}'
);
GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.museovirastoarcrest_metadata
   TO tarmo_read_write;



CREATE TABLE kooste.syke_metadata (
	update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
	last_modified timestamptz,
	layers_to_include jsonb,
	url text DEFAULT 'http://kartta.nba.fi/arcgis/rest/services/',
	CONSTRAINT museovirastoarcrest_metadata_pk PRIMARY KEY (update_id)

);

ALTER TABLE kooste.syke_metadata OWNER TO tarmo_admin;

INSERT INTO kooste.syke_metadata(
	layers_to_include
) VALUES (
	'{"WFS/MV_KulttuuriymparistoSuojellut": ["Muinaisjaannokset_piste", "RKY_piste"]}'
);
