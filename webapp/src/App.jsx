import { useState, useEffect } from 'react'
import useGeminiAI from './hooks/useGeminiAI'
import useAudioRecording from './hooks/useAudioRecording'
import useReminders from './hooks/useReminders'
import './App.css'

function App() {
  const [notes, setNotes] = useState([])
  const [currentNote, setCurrentNote] = useState('')
  const [selectedTone, setSelectedTone] = useState('profesional')
  const [processingId, setProcessingId] = useState(null)
  const [showReminderForm, setShowReminderForm] = useState(false)
  const [reminderTime, setReminderTime] = useState('18:00')
  const [reminderMessage, setReminderMessage] = useState('Tienes notas pendientes por enviar')
  const [micPermission, setMicPermission] = useState(null)
  
  const { generateText, loading: aiLoading, error: aiError } = useGeminiAI()
  const { isRecording, recordingText, error: recordingError, startRecording, stopRecording, clearRecording } = useAudioRecording()
  const { reminders, addReminder, deleteReminder, toggleReminder, requestNotificationPermission } = useReminders()

  const tones = {
    profesional: 'Tono profesional y formal',
    cercano: 'Tono cercano y amable',
    informativo: 'Tono informativo y directo'
  }

  useEffect(() => {
    requestNotificationPermission()
    requestMicrophonePermission()
  }, [])

  const requestMicrophonePermission = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      stream.getTracks().forEach(track => track.stop())
      setMicPermission('granted')
    } catch (err) {
      setMicPermission('denied')
      console.error('Permiso de micrófono denegado:', err)
    }
  }

  const handleAddNote = () => {
    if (currentNote.trim()) {
      const newNote = {
        id: Date.now(),
        rawText: currentNote,
        processedText: null,
        tone: selectedTone,
        timestamp: new Date().toLocaleString('es-ES'),
        processed: false,
        error: null
      }
      setNotes([newNote, ...notes])
      setCurrentNote('')
    }
  }

  const handleToggleRecording = async () => {
    if (isRecording) {
      stopRecording()
    } else {
      if (micPermission !== 'granted') {
        await requestMicrophonePermission()
      }
      startRecording()
    }
  }

  const handleUseRecording = () => {
    if (recordingText.trim()) {
      setCurrentNote(recordingText.trim())
      clearRecording()
    }
  }

  const handleAddReminder = () => {
    if (reminderTime) {
      addReminder(reminderTime, reminderMessage)
      setReminderTime('18:00')
      setReminderMessage('Tienes notas pendientes por enviar')
      setShowReminderForm(false)
    }
  }

  const handleProcessNote = async (id) => {
    const note = notes.find(n => n.id === id)
    if (!note || note.processed || aiLoading) return

    setProcessingId(id)
    try {
      const processedText = await generateText(note.rawText, note.tone)
      setNotes(notes.map(n => 
        n.id === id 
          ? { ...n, processedText, processed: true, error: null }
          : n
      ))
    } catch (err) {
      setNotes(notes.map(n => 
        n.id === id 
          ? { ...n, error: err.message }
          : n
      ))
    } finally {
      setProcessingId(null)
    }
  }

  const handleDeleteNote = (id) => {
    setNotes(notes.filter(note => note.id !== id))
  }

  const handleSendWhatsApp = (note) => {
    const textToSend = note.processedText || note.rawText
    const message = encodeURIComponent(textToSend)
    window.open(`https://wa.me/?text=${message}`, '_blank')
  }

  return (
    <div className="app-container">
      <header className="app-header">
        <h1 className="app-title">📚 Teacher Daily Assistant v1.1</h1>
        <p className="app-subtitle">Transforma tus notas en mensajes profesionales</p>
      </header>

      {aiError && (
        <div className="error-banner">
          <p>⚠️ {aiError}</p>
        </div>
      )}

      {recordingError && (
        <div className="error-banner">
          <p>🎤 {recordingError}</p>
        </div>
      )}

      <main className="app-main">
        {/* Input Section */}
        <section className="input-section">
          <div className="input-group">
            <label htmlFor="note-input" className="input-label">
              Escribe tu nota o graba por voz:
            </label>
            <textarea
              id="note-input"
              className="note-textarea"
              value={currentNote}
              onChange={(e) => setCurrentNote(e.target.value)}
              placeholder="Ej: Hicimos sumas en clase y dejé la página 45 como tarea"
              rows={4}
              disabled={aiLoading || isRecording}
            />
          </div>

          {isRecording && recordingText && (
            <div className="recording-preview">
              <p className="recording-label">🎙️ Texto detectado:</p>
              <p className="recording-text">{recordingText}</p>
            </div>
          )}

          <div className="controls">
            <div className="tone-selector">
              <label htmlFor="tone-select" className="tone-label">Tono:</label>
              <select
                id="tone-select"
                className="tone-select"
                value={selectedTone}
                onChange={(e) => setSelectedTone(e.target.value)}
                disabled={aiLoading || isRecording}
              >
                {Object.entries(tones).map(([key, value]) => (
                  <option key={key} value={key}>{value}</option>
                ))}
              </select>
            </div>

            <button
              className={`btn btn-recording ${isRecording ? 'recording' : ''}`}
              onClick={handleToggleRecording}
              disabled={aiLoading}
              aria-label={isRecording ? 'Detener grabación' : 'Iniciar grabación'}
              title={micPermission === 'denied' ? 'Permiso de micrófono denegado' : ''}
            >
              🎤 {isRecording ? 'Grabando...' : 'Grabar'}
            </button>
          </div>

          {isRecording && recordingText && (
            <button
              className="btn btn-secondary"
              onClick={handleUseRecording}
              aria-label="Usar grabación"
            >
              ✅ Usar Grabación
            </button>
          )}

          <button
            className="btn btn-primary"
            onClick={handleAddNote}
            disabled={!currentNote.trim() || aiLoading || isRecording}
          >
            ➕ Agregar Nota
          </button>
        </section>

        {/* Reminders Section */}
        <section className="reminders-section">
          <div className="reminders-header">
            <h2 className="section-title">⏰ Recordatorios</h2>
            <button
              className="btn btn-small"
              onClick={() => setShowReminderForm(!showReminderForm)}
              aria-label={showReminderForm ? 'Cerrar formulario' : 'Abrir formulario'}
            >
              {showReminderForm ? '✖️ Cerrar' : '➕ Nuevo'}
            </button>
          </div>

          {showReminderForm && (
            <div className="reminder-form">
              <div className="form-group">
                <label htmlFor="reminder-time" className="form-label">Hora del Recordatorio:</label>
                <input
                  id="reminder-time"
                  type="time"
                  className="form-input"
                  value={reminderTime}
                  onChange={(e) => setReminderTime(e.target.value)}
                />
              </div>

              <div className="form-group">
                <label htmlFor="reminder-message" className="form-label">Mensaje:</label>
                <input
                  id="reminder-message"
                  type="text"
                  className="form-input"
                  value={reminderMessage}
                  onChange={(e) => setReminderMessage(e.target.value)}
                  placeholder="Mensaje del recordatorio"
                  maxLength={100}
                />
              </div>

              <button
                className="btn btn-primary"
                onClick={handleAddReminder}
              >
                ➕ Agregar Recordatorio
              </button>
            </div>
          )}

          <div className="reminders-list-container">
            {reminders.length === 0 ? (
              <p className="empty-message">No hay recordatorios configurados. Agrega uno nuevo.</p>
            ) : (
              <div className="reminders-list">
                {reminders.map((reminder) => (
                  <div key={reminder.id} className="reminder-item">
                    <div className="reminder-info">
                      <p className="reminder-time">🕐 {reminder.time}</p>
                      <p className="reminder-message">{reminder.message}</p>
                    </div>
                    <div className="reminder-actions">
                      <button
                        className={`btn btn-toggle ${reminder.enabled ? 'enabled' : 'disabled'}`}
                        onClick={() => toggleReminder(reminder.id)}
                        aria-label={reminder.enabled ? 'Desactivar' : 'Activar'}
                      >
                        {reminder.enabled ? '✅ Activo' : '⭕ Inactivo'}
                      </button>
                      <button
                        className="btn btn-danger btn-small"
                        onClick={() => deleteReminder(reminder.id)}
                        aria-label="Eliminar"
                      >
                        🗑️
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </section>

        {/* Notes List Section */}
        <section className="notes-section">
          <h2 className="section-title">
            📝 Notas del Día ({notes.length})
          </h2>

          {notes.length === 0 ? (
            <div className="empty-state">
              <p className="empty-message">No hay notas aún. ¡Comienza agregando una!</p>
            </div>
          ) : (
            <div className="notes-list">
              {notes.map((note) => (
                <article key={note.id} className="note-card">
                  <div className="note-header">
                    <time className="note-timestamp">{note.timestamp}</time>
                    <span className="note-tone-badge">{tones[note.tone]}</span>
                  </div>

                  <div className="note-content">
                    <p className="note-label">Original:</p>
                    <p className="note-text">{note.rawText}</p>

                    {note.error && (
                      <div className="note-error">
                        <p>Error: {note.error}</p>
                      </div>
                    )}

                    {note.processed && (
                      <div className="note-processed">
                        <p className="note-label">✨ Procesada con IA:</p>
                        <p className="note-text processed">{note.processedText}</p>
                      </div>
                    )}

                    {processingId === note.id && (
                      <div className="note-loading">
                        <span className="spinner"></span> Mejorando con IA...
                      </div>
                    )}
                  </div>

                  <div className="note-actions">
                    {!note.processed && !note.error && (
                      <button
                        className={`btn btn-process ${processingId === note.id ? 'processing' : ''}`}
                        onClick={() => handleProcessNote(note.id)}
                        disabled={processingId === note.id || aiLoading}
                        aria-label="Procesar con IA"
                      >
                        {processingId === note.id ? '⏳ Procesando...' : '✨ Mejorar con IA'}
                      </button>
                    )}

                    <button
                      className="btn btn-secondary"
                      onClick={() => handleSendWhatsApp(note)}
                      disabled={processingId === note.id}
                      aria-label="Enviar por WhatsApp"
                    >
                      💬 WhatsApp
                    </button>
                    <button
                      className="btn btn-danger"
                      onClick={() => handleDeleteNote(note.id)}
                      disabled={processingId === note.id}
                      aria-label="Eliminar nota"
                    >
                      🗑️ Eliminar
                    </button>
                  </div>
                </article>
              ))}
            </div>
          )}
        </section>

        {/* Info Section */}
        <section className="info-section">
          <h2 className="section-title">💡 Cómo Usar</h2>
          <ol className="info-list">
            <li><strong>Escribe o graba:</strong> Tu observación del día en clase (voz o texto)</li>
            <li><strong>Usa grabación:</strong> Si grabaste, presiona "Usar Grabación" para insertar el texto</li>
            <li><strong>Elige el tono:</strong> Profesional, cercano o informativo</li>
            <li><strong>Agrégala:</strong> La nota se guardará en tu lista diaria</li>
            <li><strong>Configura recordatorios:</strong> En la sección de Recordatorios, agrega alertas personalizadas</li>
            <li><strong>Mejora con IA (Opcional):</strong> Presiona "Mejorar con IA" para pulir el mensaje</li>
            <li><strong>Envía a WhatsApp:</strong> Abre WhatsApp con la nota lista para compartir</li>
          </ol>
          
          <div className="info-box">
            <p><strong>🚀 Powered by Google Gemini</strong></p>
            <p>La IA gratuita de Google mejora automáticamente tus notas manteniéndolas fieles a tu intención original.</p>
          </div>
        </section>
      </main>

      <footer className="app-footer">
        <p>Teacher Daily Assistant v1.1 | Diseñado para maestros 📝</p>
      </footer>
    </div>
  )
}

export default App