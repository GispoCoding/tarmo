drop function kooste.get_cluster_ids;

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
