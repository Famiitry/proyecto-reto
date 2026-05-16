-- =====================================================================
-- JSON DUALITY VIEWS: GESTION_MEDICA
-- Oracle 23ai: vistas duales que exponen datos relacionales como JSON
-- con soporte completo CRUD (INSERT, UPDATE, DELETE) via API REST
-- =====================================================================
-- Ejecutar con usuario con permisos CREATE VIEW sobre el esquema

-- ---------------------------------------------------------------------
-- 1. DUALITY VIEW: PACIENTE (con citas y alergias anidadas)
-- ---------------------------------------------------------------------
CREATE OR REPLACE JSON DUALITY VIEW dv_paciente AS
SELECT JSON {
  _id : p.ID_PACIENTE,
  cedula : per.CEDULA,
  nombres : per.NOMBRES,
  apellidos : per.APELLIDOS,
  fecha_nacimiento : per.FECHA_NACIMIENTO,
  sexo : per.SEXO,
  email : per.EMAIL,
  historia_clinica : p.HISTORIA_CLINICA,
  tipo_sangre : p.TIPO_SANGRE,
  factor_rh : p.FACTOR_RH,
  ocupacion : p.OCUPACION,
  estado_civil : p.ESTADO_CIVIL,
  contacto_emergencia : {
    nombre : p.CONTACTO_EMERGENCIA_NOMBRE,
    telefono : p.CONTACTO_EMERGENCIA_TELEFONO
  },
  alergias : [
    SELECT JSON {
      alergeno : a.NOMBRE,
      categoria : a.CATEGORIA,
      severidad : pa.SEVERIDAD,
      fecha_deteccion : pa.FECHA_DETECCION,
      observaciones : pa.OBSERVACIONES
    }
    FROM paciente_alergia pa WITH INSERT UPDATE DELETE
    JOIN alergeno a ON a.ID_ALERGENO = pa.ID_ALERGENO
    WHERE pa.ID_PACIENTE = p.ID_PACIENTE
  ]
}
FROM paciente p WITH INSERT UPDATE DELETE
JOIN persona per ON per.ID_PERSONA = p.ID_PACIENTE;

-- ---------------------------------------------------------------------
-- 2. DUALITY VIEW: CITA (con paciente, medico y consultorio)
-- ---------------------------------------------------------------------
CREATE OR REPLACE JSON DUALITY VIEW dv_cita AS
SELECT JSON {
  _id : c.ID_CITA,
  fecha_hora : c.FECHA_HORA,
  duracion_min : c.DURACION_MIN,
  motivo_solicitud : c.MOTIVO_SOLICITUD,
  estado : {
    codigo : ec.CODIGO,
    descripcion : ec.DESCRIPCION
  },
  paciente : {
    _id : per_pac.ID_PERSONA,
    cedula : per_pac.CEDULA,
    nombre : per_pac.NOMBRES || ' ' || per_pac.APELLIDOS
  },
  medico : {
    _id : per_med.ID_PERSONA,
    cedula : per_med.CEDULA,
    nombre : per_med.NOMBRES || ' ' || per_med.APELLIDOS,
    registro : m.NUM_REGISTRO
  },
  consultorio : {
    codigo : co.CODIGO,
    piso : co.PISO,
    descripcion : co.DESCRIPCION
  }
}
FROM cita c WITH INSERT UPDATE DELETE
JOIN estado_cita ec ON ec.ID_ESTADO = c.ID_ESTADO
JOIN paciente p ON p.ID_PACIENTE = c.ID_PACIENTE
JOIN persona per_pac ON per_pac.ID_PERSONA = p.ID_PACIENTE
JOIN medico m ON m.ID_MEDICO = c.ID_MEDICO
JOIN persona per_med ON per_med.ID_PERSONA = m.ID_MEDICO
JOIN consultorio co ON co.ID_CONSULTORIO = c.ID_CONSULTORIO;

-- ---------------------------------------------------------------------
-- 3. DUALITY VIEW: CONSULTA (con diagnostico, signos y recetas anidadas)
-- ---------------------------------------------------------------------
CREATE OR REPLACE JSON DUALITY VIEW dv_consulta AS
SELECT JSON {
  _id : con.ID_CONSULTA,
  fecha_atencion : con.FECHA_ATENCION,
  motivo_consulta : con.MOTIVO_CONSULTA,
  enfermedad_actual : con.ENFERMEDAD_ACTUAL,
  examen_fisico : con.EXAMEN_FISICO,
  plan_tratamiento : con.PLAN_TRATAMIENTO,
  anamnesis : con.ANAMNESIS,
  paciente : {
    _id : per_pac.ID_PERSONA,
    nombre : per_pac.NOMBRES || ' ' || per_pac.APELLIDOS
  },
  medico : {
    _id : per_med.ID_PERSONA,
    nombre : per_med.NOMBRES || ' ' || per_med.APELLIDOS
  },
  diagnosticos : [
    SELECT JSON {
      codigo_cie : cd.CODIGO_CIE,
      descripcion : cie.DESCRIPCION,
      tipo : cd.TIPO,
      observacion : cd.OBSERVACION
    }
    FROM consulta_diagnostico cd WITH INSERT UPDATE DELETE
    JOIN cie10 cie ON cie.CODIGO = cd.CODIGO_CIE
    WHERE cd.ID_CONSULTA = con.ID_CONSULTA
  ],
  signos_vitales : [
    SELECT JSON {
      presion_sistolica : sv.PRESION_SISTOLICA,
      presion_diastolica : sv.PRESION_DIASTOLICA,
      frec_cardiaca : sv.FREC_CARDIACA,
      frec_respiratoria : sv.FREC_RESPIRATORIA,
      temperatura : sv.TEMPERATURA,
      saturacion_o2 : sv.SATURACION_O2,
      peso_kg : sv.PESO_KG,
      talla_cm : sv.TALLA_CM
    }
    FROM signos_vitales sv WITH INSERT UPDATE DELETE
    WHERE sv.ID_CONSULTA = con.ID_CONSULTA
  ],
  recetas : [
    SELECT JSON {
      _id : r.ID_RECETA,
      fecha_emision : r.FECHA_EMISION,
      validez_dias : r.VALIDEZ_DIAS,
      medicamentos : [
        SELECT JSON {
          medicamento : med.NOMBRE_GENERICO,
          concentracion : med.CONCENTRACION,
          forma : med.FORMA_FARMA,
          dosis : rd.DOSIS,
          frecuencia : rd.FRECUENCIA,
          duracion_dias : rd.DURACION_DIAS,
          indicaciones : rd.INDICACIONES
        }
        FROM receta_detalle rd WITH INSERT UPDATE DELETE
        JOIN medicamento med ON med.ID_MEDICAMENTO = rd.ID_MEDICAMENTO
        WHERE rd.ID_RECETA = r.ID_RECETA
      ]
    }
    FROM receta r WITH INSERT UPDATE DELETE
    WHERE r.ID_CONSULTA = con.ID_CONSULTA
  ]
}
FROM consulta con WITH INSERT UPDATE DELETE
JOIN cita c ON c.ID_CITA = con.ID_CITA AND c.FECHA_HORA = con.FECHA_CITA
JOIN persona per_pac ON per_pac.ID_PERSONA = c.ID_PACIENTE
JOIN persona per_med ON per_med.ID_PERSONA = c.ID_MEDICO;
