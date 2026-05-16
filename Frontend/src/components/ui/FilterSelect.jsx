function FilterSelect({ label, value }) {
  return (
    <label>
      <span>{label}</span>
      <select defaultValue={value}>
        <option>{value}</option>
      </select>
    </label>
  );
}

export default FilterSelect;
