-- =========================================================
-- FitLife Analytics — Modelo Estrella
-- Script 2: Queries analíticas y KPIs de negocio
-- =========================================================
-- Cómo usar este script:
-- Antes de ejecutar nada de aquí, asegúrate de haber importado
-- los 5 CSV en sus tablas correspondientes (Import Data en DBeaver).
--
-- Para ejecutar UNA query: pon el cursor dentro de ella y pulsa
-- Ctrl+Enter (o Cmd+Enter en Mac). No ejecutes todo el script de
-- golpe — ve query por query y haz capturas de cada resultado
-- para tu informe final.
-- =========================================================

-- En PostgreSQL no existe la instrucción USE. Asegúrate de que tu
-- conexión en DBeaver está apuntando a la base de datos
-- fitlife_analytics antes de ejecutar este script.

-- ---------------------------------------------------------
-- QUERY 1 — Tasa de abandono por tipo de contrato
-- Verifica la Hipótesis H1 (mensual abandona mucho más que el resto)
-- ---------------------------------------------------------
SELECT
    dc.tipo_contrato,
    COUNT(*)                                    AS total_socios,
    SUM(fm.churn)                               AS total_bajas,
    ROUND(AVG(fm.churn) * 100, 2)               AS tasa_abandono_pct
FROM fact_membresia fm
JOIN dim_contrato dc ON fm.id_contrato = dc.id_contrato
GROUP BY dc.tipo_contrato
ORDER BY tasa_abandono_pct DESC;


-- ---------------------------------------------------------
-- QUERY 2 — Tasa de abandono por canal de captación
-- Verifica la Hipótesis H3 (referidos por amigos retienen mejor)
-- ---------------------------------------------------------
SELECT
    dca.perfil_captacion,
    COUNT(*)                       AS total_socios,
    ROUND(AVG(fm.churn) * 100, 2)  AS tasa_abandono_pct
FROM fact_membresia fm
JOIN dim_captacion dca ON fm.id_captacion = dca.id_captacion
GROUP BY dca.perfil_captacion
ORDER BY tasa_abandono_pct ASC;


-- ---------------------------------------------------------
-- QUERY 3 — Abandono por asistencia a clases y antigüedad
-- Verifica la Hipótesis H4 (clases grupales reducen el abandono)
--
-- NOTA: esta query se ha reformulado. La versión original cruzaba
-- asistencia a clases con tendencia de frecuencia de visitas, pero
-- esa columna se eliminó por el bug de datos de Avg_class_frequency_*
-- (ver business_case.md). Se cruza en su lugar con segmento_lifetime,
-- que sigue siendo 100% fiable y aporta una lectura igualmente útil:
-- ¿las clases grupales retienen más incluso entre los socios nuevos?
-- ---------------------------------------------------------
SELECT
    da.asiste_clases_grp,
    fm.segmento_lifetime,
    COUNT(*)                       AS total_socios,
    ROUND(AVG(fm.churn) * 100, 2)  AS tasa_abandono_pct
FROM fact_membresia fm
JOIN dim_actividad da ON fm.id_actividad = da.id_actividad
GROUP BY da.asiste_clases_grp, fm.segmento_lifetime
ORDER BY da.asiste_clases_grp, tasa_abandono_pct DESC;


-- ---------------------------------------------------------
-- QUERY 4 — Perfil demográfico de los socios que abandonan
-- ---------------------------------------------------------
SELECT
    ds.grupo_edad,
    ds.genero,
    COUNT(*)                       AS total_socios,
    ROUND(AVG(fm.churn) * 100, 2)  AS tasa_abandono_pct
FROM fact_membresia fm
JOIN dim_socio ds ON fm.id_socio = ds.id_socio
GROUP BY ds.grupo_edad, ds.genero
ORDER BY ds.grupo_edad, ds.genero;


-- ---------------------------------------------------------
-- QUERY 5 — Segmentación de socios activos por riesgo
-- Usa CASE WHEN para crear una regla de negocio simple
--
-- NOTA: reformulada. La versión original usaba variacion_frecuencia
-- (eliminada por el bug de datos). Se basa ahora en segmento_lifetime
-- y en cuántos meses le quedan de contrato: un socio nuevo a punto de
-- terminar su contrato es, por lógica de negocio, el de mayor riesgo.
-- ---------------------------------------------------------
SELECT
    fm.id_socio,
    fm.segmento_lifetime,
    fm.meses_fin_contrato,
    CASE
        WHEN fm.segmento_lifetime = 'nuevo' AND fm.meses_fin_contrato <= 1
            THEN 'alto'
        WHEN fm.segmento_lifetime = 'nuevo' OR fm.meses_fin_contrato <= 1
            THEN 'medio'
        ELSE 'bajo'
    END AS segmento_riesgo_operativo
FROM fact_membresia fm
WHERE fm.churn = 0;


-- ---------------------------------------------------------
-- QUERY 6 — Socios con más meses de contrato restante que la
-- media de su propio tipo de contrato (SUBCONSULTA)
--
-- NOTA: reformulada. La versión original usaba gasto_adicional
-- (eliminada por el bug de datos). Se usa meses_fin_contrato como
-- proxy de "valor futuro pendiente": socios que aún tienen mucho
-- contrato por delante en relación a su propio segmento de contrato.
-- ---------------------------------------------------------
SELECT
    fm.id_socio,
    dc.tipo_contrato,
    fm.meses_fin_contrato,
    fm.churn
