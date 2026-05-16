require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const swaggerUi = require('swagger-ui-express');
const YAML = require('yamljs');

const { initialize, close } = require('./db');
const apiKeyAuth = require('./middleware/auth');
const errorHandler = require('./middleware/errorHandler');

const pacientesRouter = require('./routes/pacientes');
const medicosRouter = require('./routes/medicos');
const citasRouter = require('./routes/citas');
const consultasRouter = require('./routes/consultas');
const agregadosRouter = require('./routes/agregados');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/*', apiKeyAuth);

app.use('/api/pacientes', pacientesRouter);
app.use('/api/medicos', medicosRouter);
app.use('/api/citas', citasRouter);
app.use('/api/consultas', consultasRouter);
app.use('/api/agregados', agregadosRouter);

const swaggerDocument = YAML.load(path.join(__dirname, 'openapi.yaml'));
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.use(express.static(path.join(__dirname, '..', 'ui')));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'ui', 'index.html'));
});

app.use(errorHandler);

async function start() {
  try {
    await initialize();
    app.listen(PORT, () => {
      console.log(`API REST Gestión Médica - http://localhost:${PORT}`);
      console.log(`Swagger UI - http://localhost:${PORT}/api-docs`);
      console.log(`UI - http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('Error al iniciar:', err);
    process.exit(1);
  }
}

process.on('SIGINT', async () => {
  await close();
  process.exit(0);
});

start();

module.exports = app;
