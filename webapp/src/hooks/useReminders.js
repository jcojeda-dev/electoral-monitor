import { useState, useEffect, useCallback } from 'react'

const useReminders = () => {
  const [reminders, setReminders] = useState([])
  const [nextReminderTime, setNextReminderTime] = useState(null)

  useEffect(() => {
    try {
      const saved = localStorage.getItem('reminders')
      if (saved) {
        setReminders(JSON.parse(saved))
      }
    } catch (err) {
      console.error('Error cargando recordatorios:', err)
    }
  }, [])

  useEffect(() => {
    try {
      localStorage.setItem('reminders', JSON.stringify(reminders))
    } catch (err) {
      console.error('Error guardando recordatorios:', err)
    }
  }, [reminders])

  useEffect(() => {
    const interval = setInterval(() => {
      const now = new Date()

      reminders.forEach((reminder) => {
        if (!reminder.enabled) return

        const [hours, minutes] = reminder.time.split(':').map(Number)
        const reminderTime = new Date()
        reminderTime.setHours(hours, minutes, 0)

        if (
          now.getHours() === hours &&
          now.getMinutes() === minutes &&
          !reminder.lastShown
        ) {
          showReminderNotification(reminder)
          updateReminder(reminder.id, { lastShown: new Date().toDateString() })
        }

        if (reminder.lastShown && reminder.lastShown !== new Date().toDateString()) {
          updateReminder(reminder.id, { lastShown: null })
        }
      })
    }, 60000)

    return () => clearInterval(interval)
  }, [reminders])

  const showReminderNotification = (reminder) => {
    if ('Notification' in window && Notification.permission === 'granted') {
      new Notification('📝 Recordatorio: Notas Pendientes', {
        body: reminder.message || 'Tienes notas pendientes por enviar',
        icon: '📚',
        tag: 'teacher-reminder',
      })
    }

    alert(`⏰ ${reminder.message || 'Tienes notas pendientes por enviar'}`)
  }

  const addReminder = useCallback((time, message = '') => {
    const newReminder = {
      id: Date.now(),
      time,
      message,
      enabled: true,
      lastShown: null,
    }
    setReminders((prev) => [...prev, newReminder])
    return newReminder
  }, [])

  const updateReminder = useCallback((id, updates) => {
    setReminders((prev) =>
      prev.map((reminder) =>
        reminder.id === id ? { ...reminder, ...updates } : reminder
      )
    )
  }, [])

  const deleteReminder = useCallback((id) => {
    setReminders((prev) => prev.filter((reminder) => reminder.id !== id))
  }, [])

  const toggleReminder = useCallback((id) => {
    setReminders((prev) =>
      prev.map((reminder) =>
        reminder.id === id ? { ...reminder, enabled: !reminder.enabled } : reminder
      )
    )
  }, [])

  const requestNotificationPermission = useCallback(async () => {
    if ('Notification' in window && Notification.permission === 'default') {
      try {
        await Notification.requestPermission()
      } catch (err) {
        console.error('Error solicitando permiso de notificaciones:', err)
      }
    }
  }, [])

  return {
    reminders,
    addReminder,
    updateReminder,
    deleteReminder,
    toggleReminder,
    requestNotificationPermission,
    nextReminderTime,
  }
}

export default useReminders