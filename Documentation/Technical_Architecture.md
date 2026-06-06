# Technical Architecture - Teacher Daily Assistant

## 1. Patrón Arquitectónico (MVVM Modular)

La aplicación está diseñada sobre el patrón **MVVM (Model-View-ViewModel)** utilizando SwiftUI. Para garantizar que sea escalable a una arquitectura SaaS corporativa (con sincronización en la nube mediante Firebase y panel de administración web), estructuramos las dependencias mediante **Inyección de Dependencias (DI)** y **Protocolos**.

```
  +-------------------------+
  |         SwiftUI         |
  |          VIEWS          |
  +------------+------------+
               | (Observa y Vincula)
               v
  +-------------------------+
  |        ViewModels       |
  |     (Observable)        |
  +------------+------------+
               | (Invoca Interfaces)
               v
  +---------------------------------------------------------+
  |                       SERVICES                          |
  |  +------------------+  +------------------+  +-------+  |
  |  |  SpeechService   |  |   OpenAIService  |  | Auth  |  |
  |  +------------------+  +------------------+  +-------+  |
  +----------------------------+----------------------------+
                               | (Lee/Escribe)
                               v
  +---------------------------------------------------------+
  |                        MODELS                           |
  |              (SwiftData Local Storage)                  |
  +---------------------------------------------------------+
```