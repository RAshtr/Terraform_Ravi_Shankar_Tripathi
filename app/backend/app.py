from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/', methods=['GET'])
def index():
    return jsonify({"message": "Flask backend service is running"}), 200

@app.route('/submit', methods=['POST'])
def submit():
    data = request.get_json()
    if not data:
        return jsonify({"status": "error", "message": "No data provided"}), 400

    name = data.get('name')
    email = data.get('email')
    message = data.get('message')

    print(f"Data received -> Name: {name}, Email: {email}, Message: {message}")

    return jsonify({
        "status": "success",
        "message": f"Thank you {name}, data received successfully by Flask backend!",
        "data": {"name": name, "email": email, "message": message}
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)