# D2: Arquitectura del sistema

## 1. Diagrama general de arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                        USUARIO / NAVEGADOR                       │
│                                                                  │
│  ┌──────────────────────────┐    ┌───────────────────────────┐  │
│  │     UI Simple Funcional  │    │   Postman / cliente REST  │  │
│  │  (HTML + CSS + JS Vanilla)│    │                           │  │
│  │                          │    │                           │  │
│  │  • Vista de pacientes    │    │  • CRUD manual            │  │
│  │  • Vista de citas        │    │  • Pruebas de endpoints   │  │
│  │  • Vista de consultas    │    │  • Validación de OpenAPI  │  │
│  │  • Panel REST genérico   │    │                           │  │
│  └──────────┬───────────────┘    └───────────┬───────────────┘  │
│             │                                │                   │
│             │  X-API-Key: <key>              │                   │
└─────────────┼────────────────────────────────┼───────────────────┘
              │                                │
              ▼                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                     API REST (Node.js + Express)                  │
│                     Puerto: 3000                                  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Middleware Pipeline                                       │  │
│  │  1. CORS                    3. API Key Auth (excepto UI)  │  │
│  │  2. JSON Parser             4. Route Handlers              │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────────────────┐  │
│  │  Pacientes  │  │   Médicos   │  │  Citas                 │  │
│  │  CRUD       │  │  CRUD       │  │  CRUD + filtros        │  │
│  │  + historia │  │  + especial │  │  + por médico          │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬─────────────┘  │
│         │                │                     │                 │
│  ┌──────┴──────┐  ┌──────┴──────┐  ┌──────────┴─────────────┐  │
│  │  Consultas  │  │  Agregados   │  │  Estáticos             │  │
│  │  CRUD       │  │  • Historia  │  │  • OpenAPI (Swagger UI)│  │
│  │  + diag     │  │  • Citas x   │  │  • UI HTML/CSS/JS     │  │
│  │  + recetas  │  │    médico    │  │                        │  │
│  └──────┬──────┘  │  • Diag frec │  └────────────────────────┘  │
│         │          └──────┬──────┘                               │
└─────────┼─────────────────┼──────────────────────────────────────┘
          │                 │
          │  Conexión via   │
          │  oracledb       │
          ▼                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Oracle Database 19c+                             │
│                  Puerto: 1521 / Service: XEPDB1                   │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Esquema: GESTION_MEDICA                                   │  │
│  │                                                            │  │
│  │  Catálogos        Personas          Operacional            │  │
│  │  ┌──────────┐   ┌──────────┐   ┌──────────────┐          │  │
│  │  │ pais     │   │ persona  │   │ cita         │ (PART)   │  │
│  │  │ provincia│   │ medico   │   │ consulta     │ (PART)   │  │
│  │  │ canton   │   │ paciente │   │ receta       │          │  │
│  │  │ parroquia│   │ teléfono │   │ signos_vit   │          │  │
│  │  │ cie10    │   │ dirección│   │ cons_diag    │          │  │
│  │  │ alergeno │   │          │   │ receta_det   │          │  │
│  │  │ espcialid│   └──────────┘   │ auditoria    │ (PART)   │  │
│  │  │ medicamto│                   └──────────────┘          │  │
│  │  └──────────┘                                              │  │
│  │                                                            │  │
│  │  Vistas y Lógica                                           │  │
│  │  • v_historia_paciente (vista agregada)                    │  │
│  │  • trg_persona_fnac (trigger validación)                   │  │
│  │  • JSON Duality Views (D8)                                 │  │
│  │  • Índices funcionales sobre JSON                          │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## 2. Diagrama lógico de componentes

