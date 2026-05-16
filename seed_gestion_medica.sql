-- =====================================================================
-- SEED DATA: GESTION_MEDICA
-- Inserta ~50 registros por entidad principal respetando FKs y CHECKs
-- Orden: catálogos -> personas -> subtipos -> operacionales -> hijos
-- Motor: Oracle 19c+
-- =====================================================================
SET DEFINE OFF;
ALTER SESSION SET NLS_DATE_FORMAT      = 'YYYY-MM-DD';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

-- ---------------------------------------------------------------------
-- 1. CATÁLOGOS GEOGRÁFICOS
-- ---------------------------------------------------------------------
INSERT INTO pais (codigo_iso, nombre) VALUES ('ECU', 'Ecuador');
INSERT INTO pais (codigo_iso, nombre) VALUES ('COL', 'Colombia');
INSERT INTO pais (codigo_iso, nombre) VALUES ('PER', 'Perú');

INSERT INTO provincia (id_pais, nombre)
SELECT id_pais, 'Azuay' FROM pais WHERE codigo_iso = 'ECU';
INSERT INTO provincia (id_pais, nombre)
SELECT id_pais, 'Pichincha' FROM pais WHERE codigo_iso = 'ECU';
INSERT INTO provincia (id_pais, nombre)
SELECT id_pais, 'Guayas' FROM pais WHERE codigo_iso = 'ECU';
INSERT INTO provincia (id_pais, nombre)
SELECT id_pais, 'Cañar' FROM pais WHERE codigo_iso = 'ECU';
INSERT INTO provincia (id_pais, nombre)
SELECT id_pais, 'Loja' FROM pais WHERE codigo_iso = 'ECU';

INSERT INTO canton (id_provincia, nombre)
SELECT id_provincia, 'Cuenca' FROM provincia WHERE nombre = 'Azuay';
INSERT INTO canton (id_provincia, nombre)
SELECT id_provincia, 'Gualaceo' FROM provincia WHERE nombre = 'Azuay';
INSERT INTO canton (id_provincia, nombre)
SELECT id_provincia, 'Quito' FROM provincia WHERE nombre = 'Pichincha';
INSERT INTO canton (id_provincia, nombre)
SELECT id_provincia, 'Guayaquil' FROM provincia WHERE nombre = 'Guayas';
INSERT INTO canton (id_provincia, nombre)
SELECT id_provincia, 'Azogues' FROM provincia WHERE nombre = 'Cañar';
INSERT INTO canton (id_provincia, nombre)
SELECT id_provincia, 'Loja' FROM provincia WHERE nombre = 'Loja';

INSERT INTO parroquia (id_canton, nombre)
SELECT id_canton, 'El Sagrario' FROM canton WHERE nombre = 'Cuenca';
INSERT INTO parroquia (id_canton, nombre)
SELECT id_canton, 'San Sebastián' FROM canton WHERE nombre = 'Cuenca';
INSERT INTO parroquia (id_canton, nombre)
SELECT id_canton, 'Yanuncay' FROM canton WHERE nombre = 'Cuenca';
INSERT INTO parroquia (id_canton, nombre)
SELECT id_canton, 'Totoracocha' FROM canton WHERE nombre = 'Cuenca';
INSERT INTO parroquia (id_canton, nombre)
SELECT id_canton, 'El Vecino' FROM canton WHERE nombre = 'Cuenca';
INSERT INTO parroquia (id_canton, nombre)
SELECT id_canton, 'Gualaceo Centro' FROM canton WHERE nombre = 'Gualaceo';
INSERT INTO parroquia (id_canton, nombre)
SELECT id_canton, 'La Mariscal' FROM canton WHERE nombre = 'Quito';
INSERT INTO parroquia (id_canton, nombre)
SELECT id_canton, 'Tarqui' FROM canton WHERE nombre = 'Guayaquil';
INSERT INTO parroquia (id_canton, nombre)
SELECT id_canton, 'Azogues Centro' FROM canton WHERE nombre = 'Azogues';
INSERT INTO parroquia (id_canton, nombre)
SELECT id_canton, 'San Sebastián (Loja)' FROM canton WHERE nombre = 'Loja';

COMMIT;

