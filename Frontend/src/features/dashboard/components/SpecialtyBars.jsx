const specialties = [
  ['Cardiologia', 70, 20, 10],
  ['Dermatologia', 67, 16, 17],
  ['Endocrinologia', 71, 14, 15],
  ['Medicina general', 73, 18, 9],
];

function SpecialtyBars() {
  return (
    <div className="specialty-bars">
      {specialties.map(([label, attended, scheduled, cancelled]) => (
        <div key={label}>
          <header><span>{label}</span><b>{attended + scheduled + cancelled} total</b></header>
          <div>
            <span style={{ width: `${attended}%` }} />
            <span style={{ width: `${scheduled}%` }} />
            <span style={{ width: `${cancelled}%` }} />
          </div>
        </div>
      ))}
    </div>
  );
}

export default SpecialtyBars;
