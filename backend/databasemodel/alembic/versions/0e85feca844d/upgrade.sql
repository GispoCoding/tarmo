drop materialized view kooste.point_clusters_8;
drop materialized view kooste.point_clusters_9;
drop materialized view kooste.point_clusters_10;
drop materialized view kooste.point_clusters_11;
drop materialized view kooste.point_clusters_12;

create materialized view kooste.all_points as
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, "cityName", "tarmo_category", 'lipas_pisteet' as table_name, row_to_json(points)::jsonb as props from kooste.lipas_pisteet as points where deleted=false union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, 'Tampere' as "cityName", "tarmo_category", 'museovirastoarcrest_rkykohteet' as table_name, row_to_json(points)::jsonb as props from kooste.museovirastoarcrest_rkykohteet as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, "cityName", "tarmo_category", 'museovirastoarcrest_muinaisjaannokset' as table_name, row_to_json(points)::jsonb as props from kooste.museovirastoarcrest_muinaisjaannokset as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, 'Tampere' as "cityName", "tarmo_category", 'tamperewfs_luonnonmuistomerkit' as table_name, row_to_json(points)::jsonb as props from kooste.tamperewfs_luonnonmuistomerkit as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, 'Tampere' as "cityName", "tarmo_category", 'tamperewfs_luontopolkurastit' as table_name, row_to_json(points)::jsonb as props from kooste.tamperewfs_luontopolkurastit as points where deleted=false and visibility=true;

ALTER TABLE kooste.all_points OWNER TO tarmo_read_write;

create function kooste.get_cluster_ids(radius float)
	returns table(cluster_id int, point_geom geometry, "cityName" text, "tarmo_category" text, table_name text, props jsonb)
	as $$
	begin
		return query select ST_ClusterDBSCAN(points.geom,radius,2) over (
			partition by points."cityName", points."tarmo_category"
		) as cluster_id, points.geom, points."cityName", points."tarmo_category", points.table_name, points.props
		from kooste.all_points as points;
	end; $$
language 'plpgsql';

create function kooste.get_clusters(radius float)
	returns table(cluster_id int, size bigint, cluster_geom geometry(point,4326), "cityName" text, "tarmo_category" text, props jsonb)
	as $$
	begin
		return query with cluster_ids as (
			select * from kooste.get_cluster_ids(radius)
		), clusters as (
			select points.cluster_id, count(*) as size, ST_Centroid(ST_Collect(point_geom)) as cluster_geom, points."cityName", points."tarmo_category", row_to_json(null)::jsonb as props
			from cluster_ids as points where points.cluster_id is not null
			group by points.cluster_id, points."cityName", points."tarmo_category"
			order by points."cityName", points."tarmo_category"
		), non_clusters as (
			select points.cluster_id, 1 as size, point_geom as cluster_geom, points."cityName", points."tarmo_category", points.props
			from cluster_ids as points where points.cluster_id is null
		) select * from clusters union all select * from non_clusters;
	end; $$
language 'plpgsql';

create materialized view kooste.point_clusters_8 as
select cluster_id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.10);

create materialized view kooste.point_clusters_9 as
select cluster_id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.05);

create materialized view kooste.point_clusters_10 as
select cluster_id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.025);

create materialized view kooste.point_clusters_11 as
select cluster_id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.0125);

create materialized view kooste.point_clusters_12 as
select cluster_id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.007);

create materialized view kooste.point_clusters_13 as
select cluster_id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.002);

create index on kooste.point_clusters_8 ("cityName");
create index on kooste.point_clusters_9 ("cityName");
create index on kooste.point_clusters_10 ("cityName");
create index on kooste.point_clusters_11 ("cityName");
create index on kooste.point_clusters_12 ("cityName");
create index on kooste.point_clusters_13 ("cityName");

ALTER TABLE kooste.point_clusters_8 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_9 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_10 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_11 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_12 OWNER TO tarmo_read_write;

ALTER TABLE kooste.point_clusters_13 OWNER TO tarmo_read_write;

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

GRANT SELECT
   ON TABLE kooste.point_clusters_13
   TO tarmo_read, tarmo_admin;