-- ---------------------------------------------------------------------
-- 2. CATÁLOGOS DE NEGOCIO (especialidades, alérgenos, consultorios, estados, CIE-10, medicamentos)
-- ---------------------------------------------------------------------
INSERT INTO especialidad (nombre, descripcion) VALUES ('Medicina General',     'Atención primaria');
INSERT INTO especialidad (nombre, descripcion) VALUES ('Pediatría',            'Atención a niños');
INSERT INTO especialidad (nombre, descripcion) VALUES ('Cardiología',          'Sistema cardiovascular');
INSERT INTO especialidad (nombre, descripcion) VALUES ('Ginecología',          'Salud femenina');
INSERT INTO especialidad (nombre, descripcion) VALUES ('Dermatología',         'Piel y anexos');
INSERT INTO especialidad (nombre, descripcion) VALUES ('Traumatología',        'Sistema musculoesquelético');
INSERT INTO especialidad (nombre, descripcion) VALUES ('Endocrinología',       'Sistema endocrino');
INSERT INTO especialidad (nombre, descripcion) VALUES ('Neurología',           'Sistema nervioso');

INSERT INTO alergeno (nombre, categoria) VALUES ('Penicilina',     'MEDICAMENTO');
INSERT INTO alergeno (nombre, categoria) VALUES ('Ibuprofeno',     'MEDICAMENTO');
INSERT INTO alergeno (nombre, categoria) VALUES ('Maní',           'ALIMENTO');
INSERT INTO alergeno (nombre, categoria) VALUES ('Mariscos',       'ALIMENTO');
INSERT INTO alergeno (nombre, categoria) VALUES ('Polen',          'AMBIENTAL');
INSERT INTO alergeno (nombre, categoria) VALUES ('Ácaros',         'AMBIENTAL');
INSERT INTO alergeno (nombre, categoria) VALUES ('Pelo de gato',   'ANIMAL');
INSERT INTO alergeno (nombre, categoria) VALUES ('Látex',          'OTRO');

INSERT INTO consultorio (codigo, piso, descripcion) VALUES ('C-101', 1, 'Consultorio General 1');
INSERT INTO consultorio (codigo, piso, descripcion) VALUES ('C-102', 1, 'Consultorio General 2');
INSERT INTO consultorio (codigo, piso, descripcion) VALUES ('C-201', 2, 'Cardiología');
INSERT INTO consultorio (codigo, piso, descripcion) VALUES ('C-202', 2, 'Pediatría');
INSERT INTO consultorio (codigo, piso, descripcion) VALUES ('C-301', 3, 'Ginecología');
INSERT INTO consultorio (codigo, piso, descripcion) VALUES ('C-302', 3, 'Dermatología');
INSERT INTO consultorio (codigo, piso, descripcion) VALUES ('C-401', 4, 'Traumatología');
INSERT INTO consultorio (codigo, piso, descripcion) VALUES ('C-402', 4, 'Neurología');

INSERT INTO estado_cita (codigo, descripcion) VALUES ('PROGRAMADA',  'Cita agendada');
INSERT INTO estado_cita (codigo, descripcion) VALUES ('CONFIRMADA',  'Confirmada por paciente');
INSERT INTO estado_cita (codigo, descripcion) VALUES ('ATENDIDA',    'Consulta realizada');
INSERT INTO estado_cita (codigo, descripcion) VALUES ('CANCELADA',   'Cancelada');
INSERT INTO estado_cita (codigo, descripcion) VALUES ('NO_ASISTIO',  'Paciente no asistió');

INSERT INTO cie10 (codigo, descripcion, capitulo) VALUES ('J00',   'Rinofaringitis aguda (resfriado común)', 'X');
INSERT INTO cie10 (codigo, descripcion, capitulo) VALUES ('J02.9', 'Faringitis aguda no especificada',        'X');
INSERT INTO cie10 (codigo, descripcion, capitulo) VALUES ('I10',   'Hipertensión esencial primaria',          'IX');
INSERT INTO cie10 (codigo, descripcion, capitulo) VALUES ('E11',   'Diabetes mellitus tipo 2',                'IV');
INSERT INTO cie10 (codigo, descripcion, capitulo) VALUES ('K29.7', 'Gastritis no especificada',               'XI');
INSERT INTO cie10 (codigo, descripcion, capitulo) VALUES ('M54.5', 'Lumbago no especificado',                 'XIII');
INSERT INTO cie10 (codigo, descripcion, capitulo) VALUES ('R51',   'Cefalea',                                 'XVIII');
INSERT INTO cie10 (codigo, descripcion, capitulo) VALUES ('A09',   'Diarrea y gastroenteritis de origen infeccioso', 'I');
INSERT INTO cie10 (codigo, descripcion, capitulo) VALUES ('L20',   'Dermatitis atópica',                      'XII');
INSERT INTO cie10 (codigo, descripcion, capitulo) VALUES ('N39.0', 'Infección de vías urinarias',             'XIV');

