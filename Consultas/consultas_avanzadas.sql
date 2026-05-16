-- Consultas avanzadas para el esquema GESTION_MEDICA
-- Ejecutar en SQL*Plus/SQLcl para ver tiempos por consulta
SET TIMING ON
SET PAGESIZE 200
SET LINESIZE 200
SET TAB OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

PROMPT ============================================================
PROMPT GRUPO 1: MEDICOS Y ESPECIALIDADES
PROMPT ============================================================

PROMPT 1.1) Medicos con mas citas (ranking)
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

PROMPT 1.2) Distribucion de citas por especialidad (GROUPING SETS)
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

PROMPT 1.3) Diagnosticos mas frecuentes por medico (DENSE_RANK) //No devuelve resultados por falta de datos en consulta_diagnostico, pero la consulta es correcta para el objetivo planteado
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

PROMPT 1.4) Resumen por especialidad y estado (CUBE)
SELECT e.nombre AS especialidad,
       ec.codigo AS estado,
       COUNT(*) AS total
FROM cita c
JOIN medico_especialidad me ON me.id_medico = c.id_medico
JOIN especialidad e ON e.id_especialidad = me.id_especialidad
JOIN estado_cita ec ON ec.id_estado = c.id_estado
GROUP BY CUBE (e.nombre, ec.codigo)
ORDER BY especialidad, estado;

PROMPT ============================================================
PROMPT GRUPO 2: CITAS
PROMPT ============================================================

PROMPT 2.1) Citas por estado y mes con ROLLUP
SELECT TO_CHAR(TRUNC(CAST(c.fecha_hora AS DATE), 'MM'), 'YYYY-MM') AS mes,
       e.codigo AS estado,
       COUNT(*) AS total_citas
FROM cita c
JOIN estado_cita e ON e.id_estado = c.id_estado
GROUP BY ROLLUP (TRUNC(CAST(c.fecha_hora AS DATE), 'MM'), e.codigo)
ORDER BY mes, estado;


PROMPT 2.2) Citas por estado (PIVOT)
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

PROMPT 2.3) Listado detallado de citas
SELECT c.id_cita,
       TO_CHAR(c.fecha_hora, 'DD Mon, HH24:MI', 'NLS_DATE_LANGUAGE=SPANISH') AS fecha_hora,
       pp.nombres || ' ' || pp.apellidos AS paciente,
       pm.nombres || ' ' || pm.apellidos AS medico,
       co.codigo AS consultorio,
       e.nombre AS especialidad,
       ec.codigo AS estado
FROM cita c
JOIN persona pp ON pp.id_persona = c.id_paciente
JOIN persona pm ON pm.id_persona = c.id_medico
JOIN consultorio co ON co.id_consultorio = c.id_consultorio
JOIN medico_especialidad me ON me.id_medico = c.id_medico
JOIN especialidad e ON e.id_especialidad = me.id_especialidad
JOIN estado_cita ec ON ec.id_estado = c.id_estado
ORDER BY c.fecha_hora DESC;

PROMPT ============================================================
PROMPT GRUPO 3: PACIENTES
PROMPT ============================================================

PROMPT 3.1) Pacientes con mayor tiempo de espera entre cita y atencion
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
  SELECT e.id_paciente,
         p.apellidos || ', ' || p.nombres AS paciente,
         ROUND(AVG(e.espera_min), 2) AS espera_prom_min,
         PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY e.espera_min) AS p95_espera_min
  FROM espera e
  JOIN persona p ON p.id_persona = e.id_paciente
  GROUP BY e.id_paciente, p.apellidos, p.nombres
  ORDER BY espera_prom_min DESC
)
FETCH FIRST 20 ROWS ONLY;

PROMPT 3.2) Brechas maximas entre citas por paciente (LAG)
WITH citas_paciente AS (
  SELECT id_paciente,
         fecha_hora,
         LAG(fecha_hora) OVER (PARTITION BY id_paciente ORDER BY fecha_hora) AS fecha_prev
  FROM cita
)
SELECT cp.id_paciente,
       p.apellidos || ', ' || p.nombres AS paciente,
       MAX(CAST(cp.fecha_hora AS DATE) - CAST(cp.fecha_prev AS DATE)) AS max_gap_dias
