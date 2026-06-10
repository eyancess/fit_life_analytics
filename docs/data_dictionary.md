# Diccionario de Datos - Iron Gym Analytics

## Objetivo

Este documento define la estructura completa del modelo de datos del proyecto Iron Gym Analytics.

El dataset será generado de forma sintética para simular el funcionamiento de una cadena de gimnasios de barrio en Madrid durante el periodo 2023-2025.

---

# Modelo de datos

## Tablas de dimensión

* dim_socios
* dim_centro
* dim_contrato
* dim_canal_captacion
* dim_fecha

## Tablas de hechos

* fact_visitas
* fact_pagos
* fact_socios_mes

---

# 1. dim_socios

Información principal de cada socio.

| Campo                  | Tipo    | Descripción                     | Valores permitidos   | Ejemplo    |
| ---------------------- | ------- | ------------------------------- | -------------------- | ---------- |
| id_socio               | integer | Identificador único del socio   | Valor único          | 1001       |
| genero                 | string  | Género del socio                | Hombre, Mujer        | Mujer      |
| edad                   | integer | Edad del socio                  | 16 - 80              | 32         |
| vive_cerca             | integer | Vive cerca del gimnasio         | 0 = No, 1 = Sí       | 1          |
| tiene_pareja_socio     | integer | Su pareja también es socia      | 0 = No, 1 = Sí       | 0          |
| telefono_registrado    | integer | Tiene teléfono registrado       | 0 = No, 1 = Sí       | 1          |
| asiste_clases_grupales | integer | Suele asistir a clases grupales | 0 = No, 1 = Sí       | 1          |
| fecha_alta             | date    | Fecha de alta                   | YYYY-MM-DD           | 2023-01-15 |
| fecha_baja             | date    | Fecha de baja                   | YYYY-MM-DD o NULL    | 2023-03-20 |
| churn_final            | integer | Estado final del socio          | 0 = Activo, 1 = Baja | 1          |

---

# 2. dim_centro

Información de los centros de Iron Gym.

| Campo               | Tipo    | Descripción                    | Valores permitidos              | Ejemplo  |
| ------------------- | ------- | ------------------------------ | ------------------------------- | -------- |
| id_centro           | integer | Identificador único del centro | 1-3                             | 1        |
| nombre_centro       | string  | Nombre del centro              | Malasaña, Vallecas, Carabanchel | Malasaña |
| barrio              | string  | Barrio donde se encuentra      | Malasaña, Vallecas, Carabanchel | Malasaña |
| tipo_zona           | string  | Tipo de zona                   | céntrica, residencial, mixta    | céntrica |
| capacidad_socios    | integer | Capacidad estimada             | >0                              | 900      |
| precio_base_mensual | float   | Cuota mensual base             | >0                              | 45.00    |

---

# 3. dim_contrato

Información de los tipos de contrato.

| Campo          | Tipo    | Descripción            | Valores permitidos        | Ejemplo |
| -------------- | ------- | ---------------------- | ------------------------- | ------- |
| id_contrato    | integer | Identificador único    | 1-3                       | 1       |
| tipo_contrato  | string  | Tipo de contrato       | mensual, semestral, anual | mensual |
| duracion_meses | integer | Duración del contrato  | 1, 6, 12                  | 1       |
| cuota_mensual  | float   | Cuota mensual asociada | >0                        | 45.00   |

---

# 4. dim_canal_captacion

Información sobre cómo llegó el socio.

| Campo            | Tipo    | Descripción                      | Valores permitidos                                    | Ejemplo       |
| ---------------- | ------- | -------------------------------- | ----------------------------------------------------- | ------------- |
| id_canal         | integer | Identificador único              | 1-4                                                   | 1             |
| canal_captacion  | string  | Canal de captación               | redes_sociales, recomendacion, publicidad, paso_calle | recomendacion |
| coste_captacion  | float   | Coste estimado por socio captado | >=0                                                   | 20.00         |
| calidad_esperada | string  | Calidad histórica del canal      | baja, media, alta                                     | alta          |

---

# 5. dim_fecha

Calendario del proyecto.

| Campo      | Tipo    | Descripción            | Valores permitidos                    | Ejemplo    |
| ---------- | ------- | ---------------------- | ------------------------------------- | ---------- |
| id_fecha   | integer | Identificador de fecha | AAAAMMDD                              | 20230115   |
| fecha      | date    | Fecha completa         | YYYY-MM-DD                            | 2023-01-15 |
| año        | integer | Año                    | 2023-2025                             | 2023       |
| mes        | integer | Número de mes          | 1-12                                  | 1          |
| nombre_mes | string  | Nombre del mes         | enero-diciembre                       | enero      |
| trimestre  | string  | Trimestre              | Q1-Q4                                 | Q1         |
| temporada  | string  | Periodo de negocio     | año_nuevo, verano, septiembre, normal | año_nuevo  |

---

# 6. fact_visitas

Registro de visitas al gimnasio.

Cada fila representa una visita.

