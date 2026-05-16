# ADR-000: Frontend simple funcional

**Estado:** Aceptado
**Fecha:** 2026-05-15
**Responsable:** Persona 2

## Contexto

El proyecto requiere una interfaz de usuario que permita visualizar datos del
sistema de gestión médica y consumir los endpoints REST. La interfaz debe usarse
durante la demo final para mostrar el flujo paciente → cita → consulta → receta.

El equipo tiene disponibilidad limitada (sábado y domingo). Por tanto, se
necesita una solución de frontend que sea rápida de desarrollar, fácil de
desplegar y suficiente para demostrar las funcionalidades principales.

## Decisión

Utilizar HTML, CSS y JavaScript vanilla para una SPA (Single Page Application)
sin frameworks ni dependencias externas, servida desde el mismo backend de la
API REST como archivos estáticos.

La interfaz incluirá:
- Vista de pacientes (tabla con búsqueda)
- Vista de citas (tabla con filtros por estado y médico)
- Vista de consultas / historia clínica (detalle de consulta con diagnósticos,
  signos vitales y recetas)
- Panel REST genérico para probar cualquier endpoint (URL, método, body y
  visualización de respuesta JSON)

## Alternativas consideradas

1. **React + Vite** — framework moderno con gran ecosistema. Descartado por:
   - Requiere Node.js, dependencias npm y build step
   - Tiempo de configuración considerable frente al beneficio para una demo
   - Agrega complejidad innecesaria para 4 vistas estáticas

2. **HTMX** — permite interactividad sin JavaScript pesado. Descartado por:
   - El equipo no tiene experiencia con HTMX
   - Requiere que el servidor genere HTML para cada interacción, acoplando
     presentación y lógica
   - El objetivo es mostrar consumo REST, no interacciones hipermedia

3. **Streamlit / Gradio** — herramientas Python para UI rápidas. Descartado por:
   - No aplican bien para un panel CRUD sobre Oracle
   - La interfaz debe demostrar consumo directo de API REST, no widgets
     generados automáticamente

## Consecuencias

- **Positivas:**
  - Cero dependencias externas, se abre en cualquier navegador
  - Misma base de código y puerto que la API (sin CORS)
  - Desarrollo rápido para el conjunto limitado de vistas
  - Fácil de entender y modificar por cualquier miembro del equipo
  - El panel REST genérico cubre la necesidad de demostrar cualquier endpoint
    sin tener que construir una vista específica

- **Negativas:**
  - No escala bien si en el futuro se requieren muchas vistas o interacciones
    complejas
  - Estilos manuales sin sistema de diseño
  - Sin hot-reload ni tooling moderno durante desarrollo

- **Mitigaciones:**
  - Se documenta el alcance limitado de la UI en el acta del proyecto
  - El panel REST genérico permite probar endpoints que no tengan vista dedicada
  - Si en el futuro el proyecto crece, migrar a React sería incremental
    (componentes auto-contenidos)
