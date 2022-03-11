ALTER TABLE kooste.tamperewfs_luontorastit RENAME TO tamperewfs_luontopolkurastit;
ALTER TABLE kooste.tamperewfs_luontopolut RENAME TO tamperewfs_luontopolkureitit;
ALTER TABLE kooste.luonnonmuistomerkit RENAME TO tamperewfs_luonnonmuistomerkit;
ALTER TABLE kooste.tamperewfs_luontopolkurastit DROP CONSTRAINT tamperewfs_luontorastit_pk;
ALTER TABLE kooste.tamperewfs_luontopolkureitit DROP CONSTRAINT tamperewfs_luontopolut_pk;
ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit DROP CONSTRAINT luonnonmuistomerkit_pk;

ALTER TABLE kooste.tamperewfs_luontopolkurastit DROP COLUMN id;
ALTER TABLE kooste.tamperewfs_luontopolkurastit ADD COLUMN mi_prinx bigint NOT NULL;
ALTER TABLE kooste.tamperewfs_luontopolkurastit ADD CONSTRAINT tamperewfs_luontopolkurastit_pk PRIMARY KEY ("mi_prinx");

ALTER TABLE kooste.tamperewfs_luontopolkureitit ADD CONSTRAINT tamperewfs_luontopolkureitit_pk PRIMARY KEY ("tunnus");

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit ADD CONSTRAINT tamperewfs_luonnonmuistomerkit_pk PRIMARY KEY ("sw_member");
ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit ALTER COLUMN paatosnumero TYPE text;

CREATE TABLE kooste.tamperewfs_metadata (
	update_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY,
	last_modified timestamptz,
	layers_to_include jsonb,
	CONSTRAINT tamperewfs_metadata_pk PRIMARY KEY (update_id)
);
ALTER TABLE kooste.tamperewfs_metadata OWNER TO tarmo_admin;
INSERT INTO kooste.tamperewfs_metadata (layers_to_include) VALUES ('["luonto:YV_LUONNONMUISTOMERKKI", "luonto:YV_LUONTOPOLKU", "luonto:YV_LUONTORASTI"]');

GRANT SELECT
   ON TABLE kooste.tamperewfs_metadata
   TO tarmo_read;

GRANT SELECT,INSERT,UPDATE,DELETE
   ON TABLE kooste.tamperewfs_metadata
   TO tarmo_read_write;