FROM fact_membresia fm
JOIN dim_contrato dc ON fm.id_contrato = dc.id_contrato
WHERE fm.meses_fin_contrato > (
    SELECT AVG(fm2.meses_fin_contrato)
    FROM fact_membresia fm2
    WHERE fm2.id_contrato = fm.id_contrato
)
ORDER BY fm.meses_fin_contrato DESC
LIMIT 15;


-- ---------------------------------------------------------
-- QUERY 7 — Perfiles con tasa de abandono por encima de la
-- media global (SUBCONSULTA dentro de un FROM)
--
-- NOTA: reformulada. La versión original agrupaba por segmento y
-- tendencia de frecuencia (eliminadas por el bug de datos). Se agrupa
-- ahora por asistencia a clases y tipo de contrato, ambas columnas
-- 100% fiables, manteniendo la misma lógica de subconsulta.
-- ---------------------------------------------------------
SELECT *
FROM (
    SELECT
        da.asiste_clases_grp,
        dc.tipo_contrato,
        COUNT(*)                       AS total_socios,
        ROUND(AVG(fm.churn) * 100, 2)  AS tasa_abandono_pct
    FROM fact_membresia fm
    JOIN dim_actividad da ON fm.id_actividad = da.id_actividad
    JOIN dim_contrato dc ON fm.id_contrato = dc.id_contrato
    GROUP BY da.asiste_clases_grp, dc.tipo_contrato
) AS perfiles_actividad
WHERE tasa_abandono_pct > (
    SELECT ROUND(AVG(churn) * 100, 2) FROM fact_membresia
)
ORDER BY tasa_abandono_pct DESC;


-- ---------------------------------------------------------
-- QUERY 8 — Vida media del socio antes de la baja, por canal de captación
-- ---------------------------------------------------------
SELECT
    dca.perfil_captacion,
    COUNT(*)                       AS total_bajas,
    ROUND(AVG(fm.lifetime), 2)     AS vida_media_meses
FROM fact_membresia fm
JOIN dim_captacion dca ON fm.id_captacion = dca.id_captacion
WHERE fm.churn = 1
GROUP BY dca.perfil_captacion
ORDER BY vida_media_meses ASC;


-- =========================================================
-- KPIs DE NEGOCIO
-- =========================================================

-- ---------------------------------------------------------
-- KPI 1 — Tasa de abandono global
-- ---------------------------------------------------------
SELECT
    COUNT(*)                       AS total_socios,
    SUM(churn)                     AS total_bajas,
    ROUND(AVG(churn) * 100, 2)     AS tasa_abandono_global_pct
FROM fact_membresia;


-- ---------------------------------------------------------
-- KPI 2 — Vida media del socio antes de la baja
-- ---------------------------------------------------------
SELECT
    ROUND(AVG(lifetime), 2) AS vida_media_meses
FROM fact_membresia
WHERE churn = 1;


-- ---------------------------------------------------------
-- KPI 3 — Tasa de asistencia a clases grupales
-- ---------------------------------------------------------
SELECT
    ROUND(AVG(da.asiste_clases_grp) * 100, 2) AS tasa_asistencia_clases_pct
FROM fact_membresia fm
JOIN dim_actividad da ON fm.id_actividad = da.id_actividad;


-- ---------------------------------------------------------
-- KPI 4 — Socios activos en riesgo por antigüedad y contrato a punto
-- de vencer
--
-- NOTA: reformulado. El KPI original medía "gasto adicional en riesgo"
-- usando tendencia_frecuencia (eliminada por el bug de datos). Se
-- redefine como el número de socios activos, nuevos, a los que les
-- queda 1 mes o menos de contrato: el perfil de mayor riesgo según
-- la Query 5.
-- ---------------------------------------------------------
SELECT
    COUNT(*) AS socios_en_riesgo_alto
FROM fact_membresia fm
WHERE fm.churn = 0
  AND fm.segmento_lifetime = 'nuevo'
  AND fm.meses_fin_contrato <= 1;


-- ---------------------------------------------------------
-- KPI 5 — Coste estimado del abandono y ahorro potencial
--
-- IMPORTANTE: se asume una cuota mensual de 30€ como supuesto de
-- negocio razonado (NO es un dato del dataset original). El coste
-- de cada baja = 30€ x meses que le quedaban de contrato.
-- El ahorro potencial asume recuperar al 20% de esos socios.
-- ---------------------------------------------------------
SELECT
    SUM(churn)                                                   AS total_bajas,
    ROUND(SUM(CASE WHEN churn = 1
                   THEN 30 * meses_fin_contrato
                   ELSE 0 END), 2)                                AS coste_estimado_abandono_eur,
    ROUND(SUM(CASE WHEN churn = 1
                   THEN 30 * meses_fin_contrato
                   ELSE 0 END) * 0.20, 2)                         AS ahorro_potencial_20pct_eur
FROM fact_membresia;
