const express = require('express');
const router = express.Router();
const { execute } = require('../db');

router.get('/historia/:idPaciente', async (req, res, next) => {
  try {
    const sql = `
      SELECT id_consulta, fecha_atencion, medico, diagnosticos
      FROM v_historia_paciente
      WHERE id_paciente = :id
      ORDER BY fecha_atencion DESC
    `;
    const result = await execute(sql, { id: req.params.idPaciente });
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'No se encontraron consultas para este paciente' });
    }
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.get('/citas-por-medico', async (req, res, next) => {
  try {
    const { desde, hasta } = req.query;
    let sql = `
      SELECT c.id_medico,
             pem.nombres || ' ' || pem.apellidos AS medico,
             COUNT(*) AS total_citas
      FROM cita c
      JOIN persona pem ON pem.id_persona = c.id_medico
      WHERE 1=1
    `;
    const binds = {};

    if (desde) {
      sql += ' AND c.fecha_hora >= TO_TIMESTAMP(:desde, \'YYYY-MM-DD HH24:MI:SS\')';
      binds.desde = desde + ' 00:00:00';
    }
    if (hasta) {
      sql += ' AND c.fecha_hora <= TO_TIMESTAMP(:hasta, \'YYYY-MM-DD HH24:MI:SS\')';
      binds.hasta = hasta + ' 23:59:59';
    }

    sql += ' GROUP BY c.id_medico, pem.nombres, pem.apellidos ORDER BY total_citas DESC';

    const result = await execute(sql, binds);
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.get('/diagnosticos-frecuentes', async (req, res, next) => {
  try {
    const { limite } = req.query;
    const sql = `
      SELECT cd.codigo_cie, cie.descripcion, COUNT(*) AS total_diagnosticos
      FROM consulta_diagnostico cd
      JOIN cie10 cie ON cd.codigo_cie = cie.codigo
      GROUP BY cd.codigo_cie, cie.descripcion
      ORDER BY total_diagnosticos DESC
      FETCH FIRST :limite ROWS ONLY
    `;
    const result = await execute(sql, { limite: limite || 10 });
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.get('/citas-por-estado', async (req, res, next) => {
  try {
    const sql = `
      SELECT ec.codigo AS estado, ec.descripcion, COUNT(*) AS total
      FROM cita c
      JOIN estado_cita ec ON c.id_estado = ec.id_estado
      GROUP BY ec.codigo, ec.descripcion
      ORDER BY total DESC
    `;
    const result = await execute(sql);
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.get('/pacientes-alergias-severas', async (req, res, next) => {
  try {
    const sql = `
      SELECT p.id_paciente,
             per.nombres || ' ' || per.apellidos AS paciente,
             a.nombre AS alergeno, a.categoria, pa.severidad
      FROM paciente_alergia pa
      JOIN paciente p ON pa.id_paciente = p.id_paciente
      JOIN persona per ON per.id_persona = p.id_paciente
      JOIN alergeno a ON pa.id_alergeno = a.id_alergeno
      WHERE pa.severidad IN ('SEVERA', 'ANAFILACTICA')
      ORDER BY pa.severidad, per.apellidos
    `;
    const result = await execute(sql);
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
