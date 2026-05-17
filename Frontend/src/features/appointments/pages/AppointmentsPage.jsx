import { useCallback, useEffect, useState } from 'react';
import { CalendarDays } from 'lucide-react';
import Swal from 'sweetalert2';
import DataTable from '../../../components/ui/DataTable.jsx';
import MiniMetric from '../../../components/ui/MiniMetric.jsx';
import PageHeader from '../../../components/ui/PageHeader.jsx';
import Panel from '../../../components/ui/Panel.jsx';
import StatusBadge from '../../../components/ui/StatusBadge.jsx';
import AppointmentModal from '../components/AppointmentModal.jsx';
import AppointmentStatusSummary from '../components/AppointmentStatusSummary.jsx';
import MonthlyStateChart from '../components/MonthlyStateChart.jsx';
import RowActions from '../components/RowActions.jsx';
import Toolbar from '../components/Toolbar.jsx';
import {
  deleteAppointment,
  fetchAppointmentDetails,
  fetchAppointmentsByMonthAndStatus,
  fetchAppointmentsByStatus,
} from '../services/appointments.service.js';

function getLastDayOfMonth(month) {
  const [year, monthNumber] = month.split('-').map(Number);
  return new Date(year, monthNumber, 0).getDate().toString().padStart(2, '0');
}

