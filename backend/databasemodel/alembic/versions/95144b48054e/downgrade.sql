ALTER TABLE kooste.lipas_pisteet DROP CONSTRAINT lipas_pisteet_pk;
ALTER TABLE kooste.lipas_viivat  DROP CONSTRAINT lipas_viivat_pk;

ALTER TABLE kooste.lipas_pisteet ADD CONSTRAINT lipas_kohteet_piste_pk PRIMARY KEY ("sportsPlaceId");
ALTER TABLE kooste.lipas_viivat ADD CONSTRAINT lipas_kohteet_viiva_pk PRIMARY KEY ("sportsPlaceId");
