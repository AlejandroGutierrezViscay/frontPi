# 🚀 GUÍA DE PRUEBAS POSTMAN - FINCA SMART API

## 📋 CONFIGURACIÓN INICIAL
- *Base URL*: http://localhost:8080
- *Content-Type*: application/json (para requests POST/PUT)
- *Puerto*: 8080

---

## 👥 ENDPOINTS DE USUARIOS (/api/users)

### ✅ 1. OBTENER TODOS LOS USUARIOS
http
GET http://localhost:8080/api/users


### ✅ 2. CREAR USUARIO
http
POST http://localhost:8080/api/users
Content-Type: application/json

{
    "nombre": "Juan Pérez",
    "email": "juan@example.com",
    "telefono": "3001234567",
    "password": "password123"
}


### ✅ 3. CREAR SEGUNDO USUARIO (PROPIETARIO)
http
POST http://localhost:8080/api/users
Content-Type: application/json

{
    "nombre": "María García",
    "email": "maria@example.com",
    "telefono": "3009876543",
    "password": "password456"
}


### ✅ 4. OBTENER USUARIO POR ID
http
GET http://localhost:8080/api/users/1


### ✅ 5. OBTENER USUARIOS ACTIVOS
http
GET http://localhost:8080/api/users/activos


### ✅ 6. BUSCAR USUARIO POR EMAIL
http
GET http://localhost:8080/api/users/email/juan@example.com


### ✅ 7. BUSCAR USUARIOS POR NOMBRE
http
GET http://localhost:8080/api/users/buscar?nombre=Juan


### ✅ 8. ACTUALIZAR USUARIO
http
PUT http://localhost:8080/api/users/1
Content-Type: application/json

{
    "nombre": "Juan Carlos Pérez",
    "email": "juan.carlos@example.com",
    "telefono": "3001234567",
    "password": "newpassword123"
}


### ✅ 9. CAMBIAR ESTADO USUARIO
http
PATCH http://localhost:8080/api/users/1/estado?activo=false


### ✅ 10. ELIMINAR USUARIO (SOFT DELETE)
http
DELETE http://localhost:8080/api/users/1


### ✅ 11. VERIFICAR SI EXISTE EMAIL
http
GET http://localhost:8080/api/users/existe/test@example.com


### ✅ 12. CONTAR USUARIOS ACTIVOS
http
GET http://localhost:8080/api/users/contar/activos


---

## 🏡 ENDPOINTS DE FINCAS (/api/fincas)

### ✅ 1. OBTENER TODAS LAS FINCAS
http
GET http://localhost:8080/api/fincas


### ✅ 2. CREAR FINCA (Usar ID de usuario existente como propietario)
http
POST http://localhost:8080/api/fincas
Content-Type: application/json

{
    "nombre": "Finca El Paraíso",
    "ubicacion": "Medellín, Antioquia",
    "precioPorNoche": 150000,
    "descripcion": "Hermosa finca con piscina, BBQ y vista panorámica a las montañas. Perfecta para descansar en familia.",
    "propietario": {
        "id": 2
    }
}


### ✅ 3. CREAR SEGUNDA FINCA
http
POST http://localhost:8080/api/fincas
Content-Type: application/json

{
    "nombre": "Villa Las Flores",
    "ubicacion": "Rionegro, Antioquia",
    "precioPorNoche": 200000,
    "descripcion": "Villa moderna con jacuzzi, cancha de fútbol y zona de camping. Ideal para eventos.",
    "propietario": {
        "id": 2
    }
}


### ✅ 4. CREAR TERCERA FINCA
http
POST http://localhost:8080/api/fincas
Content-Type: application/json

{
    "nombre": "Casa de Campo Los Pinos",
    "ubicacion": "Guatapé, Antioquia",
    "precioPorNoche": 120000,
    "descripcion": "Acogedora casa de campo cerca al embalse. WiFi, cocina completa y hamacas.",
    "propietario": {
        "id": 2
    }
}


