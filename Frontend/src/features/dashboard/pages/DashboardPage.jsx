import { Activity, CalendarDays, ChartNoAxesCombined, Filter, X } from 'lucide-react';
import FilterSelect from '../../../components/ui/FilterSelect.jsx';
import KpiCard from '../../../components/ui/KpiCard.jsx';
import MiniBars from '../../../components/ui/MiniBars.jsx';
import PageHeader from '../../../components/ui/PageHeader.jsx';
import Panel from '../../../components/ui/Panel.jsx';
import DoctorRanking from '../components/DoctorRanking.jsx';
import SpecialtyBars from '../components/SpecialtyBars.jsx';
import TrendChart from '../components/TrendChart.jsx';

function DashboardPage() {
  return (
    <>
      <PageHeader
        title="Dashboard General"
        subtitle="Resumen operativo del sistema clinico"
        actions={
          <div className="filter-strip">
            <FilterSelect label="Rango de fechas" value="Ultimos 30 dias" />
            <FilterSelect label="Especialidad" value="Todas" />
            <button className="icon-button accent" aria-label="Aplicar filtros">
              <Filter size={18} />
            </button>
          </div>
        }
      />
      <section className="kpi-grid">
        <KpiCard icon={CalendarDays} label="Total de citas" value="48" trend="+12%" />
        <KpiCard icon={Activity} label="Citas atendidas" value="35" trend="+5%" tone="success" />
        <KpiCard icon={ChartNoAxesCombined} label="Citas programadas" value="9" trend="-2%" />
        <KpiCard icon={X} label="Citas canceladas" value="4" trend="+8%" tone="danger" />
      </section>
      <section className="dashboard-grid">
        <Panel className="span-8" title="Evolucion mensual de citas" subtitle="Comparativa por estado del servicio">
          <TrendChart />
        </Panel>
        <Panel className="span-4 dark-panel" title="Promedio movil (7d)" subtitle="Rendimiento semanal diario">
          <MiniBars values={[40, 65, 55, 85, 70, 95, 60]} />
          <strong className="big-number">1.0</strong>
          <span className="muted-light">Citas diarias promedio</span>
        </Panel>
        <Panel className="span-5" title="Top medicos">
          <DoctorRanking />
        </Panel>
        <Panel className="span-7" title="Citas por especialidad" subtitle="Distribucion de carga de trabajo">
          <SpecialtyBars />
        </Panel>
      </section>
    </>
  );
}

export default DashboardPage;
