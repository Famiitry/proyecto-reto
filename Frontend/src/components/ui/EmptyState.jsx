function EmptyState({ icon: Icon, title, description, className = '' }) {
  return (
    <section className={`panel empty-state ${className}`.trim()}>
      <Icon size={28} />
      <h2>{title}</h2>
      <p>{description}</p>
    </section>
  );
}

export default EmptyState;
