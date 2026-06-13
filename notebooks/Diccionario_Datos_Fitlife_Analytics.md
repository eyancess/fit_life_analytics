# Diccionario de Datos - FitLife Analytics

## Objetivo

Este documento define la estructura completa del modelo de datos del proyecto
FitLife Analytics.

El dataset de origen es `gym_churn_us.csv`, una tabla plana con 4.000 registros
y 14 variables. Este proyecto la descompone en un modelo estrella compuesto por
una tabla de hechos y cuatro tablas de dimensiones, siguiendo principios de
Data Warehousing y Business Intelligence.

---

# Modelo de datos

## Diagrama del modelo estrella

```
                    ┌─────────────────────┐
                    │     dim_socio       │
                    │  id_socio (PK)      │
                    │  genero             │
                    │  edad               │
                    │  grupo_edad         │
                    │  vive_cerca         │
                    │  tiene_pareja_socia │
                    └──────────┬──────────┘
                               │
  ┌──────────────────┐         │         ┌──────────────────────┐
  │   dim_contrato   │         │         │    dim_captacion     │
  │  id_contrato(PK) ├─────────┤         │  id_captacion (PK)   │
  │  tipo_contrato   │         │         │  viene_por_promo     │
  │  duracion_meses  │         │         │  telefono_registrado │
  │  nivel_compromiso│         │         │  perfil_captacion    │
  └──────────┬───────┘         │         └──────────┬───────────┘
             │                 │                    │
             │      ┌──────────▼──────────┐         │
             │      │   fact_membresia    │         │
             └─────►│  id_socio    (FK)   │◄────────┘
                    │  id_contrato (FK)   │
                    │  id_captacion(FK)   │◄────────────────────┐
                    │  id_actividad(FK)   │                     │
                    │                    │         ┌────────────┴──────────┐
                    │  -- MÉTRICAS --    │         │    dim_actividad      │
                    │  lifetime          │         │  id_actividad (PK)    │
                    │  meses_fin_contrato│         │  asiste_clases_grp    │
                    │  gasto_adicional   │         │  segmento_frecuencia  │
                    │  frecuencia_total  │         │  tendencia_frecuencia │
                    │  frecuencia_mes    │         └───────────────────────┘
                    │  variacion_frec    │
                    │  segmento_lifetime │
                    │  segmento_riesgo   │
                    │  churn (TARGET)    │
                    └────────────────────┘
```

## Tablas del modelo

- dim_socio
- dim_contrato
- dim_captacion
- dim_actividad
- fact_membresia

---

# 1. dim_socio

Información demográfica de cada socio.

Cada fila representa un socio único.

| Campo              | Tipo    | Origen dataset    | Descripción                              | Valores permitidos              | Ejemplo      |
|--------------------|---------|-------------------|------------------------------------------|---------------------------------|--------------|
| id_socio           | integer | Generado          | Identificador único del socio            | Valor único (índice)            | 1001         |
| genero             | string  | gender            | Género del socio                         | Hombre, Mujer                   | Mujer        |
| edad               | integer | Age               | Edad del socio en años                   | 18 - 41                         | 29           |
| grupo_edad         | string  | Calculado         | Segmento de edad del socio               | 18-25, 26-30, 31-35, 36-41      | 26-30        |
| vive_cerca         | integer | Near_Location     | Vive o trabaja cerca del gimnasio        | 0 = No, 1 = Sí                  | 1            |
| tiene_pareja_socia | integer | Partner           | Su pareja también está inscrita          | 0 = No, 1 = Sí                  | 0            |

**Campo calculado — grupo_edad:**

| Valor  | Rango de edad |
|--------|---------------|
| 18-25  | 18 a 25 años  |
| 26-30  | 26 a 30 años  |
| 31-35  | 31 a 35 años  |
| 36-41  | 36 a 41 años  |

**Campo origen — gender:**

| Valor original | Valor transformado |
|----------------|--------------------|
| 0              | Mujer              |
| 1              | Hombre             |

---

# 2. dim_contrato

Información sobre el tipo de contrato del socio.

Esta dimensión tiene solo tres registros (uno por cada tipo de contrato posible).

