-- restore the name of the metadata table of the lipas schema
ALTER TABLE lipas.lipas_metadata
RENAME TO lipas.metadata;

-- restore the name of the primary key constraint
EXEC sp_rename N'lipas.lipas_metadata_pk', N'metadata_pk', N'OBJECT'

-- object: kooste.luontorastit | type: TABLE --
DROP TABLE IF EXISTS kooste.luontorastit CASCADE;

-- object: kooste.luontopolut | type: TABLE --
DROP TABLE IF EXISTS kooste.luontopolut CASCADE;

-- object: kooste.rkykohteet | type: TABLE --
DROP TABLE IF EXISTS kooste.rkykohteet CASCADE;

-- object: kooste.muinaisjaannokset | type: TABLE --
DROP TABLE IF EXISTS kooste.muinaisjaannokset CASCADE;

-- object: kooste.metadata | type: TABLE --
DROP TABLE IF EXISTS kooste.metadata CASCADE;
