-- Consultas avanzadas para el esquema GESTION_MEDICA
-- Ejecutar en SQL*Plus/SQLcl para ver tiempos por consulta
SET TIMING ON
SET PAGESIZE 200
SET LINESIZE 200
SET TAB OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

PROMPT 1) Medicos con mas citas (ranking)
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

PROMPT 2) Citas por estado y mes con rollup
SELECT TO_CHAR(TRUNC(CAST(c.fecha_hora AS DATE), 'MM'), 'YYYY-MM') AS mes,
       e.codigo AS estado,
       COUNT(*) AS total_citas
FROM cita c
JOIN estado_cita e ON e.id_estado = c.id_estado
GROUP BY ROLLUP (TRUNC(CAST(c.fecha_hora AS DATE), 'MM'), e.codigo)
ORDER BY mes, estado;

PROMPT 3) Promedio movil de 7 dias de citas diarias
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

PROMPT 4) Pacientes con mayor tiempo de espera entre cita y atencion
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

PROMPT 5) Brechas maximas entre citas por paciente (LAG)
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

PROMPT 6) Distribucion de citas por especialidad (GROUPING SETS)
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

PROMPT 7) Top alergias por categoria y severidad (window + partition)
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

PROMPT 8) Citas por estado (PIVOT)
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
    'ATENDIDA' AS atendida,
    'CANCELADA' AS cancelada
  )
)
ORDER BY mes;

PROMPT 9) Diagnosticos mas frecuentes por medico (dense rank)
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

PROMPT 10) Ultima consulta por paciente (OUTER APPLY)
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

PROMPT 11) Jerarquia geografica completa (CTE recursivo)
WITH geo (nivel, id_pais, id_provincia, id_canton, id_parroquia, nombre, path) AS (
  SELECT 1,
         pa.id_pais,
         NULL,
         NULL,
         NULL,
         pa.nombre,
         pa.nombre
  FROM pais pa
  UNION ALL
  SELECT 2,
         pr.id_pais,
         pr.id_provincia,
         NULL,
         NULL,
         pr.nombre,
         g.path || ' > ' || pr.nombre
  FROM provincia pr
  JOIN geo g ON g.nivel = 1 AND g.id_pais = pr.id_pais
  UNION ALL
  SELECT 3,
         pr.id_pais,
         ca.id_provincia,
         ca.id_canton,
         NULL,
         ca.nombre,
         g.path || ' > ' || ca.nombre
  FROM canton ca
  JOIN provincia pr ON pr.id_provincia = ca.id_provincia
  JOIN geo g ON g.nivel = 2 AND g.id_provincia = pr.id_provincia
  UNION ALL
  SELECT 4,
         pr.id_pais,
         ca.id_provincia,
         pa.id_canton,
         pa.id_parroquia,
         pa.nombre,
         g.path || ' > ' || pa.nombre
  FROM parroquia pa
  JOIN canton ca ON ca.id_canton = pa.id_canton
  JOIN provincia pr ON pr.id_provincia = ca.id_provincia
  JOIN geo g ON g.nivel = 3 AND g.id_canton = ca.id_canton
)
SELECT nivel, path
FROM geo
ORDER BY path;

PROMPT 12) Pacientes con uso alto vs promedio (ratio z-score)
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
SELECT u.id_paciente,
       u.total_citas,
       ROUND((u.total_citas - s.avg_citas) / NULLIF(s.sd_citas, 0), 2) AS z_score
FROM uso u
CROSS JOIN stats s
ORDER BY z_score DESC NULLS LAST
FETCH FIRST 20 ROWS ONLY;

PROMPT 13) Sumarizacion por cubo de especialidad y estado
SELECT e.nombre AS especialidad,
       ec.codigo AS estado,
       COUNT(*) AS total
FROM cita c
JOIN medico_especialidad me ON me.id_medico = c.id_medico
JOIN especialidad e ON e.id_especialidad = me.id_especialidad
JOIN estado_cita ec ON ec.id_estado = c.id_estado
GROUP BY CUBE (e.nombre, ec.codigo)
ORDER BY especialidad, estado;

PROMPT 14) Consultas con resumen JSON de anamnesis
SELECT con.id_consulta,
       con.fecha_atencion,
       JSON_VALUE(con.anamnesis, '$.motivoPrincipal') AS motivo_principal
FROM consulta con
WHERE con.anamnesis IS NOT NULL
ORDER BY con.id_consulta;

PROMPT 15) Medicamentos mas recetados por mes (window + partition)
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
