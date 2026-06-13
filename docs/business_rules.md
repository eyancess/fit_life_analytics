# Business Rules - FitLife Analytics

## Objetivo

Estas reglas de negocio describen el comportamiento de los socios de FitLife
y fundamentan las decisiones de diseño del modelo de datos, el análisis exploratorio
y el modelado predictivo del proyecto.

Las reglas están validadas con datos reales del dataset `gym_churn_us.csv`.
Donde es posible, se indica el dato observado que confirma la regla.

---

# Reglas de contrato

## BR-01 - Tipo de contrato y riesgo de abandono

La duración del contrato es uno de los factores más determinantes del abandono.

Los socios con contratos más cortos presentan mayor probabilidad de baja.

| Tipo de contrato | Duración | Tasa de abandono observada |
|------------------|----------|---------------------------|
| Mensual          | 1 mes    | 42,3%                     |
| Semestral        | 6 meses  | 12,5%                     |
| Anual            | 12 meses | 2,4%                      |

Implicación analítica: el tipo de contrato es una de las variables con mayor
impacto en el modelo predictivo y debe incluirse como dimensión central del
modelo estrella.

---

## BR-02 - Meses hasta fin de contrato

Los socios que se acercan al fin de su periodo contractual presentan mayor
riesgo de no renovar.

Un socio con 1 mes restante de contrato tiene más probabilidad de darse de baja
que uno con 6 o 12 meses restantes.

La variable `Month_to_end_contract` registra este valor con una correlación
negativa de -0,381 con el churn.

---

# Reglas de comportamiento

## BR-03 - Caída de frecuencia como señal de abandono

La variable con mayor correlación con el churn en el dataset es la variación de
frecuencia entre el mes actual y la media histórica.

Patrón observado:

- Socios que **no abandonan:** variación de frecuencia media de **+0,003**
  (frecuencia estable o ligeramente creciente)
- Socios que **abandonan:** variación de frecuencia media de **-0,430**
  (caída significativa en el mes previo a la baja)

Correlación de la variación de frecuencia con el churn: **-0,596** (la más alta
del dataset)

Implicación analítica: la comparación entre `Avg_class_frequency_current_month`
y `Avg_class_frequency_total` es el indicador más potente para detectar socios en
riesgo. Se calculará como campo derivado en el modelo de datos.

---

## BR-04 - Antigüedad y riesgo

Los primeros meses son los más críticos para la retención.

Los socios más nuevos presentan mayor probabilidad de abandono.

La correlación entre `Lifetime` y `Churn` es de **-0,438**: a mayor antigüedad,
menor riesgo de baja.

Segmentación de antigüedad propuesta:

| Segmento    | Rango         | Riesgo estimado |
|-------------|---------------|-----------------|
| Nuevo       | 0 a 3 meses   | Alto            |
| Intermedio  | 4 a 12 meses  | Medio           |
| Veterano    | Más de 12 meses | Bajo          |

---

## BR-05 - Frecuencia histórica de visitas

La frecuencia media histórica de visitas refleja el nivel de engagement del socio.

Segmentación por percentiles del dataset:

| Segmento    | Rango de visitas/semana | Percentil   |
|-------------|-------------------------|-------------|
| Inactivo    | Menos de 1,18           | Menor de P25|
| Bajo        | 1,18 a 1,83             | P25 a P50   |
| Medio       | 1,83 a 2,54             | P50 a P75   |
| Alto        | Más de 2,54             | Mayor de P75|

Los socios con frecuencia alta presentan menor tasa de abandono.

---

# Reglas de captación y perfil social

## BR-06 - Captación por recomendación de amigos

Los socios captados mediante promoción de amigos presentan menor tasa de abandono.

| Canal de captación       | Tasa de abandono |
|--------------------------|-----------------|
| Sin recomendación        | 31,3%           |
| Con recomendación        | 15,8%           |

Implicación analítica: la variable `Promo_friends` es un predictor relevante
del churn y define el perfil del socio captado.

---

## BR-07 - Pareja socia

Los socios cuya pareja también está inscrita en el gimnasio presentan mayor
fidelidad.

| Estado               | Tasa de abandono |
|----------------------|-----------------|
| Sin pareja socia     | 33,3%           |
| Con pareja socia     | 19,4%           |

La presencia de la pareja genera un factor de compromiso social que reduce
el riesgo de abandono de forma significativa.

---

## BR-08 - Cercanía al gimnasio

Los socios que viven o trabajan cerca del gimnasio presentan menor tasa de
abandono, probablemente por mayor facilidad para mantener la rutina.

