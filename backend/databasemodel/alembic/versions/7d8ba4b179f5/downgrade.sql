DELETE FROM kooste.osm_metadata;
INSERT INTO kooste.osm_metadata (tags_to_include, tags_to_exclude) VALUES (
    '{"amenity": ["parking", "bicycle_parking"]}',
    '{"access": ["private", "permit"]}'
);

DELETE FROM kooste.museovirastoarcrest_metadata;
INSERT INTO kooste.museovirastoarcrest_metadata (layers_to_include) VALUES (
	'{"WFS/MV_KulttuuriymparistoSuojellut": ["Muinaisjaannokset_piste", "RKY_piste"]}'
);

DROP MATERIALIZED VIEW kooste.all_points;
drop materialized view kooste.point_clusters_8;
drop materialized view kooste.point_clusters_9;
drop materialized view kooste.point_clusters_10;
drop materialized view kooste.point_clusters_11;
drop materialized view kooste.point_clusters_12;
drop materialized view kooste.point_clusters_13;
drop function kooste.get_cluster_ids;
drop function kooste.get_clusters;
DROP TABLE kooste.museovirastoarcrest_rkyalueet;

create materialized view kooste.all_points as
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('lipas_pisteet-', "sportsPlaceId") as id, "name", "cityName", "tarmo_category", "type_name", 'lipas_pisteet' as table_name, row_to_json(points)::jsonb as props from kooste.lipas_pisteet as points where deleted=false union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_rkykohteet-', "OBJECTID") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", 'museovirastoarcrest_rkykohteet' as table_name, row_to_json(points)::jsonb as props from kooste.museovirastoarcrest_rkykohteet as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_muinaisjaannokset-', "mjtunnus") as id, "name", "cityName", "tarmo_category", "type_name", 'museovirastoarcrest_muinaisjaannokset' as table_name, row_to_json(points)::jsonb as props from kooste.museovirastoarcrest_muinaisjaannokset as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('tamperewfs_luonnonmuistomerkit-', "sw_member") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", 'tamperewfs_luonnonmuistomerkit' as table_name, row_to_json(points)::jsonb as props from kooste.tamperewfs_luonnonmuistomerkit as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('tamperewfs_luontopolkurastit-', "mi_prinx") as id ,"name", 'Tampere' as "cityName", "tarmo_category", "type_name", 'tamperewfs_luontopolkurastit' as table_name, row_to_json(points)::jsonb as props from kooste.tamperewfs_luontopolkurastit as points where deleted=false and visibility=true;

create index on kooste.all_points (id);
-- Use the trigram extension to speed up text search
create index on kooste.all_points USING gin (name gin_trgm_ops);
create index on kooste.all_points USING gin ("tarmo_category" gin_trgm_ops);
create index on kooste.all_points USING gin ("type_name" gin_trgm_ops);
create index on kooste.all_points ("cityName");

ALTER TABLE kooste.all_points OWNER TO tarmo_read_write;

GRANT SELECT
   ON TABLE kooste.all_points
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.all_points
   TO tarmo_admin;

create function kooste.get_cluster_ids(radius float)
	returns table(cluster_id int, id text, point_geom geometry, "cityName" text, "tarmo_category" text, table_name text, props jsonb)
	as $$
	begin
		return query select ST_ClusterDBSCAN(points.geom,radius,2) over (
			partition by points."cityName", points."tarmo_category", points.table_name
		) as cluster_id, points.id, points.geom, points."cityName", points."tarmo_category", points.table_name, points.props
		from kooste.all_points as points;
	end; $$
language 'plpgsql';

create function kooste.get_clusters(radius float)
	returns table(cluster_id int, size bigint, cluster_geom geometry(point,4326), "cityName" text, "tarmo_category" text, table_name text, props jsonb)
	as $$
	begin
		return query with cluster_ids as (
			select * from kooste.get_cluster_ids(radius)
		), clusters as (
			select points.cluster_id, count(*) as size, ST_Centroid(ST_Collect(point_geom)) as cluster_geom, points."cityName", points."tarmo_category", points.table_name, row_to_json(null)::jsonb as props
			from cluster_ids as points where points.cluster_id is not null
			group by points.cluster_id, points."cityName", points."tarmo_category", points.table_name
			order by points."cityName", points."tarmo_category"
		), non_clusters as (
			select points.cluster_id, 1 as size, point_geom as cluster_geom, points."cityName", points."tarmo_category", points.table_name, points.props
			from cluster_ids as points where points.cluster_id is null
		) select * from clusters union all select * from non_clusters;
	end; $$
language 'plpgsql';

create materialized view kooste.point_clusters_8 as
select cluster_id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", table_name, props
from kooste.get_clusters(0.10);

create materialized view kooste.point_clusters_9 as
select cluster_id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", table_name, props
from kooste.get_clusters(0.05);

create materialized view kooste.point_clusters_10 as
select cluster_id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", table_name, props
from kooste.get_clusters(0.025);

create materialized view kooste.point_clusters_11 as
select cluster_id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", table_name, props
from kooste.get_clusters(0.0125);

create materialized view kooste.point_clusters_12 as
select cluster_id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", table_name, props
from kooste.get_clusters(0.007);

create materialized view kooste.point_clusters_13 as
select cluster_id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", table_name, props
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
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.point_clusters_8
   TO tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_9
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.point_clusters_9
   TO tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_10
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.point_clusters_10
   TO tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_11
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.point_clusters_11
   TO tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_12
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.point_clusters_12
   TO tarmo_admin;

GRANT SELECT
   ON TABLE kooste.point_clusters_13
   TO tarmo_read;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
   ON TABLE kooste.point_clusters_13
   TO tarmo_admin;
