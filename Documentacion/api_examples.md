# Ejemplos de JSON para la API de Gestión Médica

Este documento proporciona ejemplos de payloads JSON para las operaciones comunes de la API (POST, PUT, DELETE) para las entidades principales del sistema de gestión médica.

---

## 1. Pacientes

### POST /pacientes - Registrar un nuevo paciente

http://localhost:8080/ords/medica/api/pacientes/create

```json
{
    "cedula": "1234567890",
    "nombres": "Juan",
    "apellidos": "Perez",
    "fecha_nacimiento": "1990-01-15",
    "sexo": "M",
    "email": "juan.perez@example.com",
    "historia_clinica": "HC-001-2026",
    "tipo_sangre": "A",
    "factor_rh": "+",
    "ocupacion": "Ingeniero",
    "estado_civil": "SOLTERO",
    "contacto_emergencia_nombre": "Maria Perez",
    "contacto_emergencia_telefono": "0987654321",
    "numero_telefono": "0991234567",
    "tipo_telefono": "MOVIL",
    "id_parroquia": 1,
    "calle_principal": "Av. Principal",
    "calle_secundaria": "Calle Secundaria",
    "numeracion": "123",
    "referencia": "Edificio Blanco"
}
```

---

## 2. Citas

### POST /citas - Registrar una nueva cita
http://localhost:8080/ords/medica/api/citas/create

```json
{
    "id_paciente": 101,
    "id_medico": 201,
    "id_consultorio": 1,
    "codigo_estado": "PENDIENTE",
    "fecha_hora": "2026-06-01 10:00:00",
    "duracion_min": 45,
    "motivo_solicitud": "Consulta de rutina"
}
```

### PUT /citas/{id} - Actualizar una cita existente
http://localhost:8080/ords/medica/api/citas/update
```json
{
    "id_cita": 147,
    "id_paciente": 101,
    "id_medico": 201,
    "id_consultorio": 2,
    "codigo_estado": "CONFIRMADA",
    "duracion_min": 60,
    "motivo_solicitud": "Revisión de resultados y seguimiento"
}
```

### DELETE /citas/{id} - Eliminar una cita
http://localhost:8080/ords/medica/api/citas/delete
```json
{
    "id_cita": 147
}
```

---

## 3. Consultas

### POST /consultas - Registrar una nueva consulta

http://localhost:8080/ords/medica/api/consultas/create

```json
{
    "id_cita": 147,
    "motivo_consulta": "Dolor de cabeza y fiebre",
    "enfermedad_actual": "Paciente presenta cefalea frontal y temperatura de 38.5°C por 2 días.",
    "examen_fisico": "Faringe ligeramente eritematosa, ruidos cardíacos rítmicos, abdomen blando, sin masas.",
    "plan_tratamiento": "Reposo, hidratación, analgésicos y antipiréticos. Reevaluación en 48 horas.",
    "anamnesis": {
        "motivoPrincipal": "Cefalea",
        "antecedentesPersonales": "Niega alergias, no cirugías previas.",
        "medicamentosActuales": "Ninguno"
    },
    "nlp_entidades": {
        "diagnosticoSugerido": "Cefalea tensional, faringitis viral",
        "medicamentosRecomendados": ["Paracetamol", "Ibuprofeno"]
    },
    "presion_sistolica": 120,
    "presion_diastolica": 80,
    "frec_cardiaca": 75,
    "frec_respiratoria": 18,
    "temperatura": 38.5,
    "saturacion_o2": 98,
    "peso_kg": 70.5,
    "talla_cm": 170.2,
    "codigo_cie_principal": "R51",
    "observacion_diag": "Diagnóstico principal: Cefalea."
}
```