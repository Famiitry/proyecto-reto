import Field from '../../../components/ui/Field.jsx';

function PatientQuickForm() {
  return (
    <form className="compact-form">
      <Field label="Nombres y apellidos" />
      <Field label="Cedula" />
      <Field label="Fecha de nacimiento" />
      <Field label="Sexo" />
      <button className="primary-button full">Guardar expediente</button>
    </form>
  );
}

export default PatientQuickForm;
