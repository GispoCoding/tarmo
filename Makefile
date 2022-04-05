test-create-db:
	@echo "Creating Tarmo database..."
	curl -XPOST "http://localhost:8081/2015-03-31/functions/function/invocations" -d '{"event_type" : 1}'

test-migrate-db:
	@echo "Migrating Tarmo database..."
	curl -XPOST "http://localhost:8081/2015-03-31/functions/function/invocations" -d '{"event_type" : 3}'

test-lipas:
	@echo "Loading Lipas data..."
	curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{"close_to_lon": 23.7747, "close_to_lat": 61.4980, "radius": 10}'

test-osm:
	@echo "Loading OSM data..."
	curl -XPOST "http://localhost:8082/2015-03-31/functions/function/invocations" -d '{"close_to_lon": 23.7747, "close_to_lat": 61.4980, "radius": 10}'

test-wfs:
	@echo "Loading WFS data..."
	curl -XPOST "http://localhost:8083/2015-03-31/functions/function/invocations" -d '{}'

test-arcgis:
	@echo "Loading ArcGIS data..."
	curl -XPOST "http://localhost:8085/2015-03-31/functions/function/invocations" -d '{"close_to_lon": 23.7747, "close_to_lat": 61.4980, "radius": 50}'

test-all-layers: test-create-db test-lipas test-osm test-wfs test-arcgis

revision:
	cd backend; \
	alembic revision -m "$(name)" | sed -E "s/.*([0-9a-f]{12})_([a-z_]+)\.py.*/\1/" | \
		xargs -I {} mkdir databasemodel/alembic/versions/{}

pytest:
	docker-compose -f docker-compose.dev.yml down -v
	docker-compose -f docker-compose.dev.yml build db_manager lipas_loader osm_loader wfs_loader arcgis_loader
	cd backend; pytest

rebuild:
	docker-compose -f docker-compose.dev.yml down -v
	docker-compose -f docker-compose.dev.yml build db_manager lipas_loader osm_loader wfs_loader arcgis_loader
	docker-compose -f docker-compose.dev.yml up -d

build-lambda:
	docker-compose -f docker-compose.dev.yml build db_manager lipas_loader osm_loader wfs_loader arcgis_loader
	docker-compose -f docker-compose.dev.yml up -d --no-deps db_manager lipas_loader osm_loader wfs_loader arcgis_loader
	cd backend/lambda_functions; \
	for func in db_manager lipas_loader osm_loader wfs_loader arcgis_loader ; do \
  	  rm -rf tmp_lambda; \
  	  echo $$func; \
	  docker cp tarmo_$${func}_1:/var/task tmp_lambda; \
	  mv tmp_lambda/app.py tmp_lambda/$${func}.py; \
	  cd tmp_lambda; \
	  zip -r ../"$${func}.zip" .; \
	  cd ..; \
	  rm -rf tmp_lambda; \
	done
	cd ../..
	docker-compose -f docker-compose.dev.yml down -v
