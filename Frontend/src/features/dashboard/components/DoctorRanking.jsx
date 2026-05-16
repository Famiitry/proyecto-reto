import { doctors } from '../../../data/mockData.js';

function DoctorRanking() {
  return (
    <div className="ranking-list">
      {doctors.map(([rank, name, specialty, total]) => (
        <div key={name}>
          <strong>{rank}</strong>
          <span>{name}<small>{specialty}</small></span>
          <b>{total}</b>
        </div>
      ))}
    </div>
  );
}

export default DoctorRanking;
