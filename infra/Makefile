build:
	make build-lambda-docker -C ..

update-lambda: update-db-manager update-lipas-loader
	echo "All updated"

update-db-manager:
	aws lambda update-function-code --function-name db_manager --zip-file fileb://../backend/lambda_functions/db_manager.zip

update-lipas-loader:
	aws lambda update-function-code --function-name lipas_loader --zip-file fileb://../backend/lambda_functions/lipas_loader.zip

log-db-manager:
	aws logs tail "/aws/lambda/${db_manager}"

log-lipas:
	aws logs tail "/aws/lambda/${lipas_loader}"

## Commands to invoke lambda functions
create-db:
	aws lambda invoke --cli-binary-format raw-in-base64-out --function-name ${db_manager} --payload '{"event_type": 1}' response_db.json

change-db-pw:
	aws lambda invoke --cli-binary-format raw-in-base64-out --function-name ${db_manager} --payload '{"event_type": 2}' response_db.json

populate-lipas:
	aws lambda invoke --cli-binary-format raw-in-base64-out --function-name ${lipas_loader} --payload '{"pages": [1,2,3] "do_not_update_timestamp": true}' response_lipas.json
