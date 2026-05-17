function Field({
  label,
  value = '',
  textarea = false,
  wide = false,
  large = false,
  name,
  type = 'text',
  placeholder,
  required = false,
}) {
  return (
    <label className={wide ? 'wide' : ''}>
      <span>{label}</span>
      {textarea ? (
        <textarea
          name={name}
          rows={large ? 5 : 3}
          defaultValue={value}
          placeholder={placeholder}
          required={required}
        />
      ) : (
        <input
          name={name}
          type={type}
          defaultValue={value}
          placeholder={placeholder}
          required={required}
        />
      )}
    </label>
  );
}

export default Field;
