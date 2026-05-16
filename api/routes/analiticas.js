const express = require('express');
const router = express.Router();
const { execute } = require('../db');

// ============================================================
// GRUPO 1: MEDICOS Y ESPECIALIDADES
// ============================================================

// 1.1 Medicos con mas citas (ranking)
router.get('/medicos/citas-rank', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_medicos_citas_rank');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// 1.2 Distribucion de citas por especialidad (GROUPING SETS)
router.get('/medicos/citas-especialidad', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_citas_especialidad');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// 1.3 Diagnosticos mas frecuentes por medico (DENSE_RANK)
router.get('/medicos/diagnosticos-rank', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_medicos_diagnosticos_rank');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// 1.4 Resumen por especialidad y estado (CUBE)
router.get('/medicos/especialidad-estado', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_especialidad_estado');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// ============================================================
// GRUPO 2: CITAS
// ============================================================

// 2.1 Citas por estado y mes (ROLLUP)
router.get('/citas/citas-mes', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_citas_mes');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// 2.2 Promedio movil de 7 dias de citas diarias
router.get('/citas/promedio-7d', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_citas_promedio_7d');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// 2.3 Citas por estado (PIVOT)
router.get('/citas/estado-pivot', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_citas_estado_pivot');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// 2.4 Citas por estado totales
router.get('/citas/estado-total', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_citas_estado_total');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// ============================================================
// GRUPO 3: PACIENTES
// ============================================================

// 3.1 Pacientes con mayor tiempo de espera
router.get('/pacientes/espera', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_pacientes_espera');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// 3.2 Brechas maximas entre citas (LAG)
router.get('/pacientes/brechas', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_pacientes_brechas');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// 3.3 Ultima consulta por paciente (OUTER APPLY)
router.get('/pacientes/ultima-consulta', async (req, res, next) => {
  try {
    const { nombre } = req.query;
    if (nombre) {
      const result = await execute(
        "SELECT * FROM v_pacientes_ultima_consulta WHERE UPPER(paciente) LIKE UPPER(:nombre)",
        { nombre: '%' + nombre + '%' }
      );
      return res.json(result.rows);
    }
    const result = await execute('SELECT * FROM v_pacientes_ultima_consulta');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// 3.4 Pacientes con uso alto vs promedio (z-score)
router.get('/pacientes/zscore', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_pacientes_zscore');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// 3.5 Top alergias por categoria y severidad
router.get('/pacientes/alergias-rank', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_alergias_rank');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// 3.6 Pacientes con alergias severas
router.get('/pacientes/alergias-severas', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_pacientes_alergias_severas');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// ============================================================
// GRUPO 4: CONSULTAS CLINICAS
// ============================================================

// 4.1 Consultas con resumen JSON de anamnesis
router.get('/consultas/resumen', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_consultas_resumen');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// 4.2 Diagnosticos frecuentes
router.get('/consultas/diagnosticos-frecuentes', async (req, res, next) => {
  try {
    const { limite } = req.query;
    const result = await execute(
      'SELECT * FROM v_diagnosticos_frecuentes FETCH FIRST :limite ROWS ONLY',
      { limite: limite || 10 }
    );
    res.json(result.rows);
  } catch (err) { next(err); }
});

// ============================================================
// GRUPO 5: RECETAS Y MEDICAMENTOS
// ============================================================

// 5.1 Medicamentos mas recetados por mes
router.get('/recetas/medicamentos-mas-recetados', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_medicamentos_recetados');
    res.json(result.rows);
  } catch (err) { next(err); }
});

// ============================================================
// DASHBOARD
// ============================================================

// Totales para el dashboard
router.get('/dashboard', async (req, res, next) => {
  try {
    const result = await execute('SELECT * FROM v_dashboard');
    res.json(result.rows[0]);
  } catch (err) { next(err); }
});

// Citas por medico agregado
router.get('/citas-por-medico', async (req, res, next) => {
  try {
    const { desde, hasta } = req.query;
    let sql = 'SELECT * FROM v_citas_por_medico';
    const binds = {};

    if (desde || hasta) {
      sql = `
        SELECT c.id_medico,
               pem.nombres || ' ' || pem.apellidos AS medico,
               COUNT(*) AS total_citas
        FROM cita c
        JOIN persona pem ON pem.id_persona = c.id_medico
        WHERE 1=1
      `;
      if (desde) {
        sql += " AND c.fecha_hora >= TO_TIMESTAMP(:desde, 'YYYY-MM-DD HH24:MI:SS')";
        binds.desde = desde + ' 00:00:00';
      }
      if (hasta) {
        sql += " AND c.fecha_hora <= TO_TIMESTAMP(:hasta, 'YYYY-MM-DD HH24:MI:SS')";
        binds.hasta = hasta + ' 23:59:59';
      }
      sql += ' GROUP BY c.id_medico, pem.nombres, pem.apellidos ORDER BY total_citas DESC';
    }

    const result = await execute(sql, binds);
    res.json(result.rows);
  } catch (err) { next(err); }
});

module.exports = router;
