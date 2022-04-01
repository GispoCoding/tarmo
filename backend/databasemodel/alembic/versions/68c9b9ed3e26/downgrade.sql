ALTER TABLE kooste.museovirastoarcrest_rkykohteet DROP CONSTRAINT museovirastoarcrest_rkykohteet_pk;
ALTER TABLE kooste.museovirastoarcrest_rkykohteet DROP COLUMN id;
ALTER TABLE kooste.museovirastoarcrest_rkykohteet ADD COLUMN "objectId" bigint NOT NULL;
ALTER TABLE kooste.museovirastoarcrest_rkykohteet ADD CONSTRAINT museovirastoarcrest_rkykohteet_pk PRIMARY KEY ("objectId");
ALTER TABLE kooste.museovirastoarcrest_rkykohteet DROP COLUMN geom;
ALTER TABLE kooste.museovirastoarcrest_rkykohteet ADD COLUMN geom geometry(MULTIPOINT, 3067) NOT NULL;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset DROP COLUMN geom;
ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset ADD COLUMN geom geometry(MULTIPOINT, 3067) NOT NULL;

DELETE TABLE kooste.museovirastoarcrest_metadata;
DELETE TABLE kooste.syke_metadata;
