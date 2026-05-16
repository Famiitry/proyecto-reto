const express = require('express');
const oracledb = require('oracledb');
const router = express.Router();
const { execute } = require('../db');

router.get('/', async (req, res, next) => {
  try {
    const { paciente, medico, estado, desde, hasta } = req.query;
    let sql = `
      SELECT c.id_cita, c.id_paciente, c.id_medico, c.id_consultorio, c.id_estado,
             c.fecha_hora, c.duracion_min, c.motivo_solicitud,
             pe_cod.codigo AS consultorio_cod,
             pec.nombres || ' ' || pec.apellidos AS paciente_nombre,
             pem.nombres || ' ' || pem.apellidos AS medico_nombre,
             ec.codigo AS estado_codigo, ec.descripcion AS estado_desc
      FROM cita c
      JOIN persona pec ON pec.id_persona = c.id_paciente
      JOIN persona pem ON pem.id_persona = c.id_medico
      JOIN consultorio pe_cod ON pe_cod.id_consultorio = c.id_consultorio
      JOIN estado_cita ec ON ec.id_estado = c.id_estado
      WHERE 1=1
    `;
    const binds = {};

    if (paciente) {
      sql += ' AND c.id_paciente = :paciente';
      binds.paciente = paciente;
    }
    if (medico) {
      sql += ' AND c.id_medico = :medico';
      binds.medico = medico;
    }
    if (estado) {
      sql += ' AND ec.codigo = :estado';
      binds.estado = estado;
    }
    if (desde) {
      sql += ' AND c.fecha_hora >= TO_TIMESTAMP(:desde, \'YYYY-MM-DD HH24:MI:SS\')';
      binds.desde = desde + ' 00:00:00';
    }
    if (hasta) {
      sql += ' AND c.fecha_hora <= TO_TIMESTAMP(:hasta, \'YYYY-MM-DD HH24:MI:SS\')';
      binds.hasta = hasta + ' 23:59:59';
    }

    sql += ' ORDER BY c.fecha_hora DESC FETCH FIRST 100 ROWS ONLY';

    const result = await execute(sql, binds);
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const sql = `
      SELECT c.id_cita, c.id_paciente, c.id_medico, c.id_consultorio, c.id_estado,
             c.fecha_hora, c.duracion_min, c.motivo_solicitud,
             co.codigo AS consultorio_cod,
             pec.nombres || ' ' || pec.apellidos AS paciente_nombre,
             pem.nombres || ' ' || pem.apellidos AS medico_nombre,
             ec.codigo AS estado_codigo, ec.descripcion AS estado_desc
      FROM cita c
      JOIN persona pec ON pec.id_persona = c.id_paciente
      JOIN persona pem ON pem.id_persona = c.id_medico
      JOIN consultorio co ON co.id_consultorio = c.id_consultorio
      JOIN estado_cita ec ON ec.id_estado = c.id_estado
      WHERE c.id_cita = :id
    `;
    const result = await execute(sql, { id: req.params.id });
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Cita no encontrada' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const { id_paciente, id_medico, id_consultorio, fecha_hora, duracion_min, motivo_solicitud } = req.body;

    const sql = `
      INSERT INTO cita (id_paciente, id_medico, id_consultorio, id_estado,
        fecha_hora, duracion_min, motivo_solicitud)
      VALUES (:id_paciente, :id_medico, :id_consultorio,
        (SELECT id_estado FROM estado_cita WHERE codigo='PROGRAMADA'),
        TO_TIMESTAMP(:fecha_hora, 'YYYY-MM-DD HH24:MI:SS'),
        :duracion_min, :motivo_solicitud)
      RETURNING id_cita INTO :id
    `;
    const result = await execute(sql, {
      id_paciente, id_medico, id_consultorio, fecha_hora,
      duracion_min: duracion_min || 30, motivo_solicitud,
      id: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
    });

    res.status(201).json({ id_cita: result.outBinds.id[0], message: 'Cita creada' });
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const { id_estado, fecha_hora, duracion_min, motivo_solicitud } = req.body;
    const binds = { id: req.params.id };
    const sets = [];

    if (id_estado !== undefined) {
      sets.push('c.id_estado = :id_estado');
      binds.id_estado = id_estado;
    }
    if (fecha_hora) {
      sets.push("c.fecha_hora = TO_TIMESTAMP(:fecha_hora, 'YYYY-MM-DD HH24:MI:SS')");
      binds.fecha_hora = fecha_hora;
    }
    if (duracion_min) {
      sets.push('c.duracion_min = :duracion_min');
      binds.duracion_min = duracion_min;
    }
    if (motivo_solicitud) {
      sets.push('c.motivo_solicitud = :motivo_solicitud');
      binds.motivo_solicitud = motivo_solicitud;
    }

    if (sets.length === 0) {
      return res.status(400).json({ error: 'No se proporcionaron campos para actualizar' });
    }

    await execute(`UPDATE cita c SET ${sets.join(', ')} WHERE c.id_cita = :id`, binds);
    res.json({ message: 'Cita actualizada' });
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await execute('DELETE FROM cita WHERE id_cita=:id', { id: req.params.id });
    res.json({ message: 'Cita eliminada' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