| Campo             | Tipo    | Origen dataset  | Descripción                         | Valores permitidos              | Ejemplo    |
|-------------------|---------|-----------------|-------------------------------------|---------------------------------|------------|
| id_contrato       | integer | Generado        | Identificador del tipo de contrato  | 1, 2, 3                         | 1          |
| tipo_contrato     | string  | Calculado       | Etiqueta del tipo de contrato       | mensual, semestral, anual       | mensual    |
| duracion_meses    | integer | Contract_period | Duración del contrato en meses      | 1, 6, 12                        | 1          |
| nivel_compromiso  | string  | Calculado       | Nivel de compromiso del socio       | bajo, medio, alto               | bajo       |

**Tabla de referencia completa:**

| id_contrato | tipo_contrato | duracion_meses | nivel_compromiso |
|-------------|---------------|----------------|-----------------|
| 1           | mensual       | 1              | bajo            |
| 2           | semestral     | 6              | medio           |
| 3           | anual         | 12             | alto            |

---

# 3. dim_captacion

Información sobre el canal y perfil de captación del socio.

Esta dimensión tiene cuatro registros (una combinación por cada perfil posible).

| Campo               | Tipo    | Origen dataset | Descripción                               | Valores permitidos                                                         | Ejemplo                |
|---------------------|---------|----------------|-------------------------------------------|----------------------------------------------------------------------------|------------------------|
| id_captacion        | integer | Generado       | Identificador del perfil de captación     | 1, 2, 3, 4                                                                 | 2                      |
| viene_por_promo     | integer | Promo_friends  | Captado mediante promoción de amigos      | 0 = No, 1 = Sí                                                             | 1                      |
| telefono_registrado | integer | Phone          | Tiene número de teléfono registrado       | 0 = No, 1 = Sí                                                             | 1                      |
| perfil_captacion    | string  | Calculado      | Etiqueta del perfil combinado de captación| referido_contactado, referido_sin_contacto, organico_contactado, organico_sin_contacto | referido_contactado |

**Tabla de referencia completa:**

| id_captacion | viene_por_promo | telefono_registrado | perfil_captacion         |
|--------------|-----------------|---------------------|--------------------------|
| 1            | 0               | 0                   | organico_sin_contacto    |
| 2            | 0               | 1                   | organico_contactado      |
| 3            | 1               | 0                   | referido_sin_contacto    |
| 4            | 1               | 1                   | referido_contactado      |

---

# 4. dim_actividad

Perfil de comportamiento del socio en el gimnasio.

Cada combinación de asistencia a clases y segmento de frecuencia genera un
registro único en esta dimensión.

| Campo                | Tipo    | Origen dataset               | Descripción                                   | Valores permitidos                  | Ejemplo   |
|----------------------|---------|------------------------------|-----------------------------------------------|-------------------------------------|-----------|
| id_actividad         | integer | Generado                     | Identificador del perfil de actividad         | Valor único                         | 5         |
| asiste_clases_grp    | integer | Group_visits                 | Asiste regularmente a clases grupales         | 0 = No, 1 = Sí                      | 1         |
| segmento_frecuencia  | string  | Calculado (Avg_class_frequency_total) | Nivel de actividad histórica         | inactivo, bajo, medio, alto         | medio     |
| tendencia_frecuencia | string  | Calculado (frecuencia actual vs histórica) | Tendencia reciente de visitas  | bajando, estable, subiendo          | bajando   |

**Campo calculado — segmento_frecuencia:**

Basado en percentiles de `Avg_class_frequency_total` (visitas por semana):

| Segmento | Rango               | Percentil      |
|----------|---------------------|----------------|
| inactivo | Menos de 1,18       | Menor de P25   |
| bajo     | 1,18 a 1,83         | P25 a P50      |
| medio    | 1,83 a 2,54         | P50 a P75      |
| alto     | Más de 2,54         | Mayor de P75   |

**Campo calculado — tendencia_frecuencia:**

Calculado comparando `Avg_class_frequency_current_month` con
`Avg_class_frequency_total`:

| Tendencia | Condición                                          |
|-----------|----------------------------------------------------|
| bajando   | Frecuencia actual < Frecuencia histórica × 0,70    |
| estable   | Frecuencia actual entre ×0,70 y ×1,30              |
| subiendo  | Frecuencia actual > Frecuencia histórica × 1,30    |

---

# 5. fact_membresia

Tabla de hechos central del modelo estrella.

Cada fila representa un socio con todas sus métricas y sus claves foráneas
a las dimensiones.

Esta tabla es la base para los KPIs, el análisis exploratorio, el dashboard
en Power BI y el modelo predictivo de Machine Learning.

