CREATE TABLE kooste.osm_kohteet_piste (
	id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
	osm_id bigint NOT NULL,
	osm_type text NOT NULL,
	geom geometry(POINT, 4326) NOT NULL,
	tags jsonb,
	CONSTRAINT osm_kohteet_piste_pk PRIMARY KEY (id),
	UNIQUE (osm_id, osm_type)
);
ALTER TABLE kooste.osm_kohteet_piste OWNER TO tarmo_admin;

CREATE TABLE kooste.osm_kohteet_alue (
	id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
	osm_id bigint NOT NULL,
	osm_type text NOT NULL,
	geom geometry(POLYGON, 4326) NOT NULL,
	tags jsonb,
	CONSTRAINT osm_kohteet_alue_pk PRIMARY KEY (id),
	UNIQUE (osm_id, osm_type)
);
ALTER TABLE kooste.osm_kohteet_piste OWNER TO tarmo_admin;

CREATE TABLE kooste.osm_metadata (
	update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	last_modified timestamptz,
	tags_to_include jsonb,
	tags_to_exclude jsonb,
	CONSTRAINT osm_metadata_pk PRIMARY KEY (update_id)
);
ALTER TABLE kooste.osm_metadata OWNER TO tarmo_admin;
INSERT INTO kooste.osm_metadata (tags_to_include, tags_to_exclude) VALUES ('{"amenity": ["parking"]}', '{"access": ["private"]}');

GRANT SELECT
   ON TABLE kooste.osm_kohteet_piste
   TO tarmo_read;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.osm_kohteet_piste
   TO tarmo_read_write;

GRANT SELECT
   ON TABLE kooste.osm_kohteet_alue
   TO tarmo_read;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.osm_kohteet_alue
   TO tarmo_read_write;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.osm_metadata
   TO tarmo_read_write;