```
┌──────────────────────────────────────────┐
│              CAPA DE PRESENTACIÓN         │
│  ┌────────────┬────────────┬───────────┐ │
│  │ pacientes/ │  citas/    │ consultas/│ │
│  │ index.html │  index.html│ index.html│ │
│  │            │            │           │ │
│  │ tabla +    │ tabla +    │ detalle + │ │
│  │ búsqueda   │ filtros    │ historia  │ │
│  └────────────┴────────────┴───────────┘ │
│  ┌──────────────────────────────────────┐ │
│  │ panel/index.html                     │ │
│  │ Consola REST genérica (fetch + JSON) │ │
│  └──────────────────────────────────────┘ │
└──────────────────────────────────────────┘
          │  fetch() + X-API-Key
          ▼
┌──────────────────────────────────────────┐
│             CAPA DE SERVICIOS             │
│  ┌────────────────────────────────────┐  │
│  │  Routes (Express Router)           │  │
│  │  /api/pacientes                    │  │
│  │  /api/medicos                      │  │
│  │  /api/citas                        │  │
│  │  /api/consultas                    │  │
│  │  /api/agregados                    │  │
│  └────────────┬───────────────────────┘  │
│               │                           │
│  ┌────────────┴───────────────────────┐  │
│  │  DB Layer (oracledb)               │  │
│  │  • pool de conexiones              │  │
│  │  • queries parametrizadas          │  │
│  │  • manejo de errores Oracle        │  │
│  └────────────────────────────────────┘  │
│  ┌────────────────────────────────────┐  │
│  │  Middleware                        │  │
│  │  • apiKeyAuth (401 si falla)       │  │
│  │  • errorHandler (formato estándar) │  │
│  │  • staticFiles (UI HTML/CSS/JS)    │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
          │  oracledb pool
          ▼
┌──────────────────────────────────────────┐
│            CAPA DE PERSISTENCIA            │
│         Oracle Database 19c+              │
│  • Esquema GESTION_MEDICA                 │
│  • Índices locales y globales             │
│  • Índices funcionales sobre JSON         │
│  • Particionamiento por intervalo         │
│  • PL/SQL: triggers, funciones, procs     │
│  • JSON Duality Views                     │
└──────────────────────────────────────────┘
```

## 3. Diagrama entidad-relación (apoyo)

```
                    ┌──────────────┐
                    │     pais     │
                    └──────┬───────┘
                           │ 1
                           ▼ N
                    ┌──────────────┐
                    │  provincia   │
                    └──────┬───────┘
                           │ 1
                           ▼ N
                    ┌──────────────┐
                    │    canton    │
                    └──────┬───────┘
                           │ 1
                           ▼ N
                    ┌──────────────┐
                    │  parroquia   │
                    └──────┬───────┘
                           │ 1
                           ▼ N
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   telefono   │◄──│   persona    │──►│  direccion   │
│ (multi-val)  │  N│  (supertipo) │  N│ (multi-val)  │
└──────────────┘   └──┬────────┬──┘   └──────────────┘
                      │ ISA    │ ISA
                      ▼        ▼
              ┌──────────┐  ┌──────────┐
              │ paciente │  │  medico  │
              └────┬─────┘  └────┬─────┘
                   │             │
       ┌───────────┤    ┌────────┼──────────┐
       │ N         │    │ N      │          │
       ▼           │    ▼        ▼          ▼
┌──────────────┐   │  ┌──────────────┐  ┌──────────────────┐
│pcte_alergia │   │  │medico_espec  │  │   especialidad    │
│    (4FN)     │   │  │    (4FN)     │  │                  │
└──────┬───────┘   │  └──────────────┘  └──────────────────┘
       │           │
       ▼ N         │         ┌──────────────┐
┌──────────────┐   │         │ consultorio  │
│  alergeno    │   │         └──────┬───────┘
└──────────────┘   │                │
                   │                ▼
                   │         ┌──────────────┐
                   └────────►│     cita     │◄──┌──────────────┐
                             │ (PART x mes) │   │ estado_cita  │
                             └──────┬───────┘   └──────────────┘
                                    │ 1
                                    ▼ 1
                             ┌──────────────┐
                             │   consulta   │◄──┌──────────────┐
                             │ (PART x mes) │   │    cie10     │
                             └──┬──┬──┬─────┘   └──────┬───────┘
                                │  │  │                 │ N
                    ┌───────────┘  │  └────────┐        ▼
                    ▼              ▼           ▼  ┌──────────────┐
             ┌──────────────┐ ┌──────────┐ ┌──────────────┐
             │signos_vitales│ │  receta  │ │cons_diagnost │
             │    (1:1)     │ └────┬─────┘ │    (M:N)     │
             └──────────────┘      │       └──────────────┘
                                   │ 1
                                   ▼ N
                            ┌──────────────┐
                            │receta_detalle│◄──┌──────────────┐
                            │   (M:N)      │   │ medicamento  │
                            └──────────────┘   └──────────────┘
```

