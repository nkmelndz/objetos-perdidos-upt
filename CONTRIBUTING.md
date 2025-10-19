# Guía de contribución

¡Gracias por tu interés en contribuir! Sigue estos pasos para colaborar:

## Requisitos
- Tener conocimientos básicos de Flutter/Dart
- Seguir el estilo de código del proyecto
- Probar tu código antes de enviar PR

## Configuración del entorno
1. Sigue las instrucciones estándar para crear un nuevo proyecto en Flutter.

2. Configura tu propio proyecto Firebase:
   - Crea un proyecto en [Firebase Console](https://console.firebase.google.com/)
   - Habilita los servicios necesarios: Authentication, Cloud Firestore y Storage
   - Copia `lib/firebase_options.dart.example` a `lib/firebase_options.dart` y actualiza con tus credenciales
   - Asegúrate de ejecutar `flutter pub get` una vez finalizada la configuración de Firebase para garantizar que todas las dependencias se instalen correctamente

3. Estructura de la base de datos:
   - Las colecciones necesarias son: `users` y `objetos_perdidos` (la app las crea automáticamente)
   
   Para más detalles sobre reglas de seguridad y estructura de la base de datos, consulta el archivo [firebase_rules.md](firebase_rules.md)

4. Configuración de usuarios administradores:
   - Actualmente, la aplicación solo permite acceso a usuarios con claim `admin`
   - Para configurar un usuario como administrador, ejecuta el siguiente script de Node.js:

   ```javascript
   const admin = require("firebase-admin");
   
   // Carga tus credenciales descargadas desde Firebase Console
const serviceAccount = require("./ruta-a-tu-archivo-de-credenciales.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// UID del usuario (cópialo desde Firebase Authentication)
const uid = "TuUsuarioUID123456789"; // Ejemplo: "g7H3aB9cD2eF1gH0iJ"
   
   admin
     .auth()
     .setCustomUserClaims(uid, { admin: true })
     .then(() => {
       console.log(`✅ Usuario ${uid} ahora es ADMIN`);
     })
     .catch((err) => {
       console.error("❌ Error al asignar rol:", err);
     });
   ```
   
   - Pasos para ejecutar el script:
     1. Instala Node.js si no lo tienes
     2. Instala firebase-admin: `npm install firebase-admin`
     3. Descarga el archivo de credenciales de administrador desde Firebase Console (Configuración del proyecto > Cuentas de servicio)
     4. Reemplaza el UID en el script con el ID del usuario que deseas convertir en administrador
     5. Ejecuta el script: `node nombre-del-archivo.js`

## Proceso
1. Haz un fork del repositorio y clónalo
2. Crea una rama para tu cambio:
   ```sh
   git checkout -b mi-feature
   ```
3. Realiza tus cambios y haz commit con mensajes claros
4. Haz push y abre un Pull Request
5. Espera la revisión y responde a los comentarios

## Seguridad y datos sensibles
- **NUNCA** incluyas credenciales, claves API o tokens en tus commits
- No subas archivos de configuración de Firebase (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`)
- Si encuentras información sensible en el código, repórtalo como un issue de seguridad

## Reportar bugs o sugerencias
- Usa la pestaña Issues en GitHub
- Describe el problema o mejora con detalle

## Código de conducta
Lee el [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) para mantener un ambiente respetuoso.

