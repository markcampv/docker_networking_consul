from flask import Flask, jsonify
import os, requests

app = Flask(__name__)

@app.get("/")
def index():
    try:
        r = requests.get("http://127.0.0.1:5000/", timeout=2.0)
        backend = r.json()
    except Exception as e:
        backend = {"error": str(e)}
    return jsonify({"service": "frontend", "backend": backend})

@app.get("/healthz")
def healthz():
    return "ok", 200

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "6060"))
    from waitress import serve
    serve(app, host="0.0.0.0", port=port)
