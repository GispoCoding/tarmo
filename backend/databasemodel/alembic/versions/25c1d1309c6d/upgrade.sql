ALTER TABLE kooste.tamperewfs_luontorastit DROP CONSTRAINT tamperewfs_luontorastit_pk;
ALTER TABLE kooste.tamperewfs_luontorastit DROP COLUMN kooste_id;

ALTER TABLE kooste.tamperewfs_luontorastit ADD CONSTRAINT tunnus_rasti_unique UNIQUE (tunnus, rasti);
ALTER TABLE kooste.tamperewfs_luontorastit ADD COLUMN id text NOT NULL GENERATED ALWAYS AS (CAST(tunnus AS TEXT) || '-' || CAST(rasti AS TEXT)) STORED;
ALTER TABLE kooste.tamperewfs_luontorastit ADD CONSTRAINT tamperewfs_luontorastit_pk PRIMARY KEY (id);
