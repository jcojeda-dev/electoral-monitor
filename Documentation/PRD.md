# Product Requirements Document (PRD) - Teacher Daily Assistant

## 1. Introducción y Visión General
**Teacher Daily Assistant** es una aplicación iOS móvil diseñada para solucionar el cuello de botella de comunicación entre profesores de colegios y padres de familia en Latinoamérica. El asistente permite a los docentes registrar de manera rápida y natural (mediante voz) lo acontecido durante la jornada escolar, procesarlo con inteligencia artificial para darle un tono profesional, y estructurarlo para ser compartido mediante WhatsApp en segundos.

---

## 2. Problema del Negocio
* **Sobrecarga administrativa del docente:** Al finalizar las clases, los docentes se encuentran cansados y con poco tiempo para redactar resúmenes detallados del día.
* **Canales informales e ineficientes:** WhatsApp es el canal preferido en Latinoamérica, pero se usa de forma desorganizada. Los mensajes se envían de noche, con errores ortográficos o carentes de formalidad institucional.
* **Pérdida de información:** Notas físicas, cuadernos de control y recordatorios sueltos suelen perderse antes de que el docente pueda escribirlos y compartirlos digitalmente.

---

## 3. Oportunidad del Mercado
* En América Latina, más del 90% de la comunicación escuela-hogar ocurre mediante chats de WhatsApp.
* Los colegios y docentes demandan herramientas individuales fáciles de adoptar sin complejas integraciones de sistemas escolares (SIS) o plataformas LMS.
* **Evolución SaaS:** Un MVP centrado en la productividad individual del docente permite crear tracción rápida ("Bottom-Up SaaS"), facilitando que luego los directores de colegios compren licencias multi-usuario al ver el impacto en la comunicación institucional.

---

## 4. Mercado Objetivo
* **Usuarios primarios:** Profesores de Inicial/Preescolar, Primaria y Secundaria.
* **Clientes indirectos (Fases Futuras):** Colegios privados de educación básica regular en Latinoamérica (SaaS institucional).

---

## 5. Casos de Uso del MVP
* **Caso de Uso 1: Registro Rápido Post-Clase.** El profesor sale de clases, presiona un botón y dice: *"Hicimos sumas en clase y dejé la página 45 como tarea para el lunes"*. La app transcribe y almacena el registro.
* **Caso de Uso 2: Redacción Profesional Automatizada.** El profesor selecciona la nota anterior, elige el tono "Cercano" y la app genera: *"Estimados padres de familia, hoy practicamos sumas en clase. Les recordamos repasar en casa y resolver la página 45 para el lunes. ¡Gracias!"*.
* **Caso de Uso 3: Envío Directo.** El profesor pulsa "Enviar", se abre WhatsApp con la plantilla pre-cargada y el profesor selecciona el grupo del aula correspondiente.
* **Caso de Uso 4: Prevención de Olvidos.** A las 5:00 PM la app notifica al profesor si hay actividades registradas en el día que aún no han sido compartidas por WhatsApp.

---

## 6. Alcance del MVP (Fase 1 & 2)

| Módulo / Característica | En el MVP | Fuera del MVP (Futuro) |
| :--- | :--- | :--- |
| **Plataforma** | iOS 18 (iPhone, SwiftUI, SwiftData) | Android, Web Dashboard, macOS |
| **Autenticación** | Local (Apple & Google Sign In UI/Mock Session) | Firebase Auth, SSO Colegios, Multi-usuario sync |
| **Base de Datos** | SwiftData (Local persistente) | PostgreSQL + Firebase Cloud Firestore |
| **Speech to Text** | Apple Speech Framework (On-device / Native) | API de Whisper (OpenAI) en la nube |
| **Motor de IA** | OpenAI API (GPT-4o mini) mediante Key del usuario | Backend con OpenAI/Gemini administrado por la app |
| **Integración WhatsApp** | URL Schemes nativos (`whatsapp://send`) | WhatsApp Business API, CRM integrado |
| **Resumen Diario** | Reporte en pantalla (Cursos, Actividades) | Reporte PDF automatizado por email para directores |
| **Recordatorios** | Notificaciones locales programadas en el iPhone | Push Notifications remotas (APNS via Cloud Functions) |

---

## 7. Requerimientos No Funcionales
* **Privacidad (GDPR/APPs):** Cumplimiento con almacenamiento local bajo SwiftData. Las grabaciones de voz se procesan a nivel de OS (Speech Framework de Apple) sin enviar audio a servidores externos.
* **Usabilidad:** Contraste elevado para uso bajo luz solar directa en el patio del colegio. Tipografía dinámica compatible con accesibilidad de iOS.
* **Rendimiento:** Latencia de conversión Speech-to-Text menor a 1 segundo.