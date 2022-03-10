test-create-db:
	curl -XPOST "http://localhost:8081/2015-03-31/functions/function/invocations" -d '{"event_type" : 1}'

test-migrate-db:
	curl -XPOST "http://localhost:8081/2015-03-31/functions/function/invocations" -d '{"event_type" : 3}'

test-lipas:
	curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{"pages": [1,2]}'

test-osm:
	curl -XPOST "http://localhost:8082/2015-03-31/functions/function/invocations" -d '{"close_to_lon": 23.7747, "close_to_lat": 61.4980, "radius": 10}'

test-wfs:
	curl -XPOST "http://localhost:8083/2015-03-31/functions/function/invocations" -d '{}'

revision:
	cd backend; \
	alembic revision -m "$(name)" | sed -E "s/.*([0-9a-f]{12})_([a-z_]+)\.py.*/\1/" | \
		xargs -I {} mkdir databasemodel/alembic/versions/{}

pytest:
	docker-compose -f docker-compose.dev.yml down -v
	docker-compose -f docker-compose.dev.yml build db_manager lipas_loader osm_loader wfs_loader
	cd backend; pytest

rebuild:
	docker-compose -f docker-compose.dev.yml down -v
	docker-compose -f docker-compose.dev.yml build db_manager lipas_loader osm_loader wfs_loader
	docker-compose -f docker-compose.dev.yml up -d

build-lambda:
	docker-compose -f docker-compose.dev.yml build db_manager lipas_loader osm_loader wfs_loader
	docker-compose -f docker-compose.dev.yml up -d --no-deps db_manager lipas_loader osm_loader wfs_loader
	cd backend/lambda_functions; \
	for func in db_manager lipas_loader osm_loader wfs_loader ; do \
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
