# Diccionario de Datos - Iron Gym Analytics

## Objetivo

Este documento define las tablas, columnas, tipos de datos y relaciones del modelo de datos del proyecto **Iron Gym Analytics**.

El dataset será generado de forma sintética con Python y estará orientado a simular el funcionamiento de una pequeña cadena de gimnasios de barrio en Madrid durante el periodo **2023-2025**.

---

# Modelo de datos

El proyecto seguirá un modelo tipo estrella, compuesto por:

## Tablas de dimensión

- `dim_socios`
- `dim_centro`
- `dim_contrato`
- `dim_canal_captacion`
- `dim_fecha`

## Tablas de hechos

- `fact_visitas`
- `fact_pagos`
- `fact_socios_mes`

---

# 1. dim_socios

Tabla con la información principal de cada socio.

| Campo | Tipo de dato | Descripción | Ejemplo |
|---|---|---|---|
| id_socio | integer | Identificador único del socio | 1001 |
| genero | string | Género del socio | Mujer |
| edad | integer | Edad del socio | 32 |
| vive_cerca | integer | Indica si vive cerca del gimnasio | 1 |
| tiene_pareja_socio | integer | Indica si su pareja también es socia | 0 |
| telefono_registrado | integer | Indica si tiene teléfono registrado | 1 |
| asiste_clases_grupales | integer | Indica si suele asistir a clases grupales | 1 |
| fecha_alta | date | Fecha de alta del socio | 2023-01-15 |
| fecha_baja | date | Fecha de baja del socio, si abandonó | 2023-03-20 |
| churn_final | integer | Indica si el socio abandonó durante el periodo analizado | 1 |

---

# 2. dim_centro

Tabla con la información de los centros de Iron Gym.

| Campo | Tipo de dato | Descripción | Ejemplo |
|---|---|---|---|
| id_centro | integer | Identificador único del centro | 1 |
| nombre_centro | string | Nombre del centro | Malasaña |
| barrio | string | Barrio donde se ubica el centro | Malasaña |
| tipo_zona | string | Tipo de zona del centro | céntrica |
| capacidad_socios | integer | Capacidad aproximada de socios | 900 |
| precio_base_mensual | float | Precio base mensual del centro | 45.00 |

---

# 3. dim_contrato

Tabla con los tipos de contrato disponibles.

| Campo | Tipo de dato | Descripción | Ejemplo |
|---|---|---|---|
| id_contrato | integer | Identificador único del contrato | 1 |
| tipo_contrato | string | Tipo de contrato | mensual |
| duracion_meses | integer | Duración del contrato en meses | 1 |
| cuota_mensual | float | Cuota mensual asociada al contrato | 45.00 |

---

# 4. dim_canal_captacion

Tabla con los canales por los que llegan los socios.

| Campo | Tipo de dato | Descripción | Ejemplo |
|---|---|---|---|
| id_canal | integer | Identificador único del canal | 1 |
| canal_captacion | string | Canal por el que llegó el socio | redes_sociales |
| coste_captacion | float | Coste estimado de captación por socio | 60.00 |
| calidad_esperada | string | Calidad esperada del canal en términos de retención | media_baja |

---

# 5. dim_fecha

Tabla calendario para analizar la evolución temporal.

| Campo | Tipo de dato | Descripción | Ejemplo |
|---|---|---|---|
| id_fecha | integer | Identificador de fecha | 20230115 |
| fecha | date | Fecha completa | 2023-01-15 |
| año | integer | Año | 2023 |
| mes | integer | Número de mes | 1 |
| nombre_mes | string | Nombre del mes | enero |
| trimestre | string | Trimestre del año | Q1 |
| temporada | string | Temporada o periodo de negocio | propósito_año_nuevo |

---

# 6. fact_visitas

Tabla con el registro de visitas al gimnasio.

Cada fila representa una visita de un socio a un centro.

