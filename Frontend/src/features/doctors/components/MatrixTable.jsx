import DataTable from '../../../components/ui/DataTable.jsx';

const STATUS_COLUMNS = ['ATENDIDA', 'CONFIRMADA', 'PROGRAMADA', 'CANCELADA', 'NO_ASISTIO'];

function MatrixTable({ items }) {
  const rowsBySpecialty = items
    .filter((item) => item.especialidad && item.estado)
    .reduce((accumulator, item) => {
      const currentRow = accumulator.get(item.especialidad) ?? {
        especialidad: item.especialidad,
        ATENDIDA: 0,
        CONFIRMADA: 0,
        PROGRAMADA: 0,
        CANCELADA: 0,
        NO_ASISTIO: 0,
      };

      currentRow[item.estado] = item.total;
      accumulator.set(item.especialidad, currentRow);
      return accumulator;
    }, new Map());

  const rows = Array.from(rowsBySpecialty.values()).map((row) => [
    row.especialidad,
    ...STATUS_COLUMNS.map((status) => row[status]),
  ]);

  return (
    <DataTable
      headers={['Especialidad', 'Atendida', 'Confirmada', 'Programada', 'Cancelada', 'No asistio']}
      rows={rows}
    />
  );
}

export default MatrixTable;
