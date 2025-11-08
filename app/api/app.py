from flask import Flask, jsonify
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
import time
import random

app = Flask(__name__)

REQS = Counter('api_requests_total', 'Total API requests', ['endpoint'])

@app.route('/')
def index():
    REQS.labels('/').inc()
    # pretend work
    time.sleep(random.uniform(0.01, 0.08))
    return jsonify(message="Hello from API")

@app.route('/health')
def health():
    return "ok", 200

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
