# Reglas de Seguridad para Firebase

Este documento proporciona ejemplos de reglas de seguridad para Firestore y Storage que puedes usar en tu proyecto Firebase para desarrollo local.

## Reglas de Firestore

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // --- Colección de usuarios ---
    match /usuarios/{id} {
      // Solo el propio usuario puede ver o editar su información
      allow read, update, delete: if request.auth != null && request.auth.uid == id;
      allow create: if request.auth != null;
    }

    // --- Colección de objetos perdidos ---
    match /objetos_perdidos/{id} {
      // Cualquiera puede leer (vista pública)
      allow read: if true;

      // Solo usuarios autenticados pueden crear nuevos objetos
      allow create: if request.auth != null;

      // Solo administradores pueden modificar o eliminar objetos
      allow update, delete: if request.auth != null && request.auth.token.admin == true;

      // Subcolección de entregas dentro de cada objeto
      match /entrega/{id} {
        // Solo los administradores pueden registrar o modificar entregas
        allow read, write: if request.auth != null && request.auth.token.admin == true;
      }
    }
  }
}
```

## Reglas de Storage

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // --- Carpeta de objetos (solo administradores) ---
    match /objetos/{allPaths=**} {
      // Solo los administradores pueden leer y escribir en la carpeta objetos
      allow read, write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Bloquear acceso a cualquier otra ruta
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

## Estructura de la Base de Datos

### Colección: users
```
{
  "actualizadoEn": "timestamp",
  "bio": "string",
  "creadoEn": "timestamp",
  "email": "string",
  "fotoUrl": "string",
  "nombre": "string",
  "telefono": "string",
  "tema": "string"
}
```

### Colección: objetos_perdidos
```
{
  "descripcion": "string",
  "estado": "string",
  "fecha_encontrado": "string",
  "fecha_registro": "string",
  "id_user": "string",
  "imagen_url": "string",
  "lugar_encontrado": "string",
  "nombre": "string"
}
```

### Subcolección: entrega (dentro de objetos_perdidos)
```
{
  "codigo_estudiante": "string",
  "fecha_entrega": "string",
  "foto_entrega_url": "string",
  "id_user": "string",
  "nombre_devuelto_a": "string",
  "nombre_encontrado_por": "string",
  "observaciones": "string"
}
```