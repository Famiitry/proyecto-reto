const MEDICAL_API_BASE_URL = '/api';

export async function fetchDoctorRanking() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/medicos/citas-rank`);

  if (!response.ok) {
    throw new Error('No se pudo cargar el ranking de medicos.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchAppointmentsBySpecialty() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/medicos/citas-especialidad?limit=100`);

  if (!response.ok) {
    throw new Error('No se pudo cargar la distribucion por especialidad.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchSpecialtyStatusSummary() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/medicos/especialidad-estado?limit=100`);

  if (!response.ok) {
    throw new Error('No se pudo cargar el resumen por especialidad y estado.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}
