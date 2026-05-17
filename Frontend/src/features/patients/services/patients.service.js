const MEDICAL_API_BASE_URL = '/api';

export async function createPatient(payload) {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/pacientes/create`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    throw new Error('No se pudo registrar el paciente.');
  }

  return response.json().catch(() => ({}));
}

export async function fetchPatientAppointmentGaps() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/pacientes/brachas-citas-paciente?limit=100`);

  if (!response.ok) {
    throw new Error('No se pudo cargar las brechas entre citas por paciente.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchPatientUsageScores() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/pacientes/paciente-promedio-satisfaccion?limit=100`);

  if (!response.ok) {
    throw new Error('No se pudo cargar el uso de pacientes frente al promedio.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchTopAllergies() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/pacientes/rank-alergias?limit=100`);

  if (!response.ok) {
    throw new Error('No se pudo cargar el ranking de alergias.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchPatientWaitTimes() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/pacientes/promedio-atencion?limit=100`);

  if (!response.ok) {
    throw new Error('No se pudo cargar el promedio de espera por paciente.');
  }

  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchPatientsList(offset = 0, limit = 6) {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/pacientes/listar?limit=${limit}&offset=${offset}`);

  if (!response.ok) {
    throw new Error('No se pudo cargar el listado de pacientes.');
  }

  return response.json();
}
