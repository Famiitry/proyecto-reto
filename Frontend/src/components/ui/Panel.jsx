function Panel({ title, subtitle, className = '', children }) {
  return (
    <section className={`panel ${className}`.trim()}>
      {(title || subtitle) && (
        <header className="panel-header">
          {title && <h2>{title}</h2>}
          {subtitle && <p>{subtitle}</p>}
        </header>
      )}
      {children}
    </section>
  );
}

export default Panel;
