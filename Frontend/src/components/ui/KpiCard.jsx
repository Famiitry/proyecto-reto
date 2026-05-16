function KpiCard({ icon: Icon, label, value, trend, tone = 'default' }) {
  return (
    <article className={`kpi-card ${tone}`}>
      <div>{Icon && <Icon size={18} />}{trend && <span>{trend}</span>}</div>
      <small>{label}</small>
      <strong>{value}</strong>
    </article>
  );
}

export default KpiCard;