### ✅ 5. OBTENER FINCA POR ID
http
GET http://localhost:8080/api/fincas/1


### ✅ 6. OBTENER FINCAS DISPONIBLES
http
GET http://localhost:8080/api/fincas/disponibles


### ✅ 7. OBTENER FINCAS POR PROPIETARIO
http
GET http://localhost:8080/api/fincas/propietario/2


### ✅ 8. BUSCAR FINCAS POR NOMBRE
http
GET http://localhost:8080/api/fincas/buscar/nombre?nombre=paraiso


### ✅ 9. BUSCAR FINCAS POR UBICACIÓN
http
GET http://localhost:8080/api/fincas/buscar/ubicacion?ubicacion=medellin


### ✅ 10. BUSCAR FINCAS HASTA PRECIO MÁXIMO
http
GET http://localhost:8080/api/fincas/buscar/precio-max?maxPrecio=160000


### ✅ 11. BUSCAR FINCAS POR RANGO DE PRECIOS
http
GET http://localhost:8080/api/fincas/buscar/precio-rango?minPrecio=100000&maxPrecio=180000


### ✅ 12. BUSCAR CON FILTROS COMBINADOS
http
GET http://localhost:8080/api/fincas/buscar/filtros?maxPrecio=200000&ubicacion=antioquia


### ✅ 13. ACTUALIZAR FINCA COMPLETA
http
PUT http://localhost:8080/api/fincas/1
Content-Type: application/json

{
    "nombre": "Finca El Paraíso Renovada",
    "ubicacion": "Medellín, Antioquia",
    "precioPorNoche": 180000,
    "descripcion": "Finca completamente renovada con nuevas amenidades: piscina climatizada, wifi de alta velocidad y zona gourmet.",
    "propietario": {
        "id": 2
    }
}


### ✅ 14. ACTUALIZAR SOLO PRECIO
http
PATCH http://localhost:8080/api/fincas/1/precio?precio=170000


### ✅ 15. OBTENER PRECIO PROMEDIO
http
GET http://localhost:8080/api/fincas/precio-promedio


### ✅ 16. CONTAR FINCAS POR PROPIETARIO
http
GET http://localhost:8080/api/fincas/contar/propietario/2


### ✅ 17. VERIFICAR SI EXISTE FINCA CON NOMBRE
http
GET http://localhost:8080/api/fincas/existe?nombre=Paraiso&propietarioId=2


### ✅ 18. ELIMINAR FINCA
http
DELETE http://localhost:8080/api/fincas/3


---

## 📅 ENDPOINTS DE RESERVAS (/api/reservas)

### ✅ 1. OBTENER TODAS LAS RESERVAS
http
GET http://localhost:8080/api/reservas


### ✅ 2. CREAR RESERVA
http
POST http://localhost:8080/api/reservas
Content-Type: application/json

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


### ✅ 3. CREAR SEGUNDA RESERVA
http
POST http://localhost:8080/api/reservas
Content-Type: application/json

{
    "usuario": {
        "id": 1
    },
    "finca": {
        "id": 2
    },
    "fechaInicio": "2025-12-15",
    "fechaFin": "2025-12-17",
    "estado": "PENDIENTE"
}


### ✅ 4. OBTENER RESERVA POR ID
http
GET http://localhost:8080/api/reservas/1


### ✅ 5. OBTENER RESERVAS POR USUARIO
http
GET http://localhost:8080/api/reservas/usuario/1


### ✅ 6. OBTENER RESERVAS FUTURAS POR USUARIO
http
GET http://localhost:8080/api/reservas/usuario/1/futuras


### ✅ 7. OBTENER RESERVAS PASADAS POR USUARIO
http
GET http://localhost:8080/api/reservas/usuario/1/pasadas


### ✅ 8. OBTENER RESERVAS POR FINCA
http
GET http://localhost:8080/api/reservas/finca/1


### ✅ 9. OBTENER RESERVAS EN RANGO DE FECHAS
http
GET http://localhost:8080/api/reservas/fechas?fechaInicio=2025-12-01&fechaFin=2025-12-31


