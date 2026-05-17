import { Edit3, Trash2 } from 'lucide-react';

function RowActions({ onEdit, onDelete }) {
  return (
    <div className="row-actions">
      <button aria-label="Editar" onClick={onEdit}><Edit3 size={16} /></button>
      <button aria-label="Eliminar" onClick={onDelete}><Trash2 size={16} /></button>
    </div>
  );
}

export default RowActions;
