# Plan operativo para completar el reto de Gestion de BDD

## Resumen

- Objetivo: entregar una solucion defendible para el caso de estudio de salud, basada en Oracle y en el esquema ya creado en `ddl.sql`, antes del lunes 18 de mayo de 2026 por la noche.
- Estrategia: intentar cubrir todos los entregables aplicables, priorizando evidencia funcional, documentacion clara y una demo estable.
- Exclusion acordada: se elimina por completo la parte de IA/LN. No se incluiran D9, panel NLQ ni funcionalidades de lenguaje natural.
- Resultado final esperado: base de datos ejecutable, consultas optimizadas con evidencia, API REST documentada, JSON Duality Views, interfaz simple funcional, dataset de salud, documentacion y demo.

## Organizacion del equipo

### Persona 1: Datos y optimizacion

Rol general: construir y demostrar la parte mas fuerte de base de datos del proyecto.

Debe encargarse de:

- analizar por que Oracle relacional es adecuado para el caso de salud
- mantener y corregir el esquema fisico en SQL
- preparar scripts ejecutables de creacion, carga, consultas y pruebas
- disenar el dataset clinico minimo que sostendra toda la demo
- implementar triggers, funciones y procedimientos almacenados
- construir las JSON Duality Views
- crear el catalogo de consultas avanzadas y evidenciar su optimizacion
- entregar capturas, scripts y resultados que Persona 3 usara en la documentacion final

### Persona 2: Servicios y experiencia funcional

Rol general: convertir la base de datos en una solucion consumible y demostrable.

Debe encargarse de:

- definir las decisiones tecnicas de arquitectura y documentarlas en ADRs
- elaborar el diagrama de arquitectura y apoyar los diagramas de datos
- publicar endpoints REST para las entidades principales del sistema
- documentar la API con OpenAPI/Swagger y preparar la coleccion Postman
- construir una UI minima que consuma los servicios y muestre resultados
- integrar en una sola ruta de demo el flujo paciente -> cita -> consulta -> receta
- entregar capturas, ejemplos de peticiones y respuestas para la documentacion final

### Persona 3: Direccion, validacion y entrega

Rol general: convertir el trabajo tecnico en una entrega coherente, evaluable y presentable.

Debe encargarse de:

- redactar el acta del proyecto, backlog, alcance, restricciones, riesgos y criterios de exito
- construir la historia de negocio del caso de salud y definir KPIs claros
- integrar resultados tecnicos en el informe final
- mantener el README maestro y la guia de despliegue
- verificar que cada entregable tenga evidencia, ubicacion y nombre claros
- preparar slides, guion y video demo
- revisar que la exclusion de IA/LN quede explicita y consistente en toda la entrega

### Trabajo compartido obligatorio

- Todos prueban el flujo completo antes de entregar.
- Todos revisan ortografia, consistencia visual y referencias cruzadas.
- Todos deben poder explicar al menos:
  - el problema
  - el modelo de datos
  - una consulta optimizada
  - un endpoint REST
  - el caso de estudio

## Trabajo por entregables

### D0. Acta de proyecto + backlog

Responsable: Persona 3

Debe producir:

- objetivo del proyecto
- alcance incluido y excluido
- restricciones tecnicas y de tiempo
- stakeholders
- riesgos priorizados con respuesta
- criterios de exito
- backlog con epicas e historias

Apoyo requerido:

- Persona 1 confirma alcance real de base de datos.
- Persona 2 confirma alcance real de API y UI.

### D1. ADRs

Responsable: Persona 2

Debe producir:

- ADR-000 para la decision de frontend simple funcional
- ADR-001 para la eleccion de Oracle relacional
- ADR-002 para autenticacion y autorizacion propuestas

Cada ADR debe incluir:

- contexto
- decision
- alternativas consideradas
- consecuencias

Apoyo requerido:

- Persona 1 aporta argumentos tecnicos de Oracle.
- Persona 3 revisa redaccion y consistencia con el informe.

### D2. Arquitectura + diagramas de datos

Responsable: Persona 2

Debe producir:

- diagrama general de arquitectura
- diagrama logico de componentes
- apoyo en diagrama entidad-relacion y modelo fisico
- explicacion breve del flujo UI -> REST -> Oracle

Apoyo requerido:

- Persona 1 valida entidades, relaciones y decisiones del modelo.
- Persona 3 incorpora los diagramas al documento final.

### D3. Matriz de seleccion de base de datos

Responsable: Persona 1

Debe comparar Oracle relacional contra al menos dos alternativas usando:

- consistencia
- latencia
- volumen
- patron de acceso
- costos
- mantenimiento
- transaccionalidad
- soporte JSON
- escalabilidad

