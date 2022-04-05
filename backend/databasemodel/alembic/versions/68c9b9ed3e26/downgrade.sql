ALTER TABLE kooste.museovirastoarcrest_rkykohteet RENAME COLUMN "OBJECTID" TO "objectId";
ALTER TABLE kooste.museovirastoarcrest_rkykohteet DROP COLUMN geom;
ALTER TABLE kooste.museovirastoarcrest_rkykohteet ADD COLUMN geom geometry(MULTIPOINT, 3067) NOT NULL;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset DROP COLUMN geom;
ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset ADD COLUMN geom geometry(MULTIPOINT, 3067) NOT NULL;

DROP TABLE kooste.museovirastoarcrest_metadata;

ALTER TABLE kooste.syke_natura2000 DROP COLUMN geom;
ALTER TABLE kooste.syke_natura2000 ADD COLUMN geom geometry(MULTIPOINT, 4326) NOT NULL;

ALTER TABLE kooste.syke_valtionluonnonsuojelualueet DROP COLUMN geom;
ALTER TABLE kooste.syke_valtionluonnonsuojelualueet ADD COLUMN geom geometry(MULTIPOINT, 4326) NOT NULL;

DROP TABLE kooste.syke_metadata;
