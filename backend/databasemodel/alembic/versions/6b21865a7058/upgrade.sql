DROP INDEX kooste.lipas_viivat_tarmo_category_idx;
CREATE INDEX ON kooste.lipas_viivat USING gin (name gin_trgm_ops);
CREATE INDEX ON kooste.lipas_viivat USING gin ("tarmo_category" gin_trgm_ops);
CREATE INDEX ON kooste.lipas_viivat USING gin ("type_name" gin_trgm_ops);
create index on kooste.all_points USING gin ("tarmo_category" gin_trgm_ops);
create index on kooste.all_points USING gin ("type_name" gin_trgm_ops);
