FROM public.ecr.aws/lambda/python:3.8

# Copy function code
COPY functions/db_manager.py ${LAMBDA_TASK_ROOT}/app.py
COPY databasemodel ${LAMBDA_TASK_ROOT}/databasemodel

RUN pip3 install  \
    psycopg2-binary \
    --target "${LAMBDA_TASK_ROOT}"

CMD [ "app.handler" ]
