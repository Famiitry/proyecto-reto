import { X } from 'lucide-react';
import Field from '../../../components/ui/Field.jsx';

function AppointmentModal({ onClose }) {
  return (
    <div className="modal-backdrop">
      <div className="modal">
        <header>
          <h2>Nueva cita medica</h2>
          <button onClick={onClose} aria-label="Cerrar">
            <X size={18} />
          </button>
        </header>
        <form className="form-grid">
          <Field label="Paciente" />
          <Field label="Medico asignado" />
          <Field label="Consultorio" />
          <Field label="Estado inicial" value="Confirmada" />
          <Field label="Fecha y hora" />
          <Field label="Duracion (min)" value="30" />
          <Field label="Motivo de consulta" wide textarea />
        </form>
        <footer>
          <button className="secondary-button" onClick={onClose}>Cancelar</button>
          <button className="primary-button">Guardar cita</button>
        </footer>
      </div>
    </div>
  );
}

export default AppointmentModal;
