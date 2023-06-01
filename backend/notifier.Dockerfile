FROM public.ecr.aws/lambda/python:3.8

# Copy function code
COPY lambda_functions/notifier/notifier.py ${LAMBDA_TASK_ROOT}/app/notifier.py

RUN pip3 install  \
    requests \
    urllib3==1.26 \
    --target "${LAMBDA_TASK_ROOT}"

CMD [ "app.notifier.handler" ]
