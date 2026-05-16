function SimpleList({ items }) {
  return (
    <ul className="simple-list">
      {items.map((item) => <li key={item}>{item}</li>)}
    </ul>
  );
}

export default SimpleList;
