const STATUS_ORDER = ['ATENDIDA', 'CONFIRMADA', 'PROGRAMADA', 'CANCELADA', 'NO_ASISTIO'];

const STATUS_LABELS = {
  ATENDIDA: 'Atendida',
  CONFIRMADA: 'Confirmada',
  PROGRAMADA: 'Programada',
  CANCELADA: 'Cancelada',
  NO_ASISTIO: 'No asistio',
};

function MonthlyStateChart({ items }) {
  const monthlyRows = items.filter((item) => item.mes && item.estado);
  const totalsByMonth = items
    .filter((item) => item.mes && item.estado === null)
    .reduce((accumulator, item) => {
      accumulator[item.mes] = item.total_citas;
      return accumulator;
    }, {});

  const months = [...new Set(monthlyRows.map((item) => item.mes))].sort();
  const valuesByMonth = monthlyRows.reduce((accumulator, item) => {
    accumulator[item.mes] ??= {};
    accumulator[item.mes][item.estado] = item.total_citas;
    return accumulator;
  }, {});
  const maxTotal = Math.max(...Object.values(totalsByMonth), 1);

  return (
    <>
      <div className="monthly-state-chart">
        {months.map((month) => (
          <div key={month}>
            <div className="monthly-state-bar" style={{ height: `${(totalsByMonth[month] / maxTotal) * 100}%` }}>
              {STATUS_ORDER.map((status) => {
                const value = valuesByMonth[month]?.[status] ?? 0;
                const monthTotal = totalsByMonth[month] || 1;

                return value > 0 ? (
                  <span
                    key={status}
                    className={status.toLowerCase()}
                    style={{ height: `${(value / monthTotal) * 100}%` }}
                    title={`${STATUS_LABELS[status]}: ${value}`}
                  />
                ) : null;
              })}
            </div>
            <small>{month.slice(2)}</small>
          </div>
        ))}
      </div>
      <div className="chart-legend">
        {STATUS_ORDER.map((status) => (
          <span key={status}>
            <i className={status.toLowerCase()} />
            {STATUS_LABELS[status]}
          </span>
        ))}
      </div>
    </>
  );
}

export default MonthlyStateChart;
