import { useState } from 'react';
import Swal from 'sweetalert2';
import Field from '../../../components/ui/Field.jsx';
import { createPatient } from '../services/patients.service.js';

function PatientQuickForm({ onSuccess, onCancel }) {
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(event) {
    event.preventDefault();

    const form = event.currentTarget;
    const formData = new FormData(form);
    const payload = {
      cedula: formData.get('cedula')?.trim(),
      nombres: formData.get('nombres')?.trim(),
      apellidos: formData.get('apellidos')?.trim(),
      fecha_nacimiento: formData.get('fecha_nacimiento'),
      sexo: formData.get('sexo'),
      email: formData.get('email')?.trim() || null,
      historia_clinica: formData.get('historia_clinica')?.trim(),
      tipo_sangre: formData.get('tipo_sangre') || null,
      factor_rh: formData.get('factor_rh') || null,
      ocupacion: formData.get('ocupacion')?.trim() || null,
      estado_civil: formData.get('estado_civil') || null,
      contacto_emergencia_nombre: formData.get('contacto_emergencia_nombre')?.trim() || null,
      contacto_emergencia_telefono: formData.get('contacto_emergencia_telefono')?.trim() || null,
      numero_telefono: formData.get('numero_telefono')?.trim() || null,
      tipo_telefono: formData.get('tipo_telefono') || null,
      id_parroquia: Number(formData.get('id_parroquia')),
      calle_principal: formData.get('calle_principal')?.trim(),
      calle_secundaria: formData.get('calle_secundaria')?.trim() || null,
      numeracion: formData.get('numeracion')?.trim() || null,
      referencia: formData.get('referencia')?.trim() || null,
    };

    setIsSubmitting(true);

    try {
      await createPatient(payload);
      form.reset();
      await Swal.fire({
        icon: 'success',
        title: '¡Paciente registrado!',
        text: 'El expediente se guardó correctamente.',
        confirmButtonText: 'Aceptar',
      });
      if (typeof onSuccess === 'function') {
        onSuccess();
      }
    } catch {
      Swal.fire({
        icon: 'error',
        title: 'Error al registrar',
        text: 'No se pudo guardar el expediente. Intenta de nuevo.',
        confirmButtonText: 'Cerrar',
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form className="compact-form patient-create-form" onSubmit={handleSubmit}>
      <div className="patient-grid">
        <Field label="Cédula" name="cedula" required placeholder="1234567890" />
        <Field label="Nombres" name="nombres" required placeholder="Juan" />
        <Field label="Apellidos" name="apellidos" required placeholder="Perez" />
        <Field label="Fecha de nacimiento" name="fecha_nacimiento" type="date" required />
        <label>
          <span>Sexo</span>
          <select name="sexo" defaultValue="M" required>
            <option value="M">M</option>
            <option value="F">F</option>
            <option value="X">X</option>
          </select>
        </label>
        <Field label="Email" name="email" type="email" placeholder="juan.perez@example.com" />
        <Field label="Historia clínica" name="historia_clinica" required placeholder="HC-001-2026" />
        <label>
          <span>Tipo de sangre</span>
          <select name="tipo_sangre" defaultValue="">
            <option value="">Sin especificar</option>
            <option value="A">A</option>
            <option value="B">B</option>
            <option value="AB">AB</option>
            <option value="O">O</option>
          </select>
        </label>
        <label>
          <span>Factor RH</span>
          <select name="factor_rh" defaultValue="">
            <option value="">Sin especificar</option>
            <option value="+">+</option>
            <option value="-">-</option>
          </select>
        </label>
        <Field label="Ocupación" name="ocupacion" placeholder="Ingeniero" />
        <label>
          <span>Estado civil</span>
          <select name="estado_civil" defaultValue="">
            <option value="">Sin especificar</option>
            <option value="SOLTERO">SOLTERO</option>
            <option value="CASADO">CASADO</option>
            <option value="DIVORCIADO">DIVORCIADO</option>
            <option value="VIUDO">VIUDO</option>
            <option value="UNION">UNION</option>
          </select>
        </label>
        <Field label="Contacto de emergencia" name="contacto_emergencia_nombre" placeholder="Maria Perez" />
        <Field label="Teléfono de emergencia" name="contacto_emergencia_telefono" placeholder="0987654321" />
        <Field label="Número de teléfono" name="numero_telefono" placeholder="0991234567" />
        <label>
          <span>Tipo de teléfono</span>
          <select name="tipo_telefono" defaultValue="MOVIL">
            <option value="MOVIL">MOVIL</option>
            <option value="FIJO">FIJO</option>
            <option value="TRABAJO">TRABAJO</option>
          </select>
        </label>
        <Field label="ID parroquia" name="id_parroquia" type="number" required placeholder="1" />
        <Field label="Calle principal" name="calle_principal" required placeholder="Av. Principal" />
        <Field label="Calle secundaria" name="calle_secundaria" placeholder="Calle Secundaria" />
        <Field label="Numeración" name="numeracion" placeholder="123" />
        <Field label="Referencia" name="referencia" wide textarea large placeholder="Edificio Blanco" />
      </div>
      <p className="panel-message">Llena los datos del paciente y guarda el expediente.</p>
      <div className="form-footer compact-footer">
        <button className="secondary-button" type="button" onClick={onCancel}>
          Cancelar
        </button>
        <button className="primary-button" type="submit" disabled={isSubmitting}>
          {isSubmitting ? 'Guardando...' : 'Guardar expediente'}
        </button>
      </div>
    </form>
  );
}

export default PatientQuickForm;
