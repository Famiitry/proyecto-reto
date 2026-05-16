-- =====================================================================
-- AUDITORÍA DE CITAS
-- Motor: Oracle 19c+
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. TABLA DE AUDITORÍA PARA CITAS
-- ---------------------------------------------------------------------
CREATE TABLE auditoria_cita (
    id_auditoria   NUMBER(15)   GENERATED ALWAYS AS IDENTITY,
    id_cita        NUMBER(12)   NOT NULL,
    fecha_evento   TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    usuario_db     VARCHAR2(40) NOT NULL,
    operacion      CHAR(1)      NOT NULL, -- 'I': INSERT, 'U': UPDATE, 'D': DELETE
    payload_old    CLOB         CONSTRAINT ck_aud_old_cita CHECK (payload_old IS JSON),
    payload_new    CLOB         CONSTRAINT ck_aud_new_cita CHECK (payload_new IS JSON),
    CONSTRAINT pk_auditoria_cita PRIMARY KEY (id_auditoria),
    CONSTRAINT ck_aud_cita_op    CHECK (operacion IN ('I','U','D'))
);

-- ---------------------------------------------------------------------
-- 2. TRIGGER PARA AUDITAR CAMBIOS EN LA TABLA CITA
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_auditar_cita
BEFORE INSERT OR UPDATE OR DELETE ON cita
FOR EACH ROW
DECLARE
    v_old_json CLOB;
    v_new_json CLOB;
BEGIN
    -- Construir el JSON del registro antiguo
    IF DELETING OR UPDATING THEN
        v_old_json := JSON_OBJECT(
            'id_cita' VALUE :OLD.id_cita,
            'id_paciente' VALUE :OLD.id_paciente,
            'id_medico' VALUE :OLD.id_medico,
            'id_consultorio' VALUE :OLD.id_consultorio,
            'id_estado' VALUE :OLD.id_estado,
            'fecha_hora' VALUE TO_CHAR(:OLD.fecha_hora, 'YYYY-MM-DD HH24:MI:SS'),
            'duracion_min' VALUE :OLD.duracion_min,
            'motivo_solicitud' VALUE :OLD.motivo_solicitud,
            'fecha_creacion' VALUE TO_CHAR(:OLD.fecha_creacion, 'YYYY-MM-DD HH24:MI:SS')
        );
    END IF;

    -- Construir el JSON del registro nuevo
    IF INSERTING OR UPDATING THEN
        v_new_json := JSON_OBJECT(
            'id_cita' VALUE :NEW.id_cita,
            'id_paciente' VALUE :NEW.id_paciente,
            'id_medico' VALUE :NEW.id_medico,
            'id_consultorio' VALUE :NEW.id_consultorio,
            'id_estado' VALUE :NEW.id_estado,
            'fecha_hora' VALUE TO_CHAR(:NEW.fecha_hora, 'YYYY-MM-DD HH24:MI:SS'),
            'duracion_min' VALUE :NEW.duracion_min,
            'motivo_solicitud' VALUE :NEW.motivo_solicitud,
            'fecha_creacion' VALUE TO_CHAR(:NEW.fecha_creacion, 'YYYY-MM-DD HH24:MI:SS')
        );
    END IF;

    -- Insertar en la tabla de auditoría
    IF INSERTING THEN
        INSERT INTO auditoria_cita (id_cita, usuario_db, operacion, payload_new)
        VALUES (:NEW.id_cita, USER, 'I', v_new_json);
    ELSIF UPDATING THEN
        INSERT INTO auditoria_cita (id_cita, usuario_db, operacion, payload_old, payload_new)
        VALUES (:OLD.id_cita, USER, 'U', v_old_json, v_new_json);
    ELSIF DELETING THEN
        INSERT INTO auditoria_cita (id_cita, usuario_db, operacion, payload_old)
        VALUES (:OLD.id_cita, USER, 'D', v_old_json);
    END IF;
END;
/
