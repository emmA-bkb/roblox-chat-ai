from flask import Flask
from dotenv import load_dotenv
from routes.chat import setup_chat_routes

load_dotenv()

app = Flask(__name__)
setup_chat_routes(app)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)