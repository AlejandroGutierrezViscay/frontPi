# frontpi

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## CONTEXTO DEL PROYECTO

**Nombre:** KUDOS  
**Tipo:** Aplicación móvil de seguimiento de hábitos  
**Estado:** MVP (Producto Mínimo Viable) en planeación  
**Objetivo Principal:** Permitir a los usuarios registrar, gestionar y hacer seguimiento de sus hábitos diarios con sistema de recordatorios y estadísticas motivacionales.

## ALCANCE DETALLADO DEL MVP

### MÓDULO 1: REGISTRO Y AUTENTICACIÓN (12 puntos)
- **Registro con correo y contraseña** (2 pts)
- **Login con correo y contraseña** (2 pts) 
- **Registro con Google** (3 pts)
- **Login con Google** (3 pts)
- **Confirmación de registro exitoso** (2 pts)

### MÓDULO 2: VISUALIZACIÓN DE HÁBITOS (14 puntos)
- **Listado de hábitos del día actual** (3 pts)
- **Marcado de hábitos completados** (3 pts)
- **Diferenciación visual de estados** (3 pts)
- **Calendario de hábitos por mes** (5 pts) - NUEVA FUNCIONALIDAD

### MÓDULO 3: GESTIÓN DE HÁBITOS (12 puntos)
- **Creación de nuevo hábito** (3 pts)
- **Edición de hábitos existentes** (3 pts)
- **Eliminación de hábitos** (3 pts)
- **Configuración de frecuencia** (3 pts)

### MÓDULO 4: SISTEMA DE RECORDATORIOS (16 puntos)
- **Activación/Desactivación** (3 pts)
- **Configuración de horarios** (8 pts) - AUMENTÓ LA COMPLEJIDAD
- **Recepción de notificaciones push** (5 pts)

### MÓDULO 5: ESTADÍSTICAS Y MÉTRICAS (16 puntos)
- **Visualización de rachas** (3 pts)
- **Porcentaje de cumplimiento** (3 pts)
- **Estadísticas históricas** (5 pts)
- **Métricas por hábito individual** (5 pts)

## DEFINITION OF READY (DoR) IMPLEMENTADA

Cada historia debe cumplir con:
DOR GENERAL:

Formato "Como [rol] quiero [objetivo] para [beneficio]"

Mínimo 3 criterios de aceptación Given/When/Then

Estimación en story points asignada

Tamaño adecuado para un sprint

DOR ESPECÍFICA POR MÓDULO:

AUTENTICACIÓN: Flujos de error, emails, OAuth, sesiones

HÁBITOS: Modelo de datos, estados, reglas de negocio

NOTIFICACIONES: Formatos, permisos, timezones

ESTADÍSTICAS: Fórmulas, visualizaciones, períodos

DISEÑO Y UX:

Mockups/design aprobados

Flujo de usuario definido

Estados de UI considerados

text

## DETALLES TÉCNICOS Y FUNCIONALES CLAVE

### Modelo de Datos de Hábitos
Hábito {
nombre: string (obligatorio)
descripción: string (opcional)
categoría: string
icono: string
frecuencia: "diario" | "personalizado"
días_personalizados: string[] (si frecuencia es personalizado)
recordatorio_activo: boolean
horario_recordatorio: time (opcional)
estado: "pendiente" | "completado" | "fallado"
}

text

### Flujos de Usuario Principales
1. **Onboarding:** Registro → Confirmación → Pantalla principal vacía
2. **Gestión diaria:** Ver hábitos del día → Marcar completados → Ver progreso
3. **Configuración:** Crear/editar hábitos → Configurar recordatorios → Ver stats
4. **Seguimiento:** Revisar calendario mensual → Analizar métricas → Ajustar hábitos

### Criterios de Aceptación Ejemplares
Para "Marcado de hábitos completados":
DADO usuario con hábitos pendientes

CUANDO pulsa sobre un hábito pendiente

ENTONCES cambia visualmente a completado Y persiste el estado

text

## DEPENDENCIAS TÉCNICAS IDENTIFICADAS

1. **Autenticación con Google** (OAuth2, Google Console)
2. **Sistema de Notificaciones Push** (Firebase, APNS)
3. **Base de datos para historial** (para stats y rachas)
4. **Manejo de timezones** (recordatorios locales)
5. **Algoritmos de cálculo** (rachas, porcentajes, progreso)

## METAS DE USUARIO Y VALOR DE NEGOCIO

**Usuario Objetivo:** Personas que buscan construir o mantener hábitos saludables
**Propuesta de Valor:** Sistema simple pero poderoso con recordatorios inteligentes y métricas motivacionales
**Métrica de Éxito:** Retención a 30 días > 60%, Engagement diario > 70%

## PRIORIZACIÓN ACTUAL
- **ALTA (26%):** Funcionalidades core de autenticación y gestión básica
- **MEDIA (47%):** Experiencia de usuario mejorada y recordatorios
- **BAJA (27%):** Analytics avanzados y métricas

## SOLICITUD ESPECÍFICA

Como Claude, necesito que:
1. **Comprendas la arquitectura completa** y las interdependencias
2. **Puedas sugerir mejoras** en flujos o criterios de aceptación
3. **Ayudes a identificar riesgos técnicos** o de implementación
4. **Assistas en refinamiento de historias** según el DoR establecido
5. **Proveas orientación técnica** sobre implementación de features complejas