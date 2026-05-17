import { useEffect, useState } from 'react';
import { ClipboardPlus } from 'lucide-react';
import Swal from 'sweetalert2';
import DataTable from '../../../components/ui/DataTable.jsx';
import MiniMetric from '../../../components/ui/MiniMetric.jsx';
import PageHeader from '../../../components/ui/PageHeader.jsx';
import Panel from '../../../components/ui/Panel.jsx';
import {
  fetchAppointmentsWithoutConsultation,
  fetchCie10Options,
} from '../../shared/services/relations.service.js';
import ConsultationSummaryList from '../components/ConsultationSummaryList.jsx';
import MedicationRanking from '../components/MedicationRanking.jsx';
import { createConsultation, fetchConsultationSummaries, fetchLatestConsultationByCedula, fetchRecentConsultations } from '../services/consultations.service.js';
import { fetchTopMedicationsByMonth } from '../services/prescriptions.service.js';

const EMPTY_FORM = {
  id_cita: '',
  motivo_consulta: '',
  enfermedad_actual: '',
  examen_fisico: '',
  plan_tratamiento: '',
  presion_sistolica: '',
  presion_diastolica: '',
  frec_cardiaca: '',
  frec_respiratoria: '',
  temperatura: '',
  saturacion_o2: '',
  peso_kg: '',
  talla_cm: '',
  codigo_cie_principal: '',
  observacion_diag: '',
  anamnesis_motivo: '',
  anamnesis_antecedentes: '',
  anamnesis_medicamentos: '',
  nlp_diagnostico: '',
  nlp_medicamentos: '',
};

const TABS = ['Información clínica', 'Signos vitales', 'Diagnóstico', 'Anamnesis / NLP'];

