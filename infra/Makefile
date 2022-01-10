region:=eu-central-1 # Modify to match the region
db_manager:=`terraform output -raw lambda_db_manager`
lipas_loader:=`terraform output -raw lambda_lipas_loader`

build:
	make build-lambda-docker -C ..

update-lambda: build update-db-manager update-lipas-loader
	echo "All updated"

update-db-manager: build
	aws lambda update-function-code --region=${region} --function-name ${db_manager} --zip-file fileb://../backend/lambda_functions/db_manager.zip

update-lipas-loader: build
	aws lambda update-function-code --region=${region} --function-name ${lipas_loader} --zip-file fileb://../backend/lambda_functions/lipas_loader.zip

log-db-manager:
	aws logs tail --region=${region} "/aws/lambda/${db_manager}"

log-lipas:
	aws logs tail --region=${region} "/aws/lambda/${lipas_loader}"

## Commands to invoke lambda functions
create-db:
	aws lambda invoke --region=${region} --cli-binary-format raw-in-base64-out --function-name ${db_manager} --payload '{"event_type": 1}' response_db.json

change-db-pw:
	aws lambda invoke --region=${region} --cli-binary-format raw-in-base64-out --function-name ${db_manager} --payload '{"event_type": 2}' response_db.json

populate-lipas:
	aws lambda invoke --region=eu-central-1 --cli-binary-format raw-in-base64-out --function-name ${lipas_loader} --payload '{"pages": [1,2,3] "do_not_update_timestamp": true}' response_lipas.json