Resultado esperado:

- matriz con ponderaciones
- conclusion clara de por que Oracle es adecuado para salud

### D4. Modelo logico/fisico + migraciones + PL/SQL

Responsable: Persona 1

Debe producir:

- modelo logico y fisico alineado con `ddl.sql`
- scripts de creacion y reinicio del esquema
- diccionario de datos
- dataset pequeno coherente para la demo
- triggers, funciones y procedimientos almacenados

Objetos PL/SQL minimos:

- trigger de validacion de fecha de nacimiento futura
- trigger de auditoria para tablas clave
- funcion para calcular edad del paciente
- funcion para obtener total de consultas por paciente
- procedimiento para registrar una consulta medica completa
- procedimiento para agendar una cita con validacion basica de disponibilidad

### D5. Catalogo de consultas SQL avanzadas

Responsable: Persona 1

Debe producir:

- entre 10 y 15 consultas utiles para el dominio de salud
- explicacion de cada consulta
- indice o tecnica usada para optimizarla cuando aplique
- plan de ejecucion antes/despues
- interpretacion breve del resultado

Consultas recomendadas:

- historia clinica de paciente
- citas por medico y rango de fechas
- pacientes con alergias severas
- diagnosticos mas frecuentes
- recetas por periodo
- consultas mensuales
- pacientes sin atencion reciente
- ocupacion de consultorios
- medicos por especialidad
- indicadores de volumen por mes

### D6. API REST + OpenAPI + Postman

Responsable: Persona 2

Debe producir:

- endpoints CRUD para pacientes, medicos, citas y consultas
- endpoints agregados para historia clinica, citas por medico y diagnosticos frecuentes
- documentacion OpenAPI/Swagger completa
- coleccion Postman con ejemplos correctos e incorrectos

Debe verificar:

- codigos HTTP coherentes
- respuestas entendibles
- manejo basico de errores
- consistencia con el modelo de datos

### D8. JSON Duality Views

Responsable: Persona 1

Debe producir:

- minimo 3 Duality Views sobre entidades clave
- ejemplos de lectura y modificacion
- explicacion de cuando conviene usar vista dual frente a tablas relacionales directas

Vistas recomendadas:

- paciente
- cita
- consulta

### D12. UI/UX flows + prototipo funcional

Responsable: Persona 2

Debe producir:

- flujo de pacientes
- flujo de citas
- flujo de consulta/historia
- flujo de consumo REST y visualizacion de resultados
- estados de error y vacio
- UI simple funcional para la demo

Debe priorizar:

- claridad
- navegacion directa
- pocos pasos para mostrar el caso completo

### D13. Informe de resultados

Responsable: Persona 3

Debe producir:

- resumen de resultados obtenidos
- evidencia de rendimiento antes/despues
- costos estimados
- limites de escalado
- lecciones aprendidas
- respuesta explicita a las preguntas esenciales aplicables

Debe integrar:

- resultados SQL de Persona 1
- evidencias REST/UI de Persona 2
- exclusion formal de IA/LN

### D14. Estudio de caso por industria

Responsable: Persona 3

Debe producir:

- mini-dataset de salud descrito en lenguaje de negocio
- historia "de dato a decision"
- KPIs medibles
- recorrido demostrable desde paciente hasta receta

KPIs recomendados:

- total de consultas por periodo
- diagnosticos mas frecuentes
- pacientes con alergias criticas
- carga de citas por medico

### D15. Documentacion tecnica

Responsable: Persona 3

Debe producir:

- README maestro
- guia de despliegue
- instrucciones para crear esquema y cargar datos
- diccionario de datos
- catalogo de consultas
- enlaces a ADRs, OpenAPI, Postman y evidencias

### D16. Evidencias y demo final

Responsable: Persona 3

Debe producir:

- slides ejecutivas
- guion de demo
- video de 5 a 8 minutos
- capturas y reportes de pruebas
- organizacion final de archivos para entrega

Debe mostrar:

- problema
- solucion
- modelo de datos
- consulta optimizada
- API REST
- UI
- caso de salud
- resultados

## Cambios e interfaces a producir

### Base de datos

- Mantener el esquema de salud ya definido en `ddl.sql`.
- Anadir dataset de demostracion coherente con:
  - pacientes
  - medicos
  - citas
  - consultas
  - diagnosticos
  - recetas
  - alergias
- Preparar scripts separados para:
  - creacion
  - carga de datos
  - consultas
  - pruebas
- Incorporar PL/SQL reutilizable:
  - triggers para reglas de negocio y auditoria
  - funciones para calculos o consultas reutilizables
  - procedimientos almacenados para operaciones frecuentes del dominio clinico
