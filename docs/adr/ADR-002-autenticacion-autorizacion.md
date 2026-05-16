# ADR-002: Autenticación y autorización propuestas

**Estado:** Aceptado
**Fecha:** 2026-05-15
**Responsable:** Persona 2

## Contexto

La API REST del sistema de gestión médica expone datos sensibles de pacientes
(historias clínicas, diagnósticos, recetas). Es necesario definir un mecanismo
de autenticación y autorización que proteja los endpoints.

El proyecto es una demo académica con un equipo pequeño. La prioridad es mostrar
el flujo funcional completo, no implementar un sistema de seguridad de nivel
producción.

## Decisión

Utilizar **API Key via header HTTP** como mecanismo de autenticación para la
demo, con una key única predefinida en variables de entorno del servidor.

Estructura:
- Header: `X-API-Key: <key>`
- La key se verifica en un middleware aplicado a todos los endpoints excepto la
  UI estática y la documentación OpenAPI
- En caso de key inválida o ausente, se retorna `401 Unauthorized`
- La UI consume la API desde el mismo origen, incluyendo la key en cada
  petición fetch

**Propuesta de evolución futura (no implementada en esta fase):**
- JWT con refresh tokens para autenticación de sesión
- Roles diferenciados (admin, médico, paciente) con autorización granular por
  endpoint y recurso
- OAuth 2.0 para integración con sistemas externos que expongan datos de
  pacientes a aplicaciones de terceros
- Rate limiting por API Key para prevenir abuso

## Alternativas consideradas

1. **Sin autenticación** — endpoints abiertos.
   - Se descarta por: expone datos sensibles sin ninguna protección. Incluso en
     una demo académica, se debe mostrar conciencia sobre seguridad de datos
     clínicos.

2. **JWT con login/registro** — sistema completo de sesiones.
   - Se descarta por: requiere implementar gestión de usuarios, contraseñas
     hasheadas, base de datos de sesiones o secretos, y pantallas de
     login/registro. Agrega complejidad desproporcionada para la demo.

3. **HTTP Basic Auth** — usuario y contraseña en cada petición.
   - Se descarta por: el header `Authorization: Basic <base64>` transmite
     credenciales en cada petición, es menos flexible y no escala a roles.
     Además, los navegadores cachean las credenciales de Basic Auth, lo que
     puede interferir con la demo.

4. **OAuth 2.0 / OpenID Connect** — estándar de delegación.
   - Se descarta por: requiere un servidor de autorización separado y flujos
     complejos (authorization code, PKCE). Totalmente desproporcionado para
     una demo de 5-8 minutos.

## Consecuencias

- **Positivas:**
  - Implementación trivial: un middleware de 10 líneas
  - Fácil de probar desde Postman (agregar un header)
  - La UI puede incluir la key en sus peticiones automáticamente
  - Demuestra conocimiento de seguridad API sin complejidad excesiva
  - Suficiente para proteger la demo contra accesos accidentales

- **Negativas:**
  - No hay granularidad por rol/usuario
  - La API Key se almacena en texto plano en el servidor
  - Si la key se filtra, cualquier persona puede acceder a todos los endpoints
  - No apto para producción con multi-tenencia

- **Mitigaciones:**
  - Se documenta explícitamente que esta es una solución de demo, no de
    producción
  - La key se configura por variable de entorno (.env), no hardcodeada en el
    código fuente ni en el repositorio
  - Se propone la evolución futura a JWT + roles en el informe final
  - Se incluye una sección de "mejora futura: seguridad" en la documentación
    técnica
