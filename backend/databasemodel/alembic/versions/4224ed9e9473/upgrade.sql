-- Here the constraints still retain their old names :(
ALTER TABLE kooste.osm_pisteet DROP CONSTRAINT osm_kohteet_piste_pk;
ALTER TABLE kooste.osm_alueet DROP CONSTRAINT osm_kohteet_alue_pk;
ALTER TABLE kooste.osm_pisteet DROP COLUMN id;
ALTER TABLE kooste.osm_alueet DROP COLUMN id;

ALTER TABLE kooste.osm_pisteet ADD COLUMN id text NOT NULL GENERATED ALWAYS AS (osm_type || '-' || CAST(osm_id AS TEXT)) STORED;
ALTER TABLE kooste.osm_alueet ADD COLUMN id text NOT NULL GENERATED ALWAYS AS (osm_type || '-' || CAST(osm_id AS TEXT)) STORED;
--  Change the names while we're at it
ALTER TABLE kooste.osm_pisteet ADD CONSTRAINT osm_pisteet_pk PRIMARY KEY (id);
ALTER TABLE kooste.osm_alueet ADD CONSTRAINT osm_alueet_pk PRIMARY KEY (id);
