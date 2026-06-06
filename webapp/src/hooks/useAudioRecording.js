import { useState, useRef, useCallback } from 'react'

const useAudioRecording = () => {
  const [isRecording, setIsRecording] = useState(false)
  const [recordingText, setRecordingText] = useState('')
  const [error, setError] = useState(null)
  const recognitionRef = useRef(null)

  const startRecording = useCallback(() => {
    try {
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
      
      if (!SpeechRecognition) {
        setError('Tu navegador no soporta grabación de voz. Usa Chrome, Edge o Safari.')
        return false
      }

      recognitionRef.current = new SpeechRecognition()
      recognitionRef.current.continuous = true
      recognitionRef.current.interimResults = true
      recognitionRef.current.language = 'es-ES'

      let interimTranscript = ''

      recognitionRef.current.onstart = () => {
        setIsRecording(true)
        setError(null)
        setRecordingText('')
      }

      recognitionRef.current.onresult = (event) => {
        interimTranscript = ''

        for (let i = event.resultIndex; i < event.results.length; i++) {
          const transcript = event.results[i][0].transcript

          if (event.results[i].isFinal) {
            setRecordingText((prev) => prev + transcript + ' ')
          } else {
            interimTranscript += transcript
          }
        }

        if (interimTranscript) {
          setRecordingText((prev) => {
            const finalText = prev
            return finalText + interimTranscript
          })
        }
      }

      recognitionRef.current.onerror = (event) => {
        let errorMessage = 'Error en la grabación'

        switch (event.error) {
          case 'no-speech':
            errorMessage = 'No se detectó voz. Intenta de nuevo.'
            break
          case 'audio-capture':
            errorMessage = 'No hay micrófono disponible.'
            break
          case 'network':
            errorMessage = 'Error de conexión. Verifica tu internet.'
            break
          default:
            errorMessage = `Error: ${event.error}`
        }

        setError(errorMessage)
      }

      recognitionRef.current.onend = () => {
        setIsRecording(false)
      }

      recognitionRef.current.start()
      return true
    } catch (err) {
      setError('Error al iniciar la grabación: ' + err.message)
      return false
    }
  }, [])

  const stopRecording = useCallback(() => {
    if (recognitionRef.current) {
      recognitionRef.current.stop()
      setIsRecording(false)
    }
  }, [])

  const clearRecording = useCallback(() => {
    setRecordingText('')
    setError(null)
  }, [])

  return {
    isRecording,
    recordingText,
    error,
    startRecording,
    stopRecording,
    clearRecording,
  }
}

export default useAudioRecording