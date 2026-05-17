import { useEffect, useState } from 'react';
import { X } from 'lucide-react';
import Swal from 'sweetalert2';
import { createAppointment, updateAppointment } from '../services/appointments.service.js';
import {
  fetchAppointmentStatuses,
  fetchDoctorOptions,
  fetchOfficeOptions,
  fetchPatientOptions,
} from '../../shared/services/relations.service.js';

const EMPTY_FORM = {
  id_paciente: '',
  id_medico: '',
  id_consultorio: '',
  codigo_estado: '',
  fecha_hora: '',
  duracion_min: '30',
  motivo_solicitud: '',
};

function AppointmentModal({ onClose, onSuccess, appointmentToEdit = null }) {
  const isEditing = appointmentToEdit !== null;

  const [patients, setPatients]   = useState([]);
  const [doctors, setDoctors]     = useState([]);
  const [offices, setOffices]     = useState([]);
  const [statuses, setStatuses]   = useState([]);
  const [catalogsLoading, setCatalogsLoading] = useState(true);

  const [form, setForm]           = useState(EMPTY_FORM);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    async function loadCatalogs() {
      try {
        const [p, d, o, s] = await Promise.all([
          fetchPatientOptions(),
          fetchDoctorOptions(),
          fetchOfficeOptions(),
          fetchAppointmentStatuses(),
        ]);
        setPatients(p);
        setDoctors(d);
        setOffices(o);
        setStatuses(s);

        if (isEditing) {
          const matchedPatient = p.find((x) => x.paciente === appointmentToEdit.paciente);
          const matchedDoctor  = d.find((x) => x.medico   === appointmentToEdit.medico);
          const matchedOffice  = o.find((x) => x.codigo   === appointmentToEdit.consultorio);

          setForm({
            id_paciente:      String(matchedPatient?.id_paciente    ?? ''),
            id_medico:        String(matchedDoctor?.id_medico        ?? ''),
            id_consultorio:   String(matchedOffice?.id_consultorio   ?? ''),
            codigo_estado:    appointmentToEdit.estado               ?? s[0]?.codigo ?? '',
            fecha_hora:       '',
            duracion_min:     String(appointmentToEdit.duracion_min  ?? '30'),
            motivo_solicitud: appointmentToEdit.motivo_solicitud     ?? '',
          });
        } else {
          setForm({ ...EMPTY_FORM, codigo_estado: s[0]?.codigo ?? '' });
        }
      } finally {
        setCatalogsLoading(false);
      }
    }

    loadCatalogs();
  }, []);

  function handleChange(event) {
    const { name, value } = event.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  }

  async function handleSubmit(event) {
    event.preventDefault();

    const payload = {
      id_paciente:      Number(form.id_paciente),
      id_medico:        Number(form.id_medico),
      id_consultorio:   Number(form.id_consultorio),
      codigo_estado:    form.codigo_estado,
      duracion_min:     Number(form.duracion_min),
      motivo_solicitud: form.motivo_solicitud || null,
    };

    if (isEditing) {
      payload.id_cita = appointmentToEdit.id_cita;
    } else {
      payload.fecha_hora = form.fecha_hora.replace('T', ' ') + ':00';
    }

    setIsSubmitting(true);
    let saved = false;
    try {
      if (isEditing) {
        await updateAppointment(payload);
      } else {
        await createAppointment(payload);
      }
      saved = true;
    } catch {
      Swal.fire({
        icon: 'error',
        title: isEditing ? 'Error al actualizar' : 'Error al registrar',
        text: 'No se pudo guardar la cita. Intenta de nuevo.',
        confirmButtonText: 'Cerrar',
      });
    } finally {
      setIsSubmitting(false);
    }

    if (saved) {
      await Swal.fire({
        icon: 'success',
        title: isEditing ? '¡Cita actualizada!' : '¡Cita registrada!',
        text: isEditing ? 'Los datos de la cita se actualizaron correctamente.' : 'La cita se agendó correctamente.',
        confirmButtonText: 'Aceptar',
      });
      if (typeof onSuccess === 'function') onSuccess();
      onClose();
    }
  }

  function getSubmitLabel() {
    if (catalogsLoading) return 'Cargando...';
    if (isSubmitting) return 'Guardando...';
    return isEditing ? 'Guardar cambios' : 'Agendar cita';
  }
  const submitLabel = getSubmitLabel();

  return (
    <div className="modal-backdrop">
      <div className="modal">
        <header>
          <h2>{isEditing ? 'Editar cita' : 'Nueva cita médica'}</h2>
          <button onClick={onClose} aria-label="Cerrar">
            <X size={18} />
          </button>
        </header>

        <form className="form-grid" onSubmit={handleSubmit}>
          <label>
            <span>Paciente</span>
            <select name="id_paciente" value={form.id_paciente} onChange={handleChange} required disabled={catalogsLoading}>
              <option value="">Selecciona un paciente</option>
              {patients.map((p) => (
                <option key={p.id_paciente} value={p.id_paciente}>
                  {p.paciente} — {p.cedula}
                </option>
              ))}
            </select>
          </label>

          <label>
            <span>Médico</span>
            <select name="id_medico" value={form.id_medico} onChange={handleChange} required disabled={catalogsLoading}>
              <option value="">Selecciona un médico</option>
              {doctors.map((d) => (
                <option key={d.id_medico} value={d.id_medico}>
                  {d.medico} — {d.especialidades}
                </option>
              ))}
            </select>
          </label>

          <label>
            <span>Consultorio</span>
            <select name="id_consultorio" value={form.id_consultorio} onChange={handleChange} required disabled={catalogsLoading}>
              <option value="">Selecciona un consultorio</option>
              {offices.map((o) => (
                <option key={o.id_consultorio} value={o.id_consultorio}>
                  {o.codigo} — Piso {o.piso} {o.descripcion ? `(${o.descripcion})` : ''}
                </option>
              ))}
            </select>
          </label>

          <label>
            <span>Estado</span>
            <select name="codigo_estado" value={form.codigo_estado} onChange={handleChange} required disabled={catalogsLoading}>
              {statuses.map((s) => (
                <option key={s.codigo} value={s.codigo}>
                  {s.codigo} — {s.descripcion}
                </option>
              ))}
            </select>
          </label>

          {!isEditing && (
            <label>
              <span>Fecha y hora</span>
              <input
                type="datetime-local"
                name="fecha_hora"
                value={form.fecha_hora}
                onChange={handleChange}
                required
              />
            </label>
          )}

          <label>
            <span>Duración (min)</span>
            <input
              type="number"
              name="duracion_min"
              value={form.duracion_min}
              onChange={handleChange}
              min="5"
              max="240"
              required
            />
          </label>

          <label style={{ gridColumn: '1 / -1' }}>
            <span>Motivo de consulta</span>
            <textarea
              name="motivo_solicitud"
              value={form.motivo_solicitud}
              onChange={handleChange}
              rows={3}
              placeholder="Describe el motivo de la cita..."
            />
          </label>

          <footer style={{ gridColumn: '1 / -1' }}>
            <button className="secondary-button" type="button" onClick={onClose}>
              Cancelar
            </button>
            <button className="primary-button" type="submit" disabled={catalogsLoading || isSubmitting}>
              {submitLabel}
            </button>
          </footer>
        </form>
      </div>
    </div>
  );
}

export default AppointmentModal;
