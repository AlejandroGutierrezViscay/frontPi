# 🔄 ADAPTACIÓN FRONTEND AL BACKEND - FINCA SMART

## 📋 RESUMEN DE CAMBIOS

Este documento detalla los cambios realizados en el frontend Flutter para adaptarlo correctamente al backend Spring Boot de FincaSmart.

**REGLA PRINCIPAL**: El backend NO se modifica. El frontend se adapta a la estructura del backend.

---

## ✅ CAMBIOS REALIZADOS

### 1. **Modelo User** (user.dart)

#### ❌ ANTERIOR (Incorrecto):
```dart
class User {
  final String id;
  final String email;
  final String nombre;
  final String apellido;  // ❌ No existe en backend
  final String? telefono;
  final String? fechaNacimiento;  // ❌ No existe en backend
  final Genero? genero;  // ❌ No existe en backend
  final String? photoUrl;  // ❌ No existe en backend
  final TipoUsuario tipoUsuario;  // ❌ No existe en backend
  final bool verificado;  // ❌ No existe en backend
  final bool activo;
  final String fechaRegistro;
  final String? fechaUltimoAcceso;  // ❌ No existe en backend
  final AuthProvider authProvider;  // ❌ No existe en backend
  final PreferenciasUsuario? preferencias;  // ❌ No existe en backend
}
```

#### ✅ NUEVO (Correcto):
```dart
class User {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final bool activo;
  final String? fechaRegistro;
  final String? password; // Solo para enviar, nunca se recibe
}
```

**Backend real**: `User { id, nombre, email, telefono, password, activo, fechaRegistro }`

---

### 2. **Modelo Finca** (finca.dart)

#### ❌ ANTERIOR (Incorrecto):
```dart
class Finca {
  final String id;
  final String titulo;  // ❌ Backend usa "nombre"
  final String descripcion;
  final double precio;  // ❌ Backend usa "precioPorNoche"
  final String ubicacion;
  final String ciudad;  // ❌ No existe en backend
  final String departamento;  // ❌ No existe en backend
  final double latitud;  // ❌ No existe en backend
  final double longitud;  // ❌ No existe en backend
  final List<String> imagenes;  // ❌ Backend usa List<ImagenFinca>
  final String propietarioId;  // ❌ Backend usa objeto propietario
  final int capacidadMaxima;  // ❌ No existe en backend
  final int numeroHabitaciones;  // ❌ No existe en backend
  final int numeroBanos;  // ❌ No existe en backend
  final List<String> servicios;  // ❌ Backend usa amenidades
  final List<String> actividades;  // ❌ No existe en backend
  final bool disponible;  // ❌ No existe en backend
  final double calificacion;  // ❌ No existe en backend
  final int numeroReviews;  // ❌ No existe en backend
  final DateTime fechaCreacion;  // ❌ No existe en backend
  final DateTime? fechaActualizacion;  // ❌ No existe en backend
  final TipoFinca tipo;  // ❌ No existe en backend
  final List<ReglaFinca> reglas;  // ❌ No existe en backend
}
```

#### ✅ NUEVO (Correcto):
```dart
class Finca {
  final String id;
  final String nombre;
  final String descripcion;
  final String ubicacion;
  final double precioPorNoche;
  final Map<String, dynamic>? propietario; // {id, nombre, email, telefono}
  final List<ImagenFinca>? imagenes;
  final List<Amenidad>? amenidades;
}
```

**Backend real**: `Finca { id, nombre, ubicacion, precioPorNoche, descripcion, propietario, imagenes, amenidades }`

---

### 3. **Modelo Reserva** (reserva.dart)

#### ❌ ANTERIOR (Incorrecto):
```dart
class Reserva {
  final String id;
  final String fincaId;  // ❌ Backend usa objeto finca
  final String usuarioId;  // ❌ Backend usa objeto usuario
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int numeroHuespedes;  // ❌ No existe en backend
  final double precioTotal;
  final double precioNoche;  // ❌ No existe (se calcula)
  final int numeroNoches;  // ❌ No existe (se calcula)
  final EstadoReserva estado;
  final DateTime fechaCreacion;  // ❌ No existe en backend
  final DateTime? fechaCancelacion;  // ❌ No existe en backend
  final String? motivoCancelacion;  // ❌ No existe en backend
  final String? notasEspeciales;  // ❌ No existe en backend
  final DatosContacto datosContacto;  // ❌ No existe en backend
  final List<String>? serviciosAdicionales;  // ❌ No existe en backend
}
```

