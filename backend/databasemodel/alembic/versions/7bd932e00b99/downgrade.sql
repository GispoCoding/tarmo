ALTER TABLE kooste.lipas_pisteet
RENAME TO lipas_kohteet_piste;

--sp_rename @objname = N'[kooste.lipas_kohteet_piste].[kooste.lipas_pisteet_pk]', @newname = N'lipas_kohteet_piste_pk'

ALTER TABLE kooste.lipas_viivat
RENAME TO lipas_kohteet_viiva;

ALTER TABLE lipas.metadata
RENAME COLUMN update_id TO "updateId";

ALTER TABLE lipas.metadata
RENAME COLUMN type_code_list TO "typeCodeList";

-- object: kooste.tamperewfs_luontorastit | type: TABLE --
DROP TABLE IF EXISTS kooste.tamperewfs_luontorastit CASCADE;

-- object: kooste.tamperewfs_luontopolut | type: TABLE --
DROP TABLE IF EXISTS kooste.tamperewfs_luontopolut CASCADE;

-- object: kooste.museovirastoarcrest_rkykohteet | type: TABLE --
DROP TABLE IF EXISTS kooste.museovirastoarcrest_rkykohteet CASCADE;

-- object: kooste.museovirastoarcrest_muinaisjaannokset | type: TABLE --
DROP TABLE IF EXISTS kooste.museovirastoarcrest_muinaisjaannokset CASCADE;

-- object: kooste.metadata | type: TABLE --
DROP TABLE IF EXISTS kooste.metadata CASCADE;
