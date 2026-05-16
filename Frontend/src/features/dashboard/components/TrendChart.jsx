function TrendChart() {
  return (
    <div className="trend-chart">
      <svg viewBox="0 0 800 220" preserveAspectRatio="none">
        <path d="M0,170 Q100,110 200,140 T400,70 T600,110 T800,50" />
        <path className="secondary" d="M0,195 Q120,170 220,180 T420,150 T610,165 T800,135" />
        <path className="danger" d="M0,205 Q140,200 240,205 T420,195 T620,205 T800,198" />
      </svg>
      <div className="axis-labels">
        {['May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov'].map((month) => <span key={month}>{month}</span>)}
      </div>
    </div>
  );
}

export default TrendChart;