### ✅ 10. OBTENER RESERVAS POR USUARIO Y FECHAS
http
GET http://localhost:8080/api/reservas/usuario/1/fechas?fechaDesde=2025-12-01&fechaHasta=2025-12-31


### ✅ 11. VERIFICAR DISPONIBILIDAD DE FINCA
http
GET http://localhost:8080/api/reservas/disponibilidad?fincaId=1&fechaInicio=2025-12-10&fechaFin=2025-12-12


### ✅ 12. VERIFICAR DISPONIBILIDAD FECHA ESPECÍFICA
http
GET http://localhost:8080/api/reservas/disponibilidad/fecha?fincaId=1&fecha=2025-12-05


### ✅ 13. ACTUALIZAR RESERVA
http
PUT http://localhost:8080/api/reservas/1
Content-Type: application/json

{
    "usuario": {
        "id": 1
    },
    "finca": {
        "id": 1
    },
    "fechaInicio": "2025-12-02",
    "fechaFin": "2025-12-04",
    "estado": "PENDIENTE"
}


### ✅ 14. CAMBIAR ESTADO DE RESERVA
http
PATCH http://localhost:8080/api/reservas/1/estado?estado=CONFIRMADA


### ✅ 15. CONFIRMAR RESERVA
http
PATCH http://localhost:8080/api/reservas/1/confirmar


### ✅ 16. CANCELAR RESERVA
http
PATCH http://localhost:8080/api/reservas/1/cancelar


### ✅ 17. OBTENER INGRESOS POR FINCA
http
GET http://localhost:8080/api/reservas/ingresos/finca/1


### ✅ 18. OBTENER INGRESOS POR PROPIETARIO
http
GET http://localhost:8080/api/reservas/ingresos/propietario/2


### ✅ 19. CONTAR RESERVAS POR FINCA
http
GET http://localhost:8080/api/reservas/contar/finca/1


### ✅ 20. ELIMINAR RESERVA
http
DELETE http://localhost:8080/api/reservas/2


---

## 🎯 FLUJO DE PRUEBAS RECOMENDADO

### *Paso 1: Crear datos base*
1. Crear 2-3 usuarios
2. Crear 2-3 fincas (usando IDs de usuarios como propietarios)
3. Crear 2-3 reservas (usando IDs de usuarios y fincas)

### *Paso 2: Probar consultas*
1. Obtener todas las entidades
2. Buscar por diferentes criterios
3. Probar filtros y búsquedas avanzadas

### *Paso 3: Probar actualizaciones*
1. Actualizar usuarios, fincas y reservas
2. Cambiar estados
3. Probar validaciones (precios negativos, fechas inválidas, etc.)

### *Paso 4: Probar utilidades*
1. Verificar disponibilidades
2. Calcular ingresos y promedios
3. Contar registros

### *Paso 5: Probar eliminaciones*
1. Eliminar reservas
2. Soft delete de usuarios
3. Eliminar fincas

---

## 📝 NOTAS IMPORTANTES

### *Estados de Reserva válidos:*
- PENDIENTE
- CONFIRMADA 
- CANCELADA
- COMPLETADA

### *Formato de fechas:*
- Usar formato: YYYY-MM-DD
- Ejemplo: 2025-12-01

### *Validaciones implementadas:*
- ✅ Email único para usuarios
- ✅ Precios positivos para fincas
- ✅ Fechas futuras para reservas
- ✅ Disponibilidad de fincas
- ✅ Propietarios activos

### *Códigos de respuesta esperados:*
- 200 - OK (GET, PUT, PATCH)
- 201 - Created (POST)
- 204 - No Content (DELETE)
- 400 - Bad Request (validaciones fallidas)
- 404 - Not Found (ID inexistente)

---

## 🚀 ¡LISTO PARA PROBAR!

Copia y pega estos comandos directamente en Postman. Recuerda ajustar los IDs según los datos que vayas creando.

