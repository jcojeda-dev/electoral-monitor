# Guía de Puesta en Marcha y Lanzamiento a Producción

Este documento detalla los pasos exactos y las mejores prácticas para compilar, probar en dispositivos reales y publicar la aplicación **Teacher Daily Assistant** en la App Store de Apple, listándola para su uso oficial.

---

## FASE A: Compilación en Xcode (Requiere una Mac)

Dado que las aplicaciones de iOS requieren el compilador de Apple para ser empaquetadas:

### 1. Requisitos de Software
* Una computadora Mac (MacBook, Mac Mini, iMac) con macOS Sonoma o posterior.
* **Xcode 16** o superior (descargable gratis desde la Mac App Store).

### 2. Creación del Proyecto
1. Abre Xcode y selecciona **Create a new Xcode project**.
2. Selecciona **iOS** -> **App** y presiona *Next*.
3. Llena la información:
   * **Product Name:** `TeacherDailyAssistant`
   * **Organization Identifier:** `com.tucolegio` o `com.tudominio`
   * **Interface:** *SwiftUI*
   * **Language:** *Swift*
   * **Storage:** *SwiftData* (esto activará los contenedores locales).
4. Guarda el proyecto en tu Mac.

### 3. Importación de Archivos
* Arrastra los archivos que generamos en la carpeta `TeacherDailyAssistant/` del simulador y colócalos en la barra lateral izquierda de Xcode:
  * Reemplaza el archivo `TeacherDailyAssistantApp.swift` por el que creamos.
  * Añade las carpetas `Models`, `Services`, `ViewModels` y `Views`.
  * Copia las propiedades de configuración al archivo `Info.plist` (especialmente `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`, `NSFaceIDUsageDescription` y el esquema query de `whatsapp`).

---

## FASE B: Pruebas con Profesores (Apple TestFlight)

Antes de publicarla para todo el público, debes probarla con un grupo selecto de profesores en sus propios iPhones:

1. **Apple Developer Program:** Regístrate en [developer.apple.com](https://developer.apple.com/) (tiene un costo de $99 USD anuales que cobra Apple).
2. **Vincular cuenta en Xcode:** En Xcode ve a *Settings > Accounts* y agrega tu Apple ID de desarrollador.
3. **Compilar y Archivar:**
   * Conecta un iPhone real por USB o selecciona **Any iOS Device (arm64)** en la barra superior.
   * Ve al menú superior **Product** -> **Archive**.
   * Una vez terminado el proceso, se abrirá la ventana de *Organizer*. Presiona **Distribute App** y selecciona **TestFlight / App Store Connect**.
4. **Invitar a Profesores:**
   * Ingresa a [App Store Connect](https://appstoreconnect.apple.com/).
   * Ve a la sección **TestFlight** de tu app.
   * Crea un grupo de pruebas internas (agrega los correos de Apple de tus profesores de prueba).
   * A ellos les llegará una invitación por correo para instalar la app usando la herramienta **TestFlight** oficial de Apple de manera gratuita y privada.

---

## FASE C: Seguridad e Infraestructura para Producción

En el MVP actual, los profesores pueden escribir su propio token de OpenAI en Configuración. Sin embargo, para poner la app a funcionar de manera comercial o institucional a gran escala, debes migrar a una arquitectura de servidor intermedia:

### 1. Servidor Proxy (Middleware)
* **El Problema:** Escribir la clave API de OpenAI del colegio dentro del código de la app es inseguro si el usuario inspecciona el tráfico de red, y pedir a cada docente su propia API Key reduce la adopción del usuario común.
* **La Solución:** Crea una pequeña API en la nube (usando Node.js, Python o Firebase Cloud Functions) que reciba el dictado del profesor, realice la llamada a OpenAI con tu clave guardada de forma segura en las variables de entorno del servidor, y devuelva el texto mejorado a la app.

### 2. Sincronización Firebase (Paso a SaaS)
* Para evolucionar la app y que no solo sea local:
  1. Instala el SDK de Firebase a través del gestor de paquetes de Xcode (Swift Package Manager).
  2. Implementa **Firebase Auth** para que los profesores tengan cuentas con contraseña y correo electrónico.
  3. Reemplaza el servicio de guardado local por consultas y escrituras a **Firebase Cloud Firestore**, permitiendo que las notas del profesor se sincronicen en tiempo real con una consola web para los directores del colegio.

---

## FASE D: Publicación en la App Store

Una vez que el periodo de pruebas en TestFlight sea exitoso:

1. Rellena la ficha técnica en App Store Connect (Capturas de pantalla en diferentes tamaños de iPhone, descripción comercial de la app, y enlaces a soporte).
2. Sube la **Política de Privacidad** (obligatoria para Apple). Puedes generar una plantilla que declare que la aplicación no recolecta información confidencial de alumnos.
3. Envía a revisión (**Submit for Review**). El equipo de ingenieros de Apple probará la app y la aprobará para su descarga pública en un plazo promedio de 24 a 48 horas.