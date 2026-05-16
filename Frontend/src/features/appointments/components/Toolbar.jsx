import { Download } from 'lucide-react';

function Toolbar({
  statusFilter,
  specialtyFilter,
  statuses,
  specialties,
  onStatusChange,
  onSpecialtyChange,
}) {
  return (
    <div className="toolbar">
      <select value={statusFilter} onChange={(event) => onStatusChange(event.target.value)}>
        <option value="">Todos los estados</option>
        {statuses.map((status) => (
          <option key={status} value={status}>
            {status}
          </option>
        ))}
      </select>
      <select value={specialtyFilter} onChange={(event) => onSpecialtyChange(event.target.value)}>
        <option value="">Todas las especialidades</option>
        {specialties.map((specialty) => (
          <option key={specialty} value={specialty}>
            {specialty}
          </option>
        ))}
      </select>
      <button className="secondary-button">
        <Download size={16} />
        Exportar
      </button>
    </div>
  );
}

export default Toolbar;