function ConsultationsPage() {
  const [recentConsultations, setRecentConsultations] = useState([]);
  const [recentConsultationsStatus, setRecentConsultationsStatus] = useState('loading');
  const [consultationSummaries, setConsultationSummaries] = useState([]);
  const [consultationSummaryStatus, setConsultationSummaryStatus] = useState('loading');
  const [topMedications, setTopMedications] = useState([]);
  const [topMedicationStatus, setTopMedicationStatus] = useState('loading');
  const [cedulaSearch, setCedulaSearch] = useState('');
  const [cedulaResults, setCedulaResults] = useState([]);
  const [cedulaStatus, setCedulaStatus] = useState('idle');

  const [activeTab, setActiveTab] = useState(0);
  const [form, setForm] = useState(EMPTY_FORM);
  const [citaOptions, setCitaOptions] = useState([]);
  const [cie10Query, setCie10Query] = useState('');
  const [cie10Options, setCie10Options] = useState([]);
  const [isSubmitting, setIsSubmitting] = useState(false);

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
        if (active) setRecentConsultationsStatus('error');
      }
    }

    loadRecentConsultations();
    return () => { active = false; };
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
        if (active) setConsultationSummaryStatus('error');
      }
    }

    loadConsultationSummaries();
    return () => { active = false; };
  }, []);

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
        if (active) setTopMedicationStatus('error');
      }
    }

    loadTopMedications();
    return () => { active = false; };
  }, []);

  const [citasLoading, setCitasLoading] = useState(false);

  function reloadCitaOptions() {
    setCitasLoading(true);
    fetchAppointmentsWithoutConsultation()
      .then(setCitaOptions)
      .catch(() => {})
      .finally(() => setCitasLoading(false));
  }

  useEffect(() => {
    reloadCitaOptions();
  }, []);

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchCie10Options(cie10Query)
        .then(setCie10Options)
        .catch(() => {});
    }, 300);
    return () => clearTimeout(timer);
  }, [cie10Query]);

  async function handleCedulaSearch(event) {
    event.preventDefault();
    const value = cedulaSearch.trim();
    if (!value) { setCedulaStatus('idle'); setCedulaResults([]); return; }
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

  function handleFormChange(event) {
    const { name, value } = event.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  }

  async function handleSubmit(event) {
    event.preventDefault();

    const sis = form.presion_sistolica ? Number(form.presion_sistolica) : null;
    const dia = form.presion_diastolica ? Number(form.presion_diastolica) : null;

    if (sis !== null && dia !== null && sis <= dia) {
      Swal.fire({
        icon: 'warning',
        title: 'Presión arterial inválida',
        text: `La presión sistólica (${sis}) debe ser mayor que la diastólica (${dia}).`,
        confirmButtonText: 'Corregir',
      });
      setActiveTab(1);
      return;
    }

    if ((sis !== null && dia === null) || (sis === null && dia !== null)) {
      Swal.fire({
        icon: 'warning',
        title: 'Presión arterial incompleta',
        text: 'Debes ingresar ambos valores de presión (sistólica y diastólica) o dejar los dos vacíos.',
        confirmButtonText: 'Corregir',
      });
      setActiveTab(1);
      return;
    }

    const payload = {
      id_cita:             Number(form.id_cita),
      motivo_consulta:     form.motivo_consulta,
      enfermedad_actual:   form.enfermedad_actual || null,
      examen_fisico:       form.examen_fisico || null,
      plan_tratamiento:    form.plan_tratamiento || null,
      presion_sistolica:   sis,
      presion_diastolica:  dia,
      frec_cardiaca:       form.frec_cardiaca        ? Number(form.frec_cardiaca)        : null,
      frec_respiratoria:   form.frec_respiratoria   ? Number(form.frec_respiratoria)   : null,
      temperatura:         form.temperatura          ? Number(form.temperatura)          : null,
      saturacion_o2:       form.saturacion_o2        ? Number(form.saturacion_o2)        : null,
      peso_kg:             form.peso_kg              ? Number(form.peso_kg)              : null,
      talla_cm:            form.talla_cm             ? Number(form.talla_cm)             : null,
      codigo_cie_principal: form.codigo_cie_principal || null,
      observacion_diag:    form.observacion_diag || null,
      anamnesis: {
        motivoPrincipal:          form.anamnesis_motivo || '',
        antecedentesPersonales:   form.anamnesis_antecedentes || '',
        medicamentosActuales:     form.anamnesis_medicamentos || '',
      },
      nlp_entidades: {
        diagnosticoSugerido:      form.nlp_diagnostico || '',
        medicamentosRecomendados: form.nlp_medicamentos
          ? form.nlp_medicamentos.split(',').map((s) => s.trim()).filter(Boolean)
          : [],
      },
    };

    setIsSubmitting(true);
    try {
      await createConsultation(payload);
      await Swal.fire({
        icon: 'success',
        title: '¡Consulta registrada!',
        text: 'El expediente clínico se guardó correctamente.',
        confirmButtonText: 'Aceptar',
      });
      setForm(EMPTY_FORM);
      setActiveTab(0);
      const updated = await fetchAppointmentsWithoutConsultation().catch(() => citaOptions);
      setCitaOptions(updated);
    } catch {
      Swal.fire({
        icon: 'error',
        title: 'Error al registrar',
        text: 'No se pudo guardar la consulta. Intenta de nuevo.',
        confirmButtonText: 'Cerrar',
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  const recentRows = recentConsultations.map((c) => [c.fecha, c.paciente, c.estado]);
  const cedulaRows = cedulaResults.map((c) => [c.cedula, c.paciente, c.fecha_atencion, c.motivo_consulta]);

  return (
    <>
      <PageHeader
        title="Registro de Consultas"
        subtitle="Gestión integral de expedientes y diagnósticos clínicos."
        actions={
          <button className="primary-button" onClick={() => setActiveTab(0)}>
            <ClipboardPlus size={16} />
            Nueva consulta
          </button>
        }
      />
      <section className="consultation-layout">
        <div className="stack">
          <Panel title="Consultas recientes">
            {recentConsultationsStatus === 'loading' && <p className="panel-message">Cargando consultas recientes...</p>}
            {recentConsultationsStatus === 'error' && <p className="panel-message error">No se pudieron cargar las consultas recientes.</p>}
            {recentConsultationsStatus === 'success' && recentRows.length === 0 && <p className="panel-message">No hay consultas recientes para mostrar.</p>}
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
                  onChange={(e) => setCedulaSearch(e.target.value)}
                  placeholder="0102000021"
                />
              </label>
              <button className="primary-button" type="submit">Buscar consulta</button>
            </form>
            <div style={{ marginTop: '16px' }}>
              {cedulaStatus === 'idle' && <p className="panel-message">Escribe una cédula para ver la última consulta.</p>}
              {cedulaStatus === 'loading' && <p className="panel-message">Buscando consulta...</p>}
              {cedulaStatus === 'error' && <p className="panel-message error">No se pudo cargar la consulta para esa cédula.</p>}
              {cedulaStatus === 'success' && cedulaRows.length === 0 && <p className="panel-message">No se encontraron consultas para esa cédula.</p>}
              {cedulaStatus === 'success' && cedulaRows.length > 0 && (
                <DataTable headers={['Cédula', 'Paciente', 'Fecha atención', 'Motivo']} rows={cedulaRows} />
              )}
            </div>
          </Panel>

          <Panel title="Resumen de consultas">
            {consultationSummaryStatus === 'loading' && <p className="panel-message">Cargando resumen de consultas...</p>}
            {consultationSummaryStatus === 'error' && <p className="panel-message error">No se pudo cargar el resumen de consultas.</p>}
            {consultationSummaryStatus === 'success' && consultationSummaries.length === 0 && <p className="panel-message">No hay datos disponibles para el resumen de consultas.</p>}
            {consultationSummaryStatus === 'success' && consultationSummaries.length > 0 && (
              <ConsultationSummaryList items={consultationSummaries} />
            )}
          </Panel>

          <Panel title="Top medicamentos">
            {topMedicationStatus === 'loading' && <p className="panel-message">Cargando medicamentos...</p>}
            {topMedicationStatus === 'error' && <p className="panel-message error">No se pudo cargar el ranking de medicamentos.</p>}
            {topMedicationStatus === 'success' && topMedications.length === 0 && <p className="panel-message">No hay datos disponibles para el ranking de medicamentos.</p>}
            {topMedicationStatus === 'success' && topMedications.length > 0 && (
              <MedicationRanking items={topMedications} />
            )}
          </Panel>
        </div>

        <Panel title="Nueva consulta clínica" className="consultation-form-panel">
          <div className="tabs">
            {TABS.map((tab, index) => (
              <button
                key={tab}
                type="button"
                className={activeTab === index ? 'active' : ''}
                onClick={() => setActiveTab(index)}
              >
                {tab}
              </button>
            ))}
          </div>

          <form onSubmit={handleSubmit}>
            {activeTab === 0 && (
              <div className="form-grid">
                <div style={{ gridColumn: '1 / -1', display: 'flex', flexDirection: 'column', gap: '4px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span>Cita a atender</span>
                    <button
                      type="button"
                      className="secondary-button"
                      onClick={reloadCitaOptions}
                      disabled={citasLoading}
                      style={{ fontSize: '0.75rem', padding: '2px 8px' }}
                    >
                      {citasLoading ? 'Cargando...' : '↻ Recargar citas'}
                    </button>
                  </div>
                  <select name="id_cita" value={form.id_cita} onChange={handleFormChange} required>
                    <option value="">Selecciona una cita</option>
                    {citaOptions.map((c) => (
                      <option key={c.id_cita} value={c.id_cita}>
                        #{c.id_cita} — {c.fecha_hora} | {c.paciente} / {c.medico}
                      </option>
                    ))}
                  </select>
                </div>
                <label style={{ gridColumn: '1 / -1' }}>
                  <span>Motivo de consulta *</span>
                  <textarea name="motivo_consulta" value={form.motivo_consulta} onChange={handleFormChange} rows={2} required placeholder="Describe el motivo principal..." />
                </label>
                <label style={{ gridColumn: '1 / -1' }}>
                  <span>Enfermedad actual / antecedentes</span>
                  <textarea name="enfermedad_actual" value={form.enfermedad_actual} onChange={handleFormChange} rows={3} placeholder="Descripción de la enfermedad actual..." />
                </label>
                <label style={{ gridColumn: '1 / -1' }}>
                  <span>Examen físico</span>
                  <textarea name="examen_fisico" value={form.examen_fisico} onChange={handleFormChange} rows={3} placeholder="Hallazgos del examen físico..." />
                </label>
                <label style={{ gridColumn: '1 / -1' }}>
                  <span>Plan de tratamiento</span>
                  <textarea name="plan_tratamiento" value={form.plan_tratamiento} onChange={handleFormChange} rows={3} placeholder="Indicaciones y plan terapéutico..." />
                </label>
              </div>
            )}

            {activeTab === 1 && (
              <div className="form-grid">
                <label>
                  <span>Presión sistólica (mmHg)</span>
                  <input type="number" name="presion_sistolica" value={form.presion_sistolica} onChange={handleFormChange} placeholder="120" />
                </label>
                <label>
                  <span>Presión diastólica (mmHg)</span>
                  <input type="number" name="presion_diastolica" value={form.presion_diastolica} onChange={handleFormChange} placeholder="80" />
                </label>
                <label>
                  <span>Frec. cardíaca (lpm)</span>
                  <input type="number" name="frec_cardiaca" value={form.frec_cardiaca} onChange={handleFormChange} placeholder="72" />
                </label>
                <label>
                  <span>Frec. respiratoria (rpm)</span>
                  <input type="number" name="frec_respiratoria" value={form.frec_respiratoria} onChange={handleFormChange} placeholder="18" />
                </label>
                <label>
                  <span>Temperatura (°C)</span>
                  <input type="number" step="0.1" name="temperatura" value={form.temperatura} onChange={handleFormChange} placeholder="36.5" />
                </label>
                <label>
                  <span>Saturación O₂ (%)</span>
                  <input type="number" name="saturacion_o2" value={form.saturacion_o2} onChange={handleFormChange} placeholder="98" />
                </label>
                <label>
                  <span>Peso (kg)</span>
                  <input type="number" step="0.1" name="peso_kg" value={form.peso_kg} onChange={handleFormChange} placeholder="70.5" />
                </label>
                <label>
                  <span>Talla (cm)</span>
                  <input type="number" step="0.1" name="talla_cm" value={form.talla_cm} onChange={handleFormChange} placeholder="170.0" />
                </label>
                <div className="vitals-grid" style={{ gridColumn: '1 / -1' }}>
                  <MiniMetric label="Presión art." value={form.presion_sistolica && form.presion_diastolica ? `${form.presion_sistolica}/${form.presion_diastolica}` : '—'} />
                  <MiniMetric label="Frec. card." value={form.frec_cardiaca ? `${form.frec_cardiaca} lpm` : '—'} />
                  <MiniMetric label="Temp." value={form.temperatura ? `${form.temperatura} °C` : '—'} />
                  <MiniMetric label="Saturación" value={form.saturacion_o2 ? `${form.saturacion_o2}%` : '—'} />
                </div>
              </div>
            )}

            {activeTab === 2 && (
              <div className="form-grid">
                <label style={{ gridColumn: '1 / -1' }}>
                  <span>Buscar CIE-10</span>
                  <input
                    type="text"
                    value={cie10Query}
                    onChange={(e) => setCie10Query(e.target.value)}
                    placeholder="Escribe código o descripción (ej: cefalea, R51)..."
                  />
                </label>
                <label style={{ gridColumn: '1 / -1' }}>
                  <span>Diagnóstico principal (CIE-10)</span>
                  <select name="codigo_cie_principal" value={form.codigo_cie_principal} onChange={handleFormChange}>
                    <option value="">Sin diagnóstico seleccionado</option>
                    {cie10Options.map((c) => (
                      <option key={c.codigo} value={c.codigo}>
                        {c.codigo} — {c.descripcion}
                      </option>
                    ))}
                  </select>
                </label>
                <label style={{ gridColumn: '1 / -1' }}>
                  <span>Observación del diagnóstico</span>
                  <textarea name="observacion_diag" value={form.observacion_diag} onChange={handleFormChange} rows={3} placeholder="Notas adicionales sobre el diagnóstico..." />
                </label>
              </div>
            )}

            {activeTab === 3 && (
              <div className="form-grid">
                <label style={{ gridColumn: '1 / -1' }}>
                  <span>Motivo principal (anamnesis)</span>
                  <textarea name="anamnesis_motivo" value={form.anamnesis_motivo} onChange={handleFormChange} rows={2} placeholder="Motivo principal referido por el paciente..." />
                </label>
                <label style={{ gridColumn: '1 / -1' }}>
                  <span>Antecedentes personales</span>
                  <textarea name="anamnesis_antecedentes" value={form.anamnesis_antecedentes} onChange={handleFormChange} rows={3} placeholder="Alergias, cirugías previas, enfermedades crónicas..." />
                </label>
                <label style={{ gridColumn: '1 / -1' }}>
                  <span>Medicamentos actuales</span>
                  <textarea name="anamnesis_medicamentos" value={form.anamnesis_medicamentos} onChange={handleFormChange} rows={2} placeholder="Medicamentos que toma actualmente..." />
                </label>
                <label style={{ gridColumn: '1 / -1' }}>
                  <span>Diagnóstico sugerido (NLP)</span>
                  <input type="text" name="nlp_diagnostico" value={form.nlp_diagnostico} onChange={handleFormChange} placeholder="Cefalea tensional, faringitis viral..." />
                </label>
                <label style={{ gridColumn: '1 / -1' }}>
                  <span>Medicamentos recomendados (NLP) — separados por coma</span>
                  <input type="text" name="nlp_medicamentos" value={form.nlp_medicamentos} onChange={handleFormChange} placeholder="Paracetamol, Ibuprofeno..." />
                </label>
              </div>
            )}

            <div className="form-footer">
              <span>{activeTab < TABS.length - 1 ? `Paso ${activeTab + 1} de ${TABS.length}` : 'Listo para guardar'}</span>
              <div>
                {activeTab > 0 && (
                  <button className="secondary-button" type="button" onClick={() => setActiveTab((t) => t - 1)}>
                    Atrás
                  </button>
                )}
                {activeTab < TABS.length - 1 && (
                  <button className="primary-button" type="button" onClick={() => setActiveTab((t) => t + 1)}>
                    Siguiente
                  </button>
                )}
                {activeTab === TABS.length - 1 && (
                  <button className="primary-button" type="submit" disabled={isSubmitting}>
                    {isSubmitting ? 'Guardando...' : 'Finalizar consulta'}
                  </button>
                )}
              </div>
            </div>
          </form>
        </Panel>
      </section>
    </>
  );
}

export default ConsultationsPage;
