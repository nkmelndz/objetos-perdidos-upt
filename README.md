
# Objetos Perdidos UPT

App open source para la gestión y reporte de objetos perdidos en la Universidad Privada de Tacna.

## Propósito
Esta aplicación permite a estudiantes y personal reportar, buscar y recuperar objetos perdidos dentro de la universidad. Cualquier persona puede contribuir y mejorar la plataforma.

## Requisitos previos
- [Flutter](https://flutter.dev/docs/get-started/install) >= 3.0
- Cuenta y proyecto en [Firebase](https://firebase.google.com/)
- Acceso a internet

## Instalación y ejecución
1. Clona el repositorio:
   ```sh
   git clone https://github.com/nkmelndz/objetos-perdidos-upt.git
   cd objetos-perdidos-upt
   ```
2. Instala dependencias:
   ```sh
   flutter pub get
   ```
3. Configura Firebase:
   - Crea un proyecto en Firebase y descarga los archivos de configuración (`google-services.json`, `GoogleService-Info.plist`).
   - Colócalos en las carpetas correspondientes (`android/app`, `ios/Runner`).
   - Actualiza `lib/firebase_options.dart` usando el asistente de FlutterFire.
4. Ejecuta la app:
   ```sh
   flutter run
   ```

## Ejemplo de uso
1. Inicia sesión con un correo de administrador.
2. Reporta un objeto perdido o revisa los reportes existentes.
3. Si el dueño reclama el objeto, marca el reporte como "entregado".
4. Administra tu perfil y cambia tu contraseña desde la sección de seguridad.

## Cómo contribuir
Lee el archivo [CONTRIBUTING.md](CONTRIBUTING.md) para ver las reglas y el proceso de contribución. Puedes:
- Proponer mejoras o nuevas funcionalidades
- Reportar bugs
- Mejorar la documentación
- Ayudar a otros usuarios

## Contacto y soporte
- Email: nkmelndz@gmail.com
- Issues: [GitHub Issues](https://github.com/nkmelndz/objetos-perdidos-upt/issues)
- Pull Requests: [GitHub PRs](https://github.com/nkmelndz/objetos-perdidos-upt/pulls)

## Licencia
Este proyecto está bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

## Estado del Proyecto
Este es un proyecto open source en desarrollo activo. Las contribuciones son bienvenidas.
