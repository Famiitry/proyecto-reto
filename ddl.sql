-- =====================================================================
-- ESQUEMA: GESTION_MEDICA
-- Motor: Oracle 19c+
-- Normalización: BCNF (con 4FN en multi-valuados)
-- Features: Particionamiento por rango (fechas), JSON columns con validación
-- Autor: Jonnathan
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. CREACIÓN DE TABLESPACES (opcional, ajustar paths según servidor)
-- ---------------------------------------------------------------------
-- CREATE TABLESPACE ts_medico_data DATAFILE 'medico_data01.dbf' SIZE 500M AUTOEXTEND ON;
-- CREATE TABLESPACE ts_medico_idx  DATAFILE 'medico_idx01.dbf'  SIZE 200M AUTOEXTEND ON;

-- ---------------------------------------------------------------------
-- 1. CATÁLOGOS GEOGRÁFICOS (jerarquía 3FN -> BCNF)
-- ---------------------------------------------------------------------
CREATE TABLE pais (
    id_pais        NUMBER(3)      GENERATED ALWAYS AS IDENTITY,
    codigo_iso     CHAR(3)        NOT NULL,
    nombre         VARCHAR2(80)   NOT NULL,
    CONSTRAINT pk_pais       PRIMARY KEY (id_pais),
    CONSTRAINT uk_pais_iso   UNIQUE (codigo_iso),
    CONSTRAINT uk_pais_nom   UNIQUE (nombre)
);

CREATE TABLE provincia (
    id_provincia   NUMBER(5)      GENERATED ALWAYS AS IDENTITY,
    id_pais        NUMBER(3)      NOT NULL,
    nombre         VARCHAR2(80)   NOT NULL,
    CONSTRAINT pk_provincia      PRIMARY KEY (id_provincia),
    CONSTRAINT fk_provincia_pais FOREIGN KEY (id_pais) REFERENCES pais(id_pais),
    CONSTRAINT uk_provincia_nom  UNIQUE (id_pais, nombre)
);

CREATE TABLE canton (
    id_canton      NUMBER(7)      GENERATED ALWAYS AS IDENTITY,
    id_provincia   NUMBER(5)      NOT NULL,
    nombre         VARCHAR2(80)   NOT NULL,
    CONSTRAINT pk_canton           PRIMARY KEY (id_canton),
    CONSTRAINT fk_canton_provincia FOREIGN KEY (id_provincia) REFERENCES provincia(id_provincia),
    CONSTRAINT uk_canton_nom       UNIQUE (id_provincia, nombre)
);

CREATE TABLE parroquia (
    id_parroquia   NUMBER(9)      GENERATED ALWAYS AS IDENTITY,
    id_canton      NUMBER(7)      NOT NULL,
    nombre         VARCHAR2(80)   NOT NULL,
    CONSTRAINT pk_parroquia        PRIMARY KEY (id_parroquia),
    CONSTRAINT fk_parroquia_canton FOREIGN KEY (id_canton) REFERENCES canton(id_canton),
    CONSTRAINT uk_parroquia_nom    UNIQUE (id_canton, nombre)
);

-- ---------------------------------------------------------------------
-- 2. PERSONA (supertipo) + subtipos PACIENTE / MEDICO (BCNF, ISA disjunta)
-- ---------------------------------------------------------------------
CREATE TABLE persona (
    id_persona       NUMBER(10)    GENERATED ALWAYS AS IDENTITY,
    cedula           VARCHAR2(13)  NOT NULL,
    nombres          VARCHAR2(80)  NOT NULL,
    apellidos        VARCHAR2(80)  NOT NULL,
    fecha_nacimiento DATE          NOT NULL,
    sexo             CHAR(1)       NOT NULL,
    email            VARCHAR2(120),
    fecha_registro   TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_persona          PRIMARY KEY (id_persona),
    CONSTRAINT uk_persona_cedula   UNIQUE (cedula),
    CONSTRAINT uk_persona_email    UNIQUE (email),
    CONSTRAINT ck_persona_sexo     CHECK (sexo IN ('M','F','X')),
    CONSTRAINT ck_persona_fnac     CHECK (fecha_nacimiento <= SYSDATE)
);

