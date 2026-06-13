# Business Case - FitLife Analytics

## 1. Antecedentes y justificación

FitLife es una cadena de gimnasios en Estados Unidos con presencia en varias
ciudades. No es una cadena de lujo, es el tipo de gimnasio de barrio al que va la
gente a entrenar a diario, con precios asequibles y una base de socios amplia.

El problema que tiene FitLife es uno muy común en este tipo de negocio: cada año
pierde una parte importante de sus socios sin saber muy bien por qué. El equipo de
negocio observa que muchos socios se van en los primeros meses desde que se apuntan,
que los que tienen contratos mensuales rotan mucho más que los que tienen contratos
anuales, y que algunos socios dejan de venir con antelación antes de darse de baja.
Pero no tienen ningún sistema que les ayude a anticiparse.

Captar un socio nuevo cuesta dinero: publicidad, promociones de bienvenida,
descuentos en la primera mensualidad. Retener a uno que ya tienes cuesta mucho
menos. Por eso tiene tanto sentido analizar el abandono con datos: si sabes quién
se va a ir antes de que se vaya, puedes actuar.

La idea de este proyecto es construir un sistema de análisis completo que ayude a
FitLife a entender por qué se van sus socios, identificar a los que están en riesgo
y proponer acciones concretas de retención.

---

## 2. Fuente de datos

El dataset utilizado en este proyecto es `gym_churn_us.csv`, un dataset público
disponible en Kaggle con información real anonimizada de 4.000 socios de una cadena
de gimnasios en Estados Unidos.

El dataset original es una tabla plana con 14 variables y una variable target
binaria (`Churn`: 0 = activo, 1 = baja). Para este proyecto, esa tabla plana se
descompondrá en un modelo estrella con tablas de dimensiones y una tabla de hechos,
siguiendo principios de Data Warehousing y Business Intelligence.

**Características del dataset:**

| Característica       | Valor                     |
|----------------------|---------------------------|
| Filas                | 4.000 socios              |
| Columnas originales  | 14 variables              |
| Valores nulos        | 0 (dataset limpio)        |
| Variable target      | Churn (0 = activo, 1 = baja) |
| Distribución target  | 73,5% activos / 26,5% bajas |
| Periodo simulado     | Vista snapshot mensual    |

**Variables disponibles:**

| Variable                            | Tipo     | Descripción                              |
|-------------------------------------|----------|------------------------------------------|
| gender                              | Binaria  | Género del socio                         |
| Near_Location                       | Binaria  | Vive cerca del gimnasio                  |
| Partner                             | Binaria  | Pareja también es socia                  |
| Promo_friends                       | Binaria  | Captado por promoción de amigos          |
| Phone                               | Binaria  | Teléfono registrado                      |
| Contract_period                     | Numérica | Duración del contrato (1, 6 o 12 meses)  |
| Group_visits                        | Binaria  | Asiste a clases grupales                 |
| Age                                 | Numérica | Edad (18-41 años)                        |
| Avg_additional_charges_total        | Numérica | Gasto adicional medio acumulado          |
| Month_to_end_contract               | Numérica | Meses hasta fin de contrato (1-12)       |
| Lifetime                            | Numérica | Antigüedad en meses (0-31)               |
| Avg_class_frequency_total           | Numérica | Frecuencia media histórica de visitas    |
| Avg_class_frequency_current_month   | Numérica | Frecuencia de visitas este mes           |
| Churn                               | Binaria  | Variable target (0 = activo, 1 = baja)  |

---

## 3. Definición: Objetivo, Metodología y Entregable

### Qué queremos resolver

El objetivo principal es ayudar a FitLife a saber qué socios tienen riesgo de darse
de baja antes de que eso ocurra. Para eso el proyecto responde a estas preguntas:

- ¿Qué socios tienen más riesgo de darse de baja próximamente?
- ¿Qué factores predicen mejor el abandono?
- ¿En qué momento empieza un socio a desengancharse del gimnasio?
- ¿Qué perfil de socio abandona más y cuál retiene mejor?
- ¿Cuánto dinero pierde FitLife por el abandono y cuánto podría ahorrar si retiene
  aunque sea a una parte de esos socios?

---

### Hipótesis que queremos verificar

Las hipótesis están fundamentadas en el análisis preliminar del dataset.

- **H1:** Los socios con contrato mensual tienen una tasa de abandono muy superior
  a los de contrato semestral o anual.
  > *Dato real: mensual 42,3% / semestral 12,5% / anual 2,4%*

