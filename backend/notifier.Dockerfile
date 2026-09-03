FROM public.ecr.aws/lambda/python:3.12

# Copy function code
COPY lambda_functions/notifier/notifier.py ${LAMBDA_TASK_ROOT}/app/notifier.py

RUN pip3 install  \
    requests==2.34.2 \
    urllib3==2.7.0 \
    --target "${LAMBDA_TASK_ROOT}"

CMD [ "app.notifier.handler" ]