-- Teléfonos: 4FN -- atributo multi-valuado separado
CREATE TABLE persona_telefono (
    id_persona   NUMBER(10)    NOT NULL,
    numero       VARCHAR2(20)  NOT NULL,
    tipo         VARCHAR2(15)  NOT NULL,
    CONSTRAINT pk_persona_tel     PRIMARY KEY (id_persona, numero),
    CONSTRAINT fk_persona_tel_per FOREIGN KEY (id_persona) REFERENCES persona(id_persona) ON DELETE CASCADE,
    CONSTRAINT ck_persona_tel_tip CHECK (tipo IN ('MOVIL','FIJO','TRABAJO'))
);

-- Direcciones: 4FN -- multi-valuado
CREATE TABLE persona_direccion (
    id_direccion   NUMBER(12)    GENERATED ALWAYS AS IDENTITY,
    id_persona     NUMBER(10)    NOT NULL,
    id_parroquia   NUMBER(9)     NOT NULL,
    calle_principal VARCHAR2(150) NOT NULL,
    calle_secundaria VARCHAR2(150),
    numeracion     VARCHAR2(20),
    referencia     VARCHAR2(200),
    es_principal   CHAR(1)       DEFAULT 'N' NOT NULL,
    CONSTRAINT pk_persona_dir       PRIMARY KEY (id_direccion),
    CONSTRAINT fk_persona_dir_per   FOREIGN KEY (id_persona)   REFERENCES persona(id_persona) ON DELETE CASCADE,
    CONSTRAINT fk_persona_dir_par   FOREIGN KEY (id_parroquia) REFERENCES parroquia(id_parroquia),
    CONSTRAINT ck_persona_dir_prin  CHECK (es_principal IN ('S','N'))
);

-- Subtipo PACIENTE (PK = FK a persona -> ISA exclusiva por especialización)
CREATE TABLE paciente (
    id_paciente       NUMBER(10)    NOT NULL,
    historia_clinica  VARCHAR2(15)  NOT NULL,
    tipo_sangre       VARCHAR2(3),
    factor_rh         CHAR(1),
    ocupacion         VARCHAR2(80),
    estado_civil      VARCHAR2(15),
    contacto_emergencia_nombre   VARCHAR2(160),
    contacto_emergencia_telefono VARCHAR2(20),
    CONSTRAINT pk_paciente         PRIMARY KEY (id_paciente),
    CONSTRAINT fk_paciente_persona FOREIGN KEY (id_paciente) REFERENCES persona(id_persona) ON DELETE CASCADE,
    CONSTRAINT uk_paciente_hc      UNIQUE (historia_clinica),
    CONSTRAINT ck_paciente_sangre  CHECK (tipo_sangre IN ('A','B','AB','O')),
    CONSTRAINT ck_paciente_rh      CHECK (factor_rh IN ('+','-')),
    CONSTRAINT ck_paciente_ecivil  CHECK (estado_civil IN ('SOLTERO','CASADO','DIVORCIADO','VIUDO','UNION'))
);

-- Subtipo MEDICO
CREATE TABLE medico (
    id_medico        NUMBER(10)    NOT NULL,
    num_registro     VARCHAR2(20)  NOT NULL,  -- Registro MSP / SENESCYT
    fecha_ingreso    DATE          NOT NULL,
    fecha_baja       DATE,
    titulo_principal VARCHAR2(120) NOT NULL,
    CONSTRAINT pk_medico          PRIMARY KEY (id_medico),
    CONSTRAINT fk_medico_persona  FOREIGN KEY (id_medico) REFERENCES persona(id_persona) ON DELETE CASCADE,
    CONSTRAINT uk_medico_reg      UNIQUE (num_registro),
    CONSTRAINT ck_medico_fechas   CHECK (fecha_baja IS NULL OR fecha_baja >= fecha_ingreso)
);