#### ✅ NUEVO (Correcto):
```dart
class Reserva {
  final String id;
  final Map<String, dynamic>? usuario; // {id, nombre, email, telefono}
  final Map<String, dynamic>? finca; // {id, nombre, ubicacion, precioPorNoche}
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double precioTotal;
  final EstadoReserva estado;
}
```

**Backend real**: `Reserva { id, usuario, finca, fechaInicio, fechaFin, precioTotal, estado }`

---

### 4. **Enum EstadoReserva**

#### ✅ CORRECTO (Coincide con Backend):
```dart
enum EstadoReserva {
  PENDIENTE,
  CONFIRMADA,
  CANCELADA,
  COMPLETADA
}
```

**Backend**: `enum EstadoReserva { PENDIENTE, CONFIRMADA, CANCELADA, COMPLETADA }`

---

### 5. **ApiConfig** (api_config.dart)

#### ❌ BUG CORREGIDO:
```dart
// ANTES (INCORRECTO):
static bool get isLocalhost => baseUrl.contains('localhost:8084'); // ❌ Puerto incorrecto

// AHORA (CORRECTO):
static bool get isLocalhost => baseUrl.contains('localhost:8080'); // ✅ Puerto correcto
```

---

## 📡 FORMATO JSON CORRECTO PARA EL BACKEND

### **1. Crear Usuario (POST /api/users)**
```json
{
  "nombre": "Juan Pérez",
  "email": "juan@example.com",
  "telefono": "3001234567",
  "password": "password123"
}
```

### **2. Login (POST /api/auth/login)**
```json
{
  "email": "juan@example.com",
  "password": "password123"
}
```