| Campo                | Tipo    | Origen dataset                        | Descripción                                    | Valores permitidos        | Ejemplo      |
|----------------------|---------|---------------------------------------|------------------------------------------------|---------------------------|--------------|
| id_socio             | integer | Generado (FK dim_socio)               | Identificador del socio                        | FK dim_socio              | 1001         |
| id_contrato          | integer | Contract_period (FK dim_contrato)     | Tipo de contrato                               | FK dim_contrato           | 1            |
| id_captacion         | integer | Promo_friends + Phone (FK dim_captacion) | Perfil de captación                         | FK dim_captacion          | 4            |
| id_actividad         | integer | Group_visits + freq (FK dim_actividad)| Perfil de actividad                            | FK dim_actividad          | 5            |
| lifetime             | integer | Lifetime                              | Antigüedad del socio en meses                  | 0 - 31                    | 7            |
| meses_fin_contrato   | float   | Month_to_end_contract                 | Meses restantes hasta fin de contrato          | 1 - 12                    | 3.0          |
| gasto_adicional      | float   | Avg_additional_charges_total          | Gasto adicional medio acumulado                | 0,15 - 552,59             | 146,94       |
| frecuencia_total     | float   | Avg_class_frequency_total             | Frecuencia media histórica (visitas/semana)    | 0,0 - 6,02                | 1,88         |
| frecuencia_mes       | float   | Avg_class_frequency_current_month     | Frecuencia media del mes actual (visitas/semana)| 0,0 - 6,15               | 1,77         |
| variacion_frecuencia | float   | Calculado                             | Diferencia entre frecuencia actual e histórica | Puede ser negativa        | -0,11        |
| segmento_lifetime    | string  | Calculado                             | Segmento de antigüedad del socio               | nuevo, intermedio, veterano| intermedio  |
| segmento_riesgo      | string  | Calculado (post-modelo)               | Nivel de riesgo de abandono                    | bajo, medio, alto         | medio        |
| churn                | integer | Churn                                 | Variable target: ¿se dio de baja?              | 0 = Activo, 1 = Baja      | 0            |

**Campo calculado — variacion_frecuencia:**

```
variacion_frecuencia = frecuencia_mes - frecuencia_total
```

Interpretación:

| Valor     | Interpretación                                         |
|-----------|--------------------------------------------------------|
| Positivo  | El socio viene más que su media histórica              |
| Cercano a 0| El socio mantiene su ritmo habitual                  |
| Negativo  | El socio viene menos que su media histórica (señal de riesgo)|

**Campo calculado — segmento_lifetime:**

| Segmento    | Rango de antigüedad |
|-------------|---------------------|
| nuevo       | 0 a 3 meses         |
| intermedio  | 4 a 12 meses        |
| veterano    | Más de 12 meses     |

**Campo calculado — segmento_riesgo:**

Calculado tras el modelo predictivo. Se asigna en función de la probabilidad
de churn predicha por el modelo:

| Segmento | Probabilidad de churn predicha |
|----------|-------------------------------|
| bajo     | Menos de 0,30                 |
| medio    | 0,30 a 0,60                   |
| alto     | Más de 0,60                   |

---

# Relaciones del modelo

| Tabla origen      | Campo          | Tabla destino     | Campo        |
|-------------------|----------------|-------------------|--------------|
| fact_membresia    | id_socio       | dim_socio         | id_socio     |
| fact_membresia    | id_contrato    | dim_contrato      | id_contrato  |
| fact_membresia    | id_captacion   | dim_captacion     | id_captacion |
| fact_membresia    | id_actividad   | dim_actividad     | id_actividad |

---

# Trazabilidad: dataset original → modelo estrella

Esta tabla muestra el origen exacto de cada variable del dataset original
y en qué tabla del modelo estrella termina.

