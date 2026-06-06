import Foundation

final class OpenAIService {
    static let shared = OpenAIService()
    
    private init() {}
    
    var apiKey: String {
        get {
            UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "openai_api_key")
        }
    }
    
    func rewriteActivity(content: String, tone: String, category: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let simulatedResult = self.simulateRewrite(content: content, tone: tone, category: category)
                completion(.success(simulatedResult))
            }
            return
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(.failure(NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let systemPrompt = """
        Eres un asistente redactor de comunicados para colegios en Latinoamérica. 
        Tu trabajo es mejorar el texto dictado por un profesor para enviarlo a los padres de familia. 
        Mantén la información de las actividades y tareas intacta, pero redacta de manera excelente según el tono solicitado.
        Categoría de la nota: \(category).
        Tono requerido: \(tone).
        
        Reglas de Tono:
        - "Cercano": Usa emojis, palabras amigables, un saludo afectuoso (ej. "Estimados papitos", "Queridos padres de familia"), y una despedida cálida.
        - "Formal": Redacción profesional, sin lenguaje coloquial, saludo estándar (ej. "Estimados padres de familia:"), firma y agradecimiento formal.
        - "Institucional": Redacción muy protocolar, inicia con "[COMUNICADO OFICIAL]" o similar, lenguaje corporativo de colegio.
        - "Breve": Directo al punto, una o dos oraciones máximo, ideal para lecturas en notificaciones rápidas.
        
        Devuelve únicamente el texto redactado final. No agregues introducciones como "Aquí está tu texto:" o explicaciones adicionales.
        """
        
        let parameters: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": content]
            ],
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "OpenAIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data returned"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let reply = message["content"] as? String {
                    DispatchQueue.main.async {
                        completion(.success(reply.trimmingCharacters(in: .whitespacesAndNewlines)))
                    }
                } else {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorObj = json["error"] as? [String: Any],
                       let errorMessage = errorObj["message"] as? String {
                        completion(.failure(NSError(domain: "OpenAIService", code: -3, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    } else {
                        completion(.failure(NSError(domain: "OpenAIService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse reply"])))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func simulateRewrite(content: String, tone: String, category: String) -> String {
        let cleanedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = cleanedContent.isEmpty ? "(Sin contenido registrado)" : cleanedContent
        
        switch tone.lowercased() {
        case "cercano":
            return """
            🌸 ¡Hola, queridos papitos y mamitas! ✨
            
            Les escribo para contarles sobre las novedades de la categoría [\(category)] del día de hoy:
            
            📝 \(body)
            
            Agradecemos de corazón su valioso apoyo y acompañamiento diario en casa. ¡Que tengan un hermoso día! 💕
            """
        case "formal":
            return """
            Estimados padres de familia:
            
            Junto con saludarles cordialmente, cumplo con informarles sobre las actividades correspondientes a la categoría [\(category)] de la jornada de hoy:
            
            • \(body)
            
            Agradecemos de antemano su atención y colaboración en el seguimiento académico.
            
            Atentamente,
            Dirección Docente
            """
        case "institucional":
            return """
            [COMUNICADO INSTITUCIONAL - COLEGIO TEACHER DAILY ASSISTANT]
            
            Estimados miembros de nuestra comunidad educativa:
            
            A través de esta circular informativa, se detalla lo establecido para la categoría [\(category)]:
            
            - Detalle: \(body)
            
            Solicitamos tomar las previsiones necesarias para asegurar el cumplimiento del alumno.
            
            Saludos institucionales.
            """
        case "breve":
            return "Aviso [\(category)]: \(body)"
        default:
            return "[\(category)] \(body)"
        }
    }
}