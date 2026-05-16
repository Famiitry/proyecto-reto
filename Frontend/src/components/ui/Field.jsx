function Field({ label, value = '', textarea = false, wide = false, large = false }) {
  return (
    <label className={wide ? 'wide' : ''}>
      <span>{label}</span>
      {textarea ? <textarea rows={large ? 5 : 3} defaultValue={value} /> : <input defaultValue={value} />}
    </label>
  );
}

export default Field;
