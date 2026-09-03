FROM public.ecr.aws/lambda/python:3.12

# common code
COPY lambda_functions/base_loader/__init__.py ${LAMBDA_TASK_ROOT}/app/__init__.py
COPY lambda_functions/base_loader/base_loader.py ${LAMBDA_TASK_ROOT}/app/base_loader.py
# common deps
RUN pip3 install  \
    psycopg2-binary==2.9.12 \
    geoalchemy2==0.20.0 \
    sqlalchemy==1.4.54 \
    requests==2.34.2 \
    shapely==2.1.2  \
    urllib3==2.7.0 \
    --target "${LAMBDA_TASK_ROOT}"

# this code
COPY lambda_functions/wfs_loader/wfs_loader.py ${LAMBDA_TASK_ROOT}/app/wfs_loader.py

CMD [ "app.wfs_loader.handler" ]
