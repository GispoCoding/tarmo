DROP INDEX kooste.lipas_viivat_name_idx;
DROP INDEX kooste.lipas_viivat_tarmo_category_idx;
DROP INDEX kooste.lipas_viivat_type_name_idx;
DROP INDEX kooste.all_points_tarmo_category_idx;
DROP INDEX kooste.all_points_viivat_type_name_idx;
CREATE INDEX ON kooste.lipas_viivat (tarmo_category);