*¡Felices pruebas!* 🎉# 🚀 GUÍA DE PRUEBAS POSTMAN - FINCA SMART API

## 📋 CONFIGURACIÓN INICIAL
- *Base URL*: http://localhost:8080
- *Content-Type*: application/json (para requests POST/PUT)
- *Puerto*: 8080

---

## 👥 ENDPOINTS DE USUARIOS (/api/users)

### ✅ 1. OBTENER TODOS LOS USUARIOS
http
GET http://localhost:8080/api/users


### ✅ 2. CREAR USUARIO
http
POST http://localhost:8080/api/users
Content-Type: application/json

{
    "nombre": "Juan Pérez",
    "email": "juan@example.com",
    "telefono": "3001234567",
    "password": "password123"
}


### ✅ 3. CREAR SEGUNDO USUARIO (PROPIETARIO)
http
POST http://localhost:8080/api/users
Content-Type: application/json

{
    "nombre": "María García",
    "email": "maria@example.com",
    "telefono": "3009876543",
    "password": "password456"
}


### ✅ 4. OBTENER USUARIO POR ID
http
GET http://localhost:8080/api/users/1


### ✅ 5. OBTENER USUARIOS ACTIVOS
http
GET http://localhost:8080/api/users/activos


### ✅ 6. BUSCAR USUARIO POR EMAIL
http
GET http://localhost:8080/api/users/email/juan@example.com


### ✅ 7. BUSCAR USUARIOS POR NOMBRE
http
GET http://localhost:8080/api/users/buscar?nombre=Juan


### ✅ 8. ACTUALIZAR USUARIO
http
PUT http://localhost:8080/api/users/1
Content-Type: application/json

{
    "nombre": "Juan Carlos Pérez",
    "email": "juan.carlos@example.com",
    "telefono": "3001234567",
    "password": "newpassword123"
}


### ✅ 9. CAMBIAR ESTADO USUARIO
http
PATCH http://localhost:8080/api/users/1/estado?activo=false


### ✅ 10. ELIMINAR USUARIO (SOFT DELETE)
http
DELETE http://localhost:8080/api/users/1


### ✅ 11. VERIFICAR SI EXISTE EMAIL
http
GET http://localhost:8080/api/users/existe/test@example.com


### ✅ 12. CONTAR USUARIOS ACTIVOS
http
GET http://localhost:8080/api/users/contar/activos


---

## 🏡 ENDPOINTS DE FINCAS (/api/fincas)

### ✅ 1. OBTENER TODAS LAS FINCAS
http
GET http://localhost:8080/api/fincas


### ✅ 2. CREAR FINCA (Usar ID de usuario existente como propietario)
http
POST http://localhost:8080/api/fincas
Content-Type: application/json

{
    "nombre": "Finca El Paraíso",
    "ubicacion": "Medellín, Antioquia",
    "precioPorNoche": 150000,
    "descripcion": "Hermosa finca con piscina, BBQ y vista panorámica a las montañas. Perfecta para descansar en familia.",
    "propietario": {
        "id": 2
    }
}


### ✅ 3. CREAR SEGUNDA FINCA
http
POST http://localhost:8080/api/fincas
Content-Type: application/json

{
    "nombre": "Villa Las Flores",
    "ubicacion": "Rionegro, Antioquia",
    "precioPorNoche": 200000,
    "descripcion": "Villa moderna con jacuzzi, cancha de fútbol y zona de camping. Ideal para eventos.",
    "propietario": {
        "id": 2
    }
}


### ✅ 4. CREAR TERCERA FINCA
http
POST http://localhost:8080/api/fincas
Content-Type: application/json

{
    "nombre": "Casa de Campo Los Pinos",
    "ubicacion": "Guatapé, Antioquia",
    "precioPorNoche": 120000,
    "descripcion": "Acogedora casa de campo cerca al embalse. WiFi, cocina completa y hamacas.",
    "propietario": {
        "id": 2
    }
}