INSERT INTO medicamento (nombre_generico, concentracion, forma_farma, via_admin, requiere_receta) VALUES ('Paracetamol',     '500 mg',  'Tableta',  'ORAL', 'N');
INSERT INTO medicamento (nombre_generico, concentracion, forma_farma, via_admin, requiere_receta) VALUES ('Ibuprofeno',      '400 mg',  'Tableta',  'ORAL', 'N');
INSERT INTO medicamento (nombre_generico, concentracion, forma_farma, via_admin, requiere_receta) VALUES ('Amoxicilina',     '500 mg',  'Cápsula',  'ORAL', 'S');
INSERT INTO medicamento (nombre_generico, concentracion, forma_farma, via_admin, requiere_receta) VALUES ('Losartán',        '50 mg',   'Tableta',  'ORAL', 'S');
INSERT INTO medicamento (nombre_generico, concentracion, forma_farma, via_admin, requiere_receta) VALUES ('Metformina',      '850 mg',  'Tableta',  'ORAL', 'S');
INSERT INTO medicamento (nombre_generico, concentracion, forma_farma, via_admin, requiere_receta) VALUES ('Omeprazol',       '20 mg',   'Cápsula',  'ORAL', 'N');
INSERT INTO medicamento (nombre_generico, concentracion, forma_farma, via_admin, requiere_receta) VALUES ('Loratadina',      '10 mg',   'Tableta',  'ORAL', 'N');
INSERT INTO medicamento (nombre_generico, concentracion, forma_farma, via_admin, requiere_receta) VALUES ('Salbutamol',      '100 mcg', 'Inhalador','INH',  'S');

COMMIT;

-- ---------------------------------------------------------------------
-- 3. PERSONAS (50 registros: ~15 médicos + ~35 pacientes)
-- ---------------------------------------------------------------------
-- Médicos (id_persona 1..15)
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000001','Carlos Andrés','Vásquez León','1975-03-12','M','c.vasquez@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000002','María Fernanda','Torres Pino','1980-07-21','F','m.torres@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000003','Luis Eduardo','Cabrera Mora','1972-11-05','M','l.cabrera@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000004','Andrea Paulina','Vintimilla Ortiz','1985-01-30','F','a.vintimilla@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000005','Diego Fernando','Salazar Crespo','1978-09-14','M','d.salazar@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000006','Patricia Lucía','Romero Vélez','1982-05-18','F','p.romero@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000007','Roberto Carlos','Astudillo Rivas','1970-02-09','M','r.astudillo@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000008','Verónica Isabel','Idrovo Bermeo','1983-08-22','F','v.idrovo@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000009','Marco Antonio','Peñafiel Cordero','1976-12-01','M','m.penafiel@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000010','Sofía Belén','Cordero Calle','1987-04-17','F','s.cordero@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000011','Juan Pablo','Encalada Sigüenza','1974-06-25','M','j.encalada@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000012','Daniela Cristina','Maldonado Quito','1986-10-11','F','d.maldonado@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000013','Esteban Mauricio','Brito Lema','1981-03-03','M','e.brito@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000014','Gabriela Mishelle','Ochoa Pesantez','1984-11-29','F','g.ochoa@hosp.ec');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0101000015','Pablo Sebastián','Jara Naranjo','1979-07-08','M','p.jara@hosp.ec');