- **H2:** La caída de frecuencia de visitas en el mes actual respecto a la media
  histórica es el predictor más potente de abandono.
  > *Dato real: correlación con churn de -0,596, la más alta del dataset*

- **H3:** Los socios captados por recomendación de amigos tienen menor tasa de
  abandono que los captados por otros canales.
  > *Dato real: 15,8% churn con promo_friends vs. 31,3% sin ella*

- **H4:** Los socios que asisten a clases grupales tienen menor probabilidad de
  abandono que los que solo usan la sala libre.
  > *Dato real: 17,3% churn con clases grupales vs. 33,0% sin ellas*

- **H5:** Los socios cuya pareja también está inscrita presentan mayor retención.
  > *Dato real: 19,4% churn con pareja socia vs. 33,3% sin ella*

- **H6:** Los socios más nuevos (menos de 6 meses de antigüedad) tienen mayor
  riesgo de abandono que los veteranos.
  > *Dato real: correlación entre Lifetime y Churn de -0,438*

---

### KPIs de negocio

| KPI                            | Qué mide                                                      |
|--------------------------------|---------------------------------------------------------------|
| Tasa de abandono global        | De cada 100 socios, cuántos se dan de baja                   |
| Tasa de abandono por contrato  | Separado por tipo de contrato (mensual / semestral / anual)  |
| Tasa de abandono por captación | Por canal: recomendación vs. resto                           |
| Vida media del socio           | Antigüedad media en meses antes de la baja                   |
| Socios en riesgo alto          | Socios con alta probabilidad de baja en los próximos 30 días |
| Frecuencia media de visitas    | Cuántas veces por semana viene un socio de media             |
| Tasa de asistencia a clases    | Porcentaje de socios que van a alguna clase grupal           |
| Gasto adicional en riesgo      | Cuánto gasto adicional representan los socios en riesgo      |
| Coste estimado del abandono    | Pérdida económica estimada por las bajas                     |
| Ahorro potencial               | Cuánto se ahorraría reteniendo al 20% de los socios en riesgo|

### KPIs del modelo de Machine Learning

| KPI       | Por qué importa                                                          |
|-----------|--------------------------------------------------------------------------|
| Recall    | De todos los socios que se van a ir, cuántos detecta el modelo           |
| Precisión | De los señalados como riesgo, cuántos realmente se van                   |
| ROC AUC   | Calidad general del modelo entre 0 y 1                                   |
| F1-Score  | Equilibrio entre Recall y Precisión                                      |

> **Nota:** En este proyecto se prioriza el Recall sobre la Precisión. Es peor
> no detectar a un socio que se va (falso negativo) que activar una retención
> innecesaria (falso positivo).

---

### Metodología

| Fase   | Qué hacemos                                                         | Herramienta                        |
|--------|---------------------------------------------------------------------|------------------------------------|
| Fase 1 | Carga y exploración inicial del dataset                             | Python · Pandas                    |
| Fase 2 | Limpieza: tipos de datos, outliers, codificaciones, enriquecimiento | Python · Pandas                    |
| Fase 3 | Construcción del modelo estrella: tablas dim y fact                 | Python · SQLite                    |
| Fase 4 | SQL: queries analíticas y cálculo de KPIs de negocio                | SQL · SQLite                       |
| Fase 5 | Análisis exploratorio: gráficos y validación de hipótesis           | Python · Matplotlib · Seaborn      |
| Fase 6 | Modelado ML: Regresión Logística, Random Forest y XGBoost           | Python · Scikit-learn · XGBoost    |
| Fase 7 | Interpretabilidad del modelo: variables más relevantes              | Python · SHAP                      |
| Fase 8 | Dashboard ejecutivo y operacional                                   | Power BI                           |
| Fase 9 | Documentación y presentación final                                  | GitHub · PDF                       |

---

### Entregable

Al terminar el proyecto se entregará:

- **Repositorio en GitHub** con estructura de carpetas profesional, commits
  progresivos y README completo con capturas, conclusiones y descripción del
  modelo estrella.
- **Notebooks de Python** documentados para limpieza, construcción del modelo
  estrella, análisis exploratorio y modelado predictivo.
- **Scripts SQL** para combinación de tablas y cálculo de KPIs de negocio.
- **Modelo predictivo exportado** con análisis SHAP de interpretabilidad de
  variables.
- **Dashboard en Power BI** con vista ejecutiva (KPIs globales y tendencias)
  y vista operacional (segmentación de socios por riesgo).
- **Presentación en PDF** con hallazgos, validación de hipótesis y
  recomendaciones concretas para el equipo de retención de FitLife.
