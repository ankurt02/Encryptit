# 🔐 Encrypt It

**Encrypt It** is a Flutter web application that allows users to apply cryptographic hashing techniques on input text. The backend is powered by a Python Flask server which securely handles the hashing logic.

Currently, the app supports the following hashing algorithms:
- **SHA-1**
- **SHA-256**
- **MD5**

> 🔧 *Encryption algorithms (AES, RSA, DES, Diffie-Hellman) are planned and will be integrated in upcoming updates.*

---

## 💻 Technologies Used

### 🐍 Python (Backend)
- Flask
- hashlib
- flask_cors

### 💙 Flutter (Frontend)
- dio
- gap
- flutter web

---

## 🚀 Features

- Real-time text hashing using selected algorithm.
- Simple and responsive Flutter web UI.
- Easy integration with backend using `Dio`.
- Built with scalability in mind — more algorithms will be added soon.

---


## 🌐 Deployment

- The frontend can be deployed via **GitHub Pages** (see [`build/web`] folder).
- The backend Flask server can be deployed using platforms like:
  - [Render](https://render.com)
  - [PythonAnywhere](https://www.pythonanywhere.com)
  - [Replit](https://replit.com)

> ⚠️ **Important**: After deployment, update the API `baseUrl` in your Flutter code to the deployed Python URL.

---

## 🧪 Working Algorithms

### ✅ Currently Implemented
- SHA-1
- SHA-256
- MD5

### 🚧 Coming Soon
- AES
- RSA
- DES
- Diffie-Hellman

---

## 🔜 TODO

- [x] Hashing via SHA-1, SHA-256, and MD5
- [ ] Add AES, RSA, and DES encryption modules
- [ ] Add better error handling and loading indicators
- [ ] Add input validations and format guidelines
- [ ] Create a glassmorphic UI upgrade
- [ ] Deploy backend and integrate with live frontend


