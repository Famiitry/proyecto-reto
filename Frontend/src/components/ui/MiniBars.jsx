function MiniBars({ values }) {
  return (
    <div className="mini-bars">
      {values.map((value, index) => <span key={`${value}-${index}`} style={{ height: `${value}%` }} />)}
    </div>
  );
}

export default MiniBars;
