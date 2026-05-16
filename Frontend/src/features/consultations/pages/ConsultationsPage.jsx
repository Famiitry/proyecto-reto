import { useEffect, useState } from 'react';
import { ClipboardPlus } from 'lucide-react';
import DataTable from '../../../components/ui/DataTable.jsx';
import Field from '../../../components/ui/Field.jsx';
import MiniMetric from '../../../components/ui/MiniMetric.jsx';
import PageHeader from '../../../components/ui/PageHeader.jsx';
import Panel from '../../../components/ui/Panel.jsx';
import ConsultationSummaryList from '../components/ConsultationSummaryList.jsx';
import MedicationRanking from '../components/MedicationRanking.jsx';
import {
  fetchConsultationSummaries,
  fetchLatestConsultationByCedula,
  fetchRecentConsultations,
} from '../services/consultations.service.js';
import { fetchTopMedicationsByMonth } from '../services/prescriptions.service.js';

function ConsultationsPage() {
  const [recentConsultations, setRecentConsultations] = useState([]);
  const [recentConsultationsStatus, setRecentConsultationsStatus] = useState('loading');
  const [consultationSummaries, setConsultationSummaries] = useState([]);
  const [consultationSummaryStatus, setConsultationSummaryStatus] = useState('loading');
  const [topMedications, setTopMedications] = useState([]);
  const [topMedicationStatus, setTopMedicationStatus] = useState('loading');
  const [cedulaSearch, setCedulaSearch] = useState('0102000021');
  const [cedulaResults, setCedulaResults] = useState([]);
  const [cedulaStatus, setCedulaStatus] = useState('idle');

  useEffect(() => {
    let active = true;

    async function loadRecentConsultations() {
      try {
        setRecentConsultationsStatus('loading');
        const consultations = await fetchRecentConsultations();

        if (active) {
          setRecentConsultations(consultations);
          setRecentConsultationsStatus('success');
        }
      } catch {
        if (active) {
          setRecentConsultationsStatus('error');
        }
      }
    }

    loadRecentConsultations();

    return () => {
      active = false;
    };
  }, []);

  useEffect(() => {
    let active = true;

    async function loadConsultationSummaries() {
      try {
        setConsultationSummaryStatus('loading');
        const summaries = await fetchConsultationSummaries();

        if (active) {
          setConsultationSummaries(summaries);
          setConsultationSummaryStatus('success');
        }
      } catch {
        if (active) {
          setConsultationSummaryStatus('error');
        }
      }
    }

    loadConsultationSummaries();

    return () => {
      active = false;
    };
  }, []);

  async function handleCedulaSearch(event) {
    event.preventDefault();

    const value = cedulaSearch.trim();

    if (!value) {
      setCedulaStatus('idle');
      setCedulaResults([]);
      return;
    }

    try {
      setCedulaStatus('loading');
      const consultations = await fetchLatestConsultationByCedula(value);
      setCedulaResults(consultations);
      setCedulaStatus('success');
    } catch {
      setCedulaResults([]);
      setCedulaStatus('error');
    }
  }

  const recentRows = recentConsultations.map((consultation) => [
    consultation.fecha,
    consultation.paciente,
    consultation.estado,
  ]);

  const cedulaRows = cedulaResults.map((consultation) => [
    consultation.cedula,
    consultation.paciente,
    consultation.fecha_atencion,
    consultation.motivo_consulta,
  ]);

  useEffect(() => {
    let active = true;

    async function loadTopMedications() {
      try {
        setTopMedicationStatus('loading');
        const medications = await fetchTopMedicationsByMonth();

        if (active) {
          setTopMedications(medications);
          setTopMedicationStatus('success');
        }
      } catch {
        if (active) {
          setTopMedicationStatus('error');
        }
      }
    }

    loadTopMedications();

    return () => {
      active = false;
    };
  }, []);

  return (
    <>
      <PageHeader
        title="Registro de Consultas"
        subtitle="Gestion integral de expedientes y diagnosticos clinicos."
        actions={
          <button className="primary-button">
            <ClipboardPlus size={16} />
            Nueva consulta
          </button>
        }
      />
      <section className="consultation-layout">
        <div className="stack">
          <Panel title="Consultas recientes">
            {recentConsultationsStatus === 'loading' && <p className="panel-message">Cargando consultas recientes...</p>}
            {recentConsultationsStatus === 'error' && (
              <p className="panel-message error">No se pudieron cargar las consultas recientes.</p>
            )}
            {recentConsultationsStatus === 'success' && recentRows.length === 0 && (
              <p className="panel-message">No hay consultas recientes para mostrar.</p>
            )}
            {recentConsultationsStatus === 'success' && recentRows.length > 0 && (
              <DataTable headers={['Fecha', 'Paciente', 'Estado']} rows={recentRows} />
            )}
          </Panel>

          <Panel title="Última consulta por cédula">
            <form className="compact-form" onSubmit={handleCedulaSearch}>
              <label>
                <span>Cédula del paciente</span>
                <input
                  value={cedulaSearch}
                  onChange={(event) => setCedulaSearch(event.target.value)}
                  placeholder="0102000021"
                />
              </label>
              <button className="primary-button" type="submit">
                Buscar consulta
              </button>
            </form>

            <div style={{ marginTop: '16px' }}>
              {cedulaStatus === 'idle' && <p className="panel-message">Escribe una cédula para ver la última consulta.</p>}
              {cedulaStatus === 'loading' && <p className="panel-message">Buscando consulta...</p>}
              {cedulaStatus === 'error' && (
                <p className="panel-message error">No se pudo cargar la consulta para esa cédula.</p>
              )}
              {cedulaStatus === 'success' && cedulaRows.length === 0 && (
                <p className="panel-message">No se encontraron consultas para esa cédula.</p>
              )}
              {cedulaStatus === 'success' && cedulaRows.length > 0 && (
                <DataTable
                  headers={['Cédula', 'Paciente', 'Fecha atención', 'Motivo']}
                  rows={cedulaRows}
                />
              )}
            </div>
          </Panel>

          <Panel title="Resumen de consultas">
            {consultationSummaryStatus === 'loading' && <p className="panel-message">Cargando resumen de consultas...</p>}
            {consultationSummaryStatus === 'error' && (
              <p className="panel-message error">No se pudo cargar el resumen de consultas.</p>
            )}
            {consultationSummaryStatus === 'success' && consultationSummaries.length === 0 && (
              <p className="panel-message">No hay datos disponibles para el resumen de consultas.</p>
            )}
            {consultationSummaryStatus === 'success' && consultationSummaries.length > 0 && (
              <ConsultationSummaryList items={consultationSummaries} />
            )}
          </Panel>
          <Panel title="Top medicamentos">
            {topMedicationStatus === 'loading' && <p className="panel-message">Cargando medicamentos...</p>}
            {topMedicationStatus === 'error' && (
              <p className="panel-message error">No se pudo cargar el ranking de medicamentos.</p>
            )}
            {topMedicationStatus === 'success' && topMedications.length === 0 && (
              <p className="panel-message">No hay datos disponibles para el ranking de medicamentos.</p>
            )}
            {topMedicationStatus === 'success' && topMedications.length > 0 && (
              <MedicationRanking items={topMedications} />
            )}
          </Panel>
        </div>
        <Panel title="Nueva consulta clinica" className="consultation-form-panel">
          <div className="tabs">
            <button className="active">Informacion clinica</button>
            <button>Signos vitales</button>
            <button>Diagnostico</button>
            <button>Anamnesis / NLP</button>
          </div>
          <form className="form-grid">
            <Field label="Folio de cita" value="#CIT-2026-1042" />
            <Field label="Tipo de consulta" value="Primera vez" />
            <Field label="Motivo de consulta" wide textarea />
            <Field label="Enfermedad actual / antecedentes" wide textarea large />
          </form>
          <div className="vitals-grid">
            <MiniMetric label="Presion art." value="120/80" />
            <MiniMetric label="Frec. card." value="72 bpm" />
            <MiniMetric label="Temp." value="36.5 C" />
            <MiniMetric label="Saturacion" value="98%" />
          </div>
          <div className="form-footer">
            <span>Borrador guardado hace 2 minutos</span>
            <div>
              <button className="secondary-button">Cancelar</button>
              <button className="primary-button">Finalizar consulta</button>
            </div>
          </div>
        </Panel>
      </section>
    </>
  );
}

export default ConsultationsPage;
