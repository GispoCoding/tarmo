ALTER TABLE kooste.osm_kohteet_piste
RENAME TO osm_pisteet;

--sp_rename @objname = N'[kooste.lipas_pisteet].[kooste.lipas_kohteet_piste_pk]', @newname = N'lipas_pisteet_pk'

ALTER TABLE kooste.osm_kohteet_alue
RENAME TO osm_alueet;