| Variable original                   | Tabla destino   | Campo destino         | Transformación            |
|-------------------------------------|-----------------|-----------------------|---------------------------|
| gender                              | dim_socio       | genero                | 0→Mujer, 1→Hombre         |
| Age                                 | dim_socio       | edad                  | Directa                   |
| Age                                 | dim_socio       | grupo_edad            | Segmentación por rangos   |
| Near_Location                       | dim_socio       | vive_cerca            | Directa                   |
| Partner                             | dim_socio       | tiene_pareja_socia    | Directa                   |
| Contract_period                     | dim_contrato    | duracion_meses        | Directa                   |
| Contract_period                     | dim_contrato    | tipo_contrato         | 1→mensual, 6→semestral, 12→anual |
| Contract_period                     | dim_contrato    | nivel_compromiso      | 1→bajo, 6→medio, 12→alto  |
| Promo_friends                       | dim_captacion   | viene_por_promo       | Directa                   |
| Phone                               | dim_captacion   | telefono_registrado   | Directa                   |
| Promo_friends + Phone               | dim_captacion   | perfil_captacion      | Combinación de ambas      |
| Group_visits                        | dim_actividad   | asiste_clases_grp     | Directa                   |
| Avg_class_frequency_total           | dim_actividad   | segmento_frecuencia   | Percentiles               |
| Avg_class_frequency_current_month vs total | dim_actividad | tendencia_frecuencia | Ratio actual/histórico  |
| Lifetime                            | fact_membresia  | lifetime              | Directa                   |
| Lifetime                            | fact_membresia  | segmento_lifetime     | Segmentación por rangos   |
| Month_to_end_contract               | fact_membresia  | meses_fin_contrato    | Directa                   |
| Avg_additional_charges_total        | fact_membresia  | gasto_adicional       | Directa                   |
| Avg_class_frequency_total           | fact_membresia  | frecuencia_total      | Directa                   |
| Avg_class_frequency_current_month   | fact_membresia  | frecuencia_mes        | Directa                   |
| Calculado                           | fact_membresia  | variacion_frecuencia  | frecuencia_mes - frecuencia_total |
| Calculado (post-modelo)             | fact_membresia  | segmento_riesgo       | Probabilidad de churn predicha |
| Churn                               | fact_membresia  | churn                 | Directa (variable target) |

---

# Convenciones de variables binarias

| Variable            | Valor 0        | Valor 1             |
|---------------------|----------------|---------------------|
| vive_cerca          | No vive cerca  | Vive cerca          |
| tiene_pareja_socia  | No             | Sí                  |
| viene_por_promo     | No             | Sí                  |
| telefono_registrado | No             | Sí                  |
| asiste_clases_grp   | No             | Sí                  |
| churn               | Activo         | Se ha dado de baja  |# Diccionario de Datos - FitLife Analytics

## Objetivo

Este documento define la estructura completa del modelo de datos del proyecto
FitLife Analytics.

El dataset de origen es `gym_churn_us.csv`, una tabla plana con 4.000 registros
y 14 variables. Este proyecto la descompone en un modelo estrella compuesto por
una tabla de hechos y cuatro tablas de dimensiones, siguiendo principios de
Data Warehousing y Business Intelligence.

---

# Modelo de datos

## Diagrama del modelo estrella

```
                    ┌─────────────────────┐
                    │     dim_socio       │
                    │  id_socio (PK)      │
                    │  genero             │
                    │  edad               │
                    │  grupo_edad         │
                    │  vive_cerca         │
                    │  tiene_pareja_socia │
                    └──────────┬──────────┘
                               │
  ┌──────────────────┐         │         ┌──────────────────────┐
  │   dim_contrato   │         │         │    dim_captacion     │
  │  id_contrato(PK) ├─────────┤         │  id_captacion (PK)   │
  │  tipo_contrato   │         │         │  viene_por_promo     │
  │  duracion_meses  │         │         │  telefono_registrado │
  │  nivel_compromiso│         │         │  perfil_captacion    │
  └──────────┬───────┘         │         └──────────┬───────────┘
             │                 │                    │
             │      ┌──────────▼──────────┐         │
             │      │   fact_membresia    │         │
             └─────►│  id_socio    (FK)   │◄────────┘
                    │  id_contrato (FK)   │
                    │  id_captacion(FK)   │◄────────────────────┐
                    │  id_actividad(FK)   │                     │
                    │                    │         ┌────────────┴──────────┐
                    │  -- MÉTRICAS --    │         │    dim_actividad      │
                    │  lifetime          │         │  id_actividad (PK)    │
                    │  meses_fin_contrato│         │  asiste_clases_grp    │
                    │  gasto_adicional   │         │  segmento_frecuencia  │
                    │  frecuencia_total  │         │  tendencia_frecuencia │
                    │  frecuencia_mes    │         └───────────────────────┘
                    │  variacion_frec    │
                    │  segmento_lifetime │
                    │  segmento_riesgo   │
                    │  churn (TARGET)    │
                    └────────────────────┘
```

