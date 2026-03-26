from flask import Blueprint, request, jsonify
from services.gemini_service import GeminiService

chat_bp = Blueprint("chat", __name__)
gemini_service = GeminiService()

@chat_bp.route("/chat", methods=["POST"])
def chat():
    data = request.get_json()
    user_message = data.get("message") if data else None

    if not user_message:
        return jsonify({"error": "Message is required"}), 400

    response = gemini_service.gerar_resposta(user_message)
    return jsonify({"response": response})

def setup_chat_routes(app):
    app.register_blueprint(chat_bp, url_prefix="/api")