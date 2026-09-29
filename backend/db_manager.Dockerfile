FROM public.ecr.aws/lambda/python:3.12

# Copy function code
COPY lambda_functions/db_manager/db_manager.py ${LAMBDA_TASK_ROOT}/db_manager.py
COPY databasemodel ${LAMBDA_TASK_ROOT}/databasemodel

RUN pip3 install  \
    psycopg2-binary==2.9.12 \
    alembic==1.19.1 \
    # Alembic requires sqlalchemy. We need to pin the correct SQLAlchemy version, otherwise
    # we will get a version conflict with psycopg and the newest SQLAlchemy:
    sqlalchemy==1.4.54 \
    --target "${LAMBDA_TASK_ROOT}"

CMD [ "db_manager.handler" ]