| Campo | Tipo de dato | Descripción | Ejemplo |
|---|---|---|---|
| id_visita | integer | Identificador único de la visita | 1 |
| id_socio | integer | Identificador del socio | 1001 |
| id_centro | integer | Centro donde se realiza la visita | 1 |
| id_fecha | integer | Fecha de la visita | 20230210 |
| fecha_visita | date | Fecha de la visita | 2023-02-10 |
| hora_entrada | string | Hora aproximada de entrada | 18:30 |
| duracion_minutos | integer | Duración de la visita en minutos | 65 |
| tipo_actividad | string | Actividad realizada | clase_grupal |

---

# 7. fact_pagos

Tabla con el historial de pagos de los socios.

Cada fila representa un pago o intento de pago.

| Campo | Tipo de dato | Descripción | Ejemplo |
|---|---|---|---|
| id_pago | integer | Identificador único del pago | 1 |
| id_socio | integer | Identificador del socio | 1001 |
| id_fecha | integer | Fecha del pago | 20230201 |
| fecha_pago | date | Fecha del pago | 2023-02-01 |
| importe | float | Importe cobrado | 45.00 |
| metodo_pago | string | Método de pago | tarjeta |
| estado_pago | string | Estado del pago | correcto |

---

# 8. fact_socios_mes

Tabla analítica principal del proyecto.

Cada fila representa el comportamiento de un socio durante un mes.

Esta tabla será la base principal para:

- KPIs de negocio
- dashboard de Power BI
- análisis de churn
- modelo predictivo

| Campo | Tipo de dato | Descripción | Ejemplo |
|---|---|---|---|
| id_socio_mes | string | Identificador único socio-mes | 1001_202302 |
| id_socio | integer | Identificador del socio | 1001 |
| id_centro | integer | Centro asociado al socio | 1 |
| id_contrato | integer | Tipo de contrato del socio | 1 |
| id_canal | integer | Canal de captación del socio | 2 |
| año | integer | Año del registro | 2023 |
| mes | integer | Mes del registro | 2 |
| visitas_mes | integer | Número de visitas del socio durante el mes | 8 |
| visitas_mes_anterior | integer | Número de visitas del mes anterior | 12 |
| variacion_visitas | integer | Diferencia entre visitas actuales y anteriores | -4 |
| clases_grupales_mes | integer | Número de clases grupales realizadas durante el mes | 3 |
| pagos_fallidos_mes | integer | Número de pagos fallidos durante el mes | 1 |
| importe_pagado_mes | float | Importe total pagado durante el mes | 45.00 |
| meses_desde_alta | integer | Antigüedad del socio en meses | 3 |
| churn_mes | integer | Indica si el socio se dio de baja ese mes | 1 |
| riesgo_churn | string | Segmento de riesgo calculado | alto |

---

# Relaciones principales

## Relaciones entre dimensiones y hechos

- `dim_socios.id_socio` → `fact_visitas.id_socio`
- `dim_socios.id_socio` → `fact_pagos.id_socio`
- `dim_socios.id_socio` → `fact_socios_mes.id_socio`

- `dim_centro.id_centro` → `fact_visitas.id_centro`
- `dim_centro.id_centro` → `fact_socios_mes.id_centro`

- `dim_contrato.id_contrato` → `fact_socios_mes.id_contrato`

- `dim_canal_captacion.id_canal` → `fact_socios_mes.id_canal`

- `dim_fecha.id_fecha` → `fact_visitas.id_fecha`
- `dim_fecha.id_fecha` → `fact_pagos.id_fecha`

---

# Notas de calidad de datos

El dataset incluirá errores controlados para permitir una fase realista de limpieza de datos.

Ejemplos:

- valores nulos en teléfono registrado
- canales de captación desconocidos
- duraciones de visita anómalas
- importes de pago incorrectos
- edades fuera de rango
- registros duplicados puntuales

Estos errores deberán ser tratados durante la fase de limpieza antes de construir las tablas finales.