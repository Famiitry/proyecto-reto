-- =====================================================================
-- PROCEDIMIENTOS ALMACENADOS: PACIENTES, CITAS Y CONSULTAS
-- Esquema requerido: ddl.sql
-- =====================================================================

CREATE OR REPLACE FUNCTION fn_cedula_valida (
    p_cedula IN persona.cedula%TYPE
) RETURN NUMBER IS
    v_cedula VARCHAR2(13);
    v_total  NUMBER := 0;
    v_digito NUMBER;
    v_coef   NUMBER;
    v_mod    NUMBER;
    v_verif  NUMBER;
    v_prov   NUMBER;
    v_tercer NUMBER;
BEGIN
    v_cedula := REGEXP_REPLACE(p_cedula, '\\D', '');

    IF LENGTH(v_cedula) <> 10 THEN
        RETURN 0;
    END IF;

    v_prov := TO_NUMBER(SUBSTR(v_cedula, 1, 2));
    v_tercer := TO_NUMBER(SUBSTR(v_cedula, 3, 1));

    IF v_prov < 1 OR v_prov > 24 OR v_tercer > 5 THEN
        RETURN 0;
    END IF;

    FOR i IN 1 .. 9 LOOP
        v_digito := TO_NUMBER(SUBSTR(v_cedula, i, 1));
        IF MOD(i, 2) = 1 THEN
            v_coef := v_digito * 2;
            IF v_coef > 9 THEN
                v_coef := v_coef - 9;
            END IF;
        ELSE
            v_coef := v_digito;
        END IF;
        v_total := v_total + v_coef;
    END LOOP;

    v_mod := MOD(v_total, 10);
    v_verif := CASE WHEN v_mod = 0 THEN 0 ELSE 10 - v_mod END;

    IF v_verif = TO_NUMBER(SUBSTR(v_cedula, 10, 1)) THEN
        RETURN 1;
    END IF;

    RETURN 0;
END;
/

CREATE OR REPLACE PROCEDURE sp_registrar_paciente (
    p_cedula                         IN persona.cedula%TYPE,
    p_nombres                        IN persona.nombres%TYPE,
    p_apellidos                      IN persona.apellidos%TYPE,
    p_fecha_nacimiento               IN persona.fecha_nacimiento%TYPE,
    p_sexo                           IN persona.sexo%TYPE,
    p_email                          IN persona.email%TYPE,
    p_historia_clinica               IN paciente.historia_clinica%TYPE,
    p_tipo_sangre                    IN paciente.tipo_sangre%TYPE,
    p_factor_rh                      IN paciente.factor_rh%TYPE,
    p_ocupacion                      IN paciente.ocupacion%TYPE,
    p_estado_civil                   IN paciente.estado_civil%TYPE,
    p_contacto_emergencia_nombre     IN paciente.contacto_emergencia_nombre%TYPE,
    p_contacto_emergencia_telefono   IN paciente.contacto_emergencia_telefono%TYPE,
    p_numero_telefono                IN persona_telefono.numero%TYPE,
    p_tipo_telefono                  IN persona_telefono.tipo%TYPE,
    p_id_parroquia                   IN persona_direccion.id_parroquia%TYPE,
    p_calle_principal                IN persona_direccion.calle_principal%TYPE,
    p_calle_secundaria               IN persona_direccion.calle_secundaria%TYPE DEFAULT NULL,
    p_numeracion                     IN persona_direccion.numeracion%TYPE DEFAULT NULL,
    p_referencia                     IN persona_direccion.referencia%TYPE DEFAULT NULL,
    p_id_paciente                    OUT paciente.id_paciente%TYPE
) IS
BEGIN
    IF fn_cedula_valida(p_cedula) = 0 THEN
        RAISE_APPLICATION_ERROR(-20014, 'La cedula indicada no es valida');
    END IF;

    INSERT INTO persona (
        cedula, nombres, apellidos, fecha_nacimiento, sexo, email
    ) VALUES (
        p_cedula, p_nombres, p_apellidos, p_fecha_nacimiento, p_sexo, p_email
    )
    RETURNING id_persona INTO p_id_paciente;

    INSERT INTO paciente (
        id_paciente, historia_clinica, tipo_sangre, factor_rh, ocupacion,
        estado_civil, contacto_emergencia_nombre, contacto_emergencia_telefono
    ) VALUES (
        p_id_paciente, p_historia_clinica, p_tipo_sangre, p_factor_rh, p_ocupacion,
        p_estado_civil, p_contacto_emergencia_nombre, p_contacto_emergencia_telefono
    );

    INSERT INTO persona_telefono (
        id_persona, numero, tipo
    ) VALUES (
        p_id_paciente, p_numero_telefono, p_tipo_telefono
    );

    INSERT INTO persona_direccion (
        id_persona, id_parroquia, calle_principal, calle_secundaria,
        numeracion, referencia, es_principal
    ) VALUES (
        p_id_paciente, p_id_parroquia, p_calle_principal, p_calle_secundaria,
        p_numeracion, p_referencia, 'S'
    );
END;
/

CREATE OR REPLACE PROCEDURE sp_registrar_cita (
    p_id_paciente        IN cita.id_paciente%TYPE,
    p_id_medico          IN cita.id_medico%TYPE,
    p_id_consultorio     IN cita.id_consultorio%TYPE,
    p_codigo_estado      IN estado_cita.codigo%TYPE,
    p_fecha_hora         IN cita.fecha_hora%TYPE,
    p_duracion_min       IN cita.duracion_min%TYPE DEFAULT 30,
    p_motivo_solicitud   IN cita.motivo_solicitud%TYPE,
    p_id_cita            OUT cita.id_cita%TYPE
) IS
    v_id_estado estado_cita.id_estado%TYPE;
