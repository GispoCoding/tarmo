-- This is a fix migration.
-- Up to now, using just model.sql would result in the latter constraint names.
-- Running migrations would result in the former names instead.
-- This migration fixes the names to always have the same names as the model.sql.
-- This prevents possible problems in future migrations and database operations.
ALTER TABLE kooste.lipas_pisteet DROP CONSTRAINT IF EXISTS lipas_kohteet_piste_pk;
ALTER TABLE kooste.lipas_viivat  DROP CONSTRAINT IF EXISTS lipas_kohteet_viiva_pk;
ALTER TABLE kooste.lipas_pisteet DROP CONSTRAINT IF EXISTS lipas_pisteet_pk;
ALTER TABLE kooste.lipas_viivat DROP CONSTRAINT IF EXISTS lipas_viivat_pk;

ALTER TABLE kooste.lipas_pisteet ADD CONSTRAINT lipas_pisteet_pk PRIMARY KEY ("sportsPlaceId");
ALTER TABLE kooste.lipas_viivat ADD CONSTRAINT lipas_viivat_pk PRIMARY KEY ("sportsPlaceId");
