function apiKeyAuth(req, res, next) {
  const expectedKey = process.env.API_KEY || 'demo-key-2026';
  const providedKey = req.headers['x-api-key'];

  if (!providedKey || providedKey !== expectedKey) {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'API Key inválida o ausente. Incluya el header X-API-Key.',
    });
  }

  next();
}

module.exports = apiKeyAuth;
