-- =====================================================================
-- VISTAS ANALITICAS: GESTION_MEDICA
-- Encapsulan consultas avanzadas para consumo desde API REST (Node.js + ORDS)
-- Motor: Oracle 19c+ / 23ai
-- =====================================================================

-- ---------------------------------------------------------------------
-- GRUPO 1: MEDICOS Y ESPECIALIDADES
-- ---------------------------------------------------------------------

-- 1.1 Medicos con mas citas (ranking DENSE_RANK)
CREATE OR REPLACE VIEW v_medicos_citas_rank AS
SELECT *
FROM (
  SELECT m.id_medico,
         p.apellidos || ', ' || p.nombres AS medico,
         COUNT(*) AS total_citas,
         DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
  FROM cita c
  JOIN medico m ON m.id_medico = c.id_medico
  JOIN persona p ON p.id_persona = m.id_medico
  GROUP BY m.id_medico, p.apellidos, p.nombres
)
WHERE rnk <= 10
ORDER BY total_citas DESC;

-- 1.2 Distribucion de citas por especialidad (GROUPING SETS)
CREATE OR REPLACE VIEW v_citas_especialidad AS
SELECT e.nombre AS especialidad,
       TO_CHAR(TRUNC(CAST(c.fecha_hora AS DATE), 'MM'), 'YYYY-MM') AS mes,
       COUNT(*) AS total
FROM cita c
JOIN medico_especialidad me ON me.id_medico = c.id_medico
JOIN especialidad e ON e.id_especialidad = me.id_especialidad
GROUP BY GROUPING SETS (
  (e.nombre, TRUNC(CAST(c.fecha_hora AS DATE), 'MM')),
  (e.nombre),
  (TRUNC(CAST(c.fecha_hora AS DATE), 'MM'))
)
ORDER BY especialidad, mes;

-- 1.3 Diagnosticos mas frecuentes por medico (DENSE_RANK particionado)
CREATE OR REPLACE VIEW v_medicos_diagnosticos_rank AS
SELECT *
FROM (
  SELECT c.id_medico,
         cd.codigo_cie,
         COUNT(*) AS total,
         DENSE_RANK() OVER (PARTITION BY c.id_medico ORDER BY COUNT(*) DESC) AS rnk
  FROM consulta con
  JOIN cita c ON c.id_cita = con.id_cita AND c.fecha_hora = con.fecha_cita
  JOIN consulta_diagnostico cd ON cd.id_consulta = con.id_consulta
  GROUP BY c.id_medico, cd.codigo_cie
)
WHERE rnk <= 3
ORDER BY id_medico, total DESC;

-- 1.4 Resumen por especialidad y estado (CUBE)
CREATE OR REPLACE VIEW v_especialidad_estado AS
SELECT e.nombre AS especialidad,
       ec.codigo AS estado,
       COUNT(*) AS total
FROM cita c
JOIN medico_especialidad me ON me.id_medico = c.id_medico
JOIN especialidad e ON e.id_especialidad = me.id_especialidad
JOIN estado_cita ec ON ec.id_estado = c.id_estado
GROUP BY CUBE (e.nombre, ec.codigo)
ORDER BY especialidad, estado;

-- ---------------------------------------------------------------------
-- GRUPO 2: CITAS
-- ---------------------------------------------------------------------

-- 2.1 Citas por estado y mes (ROLLUP)
CREATE OR REPLACE VIEW v_citas_mes AS
SELECT TO_CHAR(TRUNC(CAST(c.fecha_hora AS DATE), 'MM'), 'YYYY-MM') AS mes,
       e.codigo AS estado,
       COUNT(*) AS total_citas
FROM cita c
JOIN estado_cita e ON e.id_estado = c.id_estado
GROUP BY ROLLUP (TRUNC(CAST(c.fecha_hora AS DATE), 'MM'), e.codigo)
ORDER BY mes, estado;

