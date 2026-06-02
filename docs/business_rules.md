# Business Rules - Iron Gym Analytics

## Objetivo

Estas reglas de negocio definen el comportamiento de los socios de Iron Gym y servirán como base para la generación del dataset sintético del proyecto.

---

## BR-01 - Estacionalidad de altas

Los meses con más altas son:

- Enero
- Septiembre

Los meses con menos altas son:

- Julio
- Agosto
- Diciembre

---

## BR-02 - Estacionalidad de bajas

Las bajas aumentan especialmente en:

- Febrero
- Marzo
- Octubre
- Noviembre

---

## BR-03 - Tipo de contrato

Los contratos anuales tienen menor probabilidad de abandono que los mensuales.

---

## BR-04 - Pareja socia

Los socios cuya pareja también pertenece a Iron Gym presentan mayor permanencia y menor probabilidad de abandono.

---

## BR-05 - Canal de captación

Los socios captados mediante recomendación presentan menor tasa de abandono que los captados por otros canales.

---

## BR-06 - Clases grupales

Los socios que participan en clases grupales presentan mayor frecuencia de visitas y menor churn.

---

## BR-07 - Cercanía al gimnasio

Los socios que viven cerca del gimnasio asisten con mayor frecuencia y abandonan menos.

---

## BR-08 - Señales previas al abandono

Los socios que abandonan suelen reducir progresivamente sus visitas durante los dos meses anteriores a la baja.

---

## BR-09 - Pagos fallidos

Los pagos fallidos incrementan significativamente la probabilidad de abandono.

---

## BR-10 - Antigüedad

La mayor parte de las bajas se producen durante los primeros seis meses de permanencia.
