-- Ejecutar solo si quieres borrar el esquema actual y recrearlo desde cero.
-- El orden va de tablas hijas a tablas padre para respetar las claves foraneas.

BEGIN
    FOR r IN (
        SELECT column_value AS table_name
        FROM sys.odcivarchar2list(
            'RECETA_DETALLE',
            'RECETA',
            'CONSULTA_DIAGNOSTICO',
            'SIGNOS_VITALES',
            'CONSULTA',
            'CITA',
            'PACIENTE_ALERGIA',
            'MEDICO_ESPECIALIDAD',
            'MEDICO',
            'PACIENTE',
            'PERSONA_DIRECCION',
            'PERSONA_TELEFONO',
            'PERSONA',
            'PARROQUIA',
            'CANTON',
            'PROVINCIA',
            'PAIS',
            'ESPECIALIDAD',
            'ALERGENO',
            'CONSULTORIO',
            'ESTADO_CITA',
            'CIE10',
            'MEDICAMENTO',
            'AUDITORIA_EVENTO'
        )
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || r.table_name || ' CASCADE CONSTRAINTS PURGE';
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE != -942 THEN
                    RAISE;
                END IF;
        END;
    END LOOP;
END;
/
