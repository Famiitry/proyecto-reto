function ConsultationSummaryList({ items }) {
  return (
    <div className="consultation-summary-list">
      {items.map((item) => (
        <div key={item.id_consulta}>
          <strong>Consulta #{item.id_consulta}</strong>
          <span>{new Date(item.fecha_atencion).toLocaleDateString('es-EC')}</span>
          <b>{item.motivo_principal}</b>
        </div>
      ))}
    </div>
  );
}

export default ConsultationSummaryList;
