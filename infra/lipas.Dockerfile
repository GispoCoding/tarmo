FROM public.ecr.aws/lambda/python:3.8

# Copy function code
COPY functions/lipas_loader.py ${LAMBDA_TASK_ROOT}/app.py

RUN pip3 install  \
    psycopg2-binary \
    geoalchemy2 \
    requests \
    shapely  \
    --target "${LAMBDA_TASK_ROOT}"

CMD [ "app.handler" ]
