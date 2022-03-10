FROM public.ecr.aws/lambda/python:3.8

# Copy function code
COPY lambda_functions/osm_loader/osm_loader.py ${LAMBDA_TASK_ROOT}/app.py

RUN pip3 install  \
    psycopg2-binary \
    geoalchemy2 \
    requests \
    shapely==1.8.0  \
    --target "${LAMBDA_TASK_ROOT}"

CMD [ "app.handler" ]
