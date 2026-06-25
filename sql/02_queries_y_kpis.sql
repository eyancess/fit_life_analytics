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
-- ---------------------------------------------------------
SELECT
    COUNT(*) AS socios_en_riesgo_alto
FROM fact_membresia fm
WHERE fm.churn = 0
  AND fm.segmento_lifetime = 'nuevo'
  AND fm.meses_fin_contrato <= 1;


-- ---------------------------------------------------------
-- KPI 5 — Coste estimado del abandono y ahorro potencial
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
