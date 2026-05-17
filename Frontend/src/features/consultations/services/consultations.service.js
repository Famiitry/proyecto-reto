const MEDICAL_API_BASE_URL = '/api';

export async function fetchRecentConsultations() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/consultas/recientes?limit=25`);

  if (!response.ok) {
    throw new Error('No se pudieron cargar las consultas recientes.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchLatestConsultationByCedula(cedula) {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/consultas/recientes/${encodeURIComponent(cedula)}`);

  if (!response.ok) {
    throw new Error('No se pudo cargar la última consulta por cédula.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchConsultationSummaries() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/consultas/resumen?limit=100`);

  if (!response.ok) {
    throw new Error('No se pudo cargar el resumen de consultas.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}

export async function createConsultation(payload) {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/consultas/create`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });

  if (!response.ok) throw new Error('No se pudo registrar la consulta.');
  return response.json().catch(() => ({}));
}
