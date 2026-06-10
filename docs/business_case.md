# Business Case - Iron Gym Analytics

## 1. Antecedentes y justificación

Iron Gym es una cadena de gimnasios de barrio con tres centros en Madrid: 
Malasaña, Vallecas y Carabanchel. No es una cadena de lujo ni una franquicia 
corporativa, es el tipo de gimnasio al que va la gente del barrio, con precios 
asequibles y una comunidad fiel de socios.

El problema que tiene Iron Gym es uno muy común en este tipo de negocios: cada 
año pierde una parte importante de sus socios sin saber muy bien por qué. Algunos 
se van en febrero y marzo, justo después de haberse apuntado con el propósito de 
año nuevo. Otros desaparecen en septiembre. Y el equipo no tiene forma de 
anticiparse porque no hay ningún sistema que les avise de quién está a punto de 
darse de baja.

Captar un socio nuevo cuesta dinero, entre campañas, promociones y descuentos de 
bienvenida. Retener a uno que ya tienes cuesta mucho menos. Por eso tiene tanto 
sentido analizar el abandono con datos: si sabes quién se va a ir antes de que se 
vaya, puedes actuar.

La idea es construir un sistema de análisis que ayude a Iron Gym a entender por 
qué se van sus socios, identificar a los que están en riesgo y proponer acciones 
concretas para retenerlos.

---

## 2. Fuentes de datos

El dataset de este proyecto ha sido generado de forma sintética con Python, 
siguiendo las reglas de negocio definidas en `business_rules.md`.

No se han utilizado datos reales de socios. Los datos simulan el comportamiento 
real de una cadena de gimnasios de barrio en Madrid durante el periodo 2023-2025, 
incorporando patrones reales del sector como la estacionalidad de altas y bajas, 
la caída de asistencia antes del abandono, o el impacto de los pagos fallidos.

El dataset está compuesto por cuatro tablas relacionadas:

- **socios** — información demográfica y contractual de cada socio
- **visitas** — registro de cada visita al gimnasio
- **pagos** — historial de pagos y pagos fallidos
- **clases** — catálogo de clases grupales disponibles por centro

---

## 3. Definición: Objetivo, Metodología y Entregable

### Qué queremos resolver

El objetivo principal es ayudar a Iron Gym a saber quién se va a ir antes de 
que se vaya. Para eso el proyecto responde a estas preguntas:

- ¿Qué socios tienen más riesgo de darse de baja en los próximos 30 días?
- ¿En qué momento empieza un socio a desengancharse del gimnasio?
- ¿Qué factores predicen mejor el abandono?
- ¿Hay diferencias entre los tres centros?
- ¿Cuánto dinero pierde Iron Gym cada año por el abandono y cuánto podría 
  ahorrar si retiene aunque sea a una parte de esos socios?

---

### Hipótesis que queremos verificar

- **H1:** Los socios captados en enero tienen la tasa de abandono más alta del 
  año, con una vida media inferior a 60 días, por el efecto propósito de año nuevo.
- **H2:** Cuando un socio pasa de venir tres veces por semana a venir menos de 
  una, es muy probable que se dé de baja en el mes siguiente.
- **H3:** Un pago fallido es una de las señales más claras de que un socio está 
  a punto de irse.
- **H4:** Los socios que van a clases colectivas aguantan más tiempo que los que 
  solo usan la sala.
- **H5:** El comportamiento de abandono es diferente entre Malasaña, Vallecas 
  y Carabanchel.

---

### KPIs de negocio

| KPI | Qué mide |
|---|---|
| Tasa de abandono mensual | De cada 100 socios activos, cuántos se dan de baja ese mes |
| Tasa de abandono por centro | Lo mismo separado por Malasaña, Vallecas y Carabanchel |
| Vida media del socio | Cuántos meses aguanta un socio de media antes de darse de baja |
| Socios en riesgo esta semana | Lista de socios con alta probabilidad de baja en los próximos 30 días |
| Frecuencia media de visitas | Cuántas veces por semana viene un socio activo de media |
| Tasa de asistencia a clases colectivas | Qué porcentaje de socios va a alguna clase grupal |
| Pagos fallidos del mes | Cuántos socios tuvieron un pago rechazado este mes |
| Ingresos en riesgo | Cuánto dinero representa el total de socios en riesgo alto |
| Coste del abandono anual | Cuánto pierde Iron Gym al año por las bajas |
| Ahorro potencial | Cuánto se ahorraría reteniendo al 20% de los socios en riesgo |

### KPIs del modelo de Machine Learning

| KPI | Por qué importa |
|---|---|
| Recall | De todos los socios que se van a ir, cuántos detecta el modelo |
| Precisión | De los señalados como riesgo, cuántos realmente se van |
| ROC AUC | Calidad general del modelo entre 0 y 1 |
| F1-Score | Equilibrio entre Recall y Precisión |

---

### Metodología

| Fase | Qué hacemos | Herramienta |
|---|---|---|
| Fase 1 | Generación del dataset sintético con reglas de negocio | Python |
| Fase 2 | Limpieza: valores nulos, duplicados, errores de formato, outliers | Python · Pandas |
| Fase 3 | SQL: combinación de tablas y cálculo de variables por socio | SQL · SQLite |
| Fase 4 | Análisis exploratorio: gráficos y validación de hipótesis | Python · Matplotlib · Seaborn |
| Fase 5 | Modelado ML: Regresión Logística, Random Forest y XGBoost | Python · Scikit-learn · XGBoost |
| Fase 6 | Interpretabilidad del modelo: qué variables predicen el abandono | Python · SHAP |
| Fase 7 | Dashboard ejecutivo y operacional | Power BI |
| Fase 8 | Documentación y presentación final | GitHub · PDF |

---

### Entregable

Al terminar el proyecto entregaremos:

- **Repositorio en GitHub** con estructura de carpetas profesional, commits 
  progresivos y README completo con capturas y conclusiones.
- **Notebooks de Python** con generación de datos, limpieza, análisis y modelado.
- **Scripts SQL** documentados para combinación de tablas y cálculo de KPIs.
- **Modelo predictivo exportado** con análisis SHAP de interpretabilidad.
- **Dashboard en Power BI** con vista ejecutiva y vista operacional por centro.
- **Presentación en PDF** con hallazgos y recomendaciones para Iron Gym.
