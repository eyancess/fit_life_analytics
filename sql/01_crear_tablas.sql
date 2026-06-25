
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
-- ---------------------------------------------------------
CREATE TABLE dim_actividad (
    id_actividad           INT PRIMARY KEY,
    asiste_clases_grp      INT
);

-- ---------------------------------------------------------
-- 5. fact_membresia (tabla de hechos central)
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
-- Comprobación
-- ---------------------------------------------------------
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
