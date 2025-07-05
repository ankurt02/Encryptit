from flask import Flask, request, jsonify
from flask_cors import CORS
import hashlib
from Crypto.Cipher import AES, DES
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
from Crypto.Util.Padding import pad, unpad
import base64

app = Flask(__name__)
CORS(app)  # Allow CORS from frontend

# --- Hashing Route ---
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


# --- Key Processing Functions ---
def process_aes_key(key):
    """Process key for AES - ensure it's exactly 16, 24, or 32 bytes"""
    key_bytes = key.encode('utf-8')
    
    # AES supports 128, 192, or 256 bit keys (16, 24, or 32 bytes)
    if len(key_bytes) <= 16:
        return key_bytes.ljust(16, b'\0')  # Pad with null bytes to 16
    elif len(key_bytes) <= 24:
        return key_bytes.ljust(24, b'\0')  # Pad with null bytes to 24
    elif len(key_bytes) <= 32:
        return key_bytes.ljust(32, b'\0')  # Pad with null bytes to 32
    else:
        return key_bytes[:32]  # Truncate to 32 bytes

def process_des_key(key):
    """Process key for DES - ensure it's exactly 8 bytes"""
    key_bytes = key.encode('utf-8')
    if len(key_bytes) < 8:
        return key_bytes.ljust(8, b'\0')  # Pad with null bytes to 8
    else:
        return key_bytes[:8]  # Truncate to 8 bytes


# --- Encryption Route ---
@app.route('/encrypt', methods=['POST'])
def encrypt_text():
    data = request.json
    text = data.get('text')
    key = data.get('key')
    algorithm = data.get('algorithm')

    if not text or not algorithm:
        return jsonify({'error': 'Missing required fields'}), 400

    try:
        if algorithm == 'AES':
            if not key:
                return jsonify({'error': 'AES requires a key'}), 400
            
            key_bytes = process_aes_key(key)
            cipher = AES.new(key_bytes, AES.MODE_ECB)
            
            # Use proper padding from pycryptodome
            padded_text = pad(text.encode('utf-8'), AES.block_size)
            encrypted = cipher.encrypt(padded_text)
            
            return jsonify({'result': base64.b64encode(encrypted).decode()})

        elif algorithm == 'DES':
            if not key:
                return jsonify({'error': 'DES requires a key'}), 400
            
            key_bytes = process_des_key(key)
            cipher = DES.new(key_bytes, DES.MODE_ECB)
            
            # Use proper padding from pycryptodome
            padded_text = pad(text.encode('utf-8'), DES.block_size)
            encrypted = cipher.encrypt(padded_text)
            
            return jsonify({'result': base64.b64encode(encrypted).decode()})

        elif algorithm == 'RSA':
            # RSA doesn't use the provided key, it generates its own
            key_pair = RSA.generate(2048)
            cipher = PKCS1_OAEP.new(key_pair.publickey())
            encrypted = cipher.encrypt(text.encode('utf-8'))
            
            return jsonify({
                'result': base64.b64encode(encrypted).decode(),
                'public_key': key_pair.publickey().export_key().decode(),
                'private_key': key_pair.export_key().decode()
            })

        else:
            return jsonify({'error': f'Unsupported algorithm: {algorithm}'}), 400

    except Exception as e:
        return jsonify({'error': f'Encryption failed: {str(e)}'}), 500


# --- Decryption Route ---
@app.route('/decrypt', methods=['POST'])
def decrypt_text():
    data = request.json
    encrypted_text = data.get('text')
    key = data.get('key')
    algorithm = data.get('algorithm')

    if not encrypted_text or not algorithm:
        return jsonify({'error': 'Missing required fields'}), 400

    try:
        cipher_text = base64.b64decode(encrypted_text)
        
        if algorithm == 'AES':
            if not key:
                return jsonify({'error': 'AES requires a key'}), 400
            
            key_bytes = process_aes_key(key)
            cipher = AES.new(key_bytes, AES.MODE_ECB)
            
            decrypted_padded = cipher.decrypt(cipher_text)
            decrypted = unpad(decrypted_padded, AES.block_size)
            
            return jsonify({'result': decrypted.decode('utf-8')})

        elif algorithm == 'DES':
            if not key:
                return jsonify({'error': 'DES requires a key'}), 400
            
            key_bytes = process_des_key(key)
            cipher = DES.new(key_bytes, DES.MODE_ECB)
            
            decrypted_padded = cipher.decrypt(cipher_text)
            decrypted = unpad(decrypted_padded, DES.block_size)
            
            return jsonify({'result': decrypted.decode('utf-8')})

        elif algorithm == 'RSA':
            if not key:
                return jsonify({'error': 'RSA requires a private key'}), 400
            
            private_key = RSA.import_key(key)
            cipher = PKCS1_OAEP.new(private_key)
            decrypted = cipher.decrypt(cipher_text)
            
            return jsonify({'result': decrypted.decode('utf-8')})

        else:
            return jsonify({'error': f'Unsupported algorithm: {algorithm}'}), 400

    except Exception as e:
        return jsonify({'error': f'Decryption failed: {str(e)}'}), 500


# --- Test Route ---
@app.route('/test', methods=['GET'])
def test():
    return jsonify({'message': 'Flask server is running!'})


# --- Run the app ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)