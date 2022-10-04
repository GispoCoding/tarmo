import json
import logging
import os
from typing import TypedDict

import requests

HOOK_URL = os.environ.get("SLACK_HOOK_URL")

logger = logging.getLogger()
logger.setLevel(logging.INFO)


class Response(TypedDict):
    statusCode: int  # noqa N815
    body: str


class Event(TypedDict):
    event_type: int  # EventType


def handler(event: Event, _) -> Response:
    response: Response = {"statusCode": 200, "body": json.dumps("")}
    slack_message = {"text": json.dumps(event)}
    if not HOOK_URL:
        return {"statusCode": 500, "body": "Slack hook url not configured"}
    slack_response = requests.post(HOOK_URL, json=slack_message)
    if slack_response.status_code != 200:
        error_text = (
            f"POST to slack failed: HTTP {slack_response.status_code}: "
            + f"{slack_response.text}"
        )
        logger.exception(error_text)
        error_json = {"url": HOOK_URL, "payload": slack_message, "error": error_text}
        response["statusCode"] = 500
        response["body"] = json.dumps(error_json)
    else:
        logger.info(f"Event {slack_message} posted")
    return response
