FROM public.ecr.aws/lambda/python:3.10

# common code
COPY lambda_functions/base_loader/__init__.py ${LAMBDA_TASK_ROOT}/app/__init__.py
COPY lambda_functions/base_loader/base_loader.py ${LAMBDA_TASK_ROOT}/app/base_loader.py
# common deps
RUN pip3 install  \
    psycopg2-binary \
    geoalchemy2 \
    sqlalchemy==1.4 \
    requests \
    shapely==1.8.0  \
    urllib3==1.26 \
    --target "${LAMBDA_TASK_ROOT}"

# this code
COPY lambda_functions/lipas_loader/lipas_loader.py ${LAMBDA_TASK_ROOT}/app/lipas_loader.py
# extra deps
RUN pip3 install python-slugify --target "${LAMBDA_TASK_ROOT}"

CMD [ "app.lipas_loader.handler" ]
