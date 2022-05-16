create index on kooste.all_points ("cityName");

GRANT SELECT
   ON TABLE kooste.all_points
   TO tarmo_read, tarmo_admin;
