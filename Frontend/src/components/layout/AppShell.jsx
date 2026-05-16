import { useState } from 'react';
import Header from './Header.jsx';
import Sidebar from './Sidebar.jsx';

function AppShell({ activePage, onNavigate, onNewAppointment, children }) {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="app-shell">
      <Sidebar
        activePage={activePage}
        open={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
        onNavigate={(pageId) => {
          onNavigate(pageId);
          setSidebarOpen(false);
        }}
        onNewAppointment={onNewAppointment}
      />
      <div className="main-shell">
        <Header onMenuClick={() => setSidebarOpen(true)} />
        <main className="page-content">{children}</main>
      </div>
    </div>
  );
}

export default AppShell;
