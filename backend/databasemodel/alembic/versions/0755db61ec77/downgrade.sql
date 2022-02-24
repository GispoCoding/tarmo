ALTER TABLE kooste.osm_pisteet
RENAME TO osm_kohteet_piste;

--sp_rename @objname = N'[kooste.lipas_kohteet_piste].[kooste.lipas_pisteet_pk]', @newname = N'lipas_kohteet_piste_pk'

ALTER TABLE kooste.osm_alueet
RENAME TO osm_kohteet_alue;