-- Pacientes (id_persona 16..50)
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000016','Ana Lucía','Pérez Mosquera','1990-04-12','F','ana.perez@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000017','Jorge Luis','Quezada Tapia','1985-09-23','M','jorge.quezada@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000018','Mariana','Sangurima Loja','1995-02-14','F','mariana.s@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000019','Iván Andrés','Tenorio Cabrera','1988-12-05','M','ivan.t@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000020','Karla Stefanía','Mejía Ulloa','1992-06-18','F','karla.m@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000021','Fernando Javier','Bravo Sarmiento','1980-08-30','M','fernando.b@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000022','Lucía Esperanza','Yunga Pacheco','1975-01-07','F','lucia.y@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000023','Andrés Felipe','Inga Macancela','1998-11-19','M','andres.i@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000024','Paola Andrea','Galarza Fernández','1991-03-25','F','paola.g@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000025','César Augusto','Vivar Toledo','1965-05-02','M','cesar.v@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000026','Elena María','Cárdenas Rojas','1972-10-16','F','elena.c@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000027','Bryan Steven','Llivisaca Pulla','2001-07-09','M','bryan.l@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000028','Doménica Camila','Cevallos Andrade','1996-12-28','F','domenica.c@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000029','Mauricio Daniel','Espinoza Pesántez','1983-04-04','M','mauricio.e@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000030','Tatiana Belén','Reinoso Calle','1989-08-21','F','tatiana.r@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000031','Henry Patricio','Coronel Astudillo','1977-02-12','M','henry.c@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000032','Silvana Alexandra','Mora Quizhpi','1986-06-06','F','silvana.m@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000033','Kevin Alexander','Saquicela Guzmán','1999-10-13','M','kevin.s@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000034','Mishell Estefanía','Lojano Vicuña','1993-01-20','F','mishell.l@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000035','Wilson Geovanny','Pillco Tenezaca','1970-09-15','M','wilson.p@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000036','Jessica Paulina','Arévalo Quito','1984-04-27','F','jessica.a@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000037','Christian Renato','Solano Vélez','1990-11-03','M','christian.s@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000038','Adriana Carolina','Banegas Ortiz','1987-07-30','F','adriana.b@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000039','Pedro José','Quito Lema','1968-03-08','M','pedro.q@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000040','Carolina Belén','Fajardo Naula','1994-05-22','F','carolina.f@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000041','Alex Patricio','Guamán Lema','1981-12-11','M','alex.g@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000042','Nataly Estefanía','Rojas Pesantez','1997-08-04','F','nataly.r@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000043','Leonardo Andrés','Cárdenas Vélez','1979-02-26','M','leonardo.c@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000044','Cinthia Mishell','Ávila Bermeo','1991-09-17','F','cinthia.a@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000045','Boris Eduardo','Chuchuca Ortiz','1985-04-19','M','boris.c@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000046','Erika Daniela','Pesántez Loja','1988-06-29','F','erika.p@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000047','Joffre Vinicio','Sánchez Tigre','1973-11-12','M','joffre.s@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000048','Estefanía Lisbeth','Vega Crespo','2000-01-31','F','estefania.v@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000049','Marlon Ramiro','Cobos Andrade','1978-05-14','M','marlon.c@mail.com');
INSERT INTO persona (cedula, nombres, apellidos, fecha_nacimiento, sexo, email) VALUES ('0102000050','Yadira Soledad','Bermeo Pacheco','1992-10-08','F','yadira.b@mail.com');

COMMIT;

-- ---------------------------------------------------------------------
-- 4. TELÉFONOS Y DIRECCIONES (multi-valuados, 4FN)
-- ---------------------------------------------------------------------
-- Un teléfono móvil por persona
INSERT INTO persona_telefono (id_persona, numero, tipo)
SELECT id_persona, '09' || LPAD(TO_CHAR(id_persona*7+1000000), 8, '0'), 'MOVIL'
FROM persona;

-- Dirección principal por persona (rotando entre parroquias 1..10)
INSERT INTO persona_direccion (id_persona, id_parroquia, calle_principal, calle_secundaria, numeracion, referencia, es_principal)
WITH parroquias AS (
    SELECT id_parroquia,
           ROW_NUMBER() OVER (ORDER BY id_parroquia) AS rn,
           COUNT(*) OVER () AS total
    FROM parroquia
), personas AS (
    SELECT id_persona,
           ROW_NUMBER() OVER (ORDER BY id_persona) AS rn
    FROM persona
)
SELECT
    p.id_persona,
    pr.id_parroquia,
    'Av. Principal ' || id_persona,
    'Calle Secundaria ' || MOD(id_persona, 30),
    TO_CHAR(MOD(id_persona*13, 999)),
    'Frente al parque sector ' || id_persona,
    'S'
FROM personas p
JOIN parroquias pr ON pr.rn = MOD(p.rn - 1, pr.total) + 1;

COMMIT;