-- ---------------------------------------------------------------------
-- 3. ESPECIALIDADES (relación M:N con MEDICO -> 4FN)
-- ---------------------------------------------------------------------
CREATE TABLE especialidad (
    id_especialidad  NUMBER(5)     GENERATED ALWAYS AS IDENTITY,
    nombre           VARCHAR2(80)  NOT NULL,
    descripcion      VARCHAR2(300),
    CONSTRAINT pk_especialidad     PRIMARY KEY (id_especialidad),
    CONSTRAINT uk_especialidad_nom UNIQUE (nombre)
);

CREATE TABLE medico_especialidad (
    id_medico        NUMBER(10)    NOT NULL,
    id_especialidad  NUMBER(5)     NOT NULL,
    fecha_certif     DATE          NOT NULL,
    institucion      VARCHAR2(120),
    CONSTRAINT pk_med_esp     PRIMARY KEY (id_medico, id_especialidad),
    CONSTRAINT fk_med_esp_med FOREIGN KEY (id_medico)       REFERENCES medico(id_medico) ON DELETE CASCADE,
    CONSTRAINT fk_med_esp_esp FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad)
);

-- ---------------------------------------------------------------------
-- 4. ALERGIAS Y ANTECEDENTES (4FN)
-- ---------------------------------------------------------------------
CREATE TABLE alergeno (
    id_alergeno    NUMBER(7)     GENERATED ALWAYS AS IDENTITY,
    nombre         VARCHAR2(120) NOT NULL,
    categoria      VARCHAR2(40)  NOT NULL,
    CONSTRAINT pk_alergeno      PRIMARY KEY (id_alergeno),
    CONSTRAINT uk_alergeno_nom  UNIQUE (nombre),
    CONSTRAINT ck_alergeno_cat  CHECK (categoria IN ('MEDICAMENTO','ALIMENTO','AMBIENTAL','ANIMAL','OTRO'))
);

CREATE TABLE paciente_alergia (
    id_paciente     NUMBER(10)    NOT NULL,
    id_alergeno     NUMBER(7)     NOT NULL,
    severidad       VARCHAR2(10)  NOT NULL,
    fecha_deteccion DATE,
    observaciones   VARCHAR2(500),
    CONSTRAINT pk_pac_alergia     PRIMARY KEY (id_paciente, id_alergeno),
    CONSTRAINT fk_pac_alergia_pac FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente) ON DELETE CASCADE,
    CONSTRAINT fk_pac_alergia_alg FOREIGN KEY (id_alergeno) REFERENCES alergeno(id_alergeno),
    CONSTRAINT ck_pac_alergia_sev CHECK (severidad IN ('LEVE','MODERADA','SEVERA','ANAFILACTICA'))
);

-- ---------------------------------------------------------------------
-- 5. INFRAESTRUCTURA: CONSULTORIO + ESTADO_CITA
-- ---------------------------------------------------------------------
CREATE TABLE consultorio (
    id_consultorio  NUMBER(5)     GENERATED ALWAYS AS IDENTITY,
    codigo          VARCHAR2(10)  NOT NULL,
    piso            NUMBER(2),
    descripcion     VARCHAR2(120),
    CONSTRAINT pk_consultorio     PRIMARY KEY (id_consultorio),
    CONSTRAINT uk_consultorio_cod UNIQUE (codigo)
);

CREATE TABLE estado_cita (
    id_estado     NUMBER(2)     GENERATED ALWAYS AS IDENTITY,
    codigo        VARCHAR2(20)  NOT NULL,
    descripcion   VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_estado_cita     PRIMARY KEY (id_estado),
    CONSTRAINT uk_estado_cita_cod UNIQUE (codigo)
);

