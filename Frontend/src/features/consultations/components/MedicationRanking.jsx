function MedicationRanking({ items }) {
  return (
    <div className="medication-ranking">
      {items.map((item) => (
        <div key={`${item.mes}-${item.medicamento}`}>
          <span>{item.mes}</span>
          <strong>{item.medicamento}</strong>
          <b>{item.total}</b>
        </div>
      ))}
    </div>
  );
}

export default MedicationRanking;
