# Riesgos Técnicos y Guía de Publicación (App Store)

Este documento detalla los riesgos técnicos más críticos del proyecto y proporciona recomendaciones precisas para publicar la aplicación de manera exitosa en **TestFlight** y la **Apple App Store**, respetando las políticas de privacidad y hardware.

---

## 1. Riesgos Técnicos Críticos y Mitigación

### R1. Restricciones de Envío en WhatsApp (iOS Sandboxing)
* **El Riesgo:** WhatsApp no permite el envío de mensajes en segundo plano de forma 100% automatizada a través de aplicaciones de terceros sin usar la API de pago (WhatsApp Business API).
* **Mitigación:** La aplicación genera una URL formateada usando el esquema `whatsapp://send?text=...` o `https://api.whatsapp.com/send?text=...` y abre la aplicación oficial de WhatsApp. El usuario final debe seleccionar el chat o grupo de padres de familia y presionar el botón "Enviar" nativo de WhatsApp. Esto es transparente, legal y seguro ante las políticas de Meta y Apple.
* **Configuración Clave:** En iOS 15+, la aplicación debe declarar explícitamente en su archivo `Info.plist` que consultará el esquema de WhatsApp para poder abrirlo:
  ```xml
  <key>LSApplicationQueriesSchemes</key>
  <array>
      <string>whatsapp</string>
  </array>
  ```

### R2. Permisos y Límites de Reconocimiento de Voz (Speech Recognition)
* **El Riesgo:** El reconocimiento de voz de Apple (`SFSpeechRecognizer`) requiere permisos explícitos de micrófono y reconocimiento. Si el usuario los deniega, la app queda inusable. Además, Apple limita las peticiones diarias de Speech por dispositivo (usualmente 1000 grabaciones por día).
* **Mitigación:**
  1. Mostrar pantallas preparatorias explicando por qué necesitamos estos permisos antes de invocar la alerta del sistema.
  2. Implementar un fallback: Si no hay conexión a internet o falla el Speech recognizer, permitir el registro clásico por teclado.
  3. Describir claramente el uso en el `Info.plist`:
     * `NSMicrophoneUsageDescription`: *"Necesitamos acceder al micrófono para que puedas dictar las actividades y tareas del día."*
     * `NSSpeechRecognitionUsageDescription`: *"Utilizamos el reconocimiento de voz para convertir tu dictado a texto automáticamente."*

### R3. Privacidad de Datos de Menores (COPPA / FERPA / GDPR / APPs)
* **El Riesgo:** Al tratar con actividades escolares, se pueden llegar a registrar nombres de alumnos menores de edad (ej. incidencias o notas específicas). Las tiendas de apps son sumamente estrictas con la privacidad infantil.
* **Mitigación:**
  * **Almacenamiento Local (MVP):** La app no envía datos de alumnos a ningún servidor; todo reside en la base de datos local `SwiftData` encriptada por el hardware de iOS.
  * **Políticas de Privacidad:** El prompt de OpenAI para el procesamiento de IA debe indicar explícitamente que no se envíe información sensible del alumno si se usa en la nube, y las políticas de la App Store deben detallar que la app es un "asistente personal de notas locales" sin recopilación de datos de terceros (Data Not Collected).

---

## 2. Recomendaciones para TestFlight y App Store

### Paso 1: Configurar Certificados y Provisioning Profiles
1. Regístrate en el Apple Developer Program ($99 USD/año).
2. En Xcode, vincula tu cuenta de desarrollador de Apple en **Settings > Accounts**.
3. Asegúrate de habilitar las siguientes capacidades (**Capabilities**) en el proyecto de Xcode:
   * **Push Notifications** (para cuando escalemos a Firebase).
   * **App Groups / Background Modes** (opcional, para recordatorios en segundo plano).

### Paso 2: Crear el Registro en App Store Connect
1. Ingresa a [App Store Connect](https://appstoreconnect.apple.com/).
2. Crea una **Nueva App**, selecciona el Bundle ID del proyecto y asígnale el nombre **Teacher Daily Assistant**.
3. Rellena los metadatos (descripción, palabras clave, capturas de pantalla, URL de soporte y URL de política de privacidad).

### Paso 3: Lanzamiento en TestFlight (Pruebas Beta)
1. En Xcode, selecciona el destino **Any iOS Device (arm64)**.
2. Ve al menú **Product > Archive**.
3. Una vez generado el archivo, presiona **Distribute App** y elije **TestFlight / App Store Connect**.
4. En App Store Connect, agrega los correos electrónicos de los profesores de prueba en la sección de **TestFlight > Internal Testing** (hasta 100 usuarios) o **External Testing** (requiere revisión rápida de Apple, hasta 10,000 usuarios).

### Paso 4: Revisión de la App Store (App Review)
Para evitar que Apple rechace tu app, asegúrate de proveer lo siguiente en las notas de revisión:
1. **Credenciales de prueba:** Un usuario de demostración con cursos ya pre-cargados.
2. **Video explicativo:** Envíales un enlace de video mostrando cómo la app utiliza la API de OpenAI y abre WhatsApp, ya que a veces los revisores no tienen WhatsApp instalado en sus dispositivos de prueba.
3. **API Key de Prueba:** Configura una API Key temporal o un comportamiento de prueba que no falle si el revisor no ingresa su propia clave OpenAI.