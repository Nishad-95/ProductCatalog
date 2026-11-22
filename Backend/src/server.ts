import { createApp } from './app';
import { config } from './config/env';

const app = createApp();

const server = app.listen(config.PORT, () => {
  console.log(`====================================================`);
  console.log(`  Product Catalog API Server is running`);
  console.log(`  Environment: ${config.NODE_ENV}`);
  console.log(`  Port:        ${config.PORT}`);
  console.log(`  URL:         http://localhost:${config.PORT}/api/v1`);
  console.log(`  Health:      http://localhost:${config.PORT}/api/v1/health`);
  console.log(`====================================================`);
});

// Graceful shutdown handling
const shutdown = (signal: string) => {
  console.log(`Received ${signal}. Shutting down gracefully...`);
  server.close(() => {
    console.log('HTTP server closed.');
    process.exit(0);
  });
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
