const MEDICAL_API_BASE_URL = '/api';

export async function fetchAppointmentsByMonthAndStatus() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/citas/citas-mes?limit=100`);

  if (!response.ok) {
    throw new Error('No se pudo cargar el resumen mensual de citas.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchAppointmentsByStatus() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/citas/citas-estado?limit=100`);

  if (!response.ok) {
    throw new Error('No se pudo cargar las citas por estado.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchAppointmentDetails() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/citas/detalle?limit=100`);

  if (!response.ok) {
    throw new Error('No se pudo cargar el detalle de citas.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}