### ✅ 5. OBTENER FINCA POR ID
http
GET http://localhost:8080/api/fincas/1


### ✅ 6. OBTENER FINCAS DISPONIBLES
http
GET http://localhost:8080/api/fincas/disponibles


### ✅ 7. OBTENER FINCAS POR PROPIETARIO
http
GET http://localhost:8080/api/fincas/propietario/2


### ✅ 8. BUSCAR FINCAS POR NOMBRE
http
GET http://localhost:8080/api/fincas/buscar/nombre?nombre=paraiso


### ✅ 9. BUSCAR FINCAS POR UBICACIÓN
http
GET http://localhost:8080/api/fincas/buscar/ubicacion?ubicacion=medellin


### ✅ 10. BUSCAR FINCAS HASTA PRECIO MÁXIMO
http
GET http://localhost:8080/api/fincas/buscar/precio-max?maxPrecio=160000


### ✅ 11. BUSCAR FINCAS POR RANGO DE PRECIOS
http
GET http://localhost:8080/api/fincas/buscar/precio-rango?minPrecio=100000&maxPrecio=180000


### ✅ 12. BUSCAR CON FILTROS COMBINADOS
http
GET http://localhost:8080/api/fincas/buscar/filtros?maxPrecio=200000&ubicacion=antioquia


### ✅ 13. ACTUALIZAR FINCA COMPLETA
http
PUT http://localhost:8080/api/fincas/1
Content-Type: application/json

{
    "nombre": "Finca El Paraíso Renovada",
    "ubicacion": "Medellín, Antioquia",
    "precioPorNoche": 180000,
    "descripcion": "Finca completamente renovada con nuevas amenidades: piscina climatizada, wifi de alta velocidad y zona gourmet.",
    "propietario": {
        "id": 2
    }
}


### ✅ 14. ACTUALIZAR SOLO PRECIO
http
PATCH http://localhost:8080/api/fincas/1/precio?precio=170000


### ✅ 15. OBTENER PRECIO PROMEDIO
http
GET http://localhost:8080/api/fincas/precio-promedio


### ✅ 16. CONTAR FINCAS POR PROPIETARIO
http
GET http://localhost:8080/api/fincas/contar/propietario/2


### ✅ 17. VERIFICAR SI EXISTE FINCA CON NOMBRE
http
GET http://localhost:8080/api/fincas/existe?nombre=Paraiso&propietarioId=2


### ✅ 18. ELIMINAR FINCA
http
DELETE http://localhost:8080/api/fincas/3


---

## 📅 ENDPOINTS DE RESERVAS (/api/reservas)

### ✅ 1. OBTENER TODAS LAS RESERVAS
http
GET http://localhost:8080/api/reservas


### ✅ 2. CREAR RESERVA
http
POST http://localhost:8080/api/reservas
Content-Type: application/json

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


### ✅ 3. CREAR SEGUNDA RESERVA
http
POST http://localhost:8080/api/reservas
Content-Type: application/json

{
    "usuario": {
        "id": 1
    },
    "finca": {
        "id": 2
    },
    "fechaInicio": "2025-12-15",
    "fechaFin": "2025-12-17",
    "estado": "PENDIENTE"
}


### ✅ 4. OBTENER RESERVA POR ID
http
GET http://localhost:8080/api/reservas/1


### ✅ 5. OBTENER RESERVAS POR USUARIO
http
GET http://localhost:8080/api/reservas/usuario/1


### ✅ 6. OBTENER RESERVAS FUTURAS POR USUARIO
http
GET http://localhost:8080/api/reservas/usuario/1/futuras


### ✅ 7. OBTENER RESERVAS PASADAS POR USUARIO
http
GET http://localhost:8080/api/reservas/usuario/1/pasadas


### ✅ 8. OBTENER RESERVAS POR FINCA
http
GET http://localhost:8080/api/reservas/finca/1


### ✅ 9. OBTENER RESERVAS EN RANGO DE FECHAS
http
GET http://localhost:8080/api/reservas/fechas?fechaInicio=2025-12-01&fechaFin=2025-12-31


