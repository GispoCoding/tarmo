test-create-db:
	curl -XPOST "http://localhost:8081/2015-03-31/functions/function/invocations" -d \
	'{"main_db_params": {"dbname": "tarmo", "user": "postgres", "host": "db", "password": "postgres", "port": "5432"}, "root_db_params": {"dbname": "postgres", "user": "postgres", "host": "db", "password": "postgres", "port": "5432"}, "event_type" : 1}'

test-lipas:
	curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d \
	'{"db_params": {"dbname": "tarmo", "user": "postgres", "host": "db", "password": "postgres", "port": "5432"}, "pages": [1,2]}'
