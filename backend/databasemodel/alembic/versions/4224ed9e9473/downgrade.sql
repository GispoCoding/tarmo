ALTER TABLE kooste.osm_pisteet DROP CONSTRAINT osm_pisteet_pk;
ALTER TABLE kooste.osm_alueet DROP CONSTRAINT osm_alueet_pk;
ALTER TABLE kooste.osm_pisteet DROP COLUMN id;
ALTER TABLE kooste.osm_alueet DROP COLUMN id;

ALTER TABLE kooste.osm_pisteet ADD COLUMN id bigint NOT NULL GENERATED ALWAYS AS IDENTITY;
ALTER TABLE kooste.osm_alueet ADD COLUMN id bigint NOT NULL GENERATED ALWAYS AS IDENTITY;
ALTER TABLE kooste.osm_pisteet ADD CONSTRAINT osm_kohteet_piste_pk PRIMARY KEY (id);
ALTER TABLE kooste.osm_alueet ADD CONSTRAINT osm_kohteet_alue_pk PRIMARY KEY (id);
