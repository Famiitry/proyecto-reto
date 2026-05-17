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

export async function createAppointment(payload) {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/citas/create`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });

  if (!response.ok) throw new Error('No se pudo registrar la cita.');
  return response.json().catch(() => ({}));
}

export async function updateAppointment(payload) {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/citas/update`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });

  if (!response.ok) throw new Error('No se pudo actualizar la cita.');
  return response.json().catch(() => ({}));
}

export async function deleteAppointment(id_cita) {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/citas/delete`, {
    method: 'DELETE',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ id_cita }),
  });

  if (!response.ok) throw new Error('No se pudo eliminar la cita.');
  return response.json().catch(() => ({}));
}
