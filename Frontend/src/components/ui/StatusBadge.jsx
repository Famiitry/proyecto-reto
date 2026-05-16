function StatusBadge({ label }) {
  return <span className={`status ${label.toLowerCase().replace(' ', '-')}`}>{label}</span>;
}

export default StatusBadge;
