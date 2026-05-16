import { Edit3, Trash2 } from 'lucide-react';

function RowActions() {
  return (
    <div className="row-actions">
      <button aria-label="Editar"><Edit3 size={16} /></button>
      <button aria-label="Eliminar"><Trash2 size={16} /></button>
    </div>
  );
}

export default RowActions;