-- ---------------------------------------------------------------------
-- 5. SUBTIPOS: MEDICO (15) y PACIENTE (35)
-- ---------------------------------------------------------------------
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00001', DATE '2005-03-01', 'Dr. en Medicina' FROM persona WHERE cedula = '0101000001';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00002', DATE '2008-07-15', 'Dra. en Medicina' FROM persona WHERE cedula = '0101000002';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00003', DATE '2003-11-20', 'Dr. Cardiólogo' FROM persona WHERE cedula = '0101000003';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00004', DATE '2010-01-10', 'Dra. Pediatra' FROM persona WHERE cedula = '0101000004';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00005', DATE '2007-05-05', 'Dr. Ginecólogo' FROM persona WHERE cedula = '0101000005';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00006', DATE '2011-09-12', 'Dra. Dermatóloga' FROM persona WHERE cedula = '0101000006';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00007', DATE '2002-02-28', 'Dr. Traumatólogo' FROM persona WHERE cedula = '0101000007';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00008', DATE '2012-06-18', 'Dra. Endocrinóloga' FROM persona WHERE cedula = '0101000008';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00009', DATE '2006-10-22', 'Dr. Neurólogo' FROM persona WHERE cedula = '0101000009';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00010', DATE '2013-04-09', 'Dra. en Medicina' FROM persona WHERE cedula = '0101000010';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00011', DATE '2004-08-16', 'Dr. Cardiólogo' FROM persona WHERE cedula = '0101000011';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00012', DATE '2014-12-01', 'Dra. Pediatra' FROM persona WHERE cedula = '0101000012';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00013', DATE '2009-03-25', 'Dr. Dermatólogo' FROM persona WHERE cedula = '0101000013';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00014', DATE '2015-07-07', 'Dra. Ginecóloga' FROM persona WHERE cedula = '0101000014';
INSERT INTO medico (id_medico, num_registro, fecha_ingreso, titulo_principal)
SELECT id_persona, 'MSP-00015', DATE '2001-11-30', 'Dr. Traumatólogo' FROM persona WHERE cedula = '0101000015';

-- Especialidades por médico (algunos con 2)
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES ( 1, 1, DATE '2006-06-01', 'Universidad de Cuenca');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES ( 2, 1, DATE '2009-06-01', 'UCACUE');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES ( 3, 3, DATE '2005-12-15', 'Universidad Central');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES ( 4, 2, DATE '2011-03-20', 'PUCE');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES ( 5, 4, DATE '2008-09-10', 'Universidad de Cuenca');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES ( 6, 5, DATE '2013-05-22', 'UCACUE');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES ( 7, 6, DATE '2003-07-30', 'Universidad Central');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES ( 8, 7, DATE '2014-11-11', 'PUCE');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES ( 9, 8, DATE '2008-02-14', 'Universidad de Cuenca');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES (10, 1, DATE '2014-08-05', 'UCACUE');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES (11, 3, DATE '2006-04-18', 'Universidad Central');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES (12, 2, DATE '2016-10-23', 'PUCE');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES (13, 5, DATE '2011-01-30', 'Universidad de Cuenca');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES (14, 4, DATE '2017-05-12', 'UCACUE');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES (15, 6, DATE '2003-12-08', 'Universidad Central');
-- 2da especialidad para algunos
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES ( 1, 7, DATE '2010-06-01', 'Universidad de Cuenca');
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certif, institucion) VALUES ( 3, 8, DATE '2012-12-15', 'Universidad Central');

-- Pacientes (id_persona 16..50)
INSERT INTO paciente (id_paciente, historia_clinica, tipo_sangre, factor_rh, ocupacion, estado_civil, contacto_emergencia_nombre, contacto_emergencia_telefono)
SELECT
    p.id_persona,
    'HC-' || LPAD(TO_CHAR(p.id_persona), 6, '0'),
    DECODE(MOD(p.id_persona,4), 0,'O', 1,'A', 2,'B', 3,'AB'),
    DECODE(MOD(p.id_persona,2), 0,'+', '-'),
    DECODE(MOD(p.id_persona,5), 0,'Estudiante', 1,'Ingeniero', 2,'Docente', 3,'Comerciante', 'Empleado privado'),
    DECODE(MOD(p.id_persona,5), 0,'SOLTERO', 1,'CASADO', 2,'DIVORCIADO', 3,'UNION', 'VIUDO'),
    'Contacto Emergencia ' || p.id_persona,
    '07' || LPAD(TO_CHAR(p.id_persona*3+5000000), 7, '0')
FROM persona p
WHERE p.cedula LIKE '010200%';

COMMIT;