### ✅ 10. OBTENER RESERVAS POR USUARIO Y FECHAS
http
GET http://localhost:8080/api/reservas/usuario/1/fechas?fechaDesde=2025-12-01&fechaHasta=2025-12-31


### ✅ 11. VERIFICAR DISPONIBILIDAD DE FINCA
http
GET http://localhost:8080/api/reservas/disponibilidad?fincaId=1&fechaInicio=2025-12-10&fechaFin=2025-12-12


### ✅ 12. VERIFICAR DISPONIBILIDAD FECHA ESPECÍFICA
http
GET http://localhost:8080/api/reservas/disponibilidad/fecha?fincaId=1&fecha=2025-12-05


### ✅ 13. ACTUALIZAR RESERVA
http
PUT http://localhost:8080/api/reservas/1
Content-Type: application/json

{
    "usuario": {
        "id": 1
    },
    "finca": {
        "id": 1
    },
    "fechaInicio": "2025-12-02",
    "fechaFin": "2025-12-04",
    "estado": "PENDIENTE"
}


### ✅ 14. CAMBIAR ESTADO DE RESERVA
http
PATCH http://localhost:8080/api/reservas/1/estado?estado=CONFIRMADA


### ✅ 15. CONFIRMAR RESERVA
http
PATCH http://localhost:8080/api/reservas/1/confirmar


### ✅ 16. CANCELAR RESERVA
http
PATCH http://localhost:8080/api/reservas/1/cancelar


### ✅ 17. OBTENER INGRESOS POR FINCA
http
GET http://localhost:8080/api/reservas/ingresos/finca/1


### ✅ 18. OBTENER INGRESOS POR PROPIETARIO
http
GET http://localhost:8080/api/reservas/ingresos/propietario/2


### ✅ 19. CONTAR RESERVAS POR FINCA
http
GET http://localhost:8080/api/reservas/contar/finca/1


### ✅ 20. ELIMINAR RESERVA
http
DELETE http://localhost:8080/api/reservas/2


---

## 🎯 FLUJO DE PRUEBAS RECOMENDADO

### *Paso 1: Crear datos base*
1. Crear 2-3 usuarios
2. Crear 2-3 fincas (usando IDs de usuarios como propietarios)
3. Crear 2-3 reservas (usando IDs de usuarios y fincas)

### *Paso 2: Probar consultas*
1. Obtener todas las entidades
2. Buscar por diferentes criterios
3. Probar filtros y búsquedas avanzadas

### *Paso 3: Probar actualizaciones*
1. Actualizar usuarios, fincas y reservas
2. Cambiar estados
3. Probar validaciones (precios negativos, fechas inválidas, etc.)

### *Paso 4: Probar utilidades*
1. Verificar disponibilidades
2. Calcular ingresos y promedios
3. Contar registros

### *Paso 5: Probar eliminaciones*
1. Eliminar reservas
2. Soft delete de usuarios
3. Eliminar fincas

---

## 📝 NOTAS IMPORTANTES

### *Estados de Reserva válidos:*
- PENDIENTE
- CONFIRMADA 
- CANCELADA
- COMPLETADA

### *Formato de fechas:*
- Usar formato: YYYY-MM-DD
- Ejemplo: 2025-12-01

### *Validaciones implementadas:*
- ✅ Email único para usuarios
- ✅ Precios positivos para fincas
- ✅ Fechas futuras para reservas
- ✅ Disponibilidad de fincas
- ✅ Propietarios activos

### *Códigos de respuesta esperados:*
- 200 - OK (GET, PUT, PATCH)
- 201 - Created (POST)
- 204 - No Content (DELETE)
- 400 - Bad Request (validaciones fallidas)
- 404 - Not Found (ID inexistente)

---

## 🚀 ¡LISTO PARA PROBAR!

Copia y pega estos comandos directamente en Postman. Recuerda ajustar los IDs según los datos que vayas creando.

*¡Felices pruebas!* 🎉