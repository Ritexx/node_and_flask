from flask import Flask, jsonify
import json
import os

app = Flask(__name__)

@app.route('/')
def get_data():
    try:
        with open('/app/scraped_data.json') as f:
            return jsonify(json.load(f))
    except FileNotFoundError:
        return jsonify({"error": "Data not available"}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)