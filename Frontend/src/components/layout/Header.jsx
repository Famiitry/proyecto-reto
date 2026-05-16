import { Bell, CircleHelp, Menu, Search } from 'lucide-react';

function Header({ onMenuClick }) {
  return (
    <header className="topbar">
      <button className="icon-button mobile-only" onClick={onMenuClick} aria-label="Abrir menu">
        <Menu size={20} />
      </button>
      <label className="search-box">
        <Search size={18} />
        <input placeholder="Buscar pacientes, medicos..." />
      </label>
      <div className="topbar-actions">
        <button className="icon-button" aria-label="Notificaciones">
          <Bell size={18} />
        </button>
        <button className="icon-button" aria-label="Ayuda">
          <CircleHelp size={18} />
        </button>
        <div className="profile">
          <div>
            <strong>Dr. Alberto Ruiz</strong>
            <span>Director medico</span>
          </div>
          <div className="avatar">AR</div>
        </div>
      </div>
    </header>
  );
}

export default Header;
