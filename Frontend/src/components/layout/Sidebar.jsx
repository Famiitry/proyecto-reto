import {
  CalendarDays,
  ClipboardPlus,
  LayoutDashboard,
  LogOut,
  Settings,
  Stethoscope,
  Users,
} from 'lucide-react';

const navigation = [
  { id: 'dashboard', label: 'Inicio', icon: LayoutDashboard },
  { id: 'doctors', label: 'Medicos', icon: Stethoscope },
  { id: 'appointments', label: 'Citas', icon: CalendarDays },
  { id: 'patients', label: 'Pacientes', icon: Users },
  { id: 'consultations', label: 'Consultas', icon: ClipboardPlus },
];

function Sidebar({ activePage, open, onClose, onNavigate, onNewAppointment }) {
  return (
    <>
      <button className={`sidebar-backdrop ${open ? 'visible' : ''}`} onClick={onClose} aria-label="Cerrar menu" />
      <aside className={`sidebar ${open ? 'open' : ''}`}>
        <div className="brand">
          <strong>MediGestion</strong>
          <span>Panel administrativo</span>
        </div>
        <nav>
          {navigation.map(({ id, label, icon: Icon }) => (
            <button key={id} className={activePage === id ? 'active' : ''} onClick={() => onNavigate(id)}>
              <Icon size={18} />
              <span>{label}</span>
            </button>
          ))}
        </nav>
        <div className="sidebar-footer">
          <button className="primary-button full" onClick={onNewAppointment}>
            <CalendarDays size={16} />
            Nueva cita
          </button>
          <button>
            <Settings size={18} />
            Ajustes
          </button>
          <button>
            <LogOut size={18} />
            Cerrar sesion
          </button>
        </div>
      </aside>
    </>
  );
}

export default Sidebar;
