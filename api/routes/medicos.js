const express = require('express');
const oracledb = require('oracledb');
const router = express.Router();
const { execute } = require('../db');

router.get('/', async (req, res, next) => {
  try {
    const { apellido, especialidad } = req.query;
    let sql = `
      SELECT pe.id_persona AS id_medico, pe.cedula, pe.nombres, pe.apellidos,
             pe.sexo, pe.email,
             m.num_registro, m.fecha_ingreso, m.titulo_principal
      FROM persona pe
      JOIN medico m ON pe.id_persona = m.id_medico
    `;
    const binds = {};
    const conditions = [];

    if (apellido) {
      conditions.push("UPPER(pe.apellidos) LIKE UPPER(:apellido)");
      binds.apellido = '%' + apellido + '%';
    }
    if (especialidad) {
      sql += `
        JOIN medico_especialidad me ON m.id_medico = me.id_medico
        JOIN especialidad e ON me.id_especialidad = e.id_especialidad
      `;
      conditions.push("UPPER(e.nombre) LIKE UPPER(:especialidad)");
      binds.especialidad = '%' + especialidad + '%';
    }

    if (conditions.length) {
      sql += ' WHERE ' + conditions.join(' AND ');
    }
    sql += ' ORDER BY pe.apellidos, pe.nombres';

    const result = await execute(sql, binds);
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const sql = `
      SELECT pe.id_persona AS id_medico, pe.cedula, pe.nombres, pe.apellidos,
             pe.sexo, pe.email,
             m.num_registro, m.fecha_ingreso, m.titulo_principal
      FROM persona pe
      JOIN medico m ON pe.id_persona = m.id_medico
      WHERE m.id_medico = :id
    `;
    const result = await execute(sql, { id: req.params.id });
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Médico no encontrado' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    next(err);
  }
});

router.get('/:id/especialidades', async (req, res, next) => {
  try {
    const sql = `
      SELECT e.id_especialidad, e.nombre, e.descripcion,
             me.fecha_certif, me.institucion
      FROM medico_especialidad me
      JOIN especialidad e ON me.id_especialidad = e.id_especialidad
      WHERE me.id_medico = :id
      ORDER BY e.nombre
    `;
    const result = await execute(sql, { id: req.params.id });
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const { cedula, nombres, apellidos, fecha_nacimiento, sexo, email,
      num_registro, fecha_ingreso, titulo_principal } = req.body;

    const sqlPersona = `
      INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email)
      VALUES (:cedula, :nombres, :apellidos, TO_DATE(:fecha_nacimiento,'YYYY-MM-DD'), :sexo, :email)
      RETURNING id_persona INTO :id
    `;

    const result = await execute(sqlPersona, {
      cedula, nombres, apellidos, fecha_nacimiento, sexo, email,
      id: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
    });

    const idPersona = result.outBinds.id[0];
    await execute(`
      INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
      VALUES (:id, :num_registro, TO_DATE(:fecha_ingreso,'YYYY-MM-DD'), :titulo_principal)
    `, { id: idPersona, num_registro, fecha_ingreso, titulo_principal });

    res.status(201).json({ id_medico: idPersona, message: 'Médico creado' });
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const { cedula, nombres, apellidos, fecha_nacimiento, sexo, email,
      num_registro, titulo_principal } = req.body;

    await execute(`
      UPDATE persona SET cedula=:cedula, nombres=:nombres, apellidos=:apellidos,
        fecha_nacimiento=TO_DATE(:fecha_nacimiento,'YYYY-MM-DD'), sexo=:sexo, email=:email
      WHERE id_persona=:id
    `, { cedula, nombres, apellidos, fecha_nacimiento, sexo, email, id: req.params.id });

    await execute(`
      UPDATE medico SET num_registro=:num_registro, titulo_principal=:titulo_principal
      WHERE id_medico=:id
    `, { num_registro, titulo_principal, id: req.params.id });

    res.json({ message: 'Médico actualizado' });
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await execute('DELETE FROM persona WHERE id_persona=:id', { id: req.params.id });
    res.json({ message: 'Médico eliminado' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