-- ---------------------------------------------------------------------
-- 6. CITA (PARTICIONADA POR RANGO DE FECHA)
-- ---------------------------------------------------------------------
CREATE TABLE cita (
    id_cita         NUMBER(12)    GENERATED ALWAYS AS IDENTITY,
    id_paciente     NUMBER(10)    NOT NULL,
    id_medico       NUMBER(10)    NOT NULL,
    id_consultorio  NUMBER(5)     NOT NULL,
    id_estado       NUMBER(2)     NOT NULL,
    fecha_hora      TIMESTAMP     NOT NULL,
    duracion_min    NUMBER(3)     DEFAULT 30 NOT NULL,
    motivo_solicitud VARCHAR2(300),
    fecha_creacion  TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_cita        PRIMARY KEY (id_cita, fecha_hora),  -- compuesta para particionado
    CONSTRAINT fk_cita_pac    FOREIGN KEY (id_paciente)    REFERENCES paciente(id_paciente),
    CONSTRAINT fk_cita_med    FOREIGN KEY (id_medico)      REFERENCES medico(id_medico),
    CONSTRAINT fk_cita_cons   FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio),
    CONSTRAINT fk_cita_est    FOREIGN KEY (id_estado)      REFERENCES estado_cita(id_estado),
    CONSTRAINT ck_cita_dur    CHECK (duracion_min BETWEEN 5 AND 240)
)
PARTITION BY RANGE (fecha_hora)
INTERVAL (NUMTOYMINTERVAL(1,'MONTH'))
(
    PARTITION p_inicial VALUES LESS THAN (TIMESTAMP '2024-01-01 00:00:00')
);

CREATE INDEX ix_cita_paciente ON cita(id_paciente, fecha_hora) LOCAL;
CREATE INDEX ix_cita_medico   ON cita(id_medico,   fecha_hora) LOCAL;

-- ---------------------------------------------------------------------
-- 7. CATÁLOGO CIE-10 (diagnósticos)
-- ---------------------------------------------------------------------
CREATE TABLE cie10 (
    codigo        VARCHAR2(8)   NOT NULL,
    descripcion   VARCHAR2(500) NOT NULL,
    capitulo      VARCHAR2(10),
    CONSTRAINT pk_cie10 PRIMARY KEY (codigo)
);

-- ---------------------------------------------------------------------
-- 8. CONSULTA (1:1 débil con CITA) + JSON para anamnesis/lenguaje natural
-- ---------------------------------------------------------------------
CREATE TABLE consulta (
    id_consulta      NUMBER(12)   GENERATED ALWAYS AS IDENTITY,
    id_cita          NUMBER(12)   NOT NULL,
    fecha_cita       TIMESTAMP    NOT NULL,  -- denormalización controlada para FK compuesta
    fecha_atencion   TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    motivo_consulta  CLOB         NOT NULL,
    enfermedad_actual CLOB,
    examen_fisico    CLOB,
    plan_tratamiento CLOB,
    -- JSON: anamnesis estructurada flexible (NLP / formularios dinámicos)
    anamnesis        CLOB         CONSTRAINT ck_consulta_anamnesis CHECK (anamnesis IS JSON),
    -- JSON: salida de procesamiento de lenguaje natural (entidades médicas extraídas)
    nlp_entidades    CLOB         CONSTRAINT ck_consulta_nlp CHECK (nlp_entidades IS JSON),
    CONSTRAINT pk_consulta    PRIMARY KEY (id_consulta),
    CONSTRAINT uk_consulta_cita UNIQUE (id_cita),
    CONSTRAINT fk_consulta_cita FOREIGN KEY (id_cita, fecha_cita) REFERENCES cita(id_cita, fecha_hora)
)
PARTITION BY RANGE (fecha_atencion)
INTERVAL (NUMTOYMINTERVAL(1,'MONTH'))
(
    PARTITION p_inicial VALUES LESS THAN (TIMESTAMP '2024-01-01 00:00:00')
);