## Tablas del modelo

- dim_socio
- dim_contrato
- dim_captacion
- dim_actividad
- fact_membresia

---

# 1. dim_socio

Información demográfica de cada socio.

Cada fila representa un socio único.

| Campo              | Tipo    | Origen dataset    | Descripción                              | Valores permitidos              | Ejemplo      |
|--------------------|---------|-------------------|------------------------------------------|---------------------------------|--------------|
| id_socio           | integer | Generado          | Identificador único del socio            | Valor único (índice)            | 1001         |
| genero             | string  | gender            | Género del socio                         | Hombre, Mujer                   | Mujer        |
| edad               | integer | Age               | Edad del socio en años                   | 18 - 41                         | 29           |
| grupo_edad         | string  | Calculado         | Segmento de edad del socio               | 18-25, 26-30, 31-35, 36-41      | 26-30        |
| vive_cerca         | integer | Near_Location     | Vive o trabaja cerca del gimnasio        | 0 = No, 1 = Sí                  | 1            |
| tiene_pareja_socia | integer | Partner           | Su pareja también está inscrita          | 0 = No, 1 = Sí                  | 0            |

**Campo calculado — grupo_edad:**

| Valor  | Rango de edad |
|--------|---------------|
| 18-25  | 18 a 25 años  |
| 26-30  | 26 a 30 años  |
| 31-35  | 31 a 35 años  |
| 36-41  | 36 a 41 años  |

**Campo origen — gender:**

| Valor original | Valor transformado |
|----------------|--------------------|
| 0              | Mujer              |
| 1              | Hombre             |

---

# 2. dim_contrato

Información sobre el tipo de contrato del socio.

Esta dimensión tiene solo tres registros (uno por cada tipo de contrato posible).

| Campo             | Tipo    | Origen dataset  | Descripción                         | Valores permitidos              | Ejemplo    |
|-------------------|---------|-----------------|-------------------------------------|---------------------------------|------------|
| id_contrato       | integer | Generado        | Identificador del tipo de contrato  | 1, 2, 3                         | 1          |
| tipo_contrato     | string  | Calculado       | Etiqueta del tipo de contrato       | mensual, semestral, anual       | mensual    |
| duracion_meses    | integer | Contract_period | Duración del contrato en meses      | 1, 6, 12                        | 1          |
| nivel_compromiso  | string  | Calculado       | Nivel de compromiso del socio       | bajo, medio, alto               | bajo       |

**Tabla de referencia completa:**

| id_contrato | tipo_contrato | duracion_meses | nivel_compromiso |
|-------------|---------------|----------------|-----------------|
| 1           | mensual       | 1              | bajo            |
| 2           | semestral     | 6              | medio           |
| 3           | anual         | 12             | alto            |

---

# 3. dim_captacion

Información sobre el canal y perfil de captación del socio.

Esta dimensión tiene cuatro registros (una combinación por cada perfil posible).

| Campo               | Tipo    | Origen dataset | Descripción                               | Valores permitidos                                                         | Ejemplo                |
|---------------------|---------|----------------|-------------------------------------------|----------------------------------------------------------------------------|------------------------|
| id_captacion        | integer | Generado       | Identificador del perfil de captación     | 1, 2, 3, 4                                                                 | 2                      |
| viene_por_promo     | integer | Promo_friends  | Captado mediante promoción de amigos      | 0 = No, 1 = Sí                                                             | 1                      |
| telefono_registrado | integer | Phone          | Tiene número de teléfono registrado       | 0 = No, 1 = Sí                                                             | 1                      |
| perfil_captacion    | string  | Calculado      | Etiqueta del perfil combinado de captación| referido_contactado, referido_sin_contacto, organico_contactado, organico_sin_contacto | referido_contactado |

**Tabla de referencia completa:**

| id_captacion | viene_por_promo | telefono_registrado | perfil_captacion         |
|--------------|-----------------|---------------------|--------------------------|
| 1            | 0               | 0                   | organico_sin_contacto    |
| 2            | 0               | 1                   | organico_contactado      |
| 3            | 1               | 0                   | referido_sin_contacto    |
| 4            | 1               | 1                   | referido_contactado      |

---

# 4. dim_actividad

Perfil de comportamiento del socio en el gimnasio.

