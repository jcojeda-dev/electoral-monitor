import { useState, useCallback } from 'react'
import { GoogleGenerativeAI } from '@google/generative-ai'

const useGeminiAI = () => {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  const generateText = useCallback(async (prompt, tone = 'profesional') => {
    setLoading(true)
    setError(null)

    try {
      const apiKey = import.meta.env.VITE_GEMINI_API_KEY
      
      if (!apiKey) {
        throw new Error('VITE_GEMINI_API_KEY no configurada. Revisa .env.local')
      }

      const genAI = new GoogleGenerativeAI(apiKey)
      const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' })

      const toneInstructions = {
        profesional: 'Genera un mensaje profesional, formal y estructurado. Perfecto para comunicación escuela-hogar.',
        cercano: 'Genera un mensaje amable, cercano y personal. Mantén un tono conversacional pero respetuoso.',
        informativo: 'Genera un mensaje directo, claro e informativo. Enfócate en los hechos principales.'
      }

      const systemPrompt = `${toneInstructions[tone] || toneInstructions.profesional}
      
Responde SOLO con el mensaje procesado, sin explicaciones adicionales ni caracteres especiales al inicio/final.
El mensaje debe ser apropiado para enviar por WhatsApp a padres de familia.
Máximo 280 caracteres para mantenerlo conciso.`

      const result = await model.generateContent({
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: `${systemPrompt}\n\nNota original: "${prompt}"`
              }
            ]
          }
        ]
      })

      const generatedText = result.response.text().trim()
      setLoading(false)
      return generatedText

    } catch (err) {
      const errorMessage = err.message || 'Error al generar texto con Gemini'
      setError(errorMessage)
      setLoading(false)
      throw err
    }
  }, [])

  return { generateText, loading, error }
}

export default useGeminiAI