-- ---------------------------------------------------------------------
-- 9. SIGNOS VITALES (1:1 débil con CONSULTA -> BCNF)
-- ---------------------------------------------------------------------
CREATE TABLE signos_vitales (
    id_consulta       NUMBER(12)   NOT NULL,
    presion_sistolica NUMBER(3),
    presion_diastolica NUMBER(3),
    frec_cardiaca     NUMBER(3),
    frec_respiratoria NUMBER(3),
    temperatura       NUMBER(4,1),
    saturacion_o2     NUMBER(3),
    peso_kg           NUMBER(5,2),
    talla_cm          NUMBER(5,2),
    CONSTRAINT pk_signos       PRIMARY KEY (id_consulta),
    CONSTRAINT fk_signos_cons  FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta) ON DELETE CASCADE,
    CONSTRAINT ck_signos_temp  CHECK (temperatura BETWEEN 30 AND 45),
    CONSTRAINT ck_signos_sato2 CHECK (saturacion_o2 BETWEEN 50 AND 100),
    CONSTRAINT ck_signos_pres  CHECK (presion_sistolica > presion_diastolica)
);

-- ---------------------------------------------------------------------
-- 10. DIAGNÓSTICOS DE CONSULTA (M:N con CIE-10)
-- ---------------------------------------------------------------------
CREATE TABLE consulta_diagnostico (
    id_consulta   NUMBER(12)    NOT NULL,
    codigo_cie    VARCHAR2(8)   NOT NULL,
    tipo          CHAR(1)       NOT NULL,
    observacion   VARCHAR2(500),
    CONSTRAINT pk_cons_diag      PRIMARY KEY (id_consulta, codigo_cie),
    CONSTRAINT fk_cons_diag_cons FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta) ON DELETE CASCADE,
    CONSTRAINT fk_cons_diag_cie  FOREIGN KEY (codigo_cie)  REFERENCES cie10(codigo),
    CONSTRAINT ck_cons_diag_tipo CHECK (tipo IN ('P','S','D'))  -- Principal, Secundario, Diferencial
);

-- ---------------------------------------------------------------------
-- 11. RECETAS Y MEDICAMENTOS
-- ---------------------------------------------------------------------
CREATE TABLE medicamento (
    id_medicamento   NUMBER(8)     GENERATED ALWAYS AS IDENTITY,
    nombre_generico  VARCHAR2(120) NOT NULL,
    concentracion    VARCHAR2(40),
    forma_farma      VARCHAR2(40)  NOT NULL,  -- tableta, jarabe, ampolla, etc.
    via_admin        VARCHAR2(20),
    requiere_receta  CHAR(1)       DEFAULT 'S' NOT NULL,
    CONSTRAINT pk_medicamento     PRIMARY KEY (id_medicamento),
    CONSTRAINT uk_medicamento     UNIQUE (nombre_generico, concentracion, forma_farma),
    CONSTRAINT ck_medicamento_req CHECK (requiere_receta IN ('S','N'))
);

CREATE TABLE receta (
    id_receta       NUMBER(12)   GENERATED ALWAYS AS IDENTITY,
    id_consulta     NUMBER(12)   NOT NULL,
    fecha_emision   TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    validez_dias    NUMBER(3)    DEFAULT 30 NOT NULL,
    observaciones   VARCHAR2(500),
    CONSTRAINT pk_receta      PRIMARY KEY (id_receta),
    CONSTRAINT fk_receta_cons FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta) ON DELETE CASCADE
);

CREATE TABLE receta_detalle (
    id_receta        NUMBER(12)    NOT NULL,
    id_medicamento   NUMBER(8)     NOT NULL,
    dosis            VARCHAR2(60)  NOT NULL,
    frecuencia       VARCHAR2(60)  NOT NULL,
    duracion_dias    NUMBER(3),
    indicaciones     VARCHAR2(300),
    CONSTRAINT pk_receta_det      PRIMARY KEY (id_receta, id_medicamento),
    CONSTRAINT fk_receta_det_rec  FOREIGN KEY (id_receta)      REFERENCES receta(id_receta) ON DELETE CASCADE,
    CONSTRAINT fk_receta_det_med  FOREIGN KEY (id_medicamento) REFERENCES medicamento(id_medicamento)
);

