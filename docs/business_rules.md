# Business Rules - Iron Gym Analytics

## Objetivo

Estas reglas de negocio definen el comportamiento de los socios de Iron Gym y servirán como base para la generación del dataset sintético del proyecto.

El objetivo es simular un entorno de negocio realista en el que existan patrones de captación, uso, pagos y abandono similares a los observados en una cadena de gimnasios real.

---

# Reglas temporales

## BR-01 - Estacionalidad de altas

La captación de socios no es uniforme durante el año.

Meses con más altas:

* Enero (propósitos de año nuevo)
* Septiembre (vuelta a la rutina)

Meses con menos altas:

* Julio
* Agosto
* Diciembre

---

## BR-02 - Estacionalidad de bajas

Las bajas aumentan especialmente:

* Febrero
* Marzo
* Octubre
* Noviembre

Estos meses concentran gran parte de los abandonos de los socios captados durante enero y septiembre.

---

# Reglas de retención

## BR-03 - Tipo de contrato

Los socios con contratos más largos presentan menor probabilidad de abandono.

Orden de riesgo:

1. Contrato mensual (mayor riesgo)
2. Contrato semestral
3. Contrato anual (menor riesgo)

---

## BR-04 - Pareja socia

Los socios cuya pareja también pertenece a Iron Gym presentan:

* mayor frecuencia de asistencia
* mayor permanencia
* menor probabilidad de abandono

---

## BR-05 - Captación por recomendación

Los socios captados mediante recomendación tienen menor tasa de abandono que los captados por otros canales.

Canales de mayor a menor riesgo:

1. Redes sociales
2. Publicidad
3. Paso por la calle
4. Recomendación

---

## BR-06 - Clases grupales

Los socios que participan regularmente en clases grupales presentan:

* mayor engagement
* mayor frecuencia de visitas
* menor probabilidad de abandono

---

## BR-07 - Cercanía al gimnasio

Los socios que viven cerca del gimnasio:

* asisten con mayor frecuencia
* mantienen la actividad durante más tiempo
* abandonan menos

---

# Reglas de comportamiento

## BR-08 - Señales previas al abandono

Los socios que abandonan suelen mostrar señales previas.

Patrón habitual:

Mes -2:

* disminución moderada de visitas

Mes -1:

* disminución fuerte de visitas

Mes 0:

* baja definitiva

---

## BR-09 - Pagos fallidos

Los pagos fallidos incrementan significativamente el riesgo de abandono.

Un pago fallido durante los dos meses anteriores aumenta la probabilidad de churn.

---

## BR-10 - Antigüedad

Los primeros meses son los más críticos.

La probabilidad de abandono es mayor durante los primeros seis meses desde la fecha de alta.

---

# Reglas por centro

## BR-11 - Centro Malasaña

Perfil predominante:

* edad media más baja
* mayor participación en clases grupales
* mayor rotación de socios

---

## BR-12 - Centro Vallecas

Perfil predominante:

* edad media más alta
* contratos más largos
* mayor permanencia

---

## BR-13 - Centro Carabanchel

Perfil mixto.

Presenta indicadores intermedios entre Malasaña y Vallecas.

---

# Reglas de calidad de datos

## BR-14 - Valores nulos

Se introducirán valores nulos de forma controlada para simular errores reales de captura de información.

Ejemplos:

* teléfono no registrado
* canal de captación desconocido
* duración de visita no registrada

---

## BR-15 - Datos erróneos

Se introducirán errores de calidad en una pequeña proporción de registros.

Ejemplos:

* edades fuera de rango
* importes incorrectos
* duraciones de visita anómalas

Estos errores deberán ser detectados y tratados durante la fase de limpieza de datos.

---

## BR-16 - Influencia social

Los socios captados por recomendación tienen una mayor probabilidad de acudir acompañados y una mayor probabilidad de participar en clases grupales.

Esto genera relaciones entre variables y hace que los datos sean más realistas.

---

# Objetivo analítico

Estas reglas deben permitir generar un dataset coherente que permita:

* analizar abandono de clientes
* calcular KPIs de negocio
* construir un modelo estrella
* desarrollar dashboards en Power BI
* entrenar modelos predictivos de churn
* generar recomendaciones de retención basadas en datos

