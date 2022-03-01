ALTER TABLE lipas.laavu_kota_tai_kammi RENAME TO laavu_kota_kammi;
ALTER TABLE lipas.frisbeegolfrata RENAME TO frisbeegolf_rata;
ALTER TABLE lipas.kavelyreitti_ulkoilureitti RENAME TO kavely_ulkoilureitti;
ALTER TABLE lipas.laavu_kota_kammi DROP CONSTRAINT laavu_kota_tai_kammi_pk;
ALTER TABLE lipas.frisbeegolf_rata DROP CONSTRAINT frisbeegolfrata_pk;
ALTER TABLE lipas.kavely_ulkoilureitti DROP CONSTRAINT kavelyreitti_ulkoilureitti_pk;

ALTER TABLE lipas.laavu_kota_kammi ADD CONSTRAINT laavu_kota_kammi_pk PRIMARY KEY ("sportsPlaceId");
ALTER TABLE lipas.frisbeegolf_rata ADD CONSTRAINT frisbeegolf_rata_pk PRIMARY KEY ("sportsPlaceId");
ALTER TABLE lipas.kavely_ulkoilureitti ADD CONSTRAINT kavely_ulkoilureitti_pk PRIMARY KEY ("sportsPlaceId");