**Respuesta**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "id": 1,
  "nombre": "Juan Pérez",
  "email": "juan@example.com",
  "telefono": "3001234567",
  "activo": true
}
```

### **3. Registro (POST /api/auth/register)**
```json
{
  "nombre": "María López",
  "email": "maria@example.com",
  "telefono": "3009876543",
  "password": "password456"
}
```

### **4. Crear Finca (POST /api/fincas)**
```json
{
  "nombre": "Finca El Paraíso",
  "ubicacion": "Medellín, Antioquia",
  "precioPorNoche": 150000,
  "descripcion": "Hermosa finca con piscina",
  "propietario": {
    "id": 1
  }
}
```

### **5. Crear Reserva (POST /api/reservas)**
```json
{
  "usuario": {
    "id": 1
  },
  "finca": {
    "id": 1
  },
  "fechaInicio": "2025-12-01",
  "fechaFin": "2025-12-03",
  "estado": "PENDIENTE"
}
```

**⚠️ IMPORTANTE**: Las fechas deben estar en formato `YYYY-MM-DD` (LocalDate de Java)

---

## 🔑 CLASES AUXILIARES NUEVAS

### **RegisterRequest**
```dart
class RegisterRequest {
  final String nombre;
  final String email;
  final String telefono;
  final String password;
  
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'password': password,
    };
  }
}
```

### **LoginRequest**
```dart
class LoginRequest {
  final String email;
  final String password;
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
```

### **AuthResponse**
```dart
class AuthResponse {
  final String token;
  final String type;
  final User user;
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      type: json['type'] as String? ?? 'Bearer',
      user: User.fromJson(json),
    );
  }
}
```

### **ImagenFinca**
```dart
class ImagenFinca {
  final String id;
  final String urlImagen;
  final bool esPrincipal;
  final int orden;
  final String? descripcion;
}
```

### **Amenidad**
```dart
class Amenidad {
  final String id;
  final String nombre;
  final String? icono;
  final String? categoria;
}
```

---

## 🛠️ SERVICIOS QUE NECESITAN ACTUALIZACIÓN

Los siguientes servicios necesitarán ser actualizados para usar los nuevos modelos:

1. **auth_service.dart** - ✅ Revisar que use `RegisterRequest` y `LoginRequest` correctamente
2. **user_api_service.dart** - ✅ Actualizar para enviar JSON correcto
3. **finca_service.dart** - ⚠️ REQUIERE ACTUALIZACIÓN para parsear correctamente
4. **reserva_service.dart** - ⚠️ REQUIERE ACTUALIZACIÓN para parsear correctamente

---

## 📊 MAPEO CAMPOS BACKEND → FRONTEND

### **User**
| Backend | Frontend | Tipo | Notas |
|---------|----------|------|-------|
| `id` | `id` | Long → String | Convertir toString() |
| `nombre` | `nombre` | String | ✅ Igual |
| `email` | `email` | String | ✅ Igual |
| `telefono` | `telefono` | String | ✅ Igual |
| `password` | `password` | String | Solo envío, nunca recepción |
| `activo` | `activo` | Boolean | ✅ Igual |
| `fechaRegistro` | `fechaRegistro` | LocalDateTime → String | Opcional |

### **Finca**
| Backend | Frontend | Tipo | Notas |
|---------|----------|------|-------|
| `id` | `id` | Long → String | Convertir toString() |
| `nombre` | `nombre` | String | ✅ Igual |
| `descripcion` | `descripcion` | String | ✅ Igual |
| `ubicacion` | `ubicacion` | String | ✅ Igual |
| `precioPorNoche` | `precioPorNoche` | BigDecimal → double | ✅ Convertir |
| `propietario` | `propietario` | User → Map | Objeto anidado |
| `imagenes` | `imagenes` | List<ImagenFinca> | Array de objetos |
| `amenidades` | `amenidades` | List<Amenidad> | Array de objetos |

### **Reserva**
| Backend | Frontend | Tipo | Notas |
|---------|----------|------|-------|
| `id` | `id` | Long → String | Convertir toString() |
| `usuario` | `usuario` | User → Map | Objeto anidado |
| `finca` | `finca` | Finca → Map | Objeto anidado |
| `fechaInicio` | `fechaInicio` | LocalDate → DateTime | Formato YYYY-MM-DD |
| `fechaFin` | `fechaFin` | LocalDate → DateTime | Formato YYYY-MM-DD |
| `precioTotal` | `precioTotal` | BigDecimal → double | ✅ Convertir |
| `estado` | `estado` | EstadoReserva | Enum (MAYÚSCULAS) |

---

## ⚠️ PUNTOS CRÍTICOS A RECORDAR

1. **IDs como Long**: El backend devuelve IDs como `Long` (números), el frontend los maneja como `String`
   ```dart
   id: json['id'].toString() // ✅ SIEMPRE convertir
   ```

2. **Fechas en formato ISO**: 
   - Backend envía: `"2025-12-01"` (LocalDate)
   - Backend recibe: `"2025-12-01"` (LocalDate)
   - Frontend debe parsear: `DateTime.parse(json['fechaInicio'])`
   - Frontend debe formatear: `"${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"`

3. **Objetos anidados**: Cuando el backend devuelve un objeto completo (usuario, finca, propietario), guardarlo como `Map<String, dynamic>?` y extraer campos con getters

4. **Crear vs Actualizar**:
   - **Crear**: Solo enviar campos necesarios, no incluir `id`
   - **Actualizar**: Enviar todos los campos requeridos

5. **Estados enum**: Deben coincidir EXACTAMENTE con el backend (MAYÚSCULAS)
   ```dart
   enum EstadoReserva { PENDIENTE, CONFIRMADA, CANCELADA, COMPLETADA }
   ```

---

## ✅ TESTING

Para verificar que todo funciona correctamente:

1. **Test de Login**:
   ```dart
   POST /api/auth/login
   { "email": "test@test.com", "password": "123456" }
   ```

2. **Test de Registro**:
   ```dart
   POST /api/auth/register
   { "nombre": "Test", "email": "new@test.com", "telefono": "123", "password": "123456" }
   ```

3. **Test de Fincas**:
   ```dart
   GET /api/fincas
   ```

4. **Test de Reservas**:
   ```dart
   GET /api/reservas
   ```

---

## 🎯 PRÓXIMOS PASOS

1. ✅ Modelos adaptados correctamente
2. ✅ ApiConfig corregido
3. ⚠️ Actualizar servicios para usar nuevos modelos
4. ⚠️ Actualizar vistas/widgets para usar nuevos campos
5. ⚠️ Probar integración completa con backend

---

**Fecha de actualización**: Noviembre 10, 2025  
**Versión Backend**: Spring Boot 3.5.6  
**Versión Frontend**: Flutter 3.9.2
