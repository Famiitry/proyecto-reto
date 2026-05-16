function SpecialtyDistribution({ items }) {
  const totals = items
    .filter((item) => item.especialidad && item.mes === null)
    .sort((a, b) => b.total - a.total);

  const maxTotal = Math.max(...totals.map((item) => item.total), 1);

  return (
    <div className="specialty-distribution">
      {totals.map((item) => (
        <div key={item.especialidad}>
          <header>
            <span>{item.especialidad}</span>
            <strong>{item.total}</strong>
          </header>
          <div>
            <span style={{ width: `${(item.total / maxTotal) * 100}%` }} />
          </div>
        </div>
      ))}
    </div>
  );
}

export default SpecialtyDistribution;