## 4. Flujo UI → REST → Oracle

### Ejemplo: flujo de demo (paciente → cita → consulta → receta)

```
Paso 1: Usuario busca paciente
 ┌─────────────────────────────────────────────────────────────┐
 │ UI pacientes.html                                           │
 │ fetch('GET /api/pacientes?apellido=Pérez')                  │
 │   Header: X-API-Key: demo-key-2026                          │
 └──────────────────────┬──────────────────────────────────────┘
                        ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ Express Router → apiKeyAuth middleware                       │
 │ Key válida? ✓ → next()                                      │
 └──────────────────────┬──────────────────────────────────────┘
                        ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ SELECT pe.id_persona, pe.cedula, pe.nombres, pe.apellidos,  │
 │        pa.historia_clinica, pa.tipo_sangre                  │
 │ FROM persona pe JOIN paciente pa ON pe.id_persona=pa.id_paciente│
 │ WHERE UPPER(pe.apellidos) LIKE '%PEREZ%'                    │
 └──────────────────────┬──────────────────────────────────────┘
                        ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ Oracle: plan de ejecución usa ix_persona_apellido           │
 │ Retorna: [{id_paciente:16, cedula:"0102000016", ...}]       │
 └──────────────────────┬──────────────────────────────────────┘
                        ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ Express: res.json(data) → renderiza tabla HTML              │
 └─────────────────────────────────────────────────────────────┘

Paso 2: Usuario ve citas del paciente
 ┌─────────────────────────────────────────────────────────────┐
 │ fetch('GET /api/citas?paciente=16')                          │
 └──────────────────────┬──────────────────────────────────────┘
                        ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ SELECT c.id_cita, c.fecha_hora, ec.codigo AS estado,        │
 │        m.id_medico, p.nombres||' '||p.apellidos AS medico   │
 │ FROM cita c JOIN estado_cita ec ON c.id_estado=ec.id_estado │
 │ JOIN medico m ON c.id_medico=m.id_medico                    │
 │ JOIN persona p ON m.id_medico=p.id_persona                  │
 │ WHERE c.id_paciente = 16                                    │
 └──────────────────────┬──────────────────────────────────────┘
                        ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ Oracle: usa índice local ix_cita_paciente sobre partición   │
 │ Retorna: [{id_cita:1, fecha_hora:"2025-03-12 09:00",...}]   │
 └──────────────────────┬──────────────────────────────────────┘
                        ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ UI citas.html → tabla con filtros por estado y médico       │
 └─────────────────────────────────────────────────────────────┘

Paso 3: Usuario ve consulta e historia clínica
 ┌─────────────────────────────────────────────────────────────┐
 │ fetch('GET /api/agregados/historia/16')                      │
 └──────────────────────┬──────────────────────────────────────┘
                        ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ Consulta la vista predefinida v_historia_paciente           │
 │ Retorna: consultas agrupadas con diagnósticos               │
 └──────────────────────┬──────────────────────────────────────┘
                        ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ UI consultas.html → detalle con signos vitales, diagnósticos│
 │                     y recetas asociadas                     │
 └─────────────────────────────────────────────────────────────┘
```
