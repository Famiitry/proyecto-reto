function errorHandler(err, req, res, _next) {
  console.error('Error:', err.message);

  if (err.errorNum) {
    const status = err.errorNum === 1 ? 409 : 400;
    return res.status(status).json({
      error: 'Database Error',
      message: err.message,
      oracleCode: err.errorNum,
    });
  }

  res.status(err.status || 500).json({
    error: 'Internal Server Error',
    message: err.message || 'Error inesperado',
  });
}

module.exports = errorHandler;
