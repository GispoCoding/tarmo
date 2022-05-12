CREATE INDEX ON kooste.lipas_pisteet (tarmo_category);
CREATE INDEX ON kooste.lipas_viivat (tarmo_category);
CREATE INDEX ON kooste.osm_pisteet (tarmo_category);
CREATE INDEX ON kooste.osm_alueet (tarmo_category);
CREATE INDEX ON kooste.tamperewfs_luonnonmuistomerkit (tarmo_category);
CREATE INDEX ON kooste.tamperewfs_luontopolkurastit (tarmo_category);
CREATE INDEX ON kooste.tamperewfs_luontopolkureitit (tarmo_category);
CREATE INDEX ON kooste.museovirastoarcrest_rkykohteet (tarmo_category);
CREATE INDEX ON kooste.museovirastoarcrest_muinaisjaannokset (tarmo_category);

-- cluster lipas points, rkykohteet, luonnonmuistomerkit, muinaisjaannokset and luontopolkurastit at zoom 8
create materialized view kooste.point_clusters_8 as
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, "cityName", deleted, "tarmo_category", TRUE as visibility from (
	select unnest(ST_ClusterWithin(geom,0.16)) as cluster, "cityName", deleted, "tarmo_category" from kooste.lipas_pisteet group by "cityName", deleted, "tarmo_category"
) as lipas_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, 'Tampere' as "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.16)) as cluster, deleted, "tarmo_category", visibility from kooste.museovirastoarcrest_rkykohteet group by deleted, visibility, "tarmo_category"
) as rkykohteet_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.16)) as cluster, "cityName", deleted, "tarmo_category", visibility from kooste.museovirastoarcrest_muinaisjaannokset group by "cityName", deleted, visibility, "tarmo_category"
) as muinaisjaannokset_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, 'Tampere' as "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.16)) as cluster, deleted, "tarmo_category", visibility from kooste.tamperewfs_luonnonmuistomerkit group by deleted, visibility, "tarmo_category"
) as luonnonmuistomerkki_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, 'Tampere' as "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.16)) as cluster, deleted, "tarmo_category", visibility from kooste.tamperewfs_luontopolkurastit group by deleted, visibility, "tarmo_category"
) as luontopolkurasti_clusters;

-- cluster lipas points, rkykohteet, luonnonmuistomerkit, muinaisjaannokset and luontopolkurastit at zoom 9
create materialized view kooste.point_clusters_9 as
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, "cityName", deleted, "tarmo_category", TRUE as visibility from (
	select unnest(ST_ClusterWithin(geom,0.08)) as cluster, "cityName", deleted, "tarmo_category" from kooste.lipas_pisteet group by "cityName", deleted, "tarmo_category"
) as lipas_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, 'Tampere' as "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.08)) as cluster, deleted, "tarmo_category", visibility from kooste.museovirastoarcrest_rkykohteet group by deleted, visibility, "tarmo_category"
) as rkykohteet_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.08)) as cluster, "cityName", deleted, "tarmo_category", visibility from kooste.museovirastoarcrest_muinaisjaannokset group by "cityName", deleted, visibility, "tarmo_category"
) as muinaisjaannokset_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, 'Tampere' as "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.08)) as cluster, deleted, "tarmo_category", visibility from kooste.tamperewfs_luonnonmuistomerkit group by deleted, visibility, "tarmo_category"
) as luonnonmuistomerkki_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, 'Tampere' as "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.08)) as cluster, deleted, "tarmo_category", visibility from kooste.tamperewfs_luontopolkurastit group by deleted, visibility, "tarmo_category"
) as luontopolkurasti_clusters;

-- cluster lipas points, rkykohteet, luonnonmuistomerkit, muinaisjaannokset and luontopolkurastit at zoom 10
create materialized view kooste.point_clusters_10 as
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, "cityName", deleted, "tarmo_category", TRUE as visibility from (
	select unnest(ST_ClusterWithin(geom,0.04)) as cluster, "cityName", deleted, "tarmo_category" from kooste.lipas_pisteet group by "cityName", deleted, "tarmo_category"
) as lipas_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, 'Tampere' as "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.04)) as cluster, deleted, "tarmo_category", visibility from kooste.museovirastoarcrest_rkykohteet group by deleted, visibility, "tarmo_category"
) as rkykohteet_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.04)) as cluster, "cityName", deleted, "tarmo_category", visibility from kooste.museovirastoarcrest_muinaisjaannokset group by "cityName", deleted, visibility, "tarmo_category"
) as muinaisjaannokset_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, 'Tampere' as "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.04)) as cluster, deleted, "tarmo_category", visibility from kooste.tamperewfs_luonnonmuistomerkit group by deleted, visibility, "tarmo_category"
) as luonnonmuistomerkki_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, 'Tampere' as "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.04)) as cluster, deleted, "tarmo_category", visibility from kooste.tamperewfs_luontopolkurastit group by deleted, visibility, "tarmo_category"
) as luontopolkurasti_clusters;

-- cluster muinaisjaannokset and luontopolkurastit at zoom 11
create materialized view kooste.point_clusters_11 as
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.02)) as cluster, "cityName", deleted, "tarmo_category", visibility from kooste.museovirastoarcrest_muinaisjaannokset group by "cityName", deleted, visibility, "tarmo_category"
) as muinaisjaannokset_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, 'Tampere' as "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.02)) as cluster, deleted, "tarmo_category", visibility from kooste.tamperewfs_luontopolkurastit group by deleted, visibility, "tarmo_category"
) as luontopolkurasti_clusters;

-- cluster muinaisjaannokset and luontopolkurastit at zoom 12
create materialized view kooste.point_clusters_12 as
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.01)) as cluster, "cityName", deleted, "tarmo_category", visibility from kooste.museovirastoarcrest_muinaisjaannokset group by "cityName", deleted, visibility, "tarmo_category"
) as muinaisjaannokset_clusters union all
select ST_NumGeometries(cluster) as size, ST_SetSRID(ST_Centroid(cluster), 4326)::geometry(point,4326) as geom, 'Tampere' as "cityName", deleted, "tarmo_category", visibility from (
	select unnest(ST_ClusterWithin(geom,0.01)) as cluster, deleted, "tarmo_category", visibility from kooste.tamperewfs_luontopolkurastit group by deleted, visibility, "tarmo_category"
) as luontopolkurasti_clusters;

ALTER TABLE kooste.point_clusters_8 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_9 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_10 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_11 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_12 OWNER TO tarmo_read_write;

GRANT SELECT
   ON TABLE kooste.point_clusters_8
   TO tarmo_read, tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_9
   TO tarmo_read, tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_10
   TO tarmo_read, tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_11
   TO tarmo_read, tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_12
   TO tarmo_read, tarmo_admin;
