import json
import os
import uuid
from datetime import datetime, timezone

import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(body, default=str),
    }

def now_iso():
    return datetime.now(timezone.utc).isoformat()

def lambda_handler(event, context):
    request = event.get("requestContext", {}).get("http", {})
    method = request.get("method", "")
    path = event.get("rawPath", "")
    path_params = event.get("pathParameters") or {}

    try:
        if method == "GET" and path == "/health":
            return response(200, {
                "status": "ok",
                "service": "NimbusOps",
                "request_id": context.aws_request_id,
            })

        if method == "GET" and path == "/test/error":
            raise RuntimeError("Controlled failure for observability test")

        if method == "GET" and path == "/services":
            result = table.scan()
            return response(200, {"items": result.get("Items", [])})

        if method == "GET" and "id" in path_params:
            result = table.get_item(Key={"id": path_params["id"]})
            item = result.get("Item")
            if not item:
                return response(404, {"message": "Service not found"})
            return response(200, item)

        if method == "POST" and path == "/services":
            body = json.loads(event.get("body") or "{}")
            if not body.get("name"):
                return response(400, {"message": "name is required"})

            item = {
                "id": str(uuid.uuid4()),
                "name": body["name"],
                "status": body.get("status", "active"),
                "created_at": now_iso(),
                "updated_at": now_iso(),
            }
            table.put_item(Item=item)
            return response(201, item)

        if method == "PUT" and "id" in path_params:
            body = json.loads(event.get("body") or "{}")
            if not body.get("name") or not body.get("status"):
                return response(400, {"message": "name and status are required"})

            result = table.update_item(
                Key={"id": path_params["id"]},
                UpdateExpression="SET #n = :name, #s = :status, updated_at = :updated",
                ExpressionAttributeNames={"#n": "name", "#s": "status"},
                ExpressionAttributeValues={
                    ":name": body["name"],
                    ":status": body["status"],
                    ":updated": now_iso(),
                },
                ReturnValues="ALL_NEW",
            )
            return response(200, result["Attributes"])

        if method == "DELETE" and "id" in path_params:
            table.delete_item(Key={"id": path_params["id"]})
            return response(204, {})

        return response(404, {"message": "Route not found"})

    except json.JSONDecodeError:
        return response(400, {"message": "Invalid JSON body"})
    except Exception as exc:
        print(json.dumps({
            "level": "ERROR",
            "request_id": context.aws_request_id,
            "error": str(exc),
        }))
        return response(500, {
            "message": "Internal server error",
            "request_id": context.aws_request_id,
        })