FROM citas_paciente cp
JOIN persona p ON p.id_persona = cp.id_paciente
WHERE cp.fecha_prev IS NOT NULL
GROUP BY cp.id_paciente, p.apellidos, p.nombres
ORDER BY max_gap_dias DESC
FETCH FIRST 20 ROWS ONLY;

PROMPT 3.3) Ultima consulta por paciente (OUTER APPLY)
ACCEPT nombre_paciente CHAR PROMPT 'Ingrese nombre o apellido del paciente: '
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
WHERE UPPER(p.nombres || ' ' || p.apellidos) LIKE '%' || UPPER('&nombre_paciente') || '%'
ORDER BY p.id_persona;

PROMPT 3.4) Pacientes con uso alto vs promedio (z-score)
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

PROMPT 3.5) Top alergias por categoria y severidad (window + partition)
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

PROMPT 3.6) Listado de pacientes
SELECT pa.historia_clinica AS expediente,
       p.nombres || ' ' || p.apellidos AS paciente,
       p.cedula,
       TO_CHAR(MAX(c.fecha_hora), 'DD Mon, YYYY', 'NLS_DATE_LANGUAGE=SPANISH') AS ultima_cita,
       CASE
         WHEN SUM(CASE
                    WHEN ec.codigo = 'PROGRAMADA'
                     AND c.fecha_hora > SYSDATE THEN 1
                    ELSE 0
                  END) > 0 THEN 'Pendiente'
         WHEN MAX(c.fecha_hora) >= ADD_MONTHS(TRUNC(SYSDATE), -12) THEN 'Al dia'
         WHEN MAX(c.fecha_hora) IS NULL THEN 'Sin citas'
         ELSE 'Inactivo'
       END AS estado
FROM paciente pa
JOIN persona p ON p.id_persona = pa.id_paciente
LEFT JOIN cita c ON c.id_paciente = pa.id_paciente
LEFT JOIN estado_cita ec ON ec.id_estado = c.id_estado
GROUP BY pa.historia_clinica,
         p.nombres,
         p.apellidos,
         p.cedula
ORDER BY paciente;

PROMPT ============================================================
PROMPT GRUPO 4: CONSULTAS CLINICAS
PROMPT ============================================================

PROMPT 4.1) Consultas con resumen JSON de anamnesis
SELECT con.id_consulta,
       con.fecha_atencion,
       JSON_VALUE(con.anamnesis, '$.motivoPrincipal') AS motivo_principal
FROM consulta con
WHERE con.anamnesis IS NOT NULL
ORDER BY con.id_consulta;

PROMPT 4.2) Medicamentos mas recetados por mes (window + partition)
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

PROMPT 4.3) Ultima consulta (Uso de vistas)
SELECT id_consulta,
       TO_CHAR(fecha_atencion, 'DD Mon YYYY', 'NLS_DATE_LANGUAGE=SPANISH') AS fecha,
       paciente,
       estado
FROM v_consultas_recientes
WHERE :nombre IS NULL OR UPPER(paciente) LIKE '%' || UPPER(:nombre) || '%'
ORDER BY fecha_atencion DESC
OFFSET NVL(:offset,0) ROWS FETCH NEXT NVL(:limit,25) ROWS ONLY;


PROMPT 4.4) Ultima consulta (Uso de vistas)
SELECT id_paciente,
       cedula,
       paciente,
       id_consulta,
       fecha_atencion,
       motivo_consulta
FROM v_ultima_consulta_por_paciente
WHERE (:cedula IS NULL OR cedula = :cedula)
  AND (:nombre IS NULL OR UPPER(paciente) LIKE '%' || UPPER(:nombre) || '%')
ORDER BY fecha_atencion DESC;

PROMPT 4.5) Ultima consulta por numero de cedula de paciente (Uso de vistas)
SELECT id_paciente,
       cedula,
       paciente,
       id_consulta,
       fecha_atencion,
       motivo_consulta
FROM v_ultima_consulta_por_paciente
WHERE (:cedula IS NULL OR cedula = :cedula)
  AND (:nombre IS NULL OR UPPER(paciente) LIKE '%' || UPPER(:nombre) || '%')
ORDER BY fecha_atencion DESC;