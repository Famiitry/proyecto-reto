const MEDICAL_API_BASE_URL = '/api';

export async function fetchTopMedicationsByMonth() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/recetas/medicamentos-mas-recetados?limit=100`);

  if (!response.ok) {
    throw new Error('No se pudo cargar el ranking de medicamentos.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}
