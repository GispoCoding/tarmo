FROM public.ecr.aws/lambda/python:3.8

# Copy function code
COPY lambda_functions/lipas_loader/lipas_loader.py ${LAMBDA_TASK_ROOT}/app.py

RUN pip3 install  \
    psycopg2-binary \
    geoalchemy2 \
    requests \
    shapely==1.8.0  \
    python-slugify==6.1.1 \
    --target "${LAMBDA_TASK_ROOT}"

CMD [ "app.handler" ]
