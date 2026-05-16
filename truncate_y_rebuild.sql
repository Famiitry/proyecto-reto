-- Trunca todas las tablas del esquema y reconstruye indices.
-- Aviso: este script NO reinicia las columnas IDENTITY.
-- Para recargar seed_gestion_medica.sql desde cero, usa mejor:
--   1) reset_esquema.sql
--   2) ddl.sql
--   3) seed_gestion_medica.sql
-- Ejecutar en SQL*Plus/SQLcl
SET SERVEROUTPUT ON
SET TIMING ON

BEGIN
  -- Hijas -> padres para evitar FK
  EXECUTE IMMEDIATE 'TRUNCATE TABLE receta_detalle';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE receta';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE consulta_diagnostico';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE signos_vitales';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE consulta';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE cita';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE medico_especialidad';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE paciente_alergia';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE persona_direccion';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE persona_telefono';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE medico';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE paciente';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE consultorio';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE estado_cita';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE especialidad';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE alergeno';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE cie10';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE medicamento';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE auditoria_evento';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE parroquia';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE canton';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE provincia';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE pais';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE persona';
END;
/

DECLARE
  v_sql VARCHAR2(4000);
BEGIN
  FOR r IN (
    SELECT index_name
    FROM user_indexes
    WHERE index_type NOT IN ('LOB', 'DOMAIN')
      AND partitioned = 'NO'
  ) LOOP
    v_sql := 'ALTER INDEX ' || r.index_name || ' REBUILD';
    EXECUTE IMMEDIATE v_sql;
  END LOOP;
END;
/