Cada combinación de asistencia a clases y segmento de frecuencia genera un
registro único en esta dimensión.

| Campo                | Tipo    | Origen dataset               | Descripción                                   | Valores permitidos                  | Ejemplo   |
|----------------------|---------|------------------------------|-----------------------------------------------|-------------------------------------|-----------|
| id_actividad         | integer | Generado                     | Identificador del perfil de actividad         | Valor único                         | 5         |
| asiste_clases_grp    | integer | Group_visits                 | Asiste regularmente a clases grupales         | 0 = No, 1 = Sí                      | 1         |
| segmento_frecuencia  | string  | Calculado (Avg_class_frequency_total) | Nivel de actividad histórica         | inactivo, bajo, medio, alto         | medio     |
| tendencia_frecuencia | string  | Calculado (frecuencia actual vs histórica) | Tendencia reciente de visitas  | bajando, estable, subiendo          | bajando   |

**Campo calculado — segmento_frecuencia:**

Basado en percentiles de `Avg_class_frequency_total` (visitas por semana):

| Segmento | Rango               | Percentil      |
|----------|---------------------|----------------|
| inactivo | Menos de 1,18       | Menor de P25   |
| bajo     | 1,18 a 1,83         | P25 a P50      |
| medio    | 1,83 a 2,54         | P50 a P75      |
| alto     | Más de 2,54         | Mayor de P75   |

**Campo calculado — tendencia_frecuencia:**

Calculado comparando `Avg_class_frequency_current_month` con
`Avg_class_frequency_total`:

| Tendencia | Condición                                          |
|-----------|----------------------------------------------------|
| bajando   | Frecuencia actual < Frecuencia histórica × 0,70    |
| estable   | Frecuencia actual entre ×0,70 y ×1,30              |
| subiendo  | Frecuencia actual > Frecuencia histórica × 1,30    |

---

# 5. fact_membresia

Tabla de hechos central del modelo estrella.

Cada fila representa un socio con todas sus métricas y sus claves foráneas
a las dimensiones.

Esta tabla es la base para los KPIs, el análisis exploratorio, el dashboard
en Power BI y el modelo predictivo de Machine Learning.

| Campo                | Tipo    | Origen dataset                        | Descripción                                    | Valores permitidos        | Ejemplo      |
|----------------------|---------|---------------------------------------|------------------------------------------------|---------------------------|--------------|
| id_socio             | integer | Generado (FK dim_socio)               | Identificador del socio                        | FK dim_socio              | 1001         |
| id_contrato          | integer | Contract_period (FK dim_contrato)     | Tipo de contrato                               | FK dim_contrato           | 1            |
| id_captacion         | integer | Promo_friends + Phone (FK dim_captacion) | Perfil de captación                         | FK dim_captacion          | 4            |
| id_actividad         | integer | Group_visits + freq (FK dim_actividad)| Perfil de actividad                            | FK dim_actividad          | 5            |
| lifetime             | integer | Lifetime                              | Antigüedad del socio en meses                  | 0 - 31                    | 7            |
| meses_fin_contrato   | float   | Month_to_end_contract                 | Meses restantes hasta fin de contrato          | 1 - 12                    | 3.0          |
| gasto_adicional      | float   | Avg_additional_charges_total          | Gasto adicional medio acumulado                | 0,15 - 552,59             | 146,94       |
| frecuencia_total     | float   | Avg_class_frequency_total             | Frecuencia media histórica (visitas/semana)    | 0,0 - 6,02                | 1,88         |
| frecuencia_mes       | float   | Avg_class_frequency_current_month     | Frecuencia media del mes actual (visitas/semana)| 0,0 - 6,15               | 1,77         |
| variacion_frecuencia | float   | Calculado                             | Diferencia entre frecuencia actual e histórica | Puede ser negativa        | -0,11        |
| segmento_lifetime    | string  | Calculado                             | Segmento de antigüedad del socio               | nuevo, intermedio, veterano| intermedio  |
| segmento_riesgo      | string  | Calculado (post-modelo)               | Nivel de riesgo de abandono                    | bajo, medio, alto         | medio        |
| churn                | integer | Churn                                 | Variable target: ¿se dio de baja?              | 0 = Activo, 1 = Baja      | 0            |

**Campo calculado — variacion_frecuencia:**

```
variacion_frecuencia = frecuencia_mes - frecuencia_total
```

