# Home Feature - Arquitectura

Esta carpeta contiene la implementación de la funcionalidad del Dashboard/Home siguiendo los principios SOLID, especialmente el **Principio de Responsabilidad Única (SRP)**.

## Estructura

```
home/
├── models/
│   └── dashboard_data.dart          # Modelo de datos del dashboard
├── viewmodels/
│   └── home_dashboard_viewmodel.dart # Lógica de negocio
└── views/
    └── home_view.dart                # Interfaz de usuario
```

## Responsabilidades

### 1. Models (`dashboard_data.dart`)

**Responsabilidad**: Encapsular los datos del dashboard

- Define la estructura de datos `DashboardData`
- Calcula estadísticas derivadas (conteos por estado)
- Filtra objetos recientes
- No contiene lógica de acceso a datos ni UI

```dart
DashboardData.fromObjects(
  userName: 'Juan',
  objects: listOfObjects,
  recentLimit: 5,
)
```

### 2. ViewModels (`home_dashboard_viewmodel.dart`)

**Responsabilidad**: Gestionar la lógica de negocio y acceso a datos

- **Obtención de datos**: Accede a Firebase (Auth y Firestore)
- **Transformación**: Convierte datos crudos en modelos usables
- **Streams reactivos**: Combina múltiples fuentes de datos
- **Procesamiento de nombres**: Extrae y formatea nombres de usuario
- **No contiene widgets ni lógica de UI**

**Métodos principales**:

- `getDashboardDataStreamReactive()`: Stream principal que combina usuario y objetos
- `_getUserNameStream()`: Obtiene nombre del usuario desde Firestore
- `_getObjectsStream()`: Obtiene objetos desde Firestore
- `_extractUserName()`: Procesa el nombre del usuario con fallbacks

### 3. Views (`home_view.dart`)

**Responsabilidad**: Presentar la interfaz de usuario

- **Solo renderiza widgets**: No contiene lógica de negocio
- **Consume datos del ViewModel**: A través de StreamBuilder
- **Maneja estados visuales**: Loading, error, empty, success
- **Delegación**: Toda la lógica está en el ViewModel
- **Widgets componibles**: Métodos privados para construir partes de la UI

**Métodos de construcción**:

- `_buildHeader()`: Saludo personalizado
- `_buildSummaryCards()`: Tarjetas de estadísticas
- `_buildMainContent()`: Lista de objetos recientes
- `_buildLoadingState()`: Indicador de carga
- `_buildErrorState()`: Mensaje de error
- `_buildEmptyState()`: Estado vacío

## Flujo de Datos

```
Firebase Auth → ViewModel → DashboardData → View
     ↓              ↓            ↓           ↓
Firebase Firestore → Stream → Model → StreamBuilder → UI
```

1. **Usuario se autentica** → ViewModel obtiene UID
2. **ViewModel consulta Firestore** → Obtiene nombre y objetos
3. **Datos se transforman** → `DashboardData` con estadísticas calculadas
4. **Stream emite datos** → View recibe `DashboardData`
5. **View renderiza** → Widgets con los datos procesados

## Ventajas de esta Arquitectura

### ✅ Principio de Responsabilidad Única

- **Model**: Solo datos y cálculos básicos
- **ViewModel**: Solo lógica de negocio y acceso a datos
- **View**: Solo presentación y UI

### ✅ Testeable

```dart
// Fácil de testear el ViewModel sin UI
final viewModel = HomeDashboardViewModel();
final stream = viewModel.getDashboardDataStreamReactive();
expect(stream, emits(predicate((data) => data.userName == 'Test')));
```

### ✅ Reutilizable

- `DashboardData` puede usarse en otras vistas
- ViewModel puede ser compartido entre widgets
- Lógica centralizada en un solo lugar

### ✅ Mantenible

- Cambios en la UI no afectan la lógica de negocio
- Cambios en Firebase no afectan la UI
- Cada capa es independiente

### ✅ Escalable

- Fácil agregar nuevas estadísticas en `DashboardData`
- Fácil agregar nuevas fuentes de datos en ViewModel
- Fácil agregar nuevos widgets en View

## Ejemplo de Uso

```dart
// En la vista
final viewModel = HomeDashboardViewModel();

StreamBuilder<DashboardData>(
  stream: viewModel.getDashboardDataStreamReactive(),
  builder: (context, snapshot) {
    final data = snapshot.data ?? DashboardData.empty();
    
    return Text('¡Hola, ${data.userName}!');
  },
)
```

## Mejoras Futuras

- [ ] Implementar caché local con Hive o SharedPreferences
- [ ] Agregar paginación para objetos
- [ ] Implementar filtros avanzados
- [ ] Agregar analytics de usuario
- [ ] Implementar refresh manual (pull-to-refresh)

## Principios SOLID Aplicados

1. **S**ingle Responsibility Principle ✅
   - Cada clase tiene una responsabilidad clara

2. **O**pen/Closed Principle ✅
   - Extensible sin modificar código existente

3. **L**iskov Substitution Principle ✅
   - Los modelos pueden ser sustituidos sin romper código

4. **I**nterface Segregation Principle ✅
   - Interfaces específicas y no sobrecargadas

5. **D**ependency Inversion Principle ✅
   - View depende de abstracciones (Stream) no de implementaciones
