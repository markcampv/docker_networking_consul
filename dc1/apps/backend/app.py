from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.get("/")
def index():
    return jsonify({
        "service": "backend",
        "version": os.environ.get("VERSION", "v1"),
        "dc_hint": os.environ.get("CONSUL_DC", "unknown")
    })

@app.get("/healthz")
def healthz():
    return "ok", 200

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "7000"))
    from waitress import serve
    serve(app, host="0.0.0.0", port=port)
