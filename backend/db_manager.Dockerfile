FROM public.ecr.aws/lambda/python:3.10

# Copy function code
COPY lambda_functions/db_manager/db_manager.py ${LAMBDA_TASK_ROOT}/db_manager.py
COPY databasemodel ${LAMBDA_TASK_ROOT}/databasemodel

RUN pip3 install  \
    psycopg2-binary \
    alembic \
    --target "${LAMBDA_TASK_ROOT}"

CMD [ "db_manager.handler" ]
