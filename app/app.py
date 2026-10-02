from flask import Flask, jsonify, Response
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
import os

app = Flask(__name__)
REQUESTS = Counter("app_requests_total", "Total requests", ["endpoint"])
VERSION = os.getenv("APP_VERSION", "v1")


@app.route("/")
def home():
    REQUESTS.labels(endpoint="/").inc()
    return jsonify(message="Hello from GitOps platform", version=VERSION)


@app.route("/health")
def health():
    return jsonify(status="ok")


@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)