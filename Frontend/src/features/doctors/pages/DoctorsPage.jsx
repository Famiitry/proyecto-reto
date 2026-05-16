import { useEffect, useState } from 'react';
import { BarChart3 } from 'lucide-react';
import DataTable from '../../../components/ui/DataTable.jsx';
import EmptyState from '../../../components/ui/EmptyState.jsx';
import PageHeader from '../../../components/ui/PageHeader.jsx';
import Panel from '../../../components/ui/Panel.jsx';
import MatrixTable from '../components/MatrixTable.jsx';
import SpecialtyDistribution from '../components/SpecialtyDistribution.jsx';
import {
  fetchAppointmentsBySpecialty,
  fetchDoctorRanking,
  fetchSpecialtyStatusSummary,
} from '../services/doctors.service.js';

function DoctorsPage() {
  const [doctorRanking, setDoctorRanking] = useState([]);
  const [rankingStatus, setRankingStatus] = useState('loading');
  const [specialtyDistribution, setSpecialtyDistribution] = useState([]);
  const [specialtyStatus, setSpecialtyStatus] = useState('loading');
  const [specialtyStatusSummary, setSpecialtyStatusSummary] = useState([]);
  const [matrixStatus, setMatrixStatus] = useState('loading');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  useEffect(() => {
    let active = true;

    async function loadDoctorRanking() {
      try {
        setRankingStatus('loading');
        const ranking = await fetchDoctorRanking();

        if (active) {
          setDoctorRanking(ranking);
          setCurrentPage(1);
          setRankingStatus('success');
        }
      } catch {
        if (active) {
          setRankingStatus('error');
        }
      }
    }

    loadDoctorRanking();

    return () => {
      active = false;
    };
  }, []);

  useEffect(() => {
    let active = true;

    async function loadSpecialtyStatusSummary() {
      try {
        setMatrixStatus('loading');
        const summary = await fetchSpecialtyStatusSummary();

        if (active) {
          setSpecialtyStatusSummary(summary);
          setMatrixStatus('success');
        }
      } catch {
        if (active) {
          setMatrixStatus('error');
        }
      }
    }

    loadSpecialtyStatusSummary();

    return () => {
      active = false;
    };
  }, []);

  useEffect(() => {
    let active = true;

    async function loadSpecialtyDistribution() {
      try {
        setSpecialtyStatus('loading');
        const distribution = await fetchAppointmentsBySpecialty();

        if (active) {
          setSpecialtyDistribution(distribution);
          setSpecialtyStatus('success');
        }
      } catch {
        if (active) {
          setSpecialtyStatus('error');
        }
      }
    }

    loadSpecialtyDistribution();

    return () => {
      active = false;
    };
  }, []);

  const totalPages = Math.ceil(doctorRanking.length / itemsPerPage);
  const currentPageItems = doctorRanking.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);
  const rankingRows = currentPageItems.map((doctor) => [
    String(doctor.rnk).padStart(2, '0'),
    doctor.medico,
    doctor.total_citas,
  ]);

  return (
    <>
      <PageHeader title="Directorio de Medicos y Analitica" subtitle="Monitoreo de rendimiento clinico y distribucion de carga de trabajo." />
      <section className="dashboard-grid">
        <Panel className="span-7" title="Ranking de medicos">
          {rankingStatus === 'loading' && <p className="panel-message">Cargando ranking de medicos...</p>}
          {rankingStatus === 'error' && <p className="panel-message error">No se pudo cargar el ranking de medicos.</p>}
          {rankingStatus === 'success' && doctorRanking.length === 0 && (
            <p className="panel-message">No hay datos disponibles para el ranking.</p>
          )}
          {rankingStatus === 'success' && doctorRanking.length > 0 && (
            <>
              <DataTable headers={['Posicion', 'Nombre del medico', 'Total citas']} rows={rankingRows} />
              <div className="table-pagination">
                <span>
                  Mostrando {(currentPage - 1) * itemsPerPage + 1}-
                  {Math.min(currentPage * itemsPerPage, doctorRanking.length)} de {doctorRanking.length}
                </span>
                <div>
                  <button
                    className="secondary-button"
                    onClick={() => setCurrentPage((page) => Math.max(page - 1, 1))}
                    disabled={currentPage === 1}
                  >
                    Anterior
                  </button>
                  <strong>{currentPage} / {totalPages}</strong>
                  <button
                    className="secondary-button"
                    onClick={() => setCurrentPage((page) => Math.min(page + 1, totalPages))}
                    disabled={currentPage === totalPages}
                  >
                    Siguiente
                  </button>
                </div>
              </div>
            </>
          )}
        </Panel>
        <Panel className="span-5" title="Distribucion de citas por especialidad">
          {specialtyStatus === 'loading' && <p className="panel-message">Cargando distribucion por especialidad...</p>}
          {specialtyStatus === 'error' && (
            <p className="panel-message error">No se pudo cargar la distribucion por especialidad.</p>
          )}
          {specialtyStatus === 'success' && specialtyDistribution.length === 0 && (
            <p className="panel-message">No hay datos disponibles para esta distribucion.</p>
          )}
          {specialtyStatus === 'success' && specialtyDistribution.length > 0 && (
            <SpecialtyDistribution items={specialtyDistribution} />
          )}
        </Panel>
        <Panel className="span-8" title="Matriz: especialidad vs estado de cita">
          {matrixStatus === 'loading' && <p className="panel-message">Cargando matriz por especialidad...</p>}
          {matrixStatus === 'error' && (
            <p className="panel-message error">No se pudo cargar la matriz por especialidad.</p>
          )}
          {matrixStatus === 'success' && specialtyStatusSummary.length === 0 && (
            <p className="panel-message">No hay datos disponibles para la matriz.</p>
          )}
          {matrixStatus === 'success' && specialtyStatusSummary.length > 0 && (
            <MatrixTable items={specialtyStatusSummary} />
          )}
        </Panel>
        <EmptyState
          className="span-4"
          icon={BarChart3}
          title="Diagnosticos mas frecuentes"
          description="Aun no hay datos analiticos disponibles para esta seccion."
        />
      </section>
    </>
  );
}

export default DoctorsPage;
