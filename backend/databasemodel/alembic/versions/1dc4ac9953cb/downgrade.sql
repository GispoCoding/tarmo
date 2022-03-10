ALTER TABLE kooste.tamperewfs_luontopolkurastit RENAME TO tamperewfs_luontorastit;
ALTER TABLE kooste.tamperewfs_luontopolkureitit RENAME TO tamperewfs_luontopolut;
ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit RENAME TO luonnonmuistomerkit;
ALTER TABLE kooste.tamperewfs_luontorastit DROP CONSTRAINT tamperewfs_luontopolkurastit_pk;
ALTER TABLE kooste.tamperewfs_luontopolut DROP CONSTRAINT tamperewfs_luontopolkureitit_pk;
ALTER TABLE kooste.luonnonmuistomerkit DROP CONSTRAINT tamperewfs_luonnonmuistomerkit_pk;

ALTER TABLE kooste.tamperewfs_luontorastit DROP COLUMN mi_prinx;
ALTER TABLE kooste.tamperewfs_luontorastit ADD COLUMN id text NOT NULL GENERATED ALWAYS AS (CAST(tunnus AS TEXT) || '-' || CAST(rasti AS TEXT)) STORED;
ALTER TABLE kooste.tamperewfs_luontorastit ADD CONSTRAINT tamperewfs_luontorastit_pk PRIMARY KEY ("id");
ALTER TABLE kooste.tamperewfs_luontopolut ADD CONSTRAINT tamperewfs_luontopolut_pk PRIMARY KEY ("tunnus");
ALTER TABLE kooste.luonnonmuistomerkit ADD CONSTRAINT luonnonmuistomerkit_pk PRIMARY KEY ("sw_member");
ALTER TABLE kooste.luonnonmuistomerkit ALTER COLUMN paatosnumero TYPE integer USING paatosnumero::integer;

DROP TABLE kooste.tamperewfs_metadata;
