function AllergyRanking({ items }) {
  const groupedItems = items.reduce((groups, item) => {
    groups[item.categoria] ??= [];
    groups[item.categoria].push(item);
    return groups;
  }, {});

  return (
    <div className="allergy-ranking">
      {Object.entries(groupedItems).map(([category, allergies]) => (
        <section key={category}>
          <h3>{category}</h3>
          {allergies.map((allergy) => (
            <div key={`${allergy.categoria}-${allergy.nombre}-${allergy.severidad}`}>
              <span>{allergy.nombre}</span>
              <b>{allergy.severidad}</b>
            </div>
          ))}
        </section>
      ))}
    </div>
  );
}

export default AllergyRanking;
