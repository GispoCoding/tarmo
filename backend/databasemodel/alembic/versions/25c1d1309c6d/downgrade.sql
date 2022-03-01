ALTER TABLE kooste.tamperewfs_luontorastit DROP CONSTRAINT tamperewfs_luontorastit_pk;
ALTER TABLE kooste.tamperewfs_luontorastit DROP CONSTRAINT tunnus_rasti_unique;
ALTER TABLE kooste.tamperewfs_luontorastit DROP COLUMN id;

ALTER TABLE kooste.tamperewfs_luontorastit ADD COLUMN kooste_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY;
ALTER TABLE kooste.tamperewfs_luontorastit ADD CONSTRAINT tamperewfs_luontorastit_pk PRIMARY KEY (kooste_id);
