require('dotenv').config();
const oracledb = require('oracledb');

oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;
oracledb.fetchAsString = [oracledb.CLOB];

let pool;

async function initialize() {
  pool = await oracledb.createPool({
    user: process.env.ORACLE_USER || 'gestion_medica',
    password: process.env.ORACLE_PASSWORD || 'admin123',
    connectString: process.env.ORACLE_CONNECT_STRING || 'localhost:1521/XEPDB1',
    poolMin: 1,
    poolMax: 5,
    poolIncrement: 1,
    poolTimeout: 60,
    enableStatistics: false,
  });
  console.log('Pool de conexiones Oracle inicializado');
  return pool;
}

async function close() {
  if (pool) {
    await pool.close();
    console.log('Pool de conexiones cerrado');
  }
}

function getPool() {
  return pool;
}

async function execute(sql, binds = {}, opts = {}) {
  const conn = await pool.getConnection();
  try {
    const result = await conn.execute(sql, binds, {
      outFormat: oracledb.OUT_FORMAT_OBJECT,
      autoCommit: opts.autoCommit !== false,
      ...opts,
    });
    return result;
  } finally {
    await conn.close();
  }
}

module.exports = { initialize, close, getPool, execute };
