const express = require('express');
const oracledb = require('oracledb');
const router = express.Router();
const { execute } = require('../db');

router.get('/', async (req, res, next) => {
  try {
    const { paciente } = req.query;
    let sql = `
      SELECT con.id_consulta, con.id_cita, con.fecha_atencion,
             con.motivo_consulta, con.enfermedad_actual, con.examen_fisico,
             con.plan_tratamiento,
             c.id_paciente, c.id_medico,
             pec.nombres || ' ' || pec.apellidos AS paciente_nombre,
             pem.nombres || ' ' || pem.apellidos AS medico_nombre
      FROM consulta con
      JOIN cita c ON con.id_cita = c.id_cita AND con.fecha_cita = c.fecha_hora
      JOIN persona pec ON pec.id_persona = c.id_paciente
      JOIN persona pem ON pem.id_persona = c.id_medico
      WHERE 1=1
    `;
    const binds = {};

    if (paciente) {
      sql += ' AND c.id_paciente = :paciente';
      binds.paciente = paciente;
    }

    sql += ' ORDER BY con.fecha_atencion DESC FETCH FIRST 100 ROWS ONLY';

    const result = await execute(sql, binds);
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const sql = `
      SELECT con.id_consulta, con.id_cita, con.fecha_atencion,
             con.motivo_consulta, con.enfermedad_actual, con.examen_fisico,
             con.plan_tratamiento, con.anamnesis,
             c.id_paciente, c.id_medico,
             pec.nombres || ' ' || pec.apellidos AS paciente_nombre,
             pem.nombres || ' ' || pem.apellidos AS medico_nombre
      FROM consulta con
      JOIN cita c ON con.id_cita = c.id_cita AND con.fecha_cita = c.fecha_hora
      JOIN persona pec ON pec.id_persona = c.id_paciente
      JOIN persona pem ON pem.id_persona = c.id_medico
      WHERE con.id_consulta = :id
    `;
    const result = await execute(sql, { id: req.params.id });
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Consulta no encontrada' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    next(err);
  }
});

router.get('/:id/diagnosticos', async (req, res, next) => {
  try {
    const sql = `
      SELECT cd.codigo_cie, cd.tipo, cd.observacion,
             cie.descripcion, cie.capitulo
      FROM consulta_diagnostico cd
      JOIN cie10 cie ON cd.codigo_cie = cie.codigo
      WHERE cd.id_consulta = :id
      ORDER BY cd.tipo
    `;
    const result = await execute(sql, { id: req.params.id });
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.get('/:id/signos', async (req, res, next) => {
  try {
    const sql = `
      SELECT sv.presion_sistolica, sv.presion_diastolica,
             sv.frec_cardiaca, sv.frec_respiratoria,
             sv.temperatura, sv.saturacion_o2, sv.peso_kg, sv.talla_cm
      FROM signos_vitales sv
      WHERE sv.id_consulta = :id
    `;
    const result = await execute(sql, { id: req.params.id });
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Signos vitales no encontrados' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    next(err);
  }
});

router.get('/:id/recetas', async (req, res, next) => {
  try {
    const sql = `
      SELECT r.id_receta, r.fecha_emision, r.validez_dias, r.observaciones,
             rd.id_medicamento, rd.dosis, rd.frecuencia, rd.duracion_dias, rd.indicaciones,
             m.nombre_generico, m.concentracion, m.forma_farma, m.via_admin
      FROM receta r
      JOIN receta_detalle rd ON r.id_receta = rd.id_receta
      JOIN medicamento m ON rd.id_medicamento = m.id_medicamento
      WHERE r.id_consulta = :id
      ORDER BY r.id_receta, rd.id_medicamento
    `;
    const result = await execute(sql, { id: req.params.id });
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const { id_cita, motivo_consulta, enfermedad_actual, examen_fisico,
      plan_tratamiento, anamnesis } = req.body;

    const sql = `
      INSERT INTO consulta (id_cita, fecha_cita, motivo_consulta, enfermedad_actual,
        examen_fisico, plan_tratamiento, anamnesis)
      SELECT :id_cita, c.fecha_hora, :motivo_consulta, :enfermedad_actual,
        :examen_fisico, :plan_tratamiento, :anamnesis
      FROM cita c
      WHERE c.id_cita = :id_cita
      RETURNING id_consulta INTO :id
    `;
    const result = await execute(sql, {
      id_cita, motivo_consulta, enfermedad_actual, examen_fisico, plan_tratamiento,
      anamnesis: anamnesis || '{}',
      id: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
    });

    res.status(201).json({ id_consulta: result.outBinds.id[0], message: 'Consulta creada' });
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const { motivo_consulta, enfermedad_actual, examen_fisico, plan_tratamiento } = req.body;
    const binds = { id: req.params.id };
    const sets = [];

    if (motivo_consulta) { sets.push('motivo_consulta = :motivo_consulta'); binds.motivo_consulta = motivo_consulta; }
    if (enfermedad_actual) { sets.push('enfermedad_actual = :enfermedad_actual'); binds.enfermedad_actual = enfermedad_actual; }
    if (examen_fisico)     { sets.push('examen_fisico = :examen_fisico');       binds.examen_fisico = examen_fisico; }
    if (plan_tratamiento)  { sets.push('plan_tratamiento = :plan_tratamiento');  binds.plan_tratamiento = plan_tratamiento; }

    if (sets.length === 0) {
      return res.status(400).json({ error: 'No se proporcionaron campos para actualizar' });
    }

    await execute(`UPDATE consulta SET ${sets.join(', ')} WHERE id_consulta = :id`, binds);
    res.json({ message: 'Consulta actualizada' });
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await execute('DELETE FROM consulta WHERE id_consulta=:id', { id: req.params.id });
    res.json({ message: 'Consulta eliminada' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
