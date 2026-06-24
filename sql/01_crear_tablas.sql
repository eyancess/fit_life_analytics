-- =========================================================
-- FitLife Analytics — Modelo Estrella
-- Script 1: Creación de las tablas (dimensiones + hechos)
-- =========================================================
-- Cómo usar este script:
-- 1. Abre DBeaver y conéctate a la base de datos fitlife_analytics.
-- 2. Abre un SQL Editor nuevo (SQL Editor -> New SQL Script).
-- 3. Pega todo este contenido.
-- 4. Ejecuta el script completo (botón de "Execute SQL Script", el de
--    dos flechas, o Alt+X / Cmd+X según tu DBeaver).
-- 5. Cuando termine, en el árbol de la izquierda haz clic derecho sobre
--    fitlife_analytics -> Refresh, y deberías ver las 5 tablas vacías.
-- =========================================================

-- En PostgreSQL no existe la instrucción USE. Antes de ejecutar este
-- script, asegúrate de que tu conexión en DBeaver está apuntando a la
-- base de datos fitlife_analytics (lo eliges al crear o seleccionar la
-- conexión, no dentro del propio script SQL).
--
-- Si todavía no has creado la base de datos, ejecuta primero esto en
-- una conexión a la base de datos por defecto (postgres):
-- CREATE DATABASE fitlife_analytics;
-- Después, reconéctate o abre un nuevo SQL Editor ya sobre esa base
-- de datos antes de continuar con el resto de este script.

-- Si ya existían de un intento anterior, las borramos primero
-- (en este orden: la tabla de hechos antes que las dimensiones,
-- porque tiene claves foráneas que dependen de ellas)
DROP TABLE IF EXISTS fact_membresia;
DROP TABLE IF EXISTS dim_socio;
DROP TABLE IF EXISTS dim_contrato;
DROP TABLE IF EXISTS dim_captacion;
DROP TABLE IF EXISTS dim_actividad;

-- ---------------------------------------------------------
-- 1. dim_socio
-- ---------------------------------------------------------
CREATE TABLE dim_socio (
    id_socio            INT PRIMARY KEY,
    genero               VARCHAR(10),
    edad                 INT,
    grupo_edad           VARCHAR(10),
    vive_cerca           INT,
    tiene_pareja_socia   INT
);

-- ---------------------------------------------------------
-- 2. dim_contrato
-- ---------------------------------------------------------
CREATE TABLE dim_contrato (
    id_contrato        INT PRIMARY KEY,
    tipo_contrato      VARCHAR(20),
    duracion_meses     INT,
    nivel_compromiso   VARCHAR(10)
);

-- ---------------------------------------------------------
-- 3. dim_captacion
-- ---------------------------------------------------------
CREATE TABLE dim_captacion (
    id_captacion           INT PRIMARY KEY,
    viene_por_promo        INT,
    telefono_registrado    INT,
    perfil_captacion       VARCHAR(30)
);

-- ---------------------------------------------------------
-- 4. dim_actividad
-- NOTA: esta tabla se ha simplificado respecto a la versión inicial.
-- Las columnas segmento_frecuencia y tendencia_frecuencia se han
-- eliminado porque dependían de Avg_class_frequency_total y
-- Avg_class_frequency_current_month, afectadas por un bug de
-- exportación irreversible del CSV original de Kaggle (ver
-- business_case.md, apartado de limitaciones de datos).
-- ---------------------------------------------------------
CREATE TABLE dim_actividad (
    id_actividad           INT PRIMARY KEY,
    asiste_clases_grp      INT
);

-- ---------------------------------------------------------
-- 5. fact_membresia (tabla de hechos central)
-- NOTA: esta tabla ya NO incluye gasto_adicional, frecuencia_total,
-- frecuencia_mes ni variacion_frecuencia. Esas columnas dependían de
-- Avg_additional_charges_total y Avg_class_frequency_*, afectadas por
-- un bug de exportación irreversible del CSV original de Kaggle
-- (ver business_case.md, apartado de limitaciones de datos).
-- ---------------------------------------------------------
CREATE TABLE fact_membresia (
    id_socio               INT PRIMARY KEY,
    id_contrato            INT,
    id_captacion           INT,
    id_actividad           INT,
    lifetime                INT,
    meses_fin_contrato      NUMERIC(4,1),
    segmento_lifetime        VARCHAR(15),
    churn                    INT,

    CONSTRAINT fk_fact_socio
        FOREIGN KEY (id_socio) REFERENCES dim_socio(id_socio),
    CONSTRAINT fk_fact_contrato
        FOREIGN KEY (id_contrato) REFERENCES dim_contrato(id_contrato),
    CONSTRAINT fk_fact_captacion
        FOREIGN KEY (id_captacion) REFERENCES dim_captacion(id_captacion),
    CONSTRAINT fk_fact_actividad
        FOREIGN KEY (id_actividad) REFERENCES dim_actividad(id_actividad)
);

-- ---------------------------------------------------------
-- Comprobación: deberían aparecer las 5 tablas, todas con 0 filas
-- (las llenamos en el siguiente paso con "Import Data" desde los CSV)
--
-- NOTA: SHOW TABLES no existe en PostgreSQL (es sintaxis de MySQL).
-- El equivalente en Postgres es consultar el catálogo information_schema.
-- ---------------------------------------------------------
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
