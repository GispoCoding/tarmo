
DROP MATERIALIZED VIEW kooste.all_points;
drop materialized view kooste.point_clusters_8;
drop materialized view kooste.point_clusters_9;
drop materialized view kooste.point_clusters_10;
drop materialized view kooste.point_clusters_11;
drop materialized view kooste.point_clusters_12;
drop materialized view kooste.point_clusters_13;
drop function kooste.get_cluster_ids;
drop function kooste.get_clusters;

create materialized view kooste.all_points as
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('lipas_pisteet-', "sportsPlaceId") as id, "name", "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'name' as props from kooste.lipas_pisteet as points where deleted=false union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_rkykohteet-', "OBJECTID") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'name' as props from kooste.museovirastoarcrest_rkykohteet as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_muinaisjaannokset-', "mjtunnus") as id, "name", "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'name' as props from kooste.museovirastoarcrest_muinaisjaannokset as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('tamperewfs_luonnonmuistomerkit-', "id") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'id' - 'name' as props from kooste.tamperewfs_luonnonmuistomerkit as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('tamperewfs_luontopolkurastit-', "id") as id ,"name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(points)::jsonb - 'id' - 'name' as props from kooste.tamperewfs_luontopolkurastit as points where deleted=false and visibility=true union all
select ST_GeometryN(geom,1)::geometry(point,4326) as geom, CONCAT('osm_pisteet-', "id") as id , tags ->> 'name' as "name", 'Tampere' as "cityName", "tarmo_category", "type_name", tags - 'name' as props from kooste.osm_pisteet as points where deleted=false union all
select ST_Centroid(geom)::geometry(point,4326) as geom, CONCAT('osm_alueet-', "id") as id , tags ->> 'name' as "name", 'Tampere' as "cityName", "tarmo_category", "type_name", tags - 'name' as props from kooste.osm_alueet as areas where deleted=false union all
select ST_Centroid(geom)::geometry(point,4326) as geom, CONCAT('museovirastoarcrest_rkyalueet-', "OBJECTID") as id, "name", 'Tampere' as "cityName", "tarmo_category", "type_name", row_to_json(areas)::jsonb - 'name' as props from kooste.museovirastoarcrest_rkyalueet as areas where deleted=false and visibility=true;

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
	returns table(cluster_id int, id text, point_geom geometry, "cityName" text, "tarmo_category" text, name text, type_name text, props jsonb)
	as $$
	begin
		return query select ST_ClusterDBSCAN(points.geom,radius,2) over (
			partition by points."cityName", points."tarmo_category"
		) as cluster_id, points.id, points.geom, points."cityName", points."tarmo_category", points.name, points.type_name, points.props
		from kooste.all_points as points;
	end; $$
language 'plpgsql';

create function kooste.get_clusters(radius float)
	returns table(id text, size bigint, cluster_geom geometry(point,4326), "cityName" text, "tarmo_category" text, props jsonb)
	as $$
	begin
		return query with cluster_ids as (
			select * from kooste.get_cluster_ids(radius)
		), clusters as (
			-- clusters do not have any extra props atm
			select points.cluster_id::text, count(*) as size, ST_Centroid(ST_Collect(point_geom)) as cluster_geom, points."cityName", points."tarmo_category", row_to_json(null)::jsonb as props
			from cluster_ids as points where points.cluster_id is not null
			group by points.cluster_id, points."cityName", points."tarmo_category"
			order by points."cityName", points."tarmo_category"
		), non_clusters as (
			-- any all_points fields needed in single tarmo points must be added back to props json
			select points.id, 1 as size, point_geom as cluster_geom, points."cityName", points."tarmo_category", points.props || jsonb_build_object('name', points.name,'type_name', points.type_name) as props
			from cluster_ids as points where points.cluster_id is null
		) select * from clusters union all select * from non_clusters;
	end; $$
language 'plpgsql';

create materialized view kooste.point_clusters_8 as
select id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.20);

create materialized view kooste.point_clusters_9 as
select id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.10);

create materialized view kooste.point_clusters_10 as
select id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.05);

create materialized view kooste.point_clusters_11 as
select id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.025);

create materialized view kooste.point_clusters_12 as
select id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.0125);

create materialized view kooste.point_clusters_13 as
select id, size, ST_SetSRID(cluster_geom,4326)::geometry(point,4326) as cluster_geom, "cityName", "tarmo_category", props
from kooste.get_clusters(0.007);

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