BEGIN
    SELECT id_estado
      INTO v_id_estado
      FROM estado_cita
     WHERE codigo = p_codigo_estado;

    INSERT INTO cita (
        id_paciente, id_medico, id_consultorio, id_estado,
        fecha_hora, duracion_min, motivo_solicitud
    ) VALUES (
        p_id_paciente, p_id_medico, p_id_consultorio, v_id_estado,
        p_fecha_hora, p_duracion_min, p_motivo_solicitud
    )
    RETURNING id_cita INTO p_id_cita;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'El estado de cita indicado no existe');
END;
/

CREATE OR REPLACE PROCEDURE sp_registrar_consulta (
    p_id_cita                IN cita.id_cita%TYPE,
    p_motivo_consulta        IN consulta.motivo_consulta%TYPE,
    p_enfermedad_actual      IN consulta.enfermedad_actual%TYPE DEFAULT NULL,
    p_examen_fisico          IN consulta.examen_fisico%TYPE DEFAULT NULL,
    p_plan_tratamiento       IN consulta.plan_tratamiento%TYPE DEFAULT NULL,
    p_anamnesis              IN consulta.anamnesis%TYPE DEFAULT NULL,
    p_nlp_entidades          IN consulta.nlp_entidades%TYPE DEFAULT NULL,
    p_presion_sistolica      IN signos_vitales.presion_sistolica%TYPE DEFAULT NULL,
    p_presion_diastolica     IN signos_vitales.presion_diastolica%TYPE DEFAULT NULL,
    p_frec_cardiaca          IN signos_vitales.frec_cardiaca%TYPE DEFAULT NULL,
    p_frec_respiratoria      IN signos_vitales.frec_respiratoria%TYPE DEFAULT NULL,
    p_temperatura            IN signos_vitales.temperatura%TYPE DEFAULT NULL,
    p_saturacion_o2          IN signos_vitales.saturacion_o2%TYPE DEFAULT NULL,
    p_peso_kg                IN signos_vitales.peso_kg%TYPE DEFAULT NULL,
    p_talla_cm               IN signos_vitales.talla_cm%TYPE DEFAULT NULL,
    p_codigo_cie_principal   IN consulta_diagnostico.codigo_cie%TYPE,
    p_observacion_diag       IN consulta_diagnostico.observacion%TYPE DEFAULT NULL,
    p_id_consulta            OUT consulta.id_consulta%TYPE
) IS
    v_fecha_cita cita.fecha_hora%TYPE;
BEGIN
    SELECT fecha_hora
      INTO v_fecha_cita
      FROM cita
     WHERE id_cita = p_id_cita;

    INSERT INTO consulta (
        id_cita, fecha_cita, fecha_atencion, motivo_consulta,
        enfermedad_actual, examen_fisico, plan_tratamiento, anamnesis, nlp_entidades
    ) VALUES (
        p_id_cita, v_fecha_cita, SYSTIMESTAMP, p_motivo_consulta,
        p_enfermedad_actual, p_examen_fisico, p_plan_tratamiento, p_anamnesis, p_nlp_entidades
    )
    RETURNING id_consulta INTO p_id_consulta;

    INSERT INTO signos_vitales (
        id_consulta, presion_sistolica, presion_diastolica, frec_cardiaca,
        frec_respiratoria, temperatura, saturacion_o2, peso_kg, talla_cm
    ) VALUES (
        p_id_consulta, p_presion_sistolica, p_presion_diastolica, p_frec_cardiaca,
        p_frec_respiratoria, p_temperatura, p_saturacion_o2, p_peso_kg, p_talla_cm
    );

    INSERT INTO consulta_diagnostico (
        id_consulta, codigo_cie, tipo, observacion
    ) VALUES (
        p_id_consulta, p_codigo_cie_principal, 'P', p_observacion_diag
    );
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20011, 'La cita indicada no existe');
END;
/

CREATE OR REPLACE PROCEDURE sp_actualizar_cita (
    p_id_cita             IN cita.id_cita%TYPE,
    p_id_paciente         IN cita.id_paciente%TYPE,
    p_id_medico           IN cita.id_medico%TYPE,
    p_id_consultorio      IN cita.id_consultorio%TYPE,
    p_codigo_estado       IN estado_cita.codigo%TYPE,
    p_duracion_min        IN cita.duracion_min%TYPE,
    p_motivo_solicitud    IN cita.motivo_solicitud%TYPE
) IS
    v_id_estado estado_cita.id_estado%TYPE;
BEGIN
    SELECT id_estado
      INTO v_id_estado
      FROM estado_cita
     WHERE codigo = p_codigo_estado;

    UPDATE cita
       SET id_paciente = p_id_paciente,
           id_medico = p_id_medico,
           id_consultorio = p_id_consultorio,
           id_estado = v_id_estado,
           duracion_min = p_duracion_min,
           motivo_solicitud = p_motivo_solicitud
     WHERE id_cita = p_id_cita;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'La cita indicada no existe');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'El estado de cita indicado no existe');
END;
/

CREATE OR REPLACE PROCEDURE sp_eliminar_cita (
    p_id_cita IN cita.id_cita%TYPE
) IS
    v_total_consultas NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_total_consultas
      FROM consulta
     WHERE id_cita = p_id_cita;

    IF v_total_consultas > 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'No se puede eliminar la cita porque ya tiene una consulta asociada');
    END IF;

    DELETE FROM cita
     WHERE id_cita = p_id_cita;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'La cita indicada no existe');
    END IF;
END;
/