| Campo            | Tipo    | Descripción                | Valores permitidos               | Ejemplo      |
| ---------------- | ------- | -------------------------- | -------------------------------- | ------------ |
| id_visita        | integer | Identificador único        | Valor único                      | 1            |
| id_socio         | integer | Socio asociado             | FK dim_socios                    | 1001         |
| id_centro        | integer | Centro visitado            | FK dim_centro                    | 1            |
| id_fecha         | integer | Fecha de visita            | FK dim_fecha                     | 20230210     |
| fecha_visita     | date    | Fecha de visita            | YYYY-MM-DD                       | 2023-02-10   |
| hora_entrada     | string  | Hora aproximada de entrada | HH:MM                            | 18:30        |
| duracion_minutos | integer | Duración de la visita      | >0                               | 65           |
| tipo_actividad   | string  | Actividad realizada        | sala_libre, cardio, clase_grupal | clase_grupal |

---

# 7. fact_pagos

Historial de pagos.

Cada fila representa un pago o intento de pago.

| Campo       | Tipo    | Descripción         | Valores permitidos               | Ejemplo    |
| ----------- | ------- | ------------------- | -------------------------------- | ---------- |
| id_pago     | integer | Identificador único | Valor único                      | 1          |
| id_socio    | integer | Socio asociado      | FK dim_socios                    | 1001       |
| id_fecha    | integer | Fecha del pago      | FK dim_fecha                     | 20230201   |
| fecha_pago  | date    | Fecha del pago      | YYYY-MM-DD                       | 2023-02-01 |
| importe     | float   | Importe cobrado     | >=0                              | 45.00      |
| metodo_pago | string  | Método de pago      | tarjeta, domiciliacion, efectivo | tarjeta    |
| estado_pago | string  | Resultado del cobro | correcto, fallido                | correcto   |

---

# 8. fact_socios_mes

Tabla analítica principal.

Cada fila representa el comportamiento de un socio durante un mes.

Será la base para:

* KPIs
* Power BI
* análisis de churn
* Machine Learning

| Campo                | Tipo    | Descripción                         | Valores permitidos     | Ejemplo     |
| -------------------- | ------- | ----------------------------------- | ---------------------- | ----------- |
| id_socio_mes         | string  | Identificador único socio-mes       | formato socio_mes      | 1001_202302 |
| id_socio             | integer | Socio asociado                      | FK dim_socios          | 1001        |
| id_centro            | integer | Centro asociado                     | FK dim_centro          | 1           |
| id_contrato          | integer | Tipo de contrato                    | FK dim_contrato        | 1           |
| id_canal             | integer | Canal de captación                  | FK dim_canal_captacion | 2           |
| año                  | integer | Año analizado                       | 2023-2025              | 2023        |
| mes                  | integer | Mes analizado                       | 1-12                   | 2           |
| visitas_mes          | integer | Visitas realizadas en el mes        | >=0                    | 8           |
| visitas_mes_anterior | integer | Visitas del mes anterior            | >=0                    | 12          |
| variacion_visitas    | integer | Diferencia respecto al mes anterior | entero                 | -4          |
| clases_grupales_mes  | integer | Clases grupales realizadas          | >=0                    | 3           |
| pagos_fallidos_mes   | integer | Pagos fallidos durante el mes       | >=0                    | 1           |
| importe_pagado_mes   | float   | Importe total pagado                | >=0                    | 45.00       |
| meses_desde_alta     | integer | Antigüedad en meses                 | >=0                    | 3           |
| churn_mes            | integer | Baja durante ese mes                | 0 = No, 1 = Sí         | 1           |
| riesgo_churn         | string  | Segmento de riesgo                  | bajo, medio, alto      | alto        |

---

# Convenciones de variables binarias

| Variable               | 0             | 1          |
| ---------------------- | ------------- | ---------- |
| vive_cerca             | No vive cerca | Vive cerca |
| tiene_pareja_socio     | No            | Sí         |
| telefono_registrado    | No            | Sí         |
| asiste_clases_grupales | No            | Sí         |
| churn_final            | Activo        | Baja       |
| churn_mes              | No abandona   | Abandona   |

---

# Relaciones principales

* dim_socios.id_socio → fact_visitas.id_socio

* dim_socios.id_socio → fact_pagos.id_socio

* dim_socios.id_socio → fact_socios_mes.id_socio

* dim_centro.id_centro → fact_visitas.id_centro

* dim_centro.id_centro → fact_socios_mes.id_centro

* dim_contrato.id_contrato → fact_socios_mes.id_contrato

* dim_canal_captacion.id_canal → fact_socios_mes.id_canal

* dim_fecha.id_fecha → fact_visitas.id_fecha

* dim_fecha.id_fecha → fact_pagos.id_fecha

---

# Calidad de datos

El dataset incluirá errores controlados para simular situaciones reales:

* valores nulos
* registros duplicados
* duraciones anómalas
* Problemas de formato
* pagos incorrectos
* categorías incompletas

Estos problemas deberán resolverse durante la fase de limpieza y preparación de datos.

```
```