-- 2.2 Promedio movil de 7 dias de citas diarias
CREATE OR REPLACE VIEW v_citas_promedio_7d AS
WITH citas_diarias AS (
  SELECT TRUNC(CAST(c.fecha_hora AS DATE)) AS fecha,
         COUNT(*) AS total
  FROM cita c
  GROUP BY TRUNC(CAST(c.fecha_hora AS DATE))
)
SELECT fecha,
       total,
       ROUND(AVG(total) OVER (ORDER BY fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS avg_7d
FROM citas_diarias
ORDER BY fecha;

-- 2.3 Citas por estado (PIVOT)
CREATE OR REPLACE VIEW v_citas_estado_pivot AS
WITH base AS (
  SELECT TO_CHAR(TRUNC(CAST(c.fecha_hora AS DATE), 'MM'), 'YYYY-MM') AS mes,
         e.codigo AS estado
  FROM cita c
  JOIN estado_cita e ON e.id_estado = c.id_estado
)
SELECT *
FROM base
PIVOT (
  COUNT(*) FOR estado IN (
    'PROGRAMADA' AS programada,
    'ATENDIDA'   AS atendida,
    'CANCELADA'  AS cancelada
  )
)
ORDER BY mes;

-- 2.4 Citas por estado totales
CREATE OR REPLACE VIEW v_citas_estado_total AS
SELECT ec.codigo AS estado, ec.descripcion, COUNT(*) AS total
FROM cita c
JOIN estado_cita ec ON c.id_estado = ec.id_estado
GROUP BY ec.codigo, ec.descripcion
ORDER BY total DESC;

-- ---------------------------------------------------------------------
-- GRUPO 3: PACIENTES
-- ---------------------------------------------------------------------

-- 3.1 Pacientes con mayor tiempo de espera entre cita y atencion
CREATE OR REPLACE VIEW v_pacientes_espera AS
WITH espera AS (
  SELECT c.id_cita,
         c.id_paciente,
         c.fecha_hora,
         con.fecha_atencion,
         (CAST(con.fecha_atencion AS DATE) - CAST(c.fecha_hora AS DATE)) * 24 * 60 AS espera_min
  FROM cita c
  JOIN consulta con ON con.id_cita = c.id_cita AND con.fecha_cita = c.fecha_hora
  WHERE con.fecha_atencion IS NOT NULL
)
SELECT *
FROM (
  SELECT id_paciente,
         ROUND(AVG(espera_min), 2) AS espera_prom_min,
         PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY espera_min) AS p95_espera_min
  FROM espera
  GROUP BY id_paciente
  ORDER BY espera_prom_min DESC
)
FETCH FIRST 20 ROWS ONLY;

-- 3.2 Brechas maximas entre citas por paciente (LAG)
CREATE OR REPLACE VIEW v_pacientes_brechas AS
WITH citas_paciente AS (
  SELECT id_paciente,
         fecha_hora,
         LAG(fecha_hora) OVER (PARTITION BY id_paciente ORDER BY fecha_hora) AS fecha_prev
  FROM cita
)
SELECT id_paciente,
       MAX(CAST(fecha_hora AS DATE) - CAST(fecha_prev AS DATE)) AS max_gap_dias
FROM citas_paciente
WHERE fecha_prev IS NOT NULL
GROUP BY id_paciente
ORDER BY max_gap_dias DESC
FETCH FIRST 20 ROWS ONLY;

-- 3.3 Ultima consulta por paciente (OUTER APPLY)
CREATE OR REPLACE VIEW v_pacientes_ultima_consulta AS
SELECT p.id_persona AS id_paciente,
       p.apellidos || ', ' || p.nombres AS paciente,
       lc.id_consulta,
       lc.fecha_atencion,
       lc.motivo_consulta
FROM persona p
JOIN paciente pa ON pa.id_paciente = p.id_persona
OUTER APPLY (
  SELECT con.id_consulta,
         con.fecha_atencion,
         con.motivo_consulta
  FROM consulta con
  JOIN cita c ON c.id_cita = con.id_cita AND c.fecha_hora = con.fecha_cita
  WHERE c.id_paciente = pa.id_paciente
  ORDER BY con.fecha_atencion DESC
  FETCH FIRST 1 ROW ONLY
) lc
ORDER BY p.id_persona;

-- 3.4 Pacientes con uso alto vs promedio (z-score)
CREATE OR REPLACE VIEW v_pacientes_zscore AS
WITH uso AS (
  SELECT c.id_paciente,
         COUNT(*) AS total_citas
  FROM cita c
  GROUP BY c.id_paciente
), stats AS (
  SELECT AVG(total_citas) AS avg_citas,
         STDDEV(total_citas) AS sd_citas
  FROM uso
)
SELECT p.apellidos || ', ' || p.nombres AS paciente,
       u.total_citas,
       ROUND((u.total_citas - s.avg_citas) / NULLIF(s.sd_citas, 0), 2) AS z_score
FROM uso u
CROSS JOIN stats s
JOIN persona p ON p.id_persona = u.id_paciente
ORDER BY z_score DESC NULLS LAST
FETCH FIRST 20 ROWS ONLY;

-- 3.5 Top alergias por categoria y severidad
CREATE OR REPLACE VIEW v_alergias_rank AS
SELECT *
FROM (
  SELECT a.categoria,
         a.nombre,
         pa.severidad,
         COUNT(*) AS total,
         ROW_NUMBER() OVER (PARTITION BY a.categoria, pa.severidad ORDER BY COUNT(*) DESC) AS rn
  FROM paciente_alergia pa
  JOIN alergeno a ON a.id_alergeno = pa.id_alergeno
  GROUP BY a.categoria, a.nombre, pa.severidad
)
WHERE rn <= 5
ORDER BY categoria, severidad, total DESC;

-- 3.6 Pacientes con alergias severas / anafilacticas
CREATE OR REPLACE VIEW v_pacientes_alergias_severas AS
SELECT p.id_paciente,
       per.nombres || ' ' || per.apellidos AS paciente,
       a.nombre AS alergeno, a.categoria, pa.severidad
FROM paciente_alergia pa
JOIN paciente p ON pa.id_paciente = p.id_paciente
JOIN persona per ON per.id_persona = p.id_paciente
JOIN alergeno a ON pa.id_alergeno = a.id_alergeno
WHERE pa.severidad IN ('SEVERA', 'ANAFILACTICA')
ORDER BY pa.severidad, per.apellidos;

-- ---------------------------------------------------------------------
-- GRUPO 4: CONSULTAS CLINICAS
-- ---------------------------------------------------------------------

-- 4.1 Consultas con resumen JSON de anamnesis
CREATE OR REPLACE VIEW v_consultas_resumen AS
SELECT con.id_consulta,
       con.fecha_atencion,
       JSON_VALUE(con.anamnesis, '$.motivoPrincipal') AS motivo_principal,
       JSON_QUERY(con.anamnesis, '$.sintomas' NULL ON ERROR) AS sintomas,
       con.motivo_consulta,
       per_pac.nombres || ' ' || per_pac.apellidos AS paciente,
       per_med.nombres || ' ' || per_med.apellidos AS medico
FROM consulta con
JOIN cita c ON c.id_cita = con.id_cita AND c.fecha_hora = con.fecha_cita
JOIN persona per_pac ON per_pac.id_persona = c.id_paciente
JOIN persona per_med ON per_med.id_persona = c.id_medico
WHERE con.anamnesis IS NOT NULL
ORDER BY con.id_consulta;

-- 4.2 Diagnosticos frecuentes
CREATE OR REPLACE VIEW v_diagnosticos_frecuentes AS
SELECT cd.codigo_cie, cie.descripcion, COUNT(*) AS total_diagnosticos
FROM consulta_diagnostico cd
JOIN cie10 cie ON cd.codigo_cie = cie.codigo
GROUP BY cd.codigo_cie, cie.descripcion
ORDER BY total_diagnosticos DESC;

-- 4.3 Citas por medico
CREATE OR REPLACE VIEW v_citas_por_medico AS
SELECT c.id_medico,
       pem.nombres || ' ' || pem.apellidos AS medico,
       COUNT(*) AS total_citas
FROM cita c
JOIN persona pem ON pem.id_persona = c.id_medico
GROUP BY c.id_medico, pem.nombres, pem.apellidos
ORDER BY total_citas DESC;

-- ---------------------------------------------------------------------
-- GRUPO 5: RECETAS Y MEDICAMENTOS
-- ---------------------------------------------------------------------

-- 5.1 Medicamentos mas recetados por mes
CREATE OR REPLACE VIEW v_medicamentos_recetados AS
WITH det AS (
  SELECT TO_CHAR(TRUNC(CAST(r.fecha_emision AS DATE), 'MM'), 'YYYY-MM') AS mes,
         m.nombre_generico AS medicamento,
         COUNT(*) AS total
  FROM receta r
  JOIN receta_detalle rd ON rd.id_receta = r.id_receta
  JOIN medicamento m ON m.id_medicamento = rd.id_medicamento
  GROUP BY TRUNC(CAST(r.fecha_emision AS DATE), 'MM'), m.nombre_generico
)
SELECT *
FROM (
  SELECT mes,
         medicamento,
         total,
         ROW_NUMBER() OVER (PARTITION BY mes ORDER BY total DESC) AS rn
  FROM det
)
WHERE rn <= 5
ORDER BY mes, total DESC;

-- ---------------------------------------------------------------------
-- 6. VISTA HISTORIA PACIENTE (ya en ddl.sql, se incluye referencia)
--    v_historia_paciente
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- 7. RESUMEN DASHBOARD (totales)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_dashboard AS
SELECT
  (SELECT COUNT(*) FROM paciente) AS total_pacientes,
  (SELECT COUNT(*) FROM medico WHERE fecha_baja IS NULL) AS total_medicos,
  (SELECT COUNT(*) FROM cita) AS total_citas,
  (SELECT COUNT(*) FROM consulta) AS total_consultas
FROM dual;