Interpretación:

| Valor     | Interpretación                                         |
|-----------|--------------------------------------------------------|
| Positivo  | El socio viene más que su media histórica              |
| Cercano a 0| El socio mantiene su ritmo habitual                  |
| Negativo  | El socio viene menos que su media histórica (señal de riesgo)|

**Campo calculado — segmento_lifetime:**

| Segmento    | Rango de antigüedad |
|-------------|---------------------|
| nuevo       | 0 a 3 meses         |
| intermedio  | 4 a 12 meses        |
| veterano    | Más de 12 meses     |

**Campo calculado — segmento_riesgo:**

Calculado tras el modelo predictivo. Se asigna en función de la probabilidad
de churn predicha por el modelo:

| Segmento | Probabilidad de churn predicha |
|----------|-------------------------------|
| bajo     | Menos de 0,30                 |
| medio    | 0,30 a 0,60                   |
| alto     | Más de 0,60                   |

---

# Relaciones del modelo

| Tabla origen      | Campo          | Tabla destino     | Campo        |
|-------------------|----------------|-------------------|--------------|
| fact_membresia    | id_socio       | dim_socio         | id_socio     |
| fact_membresia    | id_contrato    | dim_contrato      | id_contrato  |
| fact_membresia    | id_captacion   | dim_captacion     | id_captacion |
| fact_membresia    | id_actividad   | dim_actividad     | id_actividad |

---

# Trazabilidad: dataset original → modelo estrella

Esta tabla muestra el origen exacto de cada variable del dataset original
y en qué tabla del modelo estrella termina.

| Variable original                   | Tabla destino   | Campo destino         | Transformación            |
|-------------------------------------|-----------------|-----------------------|---------------------------|
| gender                              | dim_socio       | genero                | 0→Mujer, 1→Hombre         |
| Age                                 | dim_socio       | edad                  | Directa                   |
| Age                                 | dim_socio       | grupo_edad            | Segmentación por rangos   |
| Near_Location                       | dim_socio       | vive_cerca            | Directa                   |
| Partner                             | dim_socio       | tiene_pareja_socia    | Directa                   |
| Contract_period                     | dim_contrato    | duracion_meses        | Directa                   |
| Contract_period                     | dim_contrato    | tipo_contrato         | 1→mensual, 6→semestral, 12→anual |
| Contract_period                     | dim_contrato    | nivel_compromiso      | 1→bajo, 6→medio, 12→alto  |
| Promo_friends                       | dim_captacion   | viene_por_promo       | Directa                   |
| Phone                               | dim_captacion   | telefono_registrado   | Directa                   |
| Promo_friends + Phone               | dim_captacion   | perfil_captacion      | Combinación de ambas      |
| Group_visits                        | dim_actividad   | asiste_clases_grp     | Directa                   |
| Avg_class_frequency_total           | dim_actividad   | segmento_frecuencia   | Percentiles               |
| Avg_class_frequency_current_month vs total | dim_actividad | tendencia_frecuencia | Ratio actual/histórico  |
| Lifetime                            | fact_membresia  | lifetime              | Directa                   |
| Lifetime                            | fact_membresia  | segmento_lifetime     | Segmentación por rangos   |
| Month_to_end_contract               | fact_membresia  | meses_fin_contrato    | Directa                   |
| Avg_additional_charges_total        | fact_membresia  | gasto_adicional       | Directa                   |
| Avg_class_frequency_total           | fact_membresia  | frecuencia_total      | Directa                   |
| Avg_class_frequency_current_month   | fact_membresia  | frecuencia_mes        | Directa                   |
| Calculado                           | fact_membresia  | variacion_frecuencia  | frecuencia_mes - frecuencia_total |
| Calculado (post-modelo)             | fact_membresia  | segmento_riesgo       | Probabilidad de churn predicha |
| Churn                               | fact_membresia  | churn                 | Directa (variable target) |

---

# Convenciones de variables binarias

| Variable            | Valor 0        | Valor 1             |
|---------------------|----------------|---------------------|
| vive_cerca          | No vive cerca  | Vive cerca          |
| tiene_pareja_socia  | No             | Sí                  |
| viene_por_promo     | No             | Sí                  |
| telefono_registrado | No             | Sí                  |
| asiste_clases_grp   | No             | Sí                  |
| churn               | Activo         | Se ha dado de baja  |