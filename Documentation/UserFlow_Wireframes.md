# User Flow & Wireframes - Teacher Daily Assistant

## 1. User Flow (Diagrama de Flujo del Usuario)

Este diagrama representa el flujo completo que sigue un profesor desde que abre la aplicación por primera vez hasta que comparte sus actividades y revisa su resumen diario.

```mermaid
graph TD
    A[Inicio App] --> B{¿Sesión Activa?}
    B -- No --> C[Pantalla de Login]
    C -->|Sign in with Apple / Google| D[Onboarding & Configuración Inicial]
    D --> E[Creación de Cursos Obligatoria]
    B -- Sí --> F{¿Tiene Cursos?}
    F -- No --> E
    F -- Sí --> G[Dashboard Principal]
    E --> G
    
    G -->|Presiona Micrófono| H[Pantalla de Registro por Voz]
    H -->|Hablar| I[Transcripción en Tiempo Real]
    I -->|Presiona Detener| J[Editor de Actividad]
    J -->|Seleccionar Curso y Categoría| K[Visualización y Edición de Texto]
    K -->|Presiona Mejorar con IA| L{¿Tiene Key OpenAI?}
    L -- Sí --> M[Procesar IA: Tono Seleccionado]
    L -- No --> N[Usar Texto Original Transcrito]
    M --> O[Guardar Actividad SwiftData]
    N --> O
    O --> P[Lista de Actividades Hoy]
    
    P -->|Presionar Compartir| Q[Generar Mensaje Formateado]
    Q --> R[Abrir WhatsApp y Seleccionar Chat]
    R -->|Confirmar Envío en WhatsApp| S[Marcar Actividad como Enviada]
    
    G -->|Presionar Ver Resumen| T[Resumen Diario Visual]
    G -->|Presionar Ajustes| U[Configuración / Face ID / Notificaciones]
```