-- ---------------------------------------------------------------------
-- 6. ALERGIAS DE PACIENTES (selectivo)
-- ---------------------------------------------------------------------
INSERT INTO paciente_alergia (id_paciente, id_alergeno, severidad, fecha_deteccion, observaciones) VALUES (16, 1, 'SEVERA',       DATE '2018-04-10', 'Reacción cutánea generalizada');
INSERT INTO paciente_alergia (id_paciente, id_alergeno, severidad, fecha_deteccion, observaciones) VALUES (17, 3, 'ANAFILACTICA', DATE '2015-08-22', 'Requirió epinefrina');
INSERT INTO paciente_alergia (id_paciente, id_alergeno, severidad, fecha_deteccion, observaciones) VALUES (18, 5, 'LEVE',         DATE '2020-03-15', 'Rinitis estacional');
INSERT INTO paciente_alergia (id_paciente, id_alergeno, severidad, fecha_deteccion, observaciones) VALUES (19, 2, 'MODERADA',     DATE '2019-11-02', NULL);
INSERT INTO paciente_alergia (id_paciente, id_alergeno, severidad, fecha_deteccion, observaciones) VALUES (20, 4, 'SEVERA',       DATE '2017-06-30', 'Edema facial');
INSERT INTO paciente_alergia (id_paciente, id_alergeno, severidad, fecha_deteccion, observaciones) VALUES (22, 6, 'MODERADA',     DATE '2021-01-12', 'Asma alérgica');
INSERT INTO paciente_alergia (id_paciente, id_alergeno, severidad, fecha_deteccion, observaciones) VALUES (25, 8, 'LEVE',         DATE '2022-05-18', NULL);
INSERT INTO paciente_alergia (id_paciente, id_alergeno, severidad, fecha_deteccion, observaciones) VALUES (28, 7, 'MODERADA',     DATE '2020-09-09', 'Contacto con felinos');
INSERT INTO paciente_alergia (id_paciente, id_alergeno, severidad, fecha_deteccion, observaciones) VALUES (33, 1, 'LEVE',         DATE '2019-02-20', NULL);
INSERT INTO paciente_alergia (id_paciente, id_alergeno, severidad, fecha_deteccion, observaciones) VALUES (40, 3, 'SEVERA',       DATE '2016-07-04', 'Urticaria generalizada');

COMMIT;

-- ---------------------------------------------------------------------
-- 7. CITAS (50 citas distribuidas dentro de los ultimos 12 meses)
-- ---------------------------------------------------------------------
DECLARE
    TYPE t_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_pacientes    t_ids;
    v_medicos      t_ids;
    v_consultorios t_ids;
    v_estado_atendida   NUMBER;
    v_estado_programada NUMBER;
    v_estado_confirmada NUMBER;
    v_estado_cancelada  NUMBER;
    v_estado_no_asistio NUMBER;
    v_pac NUMBER;
    v_med NUMBER;
    v_con NUMBER;
    v_est NUMBER;
    v_fh  TIMESTAMP;
BEGIN
    SELECT id_paciente BULK COLLECT INTO v_pacientes
    FROM paciente
    ORDER BY id_paciente;

    SELECT id_medico BULK COLLECT INTO v_medicos
    FROM medico
    ORDER BY id_medico;

    SELECT id_consultorio BULK COLLECT INTO v_consultorios
    FROM consultorio
    ORDER BY id_consultorio;

    SELECT id_estado INTO v_estado_atendida   FROM estado_cita WHERE codigo = 'ATENDIDA';
    SELECT id_estado INTO v_estado_programada FROM estado_cita WHERE codigo = 'PROGRAMADA';
    SELECT id_estado INTO v_estado_confirmada FROM estado_cita WHERE codigo = 'CONFIRMADA';
    SELECT id_estado INTO v_estado_cancelada  FROM estado_cita WHERE codigo = 'CANCELADA';
    SELECT id_estado INTO v_estado_no_asistio FROM estado_cita WHERE codigo = 'NO_ASISTIO';

    FOR i IN 1..50 LOOP
        v_pac := v_pacientes(MOD(i-1, v_pacientes.COUNT) + 1);
        v_med := v_medicos(MOD(i-1, v_medicos.COUNT) + 1);
        v_con := v_consultorios(MOD(i-1, v_consultorios.COUNT) + 1);
        v_est := CASE
                    WHEN i <= 35 THEN v_estado_atendida
                    WHEN i <= 42 THEN v_estado_programada
                    WHEN i <= 46 THEN v_estado_confirmada
                    WHEN i <= 48 THEN v_estado_cancelada
                    ELSE v_estado_no_asistio
                 END;
        -- Fechas relativas para que las consultas temporales sigan dando resultados.
        v_fh  := CAST(TRUNC(SYSDATE) AS TIMESTAMP)
                 - NUMTODSINTERVAL(360 - i*7, 'DAY')
                 + NUMTODSINTERVAL(8 + MOD(i,8), 'HOUR');

        INSERT INTO cita (id_paciente, id_medico, id_consultorio, id_estado, fecha_hora, duracion_min, motivo_solicitud)
        VALUES (v_pac, v_med, v_con, v_est, v_fh, 30,
                'Consulta motivo ' || i || ' - control general');
    END LOOP;
END;
/
COMMIT;