-- ---------------------------------------------------------------------
-- 12. AUDITORÍA (particionada por mes, JSON para payload)
-- ---------------------------------------------------------------------
CREATE TABLE auditoria_evento (
    id_evento     NUMBER(15)   GENERATED ALWAYS AS IDENTITY,
    fecha_evento  TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    usuario_db    VARCHAR2(40) NOT NULL,
    tabla         VARCHAR2(40) NOT NULL,
    operacion     CHAR(1)      NOT NULL,
    pk_afectada   VARCHAR2(60),
    payload_old   CLOB         CONSTRAINT ck_aud_old CHECK (payload_old IS JSON),
    payload_new   CLOB         CONSTRAINT ck_aud_new CHECK (payload_new IS JSON),
    CONSTRAINT pk_auditoria    PRIMARY KEY (id_evento, fecha_evento),
    CONSTRAINT ck_aud_op       CHECK (operacion IN ('I','U','D'))
)
PARTITION BY RANGE (fecha_evento)
INTERVAL (NUMTOYMINTERVAL(1,'MONTH'))
(
    PARTITION p_inicial VALUES LESS THAN (TIMESTAMP '2024-01-01 00:00:00')
);

-- ---------------------------------------------------------------------
-- 13. ÍNDICES ADICIONALES PARA CONSULTAS DE ALTO NIVEL
-- ---------------------------------------------------------------------
CREATE INDEX ix_persona_apellido      ON persona(apellidos, nombres);
CREATE INDEX ix_consulta_diag_cie     ON consulta_diagnostico(codigo_cie);
CREATE INDEX ix_receta_det_med        ON receta_detalle(id_medicamento);
CREATE INDEX ix_pac_alergia_alg       ON paciente_alergia(id_alergeno);

-- Índice funcional sobre JSON (anamnesis) -- ejemplo: motivo principal extraído
CREATE INDEX ix_consulta_anamnesis_motivo
    ON consulta (JSON_VALUE(anamnesis, '$.motivoPrincipal'));

-- Índice funcional sobre nlp_entidades -- ejemplo: entidad clínica detectada
CREATE INDEX ix_consulta_nlp_diag
    ON consulta (JSON_VALUE(nlp_entidades, '$.diagnosticoSugerido'));

-- ---------------------------------------------------------------------
-- 14. VISTA AGREGADA PARA CONSULTAS DE ALTO NIVEL (API REST)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_historia_paciente AS
SELECT
    p.id_paciente,
    per.cedula,
    per.nombres || ' ' || per.apellidos AS paciente,
    c.id_consulta,
    c.fecha_atencion,
    per_med.nombres || ' ' || per_med.apellidos AS medico,
    LISTAGG(cd.codigo_cie || ' - ' || cie.descripcion, '; ')
        WITHIN GROUP (ORDER BY cd.tipo) AS diagnosticos
FROM paciente p
JOIN persona per           ON per.id_persona = p.id_paciente
JOIN cita ci               ON ci.id_paciente = p.id_paciente
JOIN consulta c            ON c.id_cita = ci.id_cita
JOIN medico m              ON m.id_medico = ci.id_medico
JOIN persona per_med       ON per_med.id_persona = m.id_medico
LEFT JOIN consulta_diagnostico cd ON cd.id_consulta = c.id_consulta
LEFT JOIN cie10 cie        ON cie.codigo = cd.codigo_cie
GROUP BY p.id_paciente, per.cedula, per.nombres, per.apellidos,
         c.id_consulta, c.fecha_atencion, per_med.nombres, per_med.apellidos;

-- =====================================================================
-- FIN DEL ESQUEMA
-- =====================================================================