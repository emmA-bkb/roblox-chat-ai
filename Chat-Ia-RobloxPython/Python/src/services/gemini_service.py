import os
import google.generativeai as genai

class GeminiService:
    def __init__(self):
        genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
        self.model = genai.GenerativeModel("gemini-3-flash-preview")

    def gerar_resposta(self, prompt):
        try:
            response = self.model.generate_content(prompt)
            return response.text if response.text else "Sem resposta no momento."
        except Exception as e:
            print("Erro no Gemini:", e)
            return "Erro ao gerar resposta."