ALTER TABLE kooste.museovirastoarcrest_rkykohteet DROP CONSTRAINT museovirastoarcrest_rkykohteet_pk;
ALTER TABLE kooste.museovirastoarcrest_rkykohteet DROP COLUMN "objectId";
ALTER TABLE kooste.museovirastoarcrest_rkykohteet
ADD COLUMN "ID" bigint NOT NULL;
ALTER TABLE kooste.museovirastoarcrest_rkykohteet
ADD CONSTRAINT museovirastoarcrest_rkykohteet_pk PRIMARY KEY ("ID");

ALTER TABLE kooste.museovirastoarcrest_rkykohteet DROP COLUMN geom;
ALTER TABLE kooste.museovirastoarcrest_rkykohteet
ADD COLUMN geom geometry(MULTIPOINT, 4326) NOT NULL;
ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset DROP COLUMN geom;
ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
ADD COLUMN geom geometry(MULTIPOINT, 4326) NOT NULL;

CREATE TABLE kooste.museovirastoarcrest_metadata (
    update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    last_modified timestamptz,
    layers_to_include jsonb,
    url text DEFAULT 'https://kartta.nba.fi/arcgis/rest/services/',
    CONSTRAINT museovirastoarcrest_metadata_pk PRIMARY KEY (update_id)
);
ALTER TABLE kooste.museovirastoarcrest_metadata OWNER TO tarmo_admin;
INSERT INTO kooste.museovirastoarcrest_metadata(layers_to_include)
VALUES (
        '{"WFS/MV_KulttuuriymparistoSuojellut": ["Muinaisjaannokset_piste", "RKY_piste"]}'
    );
GRANT SELECT,
    INSERT,
    UPDATE,
    DELETE ON TABLE kooste.museovirastoarcrest_metadata TO tarmo_read_write;

ALTER TABLE kooste.syke_natura2000 DROP COLUMN geom;
ALTER TABLE kooste.syke_natura2000
ADD COLUMN geom geometry(MULTIPOLYGON, 4326) NOT NULL;

ALTER TABLE kooste.syke_valtionluonnonsuojelualueet DROP COLUMN geom;
ALTER TABLE kooste.syke_valtionluonnonsuojelualueet
ADD COLUMN geom geometry(MULTIPOLYGON, 4326) NOT NULL;

CREATE TABLE kooste.syke_metadata (
    update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
    last_modified timestamptz,
    layers_to_include jsonb,
    url text DEFAULT 'https://paikkatieto.ymparisto.fi/arcgis/rest/services/',
    CONSTRAINT syke_metadata_pk PRIMARY KEY (update_id)
);
ALTER TABLE kooste.syke_metadata OWNER TO tarmo_admin;
INSERT INTO kooste.syke_metadata(layers_to_include)
VALUES (
        '{"SYKE/SYKE_SuojellutAlueet": ["Natura 2000 - SAC Manner-Suomi aluemaiset", "Natura 2000 - SPA Manner-Suomi", "Natura 2000 - SCI Manner-Suomi", "Valtion maiden luonnonsuojelualueet"]}'
    );
GRANT SELECT,
    INSERT,
    UPDATE,
    DELETE ON TABLE kooste.syke_metadata TO tarmo_read_write;
