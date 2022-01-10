test-create-db:
	curl -XPOST "http://localhost:8081/2015-03-31/functions/function/invocations" -d '"event_type" : 1}'


test-lipas:
	curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{"pages": [1,2]}'


build-lambda-pip:
	cd backend/lambda_functions; \
	for func in db_manager lipas_loader ; do \
  	  rm -rf tmp_lambda; \
  	  echo $$func; \
  	  cp -r $$func tmp_lambda; \
  	  pip install --target tmp_lambda -r ../../requirements.txt; \
  	  cd tmp_lambda; \
	  zip -r ../"$${func}.zip" .; \
	  cd ..; \
	  rm -rf tmp_lambda; \
	done;


build-lambda-docker:
	docker-compose -f docker-compose.dev.yml build
	docker-compose -f docker-compose.dev.yml up -d
	cd backend/lambda_functions; \
	for func in db_manager lipas_loader ; do \
  	  rm -rf tmp_lambda; \
  	  echo $$func; \
	  docker cp tarmo_$${func}_1:/var/task tmp_lambda; \
	  mv tmp_lambda/{app,$${func}}.py; \
	  cd tmp_lambda; \
	  zip -r ../"$${func}.zip" .; \
	  cd ..; \
	  rm -rf tmp_lambda; \
	done
	cd ../..
	docker-compose -f docker-compose.dev.yml down -v