-- ---------------------------------------------------------------------
-- 8. CONSULTAS (solo para citas ATENDIDAS: las primeras 35) con JSON
-- ---------------------------------------------------------------------
DECLARE
    CURSOR c_cit IS
        SELECT id_cita, fecha_hora, id_medico, id_paciente
          FROM cita
         WHERE id_estado = (SELECT id_estado FROM estado_cita WHERE codigo = 'ATENDIDA')
         ORDER BY id_cita;
    v_anam CLOB;
    v_nlp  CLOB;
    v_idx  NUMBER := 0;
BEGIN
    FOR r IN c_cit LOOP
        v_idx := v_idx + 1;
        v_anam := '{"motivoPrincipal":"Dolor #' || v_idx ||
                  '","duracion":"' || MOD(v_idx,7)+1 || ' días"' ||
                  ',"antecedentes":["HTA","DM2"]' ||
                  ',"sintomas":[' ||
                    '{"nombre":"cefalea","severidad":"' ||
                      CASE WHEN MOD(v_idx,4) = 0 THEN 'ALTA' ELSE 'MEDIA' END ||
                    '"},' ||
                    '{"nombre":"fiebre","severidad":"MEDIA"},' ||
                    '{"nombre":"malestar","severidad":"BAJA"}' ||
                  ']}';
        v_nlp  := '{"diagnosticoSugerido":"' ||
                   CASE MOD(v_idx,5)
                       WHEN 0 THEN 'J00'
                       WHEN 1 THEN 'I10'
                       WHEN 2 THEN 'E11'
                       WHEN 3 THEN 'M54.5'
                       ELSE        'R51'
                   END ||
                  '","confianza":0.' || (70 + MOD(v_idx,30)) ||
                  ',"entidades":[{"tipo":"sintoma","valor":"cefalea"}]}';

        INSERT INTO consulta (id_cita, fecha_cita, fecha_atencion, motivo_consulta,
                              enfermedad_actual, examen_fisico, plan_tratamiento, anamnesis, nlp_entidades)
        VALUES (r.id_cita, r.fecha_hora, r.fecha_hora + INTERVAL '15' MINUTE,
                'Motivo de consulta #' || v_idx,
                'El paciente refiere cuadro clínico de aproximadamente ' || (MOD(v_idx,7)+1) || ' días.',
                'Paciente en buen estado general, signos vitales estables.',
                'Tratamiento sintomático, reposo relativo, control en 7 días.',
                v_anam, v_nlp);
    END LOOP;
END;
/
COMMIT;

-- ---------------------------------------------------------------------
-- 9. SIGNOS VITALES (uno por consulta)
-- ---------------------------------------------------------------------
INSERT INTO signos_vitales (id_consulta, presion_sistolica, presion_diastolica, frec_cardiaca,
                            frec_respiratoria, temperatura, saturacion_o2, peso_kg, talla_cm)
SELECT
    id_consulta,
    110 + MOD(id_consulta, 30),                       -- sistólica 110..139
     70 + MOD(id_consulta, 20),                       -- diastólica 70..89
     65 + MOD(id_consulta, 25),                       -- FC 65..89
     14 + MOD(id_consulta, 8),                        -- FR 14..21
     36.0 + MOD(id_consulta, 25)/10,                  -- 36.0..38.4
     94 + MOD(id_consulta, 6),                        -- SatO2 94..99
     55 + MOD(id_consulta, 40),                       -- peso 55..94
    150 + MOD(id_consulta, 35)                        -- talla 150..184
FROM consulta;

COMMIT;

-- ---------------------------------------------------------------------
-- 10. DIAGNÓSTICOS POR CONSULTA (uno principal + algunos secundarios)
-- ---------------------------------------------------------------------
DECLARE
    CURSOR c_con IS SELECT id_consulta FROM consulta ORDER BY id_consulta;
    v_cies SYS.ODCIVARCHAR2LIST :=
        SYS.ODCIVARCHAR2LIST('J00','J02.9','I10','E11','K29.7','M54.5','R51','A09','L20','N39.0');
    v_idx NUMBER := 0;
BEGIN
    FOR r IN c_con LOOP
        v_idx := v_idx + 1;
        -- Principal
        INSERT INTO consulta_diagnostico (id_consulta, codigo_cie, tipo, observacion)
        VALUES (r.id_consulta, v_cies(MOD(v_idx-1,10)+1), 'P', 'Diagnóstico principal');

        -- Secundario para 1 de cada 3 consultas
        IF MOD(v_idx,3) = 0 THEN
            INSERT INTO consulta_diagnostico (id_consulta, codigo_cie, tipo, observacion)
            VALUES (r.id_consulta, v_cies(MOD(v_idx,10)+1), 'S', 'Comorbilidad asociada');
        END IF;
    END LOOP;