function AppointmentsPage() {
  const [monthlyAppointments, setMonthlyAppointments] = useState([]);
  const [monthlyStatus, setMonthlyStatus] = useState('loading');
  const [appointmentsByStatus, setAppointmentsByStatus] = useState([]);
  const [appointmentsByStatusState, setAppointmentsByStatusState] = useState('loading');
  const [appointmentDetails, setAppointmentDetails] = useState([]);
  const [appointmentDetailsState, setAppointmentDetailsState] = useState('loading');
  const [selectedStatusMonth, setSelectedStatusMonth] = useState('');
  const [detailStatusFilter, setDetailStatusFilter] = useState('');
  const [detailSpecialtyFilter, setDetailSpecialtyFilter] = useState('');
  const [detailPage, setDetailPage] = useState(1);
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingAppointment, setEditingAppointment] = useState(null);

  const loadAppointmentDetails = useCallback(async () => {
    try {
      setAppointmentDetailsState('loading');
      const details = await fetchAppointmentDetails();
      setAppointmentDetails(details);
      setAppointmentDetailsState('success');
    } catch {
      setAppointmentDetailsState('error');
    }
  }, []);

  useEffect(() => {
    let active = true;

    async function loadMonthlyAppointments() {
      try {
        setMonthlyStatus('loading');
        const appointmentsByMonth = await fetchAppointmentsByMonthAndStatus();
        if (active) {
          setMonthlyAppointments(appointmentsByMonth);
          setMonthlyStatus('success');
        }
      } catch {
        if (active) setMonthlyStatus('error');
      }
    }

    loadMonthlyAppointments();
    return () => { active = false; };
  }, []);

  useEffect(() => {
    if (appointmentsByStatus.length === 0 || selectedStatusMonth) return;
    const latestMonth = appointmentsByStatus.map((item) => item.mes).sort().at(-1);
    setSelectedStatusMonth(latestMonth);
  }, [appointmentsByStatus, selectedStatusMonth]);

  useEffect(() => {
    let active = true;

    async function loadAppointmentsByStatus() {
      try {
        setAppointmentsByStatusState('loading');
        const statusSummary = await fetchAppointmentsByStatus();
        if (active) {
          setAppointmentsByStatus(statusSummary);
          setAppointmentsByStatusState('success');
        }
      } catch {
        if (active) setAppointmentsByStatusState('error');
      }
    }

    loadAppointmentsByStatus();
    return () => { active = false; };
  }, []);

  useEffect(() => {
    loadAppointmentDetails();
  }, [loadAppointmentDetails]);

  useEffect(() => {
    if (monthlyAppointments.length === 0 || startDate || endDate) return;

    const months = monthlyAppointments
      .filter((item) => item.mes)
      .map((item) => item.mes)
      .sort();
    const firstMonth = months[0];
    const lastMonth = months.at(-1);

    setStartDate(`${firstMonth}-01`);
    setEndDate(`${lastMonth}-${getLastDayOfMonth(lastMonth)}`);
  }, [monthlyAppointments, startDate, endDate]);

  function openNewModal() {
    setEditingAppointment(null);
    setShowModal(true);
  }

  function openEditModal(appointment) {
    setEditingAppointment(appointment);
    setShowModal(true);
  }

  async function handleDelete(appointment) {
    const result = await Swal.fire({
      icon: 'warning',
      title: '¿Eliminar cita?',
      text: `Se eliminará la cita de ${appointment.paciente}. Esta acción no se puede deshacer.`,
      showCancelButton: true,
      confirmButtonText: 'Sí, eliminar',
      cancelButtonText: 'Cancelar',
    });

    if (!result.isConfirmed) return;

    try {
      await deleteAppointment(appointment.id_cita);
      Swal.fire({ icon: 'success', title: 'Cita eliminada', timer: 1500, showConfirmButton: false });
      loadAppointmentDetails();
    } catch {
      Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo eliminar la cita.' });
    }
  }

  const startMonth = startDate ? startDate.slice(0, 7) : null;
  const endMonth = endDate ? endDate.slice(0, 7) : null;
  const filteredMonthlyAppointments = monthlyAppointments.filter((item) => {
    if (!item.mes) return false;
    return (!startMonth || item.mes >= startMonth) && (!endMonth || item.mes <= endMonth);
  });
  const statusMonths = appointmentsByStatus.map((item) => item.mes).sort();
  const filteredAppointmentsByStatus = appointmentsByStatus.filter((item) => item.mes === selectedStatusMonth);
  const detailStatuses = [...new Set(appointmentDetails.map((item) => item.estado))].sort((a, b) => a.localeCompare(b));
  const detailSpecialties = [...new Set(appointmentDetails.map((item) => item.especialidad))].sort((a, b) => a.localeCompare(b));
  const filteredAppointmentDetails = appointmentDetails.filter(
    (item) =>
      (!detailStatusFilter || item.estado === detailStatusFilter) &&
      (!detailSpecialtyFilter || item.especialidad === detailSpecialtyFilter),
  );
  const detailsPerPage = 5;
  const totalDetailPages = Math.max(Math.ceil(filteredAppointmentDetails.length / detailsPerPage), 1);
  const safeDetailPage = Math.min(detailPage, totalDetailPages);
  const paginatedAppointmentDetails = filteredAppointmentDetails.slice(
    (safeDetailPage - 1) * detailsPerPage,
    safeDetailPage * detailsPerPage,
  );
  const statusTotals = filteredMonthlyAppointments
    .filter((item) => item.estado)
    .reduce((totals, item) => {
      totals[item.estado] = (totals[item.estado] ?? 0) + item.total_citas;
      return totals;
    }, {});
  const totalAppointments = filteredMonthlyAppointments
    .filter((item) => item.estado === null)
    .reduce((total, item) => total + item.total_citas, 0);

  function resetDateRange() {
    const months = monthlyAppointments
      .filter((item) => item.mes)
      .map((item) => item.mes)
      .sort();

    if (months.length === 0) {
      setStartDate('');
      setEndDate('');
      return;
    }

    const firstMonth = months[0];
    const lastMonth = months.at(-1);
    setStartDate(`${firstMonth}-01`);
    setEndDate(`${lastMonth}-${getLastDayOfMonth(lastMonth)}`);
  }

  return (
    <>
      <PageHeader
        title="Gestion de Citas"
        subtitle="Agenda, seguimiento y control operativo."
        actions={
          <button className="primary-button" onClick={openNewModal}>
            <CalendarDays size={16} />
            Nueva cita
          </button>
        }
      />

      {showModal && (
        <AppointmentModal
          appointmentToEdit={editingAppointment}
          onClose={() => setShowModal(false)}
          onSuccess={loadAppointmentDetails}
        />
      )}

      <section className="dashboard-grid">
        <Panel className="span-12 date-filter-panel">
          <div className="date-filter-bar">
            <label>
              <span>Desde</span>
              <input
                type="date"
                value={startDate}
                max={endDate || undefined}
                onChange={(event) => setStartDate(event.target.value)}
              />
            </label>
            <label>
              <span>Hasta</span>
              <input
                type="date"
                value={endDate}
                min={startDate || undefined}
                onChange={(event) => setEndDate(event.target.value)}
              />
            </label>
            <button className="secondary-button" onClick={resetDateRange}>
              Restablecer
            </button>
          </div>
        </Panel>

        <Panel className="span-4" title="Citas por estado">
          {appointmentsByStatusState === 'success' && appointmentsByStatus.length > 0 && (
            <label className="month-select">
              <span>Mes</span>
              <select value={selectedStatusMonth} onChange={(event) => setSelectedStatusMonth(event.target.value)}>
                {statusMonths.map((month) => (
                  <option key={month} value={month}>{month}</option>
                ))}
              </select>
            </label>
          )}
          {appointmentsByStatusState === 'loading' && <p className="panel-message">Cargando citas por estado...</p>}
          {appointmentsByStatusState === 'error' && <p className="panel-message error">No se pudo cargar las citas por estado.</p>}
          {appointmentsByStatusState === 'success' && filteredAppointmentsByStatus.length === 0 && <p className="panel-message">No hay datos disponibles para las citas por estado.</p>}
          {appointmentsByStatusState === 'success' && filteredAppointmentsByStatus.length > 0 && (
            <AppointmentStatusSummary items={filteredAppointmentsByStatus} />
          )}
        </Panel>

        <Panel className="span-8" title="Citas por estado y mes">
          <div className="summary-grid">
            <MiniMetric label="Total citas" value={totalAppointments} />
            <MiniMetric label="Atendidas" value={statusTotals.ATENDIDA ?? 0} />
            <MiniMetric label="Programadas" value={statusTotals.PROGRAMADA ?? 0} />
            <MiniMetric label="Canceladas" value={statusTotals.CANCELADA ?? 0} />
          </div>
          {monthlyStatus === 'loading' && <p className="panel-message">Cargando resumen mensual de citas...</p>}
          {monthlyStatus === 'error' && <p className="panel-message error">No se pudo cargar el resumen mensual de citas.</p>}
          {monthlyStatus === 'success' && filteredMonthlyAppointments.length === 0 && <p className="panel-message">No hay datos disponibles para el resumen mensual.</p>}
          {monthlyStatus === 'success' && filteredMonthlyAppointments.length > 0 && (
            <MonthlyStateChart items={filteredMonthlyAppointments} />
          )}
        </Panel>

        <Panel className="span-12" title="Listado de citas">
          <Toolbar
            statusFilter={detailStatusFilter}
            specialtyFilter={detailSpecialtyFilter}
            statuses={detailStatuses}
            specialties={detailSpecialties}
            onStatusChange={(value) => { setDetailStatusFilter(value); setDetailPage(1); }}
            onSpecialtyChange={(value) => { setDetailSpecialtyFilter(value); setDetailPage(1); }}
          />
          {appointmentDetailsState === 'loading' && <p className="panel-message">Cargando listado de citas...</p>}
          {appointmentDetailsState === 'error' && <p className="panel-message error">No se pudo cargar el listado de citas.</p>}
          {appointmentDetailsState === 'success' && filteredAppointmentDetails.length === 0 && <p className="panel-message">No hay citas para los filtros seleccionados.</p>}
          {appointmentDetailsState === 'success' && filteredAppointmentDetails.length > 0 && (
            <>
              <DataTable
                headers={['Fecha / hora', 'Paciente', 'Medico', 'Consultorio', 'Especialidad', 'Estado', 'Acciones']}
                rows={paginatedAppointmentDetails.map((appointment) => [
                  appointment.fecha_hora,
                  appointment.paciente,
                  appointment.medico,
                  appointment.consultorio,
                  appointment.especialidad,
                  <StatusBadge key={`badge-${appointment.id_cita}`} label={appointment.estado} />,
                  <RowActions
                    key={`actions-${appointment.id_cita}`}
                    onEdit={() => openEditModal(appointment)}
                    onDelete={() => handleDelete(appointment)}
                  />,
                ])}
              />
              <div className="table-pagination">
                <span>Pagina {safeDetailPage} de {totalDetailPages}</span>
                <div>
                  <button
                    className="secondary-button"
                    disabled={safeDetailPage === 1}
                    onClick={() => setDetailPage((page) => Math.max(page - 1, 1))}
                  >
                    Anterior
                  </button>
                  <button
                    className="secondary-button"
                    disabled={safeDetailPage === totalDetailPages}
                    onClick={() => setDetailPage((page) => Math.min(page + 1, totalDetailPages))}
                  >
                    Siguiente
                  </button>
                </div>
              </div>
            </>
          )}
        </Panel>
      </section>
    </>
  );
}

export default AppointmentsPage;
