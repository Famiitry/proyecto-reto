# Plan operativo para completar el reto de Gestion de BDD

## Resumen

- Objetivo: entregar una solucion defendible para el caso de estudio de salud, basada en Oracle y en el esquema ya creado en `ddl.sql`, antes del lunes 18 de mayo de 2026 por la noche.
- Estrategia: intentar cubrir todos los entregables aplicables, priorizando evidencia funcional, documentacion clara y una demo estable.
- Exclusion acordada: se elimina por completo la parte de IA/LN. No se incluiran D9, panel NLQ ni funcionalidades de lenguaje natural.
- Resultado final esperado: base de datos ejecutable, consultas optimizadas con evidencia, API REST documentada, JSON Duality Views, interfaz simple funcional, dataset de salud, documentacion y demo.

## Organizacion del equipo

### Persona 1: Datos y optimizacion

Responsable principal de:

- D3 Matriz de seleccion de base de datos
- D4 Modelo logico/fisico, migraciones, scripts PL/SQL
- D5 Catalogo de 10 a 15 consultas SQL avanzadas
- D8 JSON Duality Views
- Dataset pequeno del caso de salud
- Evidencia de planes de ejecucion antes/despues

Entregables concretos:

- scripts SQL limpios y ejecutables
- triggers, funciones y procedimientos almacenados documentados
- diccionario de datos
- consultas con explicacion y evidencia
- minimo 3 Duality Views con ejemplos `GET/POST/PATCH`

### Persona 2: Servicios y experiencia funcional

Responsable principal de:

- D1 ADR-000, ADR-001 y ADR-002
- D2 Arquitectura y diagramas
- D6 API REST + OpenAPI + coleccion Postman
- D12 UI simple funcional
- integracion de la demo tecnica

Entregables concretos:

- endpoints CRUD, agregados y busquedas
- documentacion Swagger/OpenAPI
- coleccion Postman probada
- interfaz minima para consultar datos y visualizar resultados

### Persona 3: Direccion, validacion y entrega

Responsable principal de:

- D0 Acta de proyecto + backlog
- D13 Informe de resultados
- D14 Estudio de caso por industria
- D15 Documentacion tecnica
- D16 Evidencias, slides y video demo

Entregables concretos:

- README maestro
- guia de despliegue
- historia "de dato a decision" para salud
- KPIs de negocio
- slides ejecutivas
- guion y grabacion de demo de 5 a 8 minutos

### Trabajo compartido obligatorio

- Todos prueban el flujo completo antes de entregar.
- Todos revisan ortografia, consistencia visual y referencias cruzadas.
- Todos deben poder explicar al menos:
  - el problema
  - el modelo de datos
  - una consulta optimizada
  - un endpoint REST
  - el caso de estudio

## Cronograma realista

### Viernes 15 de mayo

Objetivo: dejar la estructura del proyecto cerrada.

- Persona 1:
  - validar definitivamente `ddl.sql`
  - crear dataset minimo de salud
  - listar consultas candidatas
- Persona 2:
  - definir arquitectura minima basada en Oracle
  - bosquejar endpoints REST
  - decidir estructura de UI simple
- Persona 3:
  - redactar acta, alcance, riesgos y backlog
  - preparar plantilla del README maestro
  - definir historia del caso de salud y KPIs
- Cierre del dia:
  - reunion corta
  - congelar alcance
  - confirmar que se entregara y que queda excluido

### Sabado 16 de mayo

Objetivo: producir la mayor parte tecnica.

- Persona 1:
  - terminar modelo fisico, scripts, Duality Views y primeras consultas
  - generar evidencias de optimizacion
- Persona 2:
  - implementar API REST
  - documentar OpenAPI
  - preparar Postman
  - levantar UI basica
- Persona 3:
  - completar D0, D13 preliminar, D14 y estructura de D15
  - comenzar slides y guion de demo
- Cierre del dia:
  - probar inserciones, consultas, REST y dataset completo

### Domingo 17 de mayo

Objetivo: integrar y convertir trabajo suelto en entrega.

- Persona 1:
  - cerrar catalogo SQL con 10 a 15 consultas
  - completar evidencia antes/despues
- Persona 2:
  - cerrar endpoints faltantes
  - conectar UI con API
  - preparar capturas para documentacion
- Persona 3:
  - cerrar documentacion tecnica
  - consolidar resultados
  - montar slides
- Trabajo conjunto:
  - ensayo de demo
  - revision cruzada de todos los entregables
  - detectar huecos contra la rubrica

### Lunes 18 de mayo

Objetivo: estabilizar, no inventar.

- Manana/tarde:
  - correcciones finales
  - revision de consistencia entre diagramas, SQL, API y demo
  - empaquetar evidencias
- Noche:
  - grabar video final
  - exportar documentos
  - verificar nombres de archivos
  - entregar con margen antes del cierre

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
  - Control: usar el lunes solo para cierre y no para desarrollar modulos nuevos.
- Riesgo: documentacion desconectada de lo implementado.
  - Control: una revision cruzada obligatoria el domingo.
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
