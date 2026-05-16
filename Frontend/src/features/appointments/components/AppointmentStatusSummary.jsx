const STATUS_META = [
  { key: 'atendida', label: 'Atendidas' },
  { key: 'programada', label: 'Programadas' },
  { key: 'cancelada', label: 'Canceladas' },
];

function AppointmentStatusSummary({ items }) {
  const currentMonth = items[0];
  const totals = STATUS_META.reduce((accumulator, status) => {
    accumulator[status.key] = currentMonth?.[status.key] ?? 0;
    return accumulator;
  }, {});
  const maxTotal = Math.max(...Object.values(totals), 1);

  return (
    <div className="appointment-status-summary">
      {STATUS_META.map((status) => (
        <div key={status.key}>
          <header>
            <span>{status.label}</span>
            <strong>{totals[status.key]}</strong>
          </header>
          <div>
            <span
              className={status.key}
              style={{ width: `${(totals[status.key] / maxTotal) * 100}%` }}
            />
          </div>
        </div>
      ))}
    </div>
  );
}

export default AppointmentStatusSummary;
