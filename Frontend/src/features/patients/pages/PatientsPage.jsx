import { useEffect, useState } from 'react';
import { UserPlus, X } from 'lucide-react';
import DataTable from '../../../components/ui/DataTable.jsx';
import PageHeader from '../../../components/ui/PageHeader.jsx';
import Panel from '../../../components/ui/Panel.jsx';
import AllergyRanking from '../components/AllergyRanking.jsx';
import PatientQuickForm from '../components/PatientQuickForm.jsx';
import {
  fetchPatientAppointmentGaps,
  fetchPatientsList,
  fetchPatientWaitTimes,
  fetchPatientUsageScores,
  fetchTopAllergies,
} from '../services/patients.service.js';

function PatientsPage() {
  const [appointmentGaps, setAppointmentGaps] = useState([]);
  const [gapStatus, setGapStatus] = useState('loading');
  const [gapPage, setGapPage] = useState(1);
  const [usageScores, setUsageScores] = useState([]);
  const [usageStatus, setUsageStatus] = useState('loading');
  const [topAllergies, setTopAllergies] = useState([]);
  const [allergyStatus, setAllergyStatus] = useState('loading');
  const [waitTimes, setWaitTimes] = useState([]);
  const [waitTimeStatus, setWaitTimeStatus] = useState('loading');
  const [patientList, setPatientList] = useState([]);
  const [patientListStatus, setPatientListStatus] = useState('loading');
  const [patientPage, setPatientPage] = useState(1);
  const [patientHasMore, setPatientHasMore] = useState(false);
  const [isPatientModalOpen, setIsPatientModalOpen] = useState(false);
  const gapsPerPage = 5;
  const patientsPerPage = 6;

  useEffect(() => {
    let active = true;

    async function loadAppointmentGaps() {
      try {
        setGapStatus('loading');
        const gaps = await fetchPatientAppointmentGaps();

        if (active) {
          setAppointmentGaps(gaps);
          setGapPage(1);
          setGapStatus('success');
        }
      } catch {
        if (active) {
          setGapStatus('error');
        }
      }
    }

    loadAppointmentGaps();

    return () => {
      active = false;
    };
  }, []);

  useEffect(() => {
    let active = true;

    async function loadPatientsList() {
      try {
        setPatientListStatus('loading');
        const payload = await fetchPatientsList((patientPage - 1) * patientsPerPage, patientsPerPage);

        if (active) {
          setPatientList(payload.items ?? []);
          setPatientHasMore(Boolean(payload.hasMore));
          setPatientListStatus('success');
        }
      } catch {
        if (active) {
          setPatientListStatus('error');
        }
      }
    }

    loadPatientsList();

    return () => {
      active = false;
    };
  }, [patientPage]);

  useEffect(() => {
    let active = true;

    async function loadWaitTimes() {
      try {
        setWaitTimeStatus('loading');
        const waits = await fetchPatientWaitTimes();

        if (active) {
          setWaitTimes(waits);
          setWaitTimeStatus('success');
        }
      } catch {
        if (active) {
          setWaitTimeStatus('error');
        }
      }
    }

    loadWaitTimes();

    return () => {
      active = false;
    };
  }, []);

  useEffect(() => {
    let active = true;

    async function loadTopAllergies() {
      try {
        setAllergyStatus('loading');
        const allergies = await fetchTopAllergies();

        if (active) {
          setTopAllergies(allergies);
          setAllergyStatus('success');
        }
      } catch {
        if (active) {
          setAllergyStatus('error');
        }
      }
    }

    loadTopAllergies();

    return () => {
      active = false;
    };
  }, []);

  useEffect(() => {
    let active = true;

    async function loadUsageScores() {
      try {
        setUsageStatus('loading');
        const scores = await fetchPatientUsageScores();

        if (active) {
          setUsageScores(scores);
          setUsageStatus('success');
        }
      } catch {
        if (active) {
          setUsageStatus('error');
        }
      }
    }

    loadUsageScores();

    return () => {
      active = false;
    };
  }, []);

  const totalGapPages = Math.max(Math.ceil(appointmentGaps.length / gapsPerPage), 1);
  const gapRows = appointmentGaps
    .slice((gapPage - 1) * gapsPerPage, gapPage * gapsPerPage)
    .map((item) => [item.paciente, Number(item.max_gap_dias).toFixed(2)]);
  const topUsagePatients = usageScores.slice(0, 5);
  const waitTimeRows = waitTimes.map((item) => [
    item.paciente,
    Number(item.espera_prom_min).toFixed(2),
    Number(item.p95_espera_min).toFixed(2),
  ]);
  const patientRows = patientList.map((item) => [
    item.expediente,
    item.paciente,
    item.cedula,
    item.ultima_cita ?? '-',
    item.estado,
  ]);

  return (
    <>
      <PageHeader
        title="Directorio de Pacientes"
        subtitle="Gestion centralizada de expedientes y analisis clinico."
        actions={
          <button className="primary-button" type="button" onClick={() => setIsPatientModalOpen(true)}>
            <UserPlus size={16} />
            Nuevo paciente
          </button>
        }
      />
      <section className="dashboard-grid">
        <Panel className="span-3" title="Uso alto vs promedio">
          {usageStatus === 'loading' && <p className="panel-message">Cargando uso de pacientes...</p>}
          {usageStatus === 'error' && (
            <p className="panel-message error">No se pudo cargar el uso de pacientes.</p>
          )}
          {usageStatus === 'success' && usageScores.length === 0 && (
            <p className="panel-message">No hay datos disponibles para este indicador.</p>
          )}
          {usageStatus === 'success' && usageScores.length > 0 && (
            <div className="usage-score-list">
              {topUsagePatients.map((item) => (
                <div key={item.paciente}>
                  <strong>{item.paciente}</strong>
                  <span>{item.total_citas} citas</span>
                  <b>Z {Number(item.z_score).toFixed(2)}</b>
                </div>
              ))}
            </div>
          )}
        </Panel>
        <Panel className="span-5" title="Brechas maximas entre citas">
          {gapStatus === 'loading' && <p className="panel-message">Cargando brechas entre citas...</p>}
          {gapStatus === 'error' && (
            <p className="panel-message error">No se pudo cargar las brechas entre citas.</p>
          )}
          {gapStatus === 'success' && appointmentGaps.length === 0 && (
            <p className="panel-message">No hay datos disponibles para las brechas entre citas.</p>
          )}
          {gapStatus === 'success' && appointmentGaps.length > 0 && (
            <>
              <DataTable headers={['Paciente', 'Max gap dias']} rows={gapRows} />
              <div className="table-pagination">
                <span>
                  Mostrando {(gapPage - 1) * gapsPerPage + 1}-
                  {Math.min(gapPage * gapsPerPage, appointmentGaps.length)} de {appointmentGaps.length}
                </span>
                <div>
                  <button
                    className="secondary-button"
                    onClick={() => setGapPage((page) => Math.max(page - 1, 1))}
                    disabled={gapPage === 1}
                  >
                    Anterior
                  </button>
                  <strong>{gapPage} / {totalGapPages}</strong>
                  <button
                    className="secondary-button"
                    onClick={() => setGapPage((page) => Math.min(page + 1, totalGapPages))}
                    disabled={gapPage === totalGapPages}
                  >
                    Siguiente
                  </button>
                </div>
              </div>
            </>
          )}
        </Panel>
        <Panel className="span-4" title="Top alergias">
          {allergyStatus === 'loading' && <p className="panel-message">Cargando ranking de alergias...</p>}
          {allergyStatus === 'error' && (
            <p className="panel-message error">No se pudo cargar el ranking de alergias.</p>
          )}
          {allergyStatus === 'success' && topAllergies.length === 0 && (
            <p className="panel-message">No hay datos disponibles para el ranking de alergias.</p>
          )}
          {allergyStatus === 'success' && topAllergies.length > 0 && <AllergyRanking items={topAllergies} />}
        </Panel>
        <Panel className="span-8" title="Listado de pacientes">
          {patientListStatus === 'loading' && <p className="panel-message">Cargando listado de pacientes...</p>}
          {patientListStatus === 'error' && (
            <p className="panel-message error">No se pudo cargar el listado de pacientes.</p>
          )}
          {patientListStatus === 'success' && patientList.length === 0 && (
            <p className="panel-message">No hay pacientes disponibles.</p>
          )}
          {patientListStatus === 'success' && patientList.length > 0 && (
            <>
              <DataTable headers={['Expediente', 'Paciente', 'Cedula', 'Ultima cita', 'Estado']} rows={patientRows} />
              <div className="table-pagination">
                <span>Pagina {patientPage}</span>
                <div>
                  <button
                    className="secondary-button"
                    disabled={patientPage === 1}
                    onClick={() => setPatientPage((page) => Math.max(page - 1, 1))}
                  >
                    Anterior
                  </button>
                  <button
                    className="secondary-button"
                    disabled={!patientHasMore}
                    onClick={() => setPatientPage((page) => page + 1)}
                  >
                    Siguiente
                  </button>
                </div>
              </div>
            </>
          )}
        </Panel>
        <Panel className="span-4" title="Registro rapido">
          <p className="panel-message">
            Abre el formulario completo desde <strong>Nuevo paciente</strong> para registrar un expediente.
          </p>
        </Panel>
        <Panel className="span-12" title="Pacientes con mayor tiempo de espera">
          {waitTimeStatus === 'loading' && <p className="panel-message">Cargando tiempos de espera...</p>}
          {waitTimeStatus === 'error' && (
            <p className="panel-message error">No se pudo cargar los tiempos de espera.</p>
          )}
          {waitTimeStatus === 'success' && waitTimes.length === 0 && (
            <p className="panel-message">No hay datos disponibles para tiempos de espera.</p>
          )}
          {waitTimeStatus === 'success' && waitTimes.length > 0 && (
            <DataTable headers={['Paciente', 'Espera prom. min', 'P95 espera min']} rows={waitTimeRows} />
          )}
        </Panel>
      </section>

      {isPatientModalOpen && (
        <div className="modal-backdrop visible" onClick={() => setIsPatientModalOpen(false)}>
          <div className="modal patient-modal" onClick={(event) => event.stopPropagation()}>
            <header>
              <div>
                <h2>Nuevo paciente</h2>
                <p className="muted-light">Completa los datos del POST para crear el expediente.</p>
              </div>
              <button type="button" onClick={() => setIsPatientModalOpen(false)}>
                <X size={18} />
              </button>
            </header>
            <div className="patient-modal-body">
              <PatientQuickForm
                onCancel={() => setIsPatientModalOpen(false)}
                onSuccess={() => setIsPatientModalOpen(false)}
              />
            </div>
          </div>
        </div>
      )}
    </>
  );
}

export default PatientsPage;
