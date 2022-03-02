ALTER TABLE lipas.laavu_kota_kammi RENAME TO laavu_kota_tai_kammi;
ALTER TABLE lipas.frisbeegolf_rata RENAME TO frisbeegolfrata;
ALTER TABLE lipas.kavely_ulkoilureitti RENAME TO kavelyreitti_ulkoilureitti;
ALTER TABLE lipas.laavu_kota_tai_kammi DROP CONSTRAINT laavu_kota_kammi_pk;
ALTER TABLE lipas.frisbeegolfrata DROP CONSTRAINT frisbeegolf_rata_pk;
ALTER TABLE lipas.kavelyreitti_ulkoilureitti DROP CONSTRAINT kavely_ulkoilureitti_pk;

ALTER TABLE lipas.laavu_kota_tai_kammi ADD CONSTRAINT laavu_kota_tai_kammi_pk PRIMARY KEY ("sportsPlaceId");
ALTER TABLE lipas.frisbeegolfrata ADD CONSTRAINT frisbeegolfrata_pk PRIMARY KEY ("sportsPlaceId");
ALTER TABLE lipas.kavelyreitti_ulkoilureitti ADD CONSTRAINT kavelyreitti_ulkoilureitti_pk PRIMARY KEY ("sportsPlaceId");
