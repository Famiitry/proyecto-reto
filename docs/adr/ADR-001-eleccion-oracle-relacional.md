# ADR-001: Elección de base de datos Oracle relacional

**Estado:** Aceptado
**Fecha:** 2026-05-15
**Responsable:** Persona 2 (con apoyo técnico de Persona 1)

## Contexto

El reto de la materia Gestión de Bases de Datos exige utilizar Oracle como
núcleo tecnológico. El caso de estudio es un sistema de gestión médica que
maneja entidades como pacientes, médicos, citas, consultas, diagnósticos y
recetas.

Para cumplir con los entregables D3 (matriz de selección), D4 (modelo
lógico/físico) y D5 (catálogo de consultas), se evaluó Oracle frente a otras
alternativas mediante una matriz de ponderación cuyos resultados completos se
encuentran en el documento de matriz de selección (D3).

## Decisión

Utilizar **Oracle Database 19c+** como motor relacional para el sistema de
gestión médica.

## Alternativas consideradas

1. **PostgreSQL** — base de datos relacional open source madura.
   - Es open source y gratuito, con buen soporte JSON y particionamiento.
   - Se descarta por: no cumple con el requisito académico del reto. Carece de
     funcionalidades avanzadas como Interval Partitioning, JSON Duality Views,
     y herramientas de optimización nativas como SQL Plan Management y AWR.

2. **MongoDB** — base de datos documental NoSQL.
   - Se descarta por: no es adecuado para el dominio de salud, donde la
     integridad referencial, las restricciones ACID y la transaccionalidad son
     críticas. Los datos de citas y recetas tienen relaciones fuertes que son
     más naturales en un modelo relacional.

3. **MySQL / MariaDB** — bases relacionales de amplio uso.
   - Se descartan por: carecen de particionamiento por intervalo automático,
     JSON Duality Views, optimizador avanzado con SQL Plan Management, y otras
     capacidades que Oracle ofrece nativamente para sistemas de salud de alta
     concurrencia.

## Consecuencias

- **Positivas:**
  - ACID completo con transaccionalidad a nivel de fila y serializable
  - JSON Duality Views permiten exponer los mismos datos en formato relacional
    y documental simultáneamente (entregable D8)
  - Particionamiento automático por intervalo (citas y consultas por mes) sin
    intervención manual del DBA
  - Índices funcionales sobre columnas JSON para consultas eficientes sobre
    anamnesis y entidades NLP
  - PL/SQL permite lógica de negocio compleja en la capa de datos (triggers de
    validación y auditoría, funciones y procedimientos)
  - SQL Plan Management (SPM) y Automatic Workload Repository (AWR) para
    garantizar estabilidad de planes de ejecución en consultas de alto volumen
  - Oracle Data Pump para migraciones y backups coherentes

- **Negativas:**
  - Requiere licencia para uso en producción
  - Mayor consumo de recursos que alternativas ligeras
  - Curva de aprendizaje moderada para administración

- **Mitigaciones:**
  - El ámbito es académico, por lo que la licencia Oracle Database Free (hasta
    12 GB de datos de usuario) es suficiente
  - Se documentan los scripts de creación y carga para automatizar el despliegue
  - El dataset de demo es pequeño (~50 registros por entidad), por lo que los
    requerimientos de hardware son mínimos