| Cercanía          | Tasa de abandono |
|-------------------|-----------------|
| No vive cerca     | 39,7%           |
| Vive cerca        | 24,1%           |

---

# Reglas de engagement

## BR-09 - Participación en clases grupales

Los socios que asisten regularmente a clases grupales presentan mayor engagement
y menor probabilidad de abandono.

| Asistencia a clases   | Tasa de abandono |
|-----------------------|-----------------|
| No asiste a clases    | 33,0%           |
| Asiste a clases       | 17,3%           |

Los socios que combinan sala libre con clases grupales tienen una vinculación
más fuerte con el gimnasio.

---

## BR-10 - Gasto adicional como indicador de engagement

El gasto adicional medio acumulado (`Avg_additional_charges_total`) refleja
el nivel de uso de servicios complementarios como tienda, nutrición, entrenador
personal u otros servicios de pago.

Un mayor gasto adicional está asociado con un mayor nivel de engagement
y menor probabilidad de abandono.

Correlación con el churn: **-0,199**

---

# Reglas de perfil demográfico

## BR-11 - Edad del socio

La edad del socio presenta correlación negativa con el abandono: los socios
más jóvenes abandonan más.

Correlación entre `Age` y `Churn`: **-0,405**

Segmentación por grupos de edad propuesta:

| Grupo de edad | Rango     |
|---------------|-----------|
| Joven         | 18 a 25   |
| Adulto joven  | 26 a 30   |
| Adulto        | 31 a 35   |
| Senior        | 36 a 41   |

---

## BR-12 - Teléfono registrado

Los socios con teléfono registrado son más fáciles de contactar en campañas
de retención. La variable `Phone` no predice el abandono de forma directa pero
es relevante para la operativa del equipo comercial.

---

# Reglas de construcción del modelo estrella

## BR-13 - Tabla de hechos central

La tabla `fact_membresia` contiene las métricas cuantitativas de cada socio.
Cada fila representa un socio con sus métricas agregadas.

Las variables métricas son:

- Antigüedad en meses (`Lifetime`)
- Meses hasta fin de contrato (`Month_to_end_contract`)
- Gasto adicional medio (`Avg_additional_charges_total`)
- Frecuencia media histórica (`Avg_class_frequency_total`)
- Frecuencia del mes actual (`Avg_class_frequency_current_month`)
- Variación de frecuencia (campo calculado)
- Churn (variable target)

---

## BR-14 - Tablas de dimensión

Las variables descriptivas del socio se separan en cuatro dimensiones:

**dim_socio:** variables demográficas del socio
- Género, edad, cercanía, pareja socia

**dim_contrato:** tipo y duración del contrato
- Duración en meses, etiqueta del tipo, nivel de compromiso

**dim_captacion:** cómo llegó el socio al gimnasio
- Promoción de amigos, teléfono registrado, perfil de captación

**dim_actividad:** comportamiento en el gimnasio
- Asistencia a clases grupales, segmento de frecuencia, tendencia

---

## BR-15 - Campos enriquecidos

El proceso de construcción del modelo estrella incorpora campos calculados
que no existen en el dataset original pero que añaden valor analítico:

| Campo derivado          | Tabla          | Cómo se calcula                                         |
|-------------------------|----------------|---------------------------------------------------------|
| tipo_contrato           | dim_contrato   | 1 → mensual, 6 → semestral, 12 → anual                 |
| nivel_compromiso        | dim_contrato   | 1 → bajo, 6 → medio, 12 → alto                         |
| grupo_edad              | dim_socio      | Segmentación por rangos: 18-25, 26-30, 31-35, 36-41    |
| perfil_captacion        | dim_captacion  | Combinación de promo_friends y phone                    |
| segmento_frecuencia     | dim_actividad  | Percentiles de Avg_class_frequency_total                |
| tendencia_frecuencia    | dim_actividad  | Comparación entre frecuencia actual e histórica         |
| variacion_frecuencia    | fact_membresia | Avg_class_frequency_current_month - Avg_class_frequency_total |
| segmento_lifetime       | fact_membresia | 0-3 → nuevo, 4-12 → intermedio, >12 → veterano          |
| segmento_riesgo         | fact_membresia | Calculado tras el modelo predictivo: bajo, medio, alto  |

---

# Objetivo analítico

Estas reglas permiten:

- Analizar el abandono de socios desde múltiples dimensiones
- Calcular KPIs de negocio fiables y comparables
- Construir un modelo estrella coherente y bien justificado
- Desarrollar un dashboard ejecutivo y operacional en Power BI
- Entrenar un modelo predictivo de churn con variables bien definidas
- Generar recomendaciones de retención basadas en datos reales
