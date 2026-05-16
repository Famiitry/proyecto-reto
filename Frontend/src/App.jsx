import { useMemo, useState } from 'react';
import AppShell from './components/layout/AppShell.jsx';
import AppointmentModal from './features/appointments/components/AppointmentModal.jsx';
import AppointmentsPage from './features/appointments/pages/AppointmentsPage.jsx';
import ConsultationsPage from './features/consultations/pages/ConsultationsPage.jsx';
import DashboardPage from './features/dashboard/pages/DashboardPage.jsx';
import DoctorsPage from './features/doctors/pages/DoctorsPage.jsx';
import PatientsPage from './features/patients/pages/PatientsPage.jsx';

function App() {
  const [activePage, setActivePage] = useState('dashboard');
  const [appointmentModalOpen, setAppointmentModalOpen] = useState(false);

  const currentPage = useMemo(() => {
    switch (activePage) {
      case 'doctors':
        return <DoctorsPage />;
      case 'appointments':
        return <AppointmentsPage onNewAppointment={() => setAppointmentModalOpen(true)} />;
      case 'patients':
        return <PatientsPage />;
      case 'consultations':
        return <ConsultationsPage />;
      default:
        return <DashboardPage />;
    }
  }, [activePage]);

  return (
    <>
      <AppShell
        activePage={activePage}
        onNavigate={setActivePage}
        onNewAppointment={() => setAppointmentModalOpen(true)}
      >
        {currentPage}
      </AppShell>
      {appointmentModalOpen && <AppointmentModal onClose={() => setAppointmentModalOpen(false)} />}
    </>
  );
}

export default App;