- Propuesta minima de objetos PL/SQL:
  - trigger de validacion de fecha de nacimiento futura
  - trigger de auditoria para inserciones/actualizaciones/eliminaciones en tablas clave
  - funcion para calcular edad del paciente
  - funcion para obtener total de consultas por paciente
  - procedimiento para registrar una consulta medica completa
  - procedimiento para agendar una cita validando disponibilidad basica
- Implementar al menos 3 JSON Duality Views sobre entidades de alto valor, recomendadas:
  - paciente
  - cita
  - consulta

### API REST

- CRUD minimo para entidades centrales:
  - pacientes
  - medicos
  - citas
  - consultas
- Endpoints agregados:
  - historia clinica resumida
  - citas por medico
  - diagnosticos frecuentes
- Documentar todo en OpenAPI y Postman.

### UI simple funcional

- Vista de pacientes
- Vista de citas
- Vista de consultas/historia
- Panel sencillo para consumir endpoints REST y mostrar resultados
- Manejo basico de errores y estados vacios

### Documentacion

- ADR-000: decision de frontend simple
- ADR-001: eleccion de base relacional Oracle
- ADR-002: autenticacion/autorizacion propuesta
- README maestro con:
  - instalacion
  - despliegue
  - ejecucion de scripts
  - endpoints
  - estructura del proyecto
- Informe final que responda las preguntas esenciales aplicables, dejando explicito que IA/LN queda fuera de alcance por decision del equipo.

## Casos de prueba y validacion

- Crear esquema desde cero sin errores.
- Cargar dataset completo sin violaciones de integridad.
- Ejecutar todas las consultas del catalogo.
- Probar triggers con casos validos e invalidos.
- Probar funciones con datos conocidos y resultados esperados.
- Probar procedimientos almacenados con escenarios exitosos y de error.
- Comparar planes de ejecucion antes/despues en las consultas optimizadas.
- Probar todos los endpoints REST con casos validos e invalidos.
- Verificar Duality Views con ejemplos de lectura y modificacion.
- Validar flujo completo de demo:
  1. paciente
  2. cita
  3. consulta
  4. diagnostico
  5. receta
  6. visualizacion en UI
- Revisar que cada entregable pedido tenga evidencia concreta y ubicacion clara en el repositorio.

## Riesgos y controles

- Riesgo: intentar abarcar demasiado y terminar superficial.
  - Control: cerrar primero los entregables obligatorios y no abrir mejoras nuevas hasta tener evidencia completa.
- Riesgo: documentacion desconectada de lo implementado.
  - Control: Persona 3 solo documenta funciones verificadas por Persona 1 y Persona 2.
- Riesgo: demo inestable.
  - Control: dataset pequeno, flujo corto y endpoints ya probados en Postman.
- Riesgo: exclusion de IA afecte evaluacion.
  - Control: declarar la exclusion de forma consistente y reforzar el resto de entregables con buena evidencia.

## Checklist final

- [ ] `ddl.sql` ejecuta sin errores
- [ ] dataset de salud cargado
- [ ] triggers implementados y probados
- [ ] funciones implementadas y probadas
- [ ] procedimientos almacenados implementados y probados
- [ ] 10 a 15 consultas SQL documentadas
- [ ] evidencia antes/despues de optimizacion
- [ ] minimo 3 JSON Duality Views
- [ ] API REST funcional
- [ ] OpenAPI completo
- [ ] coleccion Postman probada
- [ ] UI simple funcional
- [ ] ADR-000, ADR-001 y ADR-002 completos
- [ ] acta, backlog y riesgos terminados
- [ ] caso de estudio de salud con KPIs
- [ ] README maestro completo
- [ ] slides ejecutivas terminadas
- [ ] video demo grabado
- [ ] revision final contra la rubrica

## Definicion de terminado

El proyecto se considera listo cuando:

- el esquema puede recrearse desde cero
- el dataset permite demostrar un caso clinico completo
- las consultas, la API y las Duality Views funcionan con evidencia
- la interfaz permite mostrar el flujo principal
- la documentacion explica como desplegar, probar y defender la solucion
- la demo se puede ejecutar sin depender de funciones de IA/LN

## Supuestos fijados

- El equipo tiene alta disponibilidad sabado y domingo.
- Se trabajara con Oracle como nucleo tecnico.
- El frontend sera simple pero funcional.
- El dataset de salud se creara desde cero y sera pequeno.
- La parte de IA/LN se excluye por completo del alcance.
- El plan prioriza una entrega completa y defendible sobre una solucion muy sofisticada.