END;
/
COMMIT;

-- ---------------------------------------------------------------------
-- 11. RECETAS Y DETALLE (una receta por consulta, 1-2 medicamentos)
-- ---------------------------------------------------------------------
DECLARE
    CURSOR c_con IS SELECT id_consulta FROM consulta ORDER BY id_consulta;
    v_rec NUMBER;
    v_idx NUMBER := 0;
BEGIN
    FOR r IN c_con LOOP
        v_idx := v_idx + 1;
        INSERT INTO receta (id_consulta, validez_dias, observaciones)
        VALUES (r.id_consulta, 30, 'Receta emitida en consulta')
        RETURNING id_receta INTO v_rec;

        INSERT INTO receta_detalle (id_receta, id_medicamento, dosis, frecuencia, duracion_dias, indicaciones)
        VALUES (v_rec, MOD(v_idx-1,8)+1, '1 unidad', 'Cada 8 horas', 5, 'Tomar con alimentos');

        IF MOD(v_idx,2) = 0 THEN
            INSERT INTO receta_detalle (id_receta, id_medicamento, dosis, frecuencia, duracion_dias, indicaciones)
            VALUES (v_rec, MOD(v_idx,8)+1, '1 unidad', 'Cada 12 horas', 7, 'Tomar después de comer');
        END IF;
    END LOOP;
END;
/
COMMIT;

-- ---------------------------------------------------------------------
-- 12. AUDITORÍA (muestra)
-- ---------------------------------------------------------------------
INSERT INTO auditoria_evento (usuario_db, tabla, operacion, pk_afectada, payload_old, payload_new)
VALUES (USER, 'paciente', 'I', '16', NULL, '{"id_paciente":16,"historia_clinica":"HC-000016"}');
INSERT INTO auditoria_evento (usuario_db, tabla, operacion, pk_afectada, payload_old, payload_new)
VALUES (USER, 'cita', 'U', '1', '{"id_estado":1}', '{"id_estado":3}');
INSERT INTO auditoria_evento (usuario_db, tabla, operacion, pk_afectada, payload_old, payload_new)
VALUES (USER, 'consulta', 'I', '1', NULL, '{"id_consulta":1,"motivo":"control"}');

COMMIT;

-- =====================================================================
-- VERIFICACIÓN RÁPIDA
-- =====================================================================
PROMPT === Conteos por tabla ===
SELECT 'pais'                  AS tabla, COUNT(*) AS filas FROM pais UNION ALL
SELECT 'provincia',                       COUNT(*) FROM provincia UNION ALL
SELECT 'canton',                          COUNT(*) FROM canton UNION ALL
SELECT 'parroquia',                       COUNT(*) FROM parroquia UNION ALL
SELECT 'persona',                         COUNT(*) FROM persona UNION ALL
SELECT 'persona_telefono',                COUNT(*) FROM persona_telefono UNION ALL
SELECT 'persona_direccion',               COUNT(*) FROM persona_direccion UNION ALL
SELECT 'medico',                          COUNT(*) FROM medico UNION ALL
SELECT 'paciente',                        COUNT(*) FROM paciente UNION ALL
SELECT 'especialidad',                    COUNT(*) FROM especialidad UNION ALL
SELECT 'medico_especialidad',             COUNT(*) FROM medico_especialidad UNION ALL
SELECT 'alergeno',                        COUNT(*) FROM alergeno UNION ALL
SELECT 'paciente_alergia',                COUNT(*) FROM paciente_alergia UNION ALL
SELECT 'consultorio',                     COUNT(*) FROM consultorio UNION ALL
SELECT 'estado_cita',                     COUNT(*) FROM estado_cita UNION ALL
SELECT 'cita',                            COUNT(*) FROM cita UNION ALL
SELECT 'cie10',                           COUNT(*) FROM cie10 UNION ALL
SELECT 'consulta',                        COUNT(*) FROM consulta UNION ALL
SELECT 'signos_vitales',                  COUNT(*) FROM signos_vitales UNION ALL
SELECT 'consulta_diagnostico',            COUNT(*) FROM consulta_diagnostico UNION ALL
SELECT 'medicamento',                     COUNT(*) FROM medicamento UNION ALL
SELECT 'receta',                          COUNT(*) FROM receta UNION ALL
SELECT 'receta_detalle',                  COUNT(*) FROM receta_detalle UNION ALL
SELECT 'auditoria_evento',                COUNT(*) FROM auditoria_evento;
