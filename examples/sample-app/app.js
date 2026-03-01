const express = require('express');
const app = express();

// Read configuration from environment variables (injected from ConfigMap)
const config = {
  dbHost: process.env.DB_HOST || 'localhost',
  apiUrl: process.env.API_URL || 'http://localhost',
  appMode: process.env.APP_MODE || 'development',
  logLevel: process.env.LOG_LEVEL || 'info',
  featureNewUI: process.env.FEATURE_NEW_UI === 'true'
};

console.log('Application Configuration:', JSON.stringify(config, null, 2));

app.get('/', (req, res) => {
  res.json({
    message: 'ConfigMap Demo App',
    config: config,
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.get('/config', (req, res) => {
  res.json(config);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${config.appMode}`);
  console.log(`DB Host: ${config.dbHost}`);
});
