
-- Módulo de consultas de referencia para llenar IDs en los JSON de la API
-- Schema: SISTEMAMEDICO
--

BEGIN
  ORDS.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => 'SISTEMAMEDICO',
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'medica',
      p_auto_rest_auth      => FALSE);

  ORDS.DEFINE_MODULE(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_base_path      => '/api/relaciones/',
      p_items_per_page => 25,
      p_status         => 'PUBLISHED',
      p_comments       => 'Endpoints de referencia para obtener IDs de catálogos');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'parroquias',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => 'Lista de parroquias con jerarquía geográfica completa');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'parroquias',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         =>
'SELECT par.id_parroquia,
       par.nombre     AS parroquia,
       can.nombre     AS canton,
       pro.nombre     AS provincia,
       pai.nombre     AS pais
FROM parroquia par
JOIN canton    can ON can.id_canton    = par.id_canton
JOIN provincia pro ON pro.id_provincia = can.id_provincia
JOIN pais      pai ON pai.id_pais      = pro.id_pais
WHERE (:provincia IS NULL OR UPPER(pro.nombre) LIKE ''%'' || UPPER(:provincia) || ''%'')
  AND (:canton    IS NULL OR UPPER(can.nombre) LIKE ''%'' || UPPER(:canton)    || ''%'')
  AND (:parroquia IS NULL OR UPPER(par.nombre) LIKE ''%'' || UPPER(:parroquia) || ''%'')
ORDER BY pro.nombre, can.nombre, par.nombre
OFFSET NVL(:offset, 0) ROWS FETCH NEXT NVL(:limit, 25) ROWS ONLY');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'pacientes',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => 'Lista de pacientes para selección de IDs');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'pacientes',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         =>
'SELECT pac.id_paciente,
       per.cedula,
       per.nombres || '' '' || per.apellidos AS paciente,
       pac.historia_clinica
FROM paciente pac
JOIN persona per ON per.id_persona = pac.id_paciente
WHERE (:nombre  IS NULL OR UPPER(per.nombres || '' '' || per.apellidos) LIKE ''%'' || UPPER(:nombre)  || ''%'')
  AND (:cedula  IS NULL OR per.cedula = :cedula)
ORDER BY per.apellidos, per.nombres
OFFSET NVL(:offset, 0) ROWS FETCH NEXT NVL(:limit, 25) ROWS ONLY');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'medicos',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => 'Lista de médicos activos con especialidades');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'medicos',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         =>
'SELECT med.id_medico,
       per.nombres || '' '' || per.apellidos AS medico,
       med.num_registro,
       med.titulo_principal,
       LISTAGG(esp.nombre, '', '') WITHIN GROUP (ORDER BY esp.nombre) AS especialidades
FROM medico med
JOIN persona per ON per.id_persona = med.id_medico
LEFT JOIN medico_especialidad me  ON me.id_medico       = med.id_medico
LEFT JOIN especialidad        esp ON esp.id_especialidad = me.id_especialidad
WHERE med.fecha_baja IS NULL
  AND (:nombre IS NULL OR UPPER(per.nombres || '' '' || per.apellidos) LIKE ''%'' || UPPER(:nombre) || ''%'')
GROUP BY med.id_medico, per.nombres, per.apellidos, med.num_registro, med.titulo_principal
ORDER BY per.apellidos, per.nombres
OFFSET NVL(:offset, 0) ROWS FETCH NEXT NVL(:limit, 25) ROWS ONLY');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'consultorios',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => 'Lista de consultorios');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'consultorios',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         =>
'SELECT id_consultorio,
       codigo,
       piso,
       descripcion
FROM consultorio
ORDER BY piso, codigo');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'estados-cita',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => 'Catálogo de estados de cita');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'estados-cita',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         =>
'SELECT codigo,
       descripcion
FROM estado_cita
ORDER BY id_estado');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'citas-sin-consulta',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => 'Citas sin consulta asociada, listas para registrar consulta');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'citas-sin-consulta',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page => 1000,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         =>
'SELECT ci.id_cita,
       TO_CHAR(ci.fecha_hora, ''YYYY-MM-DD HH24:MI:SS'') AS fecha_hora,
       per_pac.nombres || '' '' || per_pac.apellidos      AS paciente,
       per_med.nombres || '' '' || per_med.apellidos      AS medico,
       ec.codigo                                          AS estado
FROM cita ci
JOIN paciente  pac     ON pac.id_paciente   = ci.id_paciente
JOIN persona   per_pac ON per_pac.id_persona = pac.id_paciente
JOIN medico    med     ON med.id_medico      = ci.id_medico
JOIN persona   per_med ON per_med.id_persona = med.id_medico
JOIN estado_cita ec    ON ec.id_estado       = ci.id_estado
WHERE NOT EXISTS (
    SELECT 1 FROM consulta con WHERE con.id_cita = ci.id_cita
)
ORDER BY ci.fecha_hora');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'cie10',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => 'Búsqueda en catálogo CIE-10 por código o descripción');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'sistema.medico.api.relaciones',
      p_pattern        => 'cie10',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page => 25,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         =>
'SELECT codigo,
       descripcion,
       capitulo
FROM cie10
WHERE (:q IS NULL
       OR UPPER(descripcion) LIKE ''%'' || UPPER(:q) || ''%''
       OR UPPER(codigo)      LIKE ''%'' || UPPER(:q) || ''%'')
ORDER BY codigo
OFFSET NVL(:offset, 0) ROWS FETCH NEXT NVL(:limit, 25) ROWS ONLY');

COMMIT;

END;
