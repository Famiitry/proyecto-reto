const express = require('express');
const oracledb = require('oracledb');
const router = express.Router();
const { execute } = require('../db');

router.get('/', async (req, res, next) => {
  try {
    const { apellido, cedula } = req.query;
    let sql = `
      SELECT pe.id_persona AS id_paciente, pe.cedula, pe.nombres, pe.apellidos,
             pe.fecha_nacimiento, pe.sexo, pe.email,
             pa.historia_clinica, pa.tipo_sangre, pa.factor_rh,
             pa.ocupacion, pa.estado_civil,
             pa.contacto_emergencia_nombre, pa.contacto_emergencia_telefono
      FROM persona pe
      JOIN paciente pa ON pe.id_persona = pa.id_paciente
      WHERE 1=1
    `;
    const binds = {};

    if (apellido) {
      sql += ' AND UPPER(pe.apellidos) LIKE UPPER(:apellido)';
      binds.apellido = '%' + apellido + '%';
    }
    if (cedula) {
      sql += ' AND pe.cedula = :cedula';
      binds.cedula = cedula;
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
      SELECT pe.id_persona AS id_paciente, pe.cedula, pe.nombres, pe.apellidos,
             pe.fecha_nacimiento, pe.sexo, pe.email,
             pa.historia_clinica, pa.tipo_sangre, pa.factor_rh,
             pa.ocupacion, pa.estado_civil,
             pa.contacto_emergencia_nombre, pa.contacto_emergencia_telefono
      FROM persona pe
      JOIN paciente pa ON pe.id_persona = pa.id_paciente
      WHERE pa.id_paciente = :id
    `;
    const result = await execute(sql, { id: req.params.id });
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Paciente no encontrado' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const {
      cedula, nombres, apellidos, fecha_nacimiento, sexo, email,
      historia_clinica, tipo_sangre, factor_rh, ocupacion, estado_civil,
      contacto_emergencia_nombre, contacto_emergencia_telefono,
    } = req.body;

    const sqlPersona = `
      INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email)
      VALUES (:cedula, :nombres, :apellidos, TO_DATE(:fecha_nacimiento, 'YYYY-MM-DD'), :sexo, :email)
      RETURNING id_persona INTO :id
    `;

    const result = await execute(sqlPersona, {
      cedula, nombres, apellidos, fecha_nacimiento, sexo, email,
      id: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
    });

    const idPersona = result.outBinds.id[0];
    const sqlPaciente = `
      INSERT INTO paciente (id_paciente, historia_clinica, tipo_sangre, factor_rh,
        ocupacion, estado_civil, contacto_emergencia_nombre, contacto_emergencia_telefono)
      VALUES (:id, :historia_clinica, :tipo_sangre, :factor_rh,
        :ocupacion, :estado_civil, :contacto_emergencia_nombre, :contacto_emergencia_telefono)
    `;
    await execute(sqlPaciente, {
      id: idPersona, historia_clinica, tipo_sangre, factor_rh,
      ocupacion, estado_civil, contacto_emergencia_nombre, contacto_emergencia_telefono,
    });

    res.status(201).json({ id_paciente: idPersona, message: 'Paciente creado' });
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const { cedula, nombres, apellidos, fecha_nacimiento, sexo, email,
      tipo_sangre, factor_rh, ocupacion, estado_civil,
      contacto_emergencia_nombre, contacto_emergencia_telefono } = req.body;

    const sqlPersona = `
      UPDATE persona SET cedula=:cedula, nombres=:nombres, apellidos=:apellidos,
        fecha_nacimiento=TO_DATE(:fecha_nacimiento,'YYYY-MM-DD'), sexo=:sexo, email=:email
      WHERE id_persona=:id
    `;
    await execute(sqlPersona, { cedula, nombres, apellidos, fecha_nacimiento, sexo, email, id: req.params.id });

    const sqlPaciente = `
      UPDATE paciente SET tipo_sangre=:tipo_sangre, factor_rh=:factor_rh,
        ocupacion=:ocupacion, estado_civil=:estado_civil,
        contacto_emergencia_nombre=:contacto_emergencia_nombre,
        contacto_emergencia_telefono=:contacto_emergencia_telefono
      WHERE id_paciente=:id
    `;
    await execute(sqlPaciente, { tipo_sangre, factor_rh, ocupacion, estado_civil,
      contacto_emergencia_nombre, contacto_emergencia_telefono, id: req.params.id });

    res.json({ message: 'Paciente actualizado' });
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await execute('DELETE FROM persona WHERE id_persona=:id', { id: req.params.id });
    res.json({ message: 'Paciente eliminado' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
