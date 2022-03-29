ALTER TABLE kooste.osm_pisteet DROP CONSTRAINT osm_pisteet_pk;
ALTER TABLE kooste.osm_alueet DROP CONSTRAINT osm_alueet_pk;
ALTER TABLE kooste.osm_pisteet DROP COLUMN id;
ALTER TABLE kooste.osm_alueet DROP COLUMN id;
ALTER TABLE kooste.osm_pisteet
ADD COLUMN id text NOT NULL GENERATED ALWAYS AS (osm_type || '-' || CAST(osm_id AS TEXT)) STORED;
ALTER TABLE kooste.osm_alueet
ADD COLUMN id text NOT NULL GENERATED ALWAYS AS (osm_type || '-' || CAST(osm_id AS TEXT)) STORED;
ALTER TABLE kooste.osm_pisteet
ADD CONSTRAINT osm_pisteet_pk PRIMARY KEY (id);
ALTER TABLE kooste.osm_alueet
ADD CONSTRAINT osm_alueet_pk PRIMARY KEY (id);
