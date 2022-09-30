# Call with make prefix=tarmo, make prefix=tarmo-tampere etc.
# depending on the deployment you want to work with.

build:
	make build-lambda -C ..

update-lambda: update-db-manager update-lipas-loader update-osm-loader update-wfs-loader update-arcgis-loader
	echo "All updated"

update-db-manager:
	aws lambda update-function-code --function-name $(prefix)-db_manager --zip-file fileb://../backend/lambda_functions/db_manager.zip

update-lipas-loader:
	aws lambda update-function-code --function-name $(prefix)-lipas_loader --zip-file fileb://../backend/lambda_functions/lipas_loader.zip

update-osm-loader:
	aws lambda update-function-code --function-name $(prefix)-osm_loader --zip-file fileb://../backend/lambda_functions/osm_loader.zip

update-wfs-loader:
	aws lambda update-function-code --function-name $(prefix)-wfs_loader --zip-file fileb://../backend/lambda_functions/wfs_loader.zip

update-arcgis-loader:
	aws lambda update-function-code --function-name $(prefix)-arcgis_loader --zip-file fileb://../backend/lambda_functions/arcgis_loader.zip

update-tileserver:
	aws ecs update-service --cluster $(prefix)-pg_tileserv --service pg_tileserv --force-new-deployment

log-db-manager:
	aws logs tail "/aws/lambda/$(prefix)-db_manager"

log-lipas:
	aws logs tail "/aws/lambda/$(prefix)-lipas_loader"

log-osm:
	aws logs tail "/aws/lambda/$(prefix)-osm_loader"

log-wfs:
	aws logs tail "/aws/lambda/$(prefix)-wfs_loader"

log-arcgis:
	aws logs tail "/aws/lambda/$(prefix)-arcgis_loader"

log-tileserver:
	aws logs tail "/aws/ecs/$(prefix)-pg_tileserv"

log-db:
	aws logs tail "/aws/rds/instance/$(prefix)db/postgresql"

## Commands to invoke lambda functions
create-db:
	aws lambda invoke --cli-binary-format raw-in-base64-out --function-name $(prefix)-db_manager --payload '{"event_type": 1}' response_db.json

change-db-pw:
	aws lambda invoke --cli-binary-format raw-in-base64-out --function-name $(prefix)-db_manager --payload '{"event_type": 2}' response_db.json

migrate-db:
	aws lambda invoke --cli-binary-format raw-in-base64-out --function-name $(prefix)-db_manager --payload '{"event_type": 3}' response_db.json

populate-lipas:
	aws lambda invoke --cli-binary-format raw-in-base64-out --function-name $(prefix)-lipas_loader --payload '{"pages": [98,99], "do_not_update_timestamp": true}' response_lipas.json

populate-lipas-tre:
	aws lambda invoke --cli-binary-format raw-in-base64-out --cli-read-timeout 900 --cli-connect-timeout 900 --function-name $(prefix)-lipas_loader --payload '{"close_to_lon": 23.7634608, "close_to_lat":61.4976505, "radius": 100}' response_lipas.json

populate-osm-tre:
	aws lambda invoke --cli-binary-format raw-in-base64-out --cli-read-timeout 900 --cli-connect-timeout 900 --function-name $(prefix)-osm_loader --payload '{"close_to_lon": 23.7634608, "close_to_lat":61.4976505, "radius": 100}' response_osm.json

populate-wfs-tre:
	aws lambda invoke --cli-binary-format raw-in-base64-out --cli-read-timeout 900 --cli-connect-timeout 900 --function-name $(prefix)-wfs_loader --payload '{}' response_wfs.json

populate-arcgis-tre:
	aws lambda invoke --cli-binary-format raw-in-base64-out --cli-read-timeout 900 --cli-connect-timeout 900 --function-name $(prefix)-arcgis_loader --payload '{"close_to_lon": 23.7634608, "close_to_lat":61.4976505, "radius": 100}' response_arcgis.json
