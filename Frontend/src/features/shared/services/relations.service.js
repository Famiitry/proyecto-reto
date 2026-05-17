const MEDICAL_API_BASE_URL = '/api';

export async function fetchParroquiaOptions(provincia = '', canton = '') {
  const params = new URLSearchParams();
  if (provincia) params.set('provincia', provincia);
  if (canton) params.set('canton', canton);
  params.set('limit', '500');
  const response = await fetch(`${MEDICAL_API_BASE_URL}/relaciones/parroquias?${params}`);
  if (!response.ok) throw new Error('No se pudieron cargar las parroquias.');
  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchPatientOptions() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/relaciones/pacientes?limit=200`);
  if (!response.ok) throw new Error('No se pudieron cargar los pacientes.');
  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchDoctorOptions() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/relaciones/medicos?limit=200`);
  if (!response.ok) throw new Error('No se pudieron cargar los médicos.');
  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchOfficeOptions() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/relaciones/consultorios`);
  if (!response.ok) throw new Error('No se pudieron cargar los consultorios.');
  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchAppointmentStatuses() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/relaciones/estados-cita`);
  if (!response.ok) throw new Error('No se pudieron cargar los estados de cita.');
  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchAppointmentsWithoutConsultation() {
  const response = await fetch(`${MEDICAL_API_BASE_URL}/relaciones/citas-sin-consulta?limit=200`);
  if (!response.ok) throw new Error('No se pudieron cargar las citas disponibles.');
  const payload = await response.json();
  return payload.items ?? [];
}

export async function fetchCie10Options(q = '') {
  const params = q ? `?q=${encodeURIComponent(q)}&limit=50` : '?limit=50';
  const response = await fetch(`${MEDICAL_API_BASE_URL}/relaciones/cie10${params}`);
  if (!response.ok) throw new Error('No se pudo buscar en CIE-10.');
  const payload = await response.json();
  return payload.items ?? [];
}
