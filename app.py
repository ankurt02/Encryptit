from flask import Flask, request, jsonify
import hashlib
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # allow requests from Flutter

def generate_hash(text, algorithm):
    encoded_text = text.encode()
    if algorithm == 'SHA-1':
        return hashlib.sha1(encoded_text).hexdigest()
    elif algorithm == 'SHA-256':
        return hashlib.sha256(encoded_text).hexdigest()
    elif algorithm == 'MD5':
        return hashlib.md5(encoded_text).hexdigest()
    else:
        return "Unsupported algorithm"

@app.route('/hash', methods=['POST'])
def hash_text():
    data = request.json
    text = data.get('text')
    algorithm = data.get('algorithm')
    if not text or not algorithm:
        return jsonify({"error": "Missing text or algorithm"}), 400

    hashed = generate_hash(text, algorithm)
    return jsonify({"hashed": hashed})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
